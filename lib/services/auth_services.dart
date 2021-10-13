import 'dart:convert';

import 'package:chat_app/global/environments.dart';
import 'package:chat_app/models/login_response.dart';
import 'package:chat_app/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  late Usuario usuario;
  bool _autenticando = false;
  // Create storage
  final _storage = const FlutterSecureStorage();

  bool get autenticando => _autenticando;
  set autenticando(bool valor) {
    _autenticando = valor;
    notifyListeners();
  }

  // getters del token de forma estatica
  static Future<String> getToken() async {
    const _storage = FlutterSecureStorage();
    final tokenStorage = await _storage.read(key: 'token');
    String token = '';
    if (tokenStorage != null) {
      token = tokenStorage;
    }
    return token;
  }

  static Future<void> deleteToken() async {
    const _storage = FlutterSecureStorage();
    await _storage.delete(key: 'token');
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
      // guardar el token
      await _guardarToken(loginResponse.token);
      return true;
    } else {
      return false;
    }
  }

  Future register(String email, String password, String nombre) async {
    autenticando = true;

    final data = {
      'email': email,
      'password': password,
      'nombre': nombre,
    };

    final resp = await http.post(
      Uri.parse('${Environments.apiUrl}/login/new'),
      body: jsonEncode(data),
      headers: {'Content-Type': 'applications/json'},
    );

    autenticando = false;
    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      usuario = loginResponse.usuario;
      // guardar el token
      await _guardarToken(loginResponse.token);
      return true;
    } else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  Future<bool> isLoogedIn() async {
    final token = await getToken();

    final resp = await http.get(
      Uri.parse('${Environments.apiUrl}/login/renew'),
      headers: {
        'Content-Type': 'applications/json',
        'x-token': token,
      },
    );

    if (resp.statusCode == 200) {
      final loginResponse = loginResponseFromJson(resp.body);
      usuario = loginResponse.usuario;
      // guardar el token
      await _guardarToken(loginResponse.token);
      return true;
    } else {
      logout(token);
      return false;
    }
  }

  Future _guardarToken(String token) async {
    return await _storage.write(
      key: 'token',
      value: token,
    );
  }

  Future logout(String token) async {
    return await _storage.delete(key: 'token');
  }
}
