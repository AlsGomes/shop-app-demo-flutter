import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/models/auth_mode.dart';
import 'package:shop/providers/auth_provider.dart';

//enum AuthMode { signup, login }

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  Map<String, String> _authData = {"email": "", "password": ""};

  AuthMode _authMode = AuthMode.login;
  bool _isLogin() => _authMode == AuthMode.login;
  bool _isSignup() => _authMode == AuthMode.signup;

  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  void _switchAuthMode() {
    setState(() {
      _isLogin() ? _authMode = AuthMode.signup : _authMode = AuthMode.login;
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ocorreu um erro"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    setState(() => _isLoading = true);

    _formKey.currentState?.save();

    AuthProvider auth = Provider.of(
      context,
      listen: false,
    );

    try {
      await auth.authenticate(
        _authData['email']!,
        _authData['password']!,
        _authMode,
      );
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog("Ocorreu um erro inesperado");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      child: AnimatedContainer(
        height: _isLogin() ? 310 : 400,
        width: MediaQuery.of(context).size.width * 0.75,
        padding: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                  decoration: InputDecoration(labelText: "E-mail"),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (email) => _authData["email"] = email ?? "",
                  validator: (_email) {
                    var email = _email ?? "";
                    email = email.trim();

                    if (email.isEmpty || !email.contains("@")) {
                      return "Email informado não é válido";
                    }

                    return null;
                  }),
              TextFormField(
                  decoration: InputDecoration(labelText: "Senha"),
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  controller: _passwordController,
                  onSaved: (password) => _authData["password"] = password ?? "",
                  validator: (_password) {
                    final password = _password ?? "";
                    if (password.isEmpty || password.length < 5) {
                      return "Senha não pode ser vazia e nem conter menos que 5 caracteres";
                    }

                    return null;
                  }),
              if (_isSignup())
                TextFormField(
                  decoration:
                      InputDecoration(labelText: "Confirmação de Senha"),
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  validator: _isLogin()
                      ? null
                      : (_password) {
                          final password = _password ?? "";
                          if (_passwordController.text != password) {
                            return "Senhas não conferem";
                          }

                          return null;
                        },
                ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                      _authMode == AuthMode.login ? "Entrar" : "Registrar"),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 8,
                    ),
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: _switchAuthMode,
                child: Text(
                    _isLogin() ? "Deseja Cadastrar-se?" : "Já Possui Conta?"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
