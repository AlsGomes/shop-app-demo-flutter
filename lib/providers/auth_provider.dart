import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/store.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/models/auth_mode.dart';

class AuthProvider with ChangeNotifier {
  static const _apiKey = '';
  static const _signupUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey';
  static const _loginUrl =
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey';

  String? _token;
  String? _email;
  String? _uid;
  DateTime? _expiryDate;
  Timer? _logoutTimer;

  bool get isAuth {
    bool isValid = _expiryDate?.isAfter(DateTime.now()) ?? false;
    return _token != null && isValid;
  }

  String? get token {
    return isAuth ? _token : null;
  }

  String? get email {
    return isAuth ? _email : null;
  }

  String? get uid {
    return isAuth ? _uid : null;
  }

  Future<void> tryAutoLogin() async {
    if (isAuth) return;

    final userData = await Store.getMap('userData');
    if (userData.isEmpty) return;

    final expiryDate = DateTime.parse(userData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) return;

    _token = userData['token'];
    _email = userData['email'];
    _uid = userData['uid'];
    _expiryDate = expiryDate;

    _autoLogout();
    notifyListeners();
  }

  Future<void> authenticate(
      String email, String password, AuthMode authMode) async {
    final res = await http.post(
      Uri.parse(authMode == AuthMode.signup ? _signupUrl : _loginUrl),
      body: jsonEncode({
        "email": email,
        "password": password,
        "returnSecureToken": true,
      }),
    );

    final body = jsonDecode(res.body);

    if (body['error'] != null) throw AuthException(body['error']['message']);

    _token = body['idToken'];
    _email = body['email'];
    _uid = body['localId'];
    _expiryDate =
        DateTime.now().add(Duration(seconds: int.parse(body['expiresIn'])));

    Store.saveMap('userData', {
      'token': _token,
      'email': _email,
      'uid': _uid,
      'expiryDate': _expiryDate!.toIso8601String(),
    });

    _autoLogout();
    notifyListeners();
  }

  void logout() {
    _token = null;
    _email = null;
    _uid = null;
    _expiryDate = null;
    clearLogoutTimer();
    Store.remove("userData").then((_) => notifyListeners());
  }

  void clearLogoutTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = null;
  }

  void _autoLogout() {
    clearLogoutTimer();
    final timeToLogout = _expiryDate?.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(
      Duration(seconds: timeToLogout ?? 0),
      logout,
    );
  }
}
