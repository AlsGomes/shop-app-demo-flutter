import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/providers/product_list_provider.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({Key? key}) : super(key: key);

  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _imageUrlFocus = FocusNode();

  final _imageUrlController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final Map<String, Object> _formData = {};

  bool _isLoading = false;

  @override
  void dispose() {
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    _imageUrlFocus.removeListener(updateImage);
    _imageUrlFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _imageUrlFocus.addListener(updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;

      if (arg != null) {
        final product = arg as Product;
        _formData["id"] = product.id;
        _formData["name"] = product.name;
        _formData["price"] = product.price;
        _formData["description"] = product.description;
        _formData["imageUrl"] = product.imageUrl;

        _imageUrlController.text = product.imageUrl;
      }
    }
  }

  void updateImage() {
    if (isValidImageUrl(_imageUrlController.text)) {
      setState(() {});
    }
  }

  bool isValidImageUrl(String url) {
    bool endsWithImageExtension =
        url.endsWith(".png") || url.endsWith(".jpg") || url.endsWith(".jpeg");
    bool isValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;

    return isValidUrl && endsWithImageExtension;
  }

  Future<void> _submitForm() async {
    final isValidated = _formKey.currentState?.validate() ?? false;

    if (!isValidated) return;

    _formKey.currentState?.save();

    setState(() => _isLoading = true);

    try {
      await Provider.of<ProductListProvider>(
        context,
        listen: false,
      ).saveItem(_formData);

      Navigator.of(context).pop();
    } catch (error) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Ocorreu um erro"),
          content: const Text("Desculpe, não foi possível salvar o produto"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Ok"),
            ),
          ],
        ),
      );

      print(error.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Formulário de Produto"), actions: [
        IconButton(
          onPressed: _submitForm,
          icon: Icon(Icons.save),
        )
      ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _formData["name"]?.toString(),
                        decoration: const InputDecoration(labelText: "Nome"),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_priceFocus),
                        onSaved: (name) => _formData["name"] = name ?? "",
                        validator: (_name) {
                          var name = _name ?? "";
                          name = name.trim();

                          if (name.isEmpty) return "O nome é obrigatório";

                          if (name.length < 3) {
                            return "O nome precisa conter no mínimo 3 letras";
                          }

                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData["price"]?.toString(),
                        decoration: const InputDecoration(labelText: "Preço"),
                        textInputAction: TextInputAction.next,
                        focusNode: _priceFocus,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_descriptionFocus),
                        onSaved: (price) =>
                            _formData["price"] = double.parse(price ?? "0"),
                        validator: (_price) {
                          final priceString = _price ?? '';
                          final price = double.tryParse(priceString) ?? -1;

                          if (price <= 0) {
                            return "Escreva um preço válido maior que 0,00";
                          }

                          return null;
                        },
                      ),
                      TextFormField(
                        initialValue: _formData["description"]?.toString(),
                        decoration:
                            const InputDecoration(labelText: "Descrição"),
                        textInputAction: TextInputAction.next,
                        focusNode: _descriptionFocus,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                        onSaved: (description) =>
                            _formData["description"] = description ?? "",
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_imageUrlFocus),
                        validator: (_description) {
                          var description = _description ?? "";
                          description = description.trim();

                          if (description.isEmpty)
                            return "A descrição é obrigatória";

                          if (description.length < 10) {
                            return "A descrição precisa conter no mínimo 10 letras";
                          }

                          return null;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  labelText: "Url da Imagem"),
                              textInputAction: TextInputAction.done,
                              focusNode: _imageUrlFocus,
                              keyboardType: TextInputType.url,
                              controller: _imageUrlController,
                              onFieldSubmitted: (_) => _submitForm(),
                              onSaved: (imageUrl) =>
                                  _formData["imageUrl"] = imageUrl ?? "",
                              validator: (_imageUrl) {
                                var imageUrl = _imageUrl ?? "";
                                imageUrl = imageUrl.trim();
                                if (!isValidImageUrl(imageUrl)) {
                                  return "A URL da imagem não é válida";
                                }

                                return null;
                              },
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(
                              top: 10,
                              left: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? const Text("Informe a URL")
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                            alignment: Alignment.center,
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
    );
  }
}
