import 'dart:convert';

import 'package:chat_app/global/environments.dart';
import 'package:chat_app/models/login_response.dart';
import 'package:chat_app/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  Usuario? usuario;
  bool _autenticando = false;

  bool get autenticando => _autenticando;
  set autenticando(bool valor) {
    _autenticando = valor;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    autenticando = true;

    final data = {
      'email': email,
      'password': password,
    };

    final resp = await http.post(
      Uri.parse('${Environments.apiUrl}/login'),
      body: jsonEncode(data),
      headers: {'Content-Type': 'applications/json'},
    );

    autenticando = false;
    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      usuario = loginResponse.usuario;
      return true;
    } else {
      return false;
    }
  }
}
