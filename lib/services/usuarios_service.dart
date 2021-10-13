import 'package:chat_app/global/environments.dart';
import 'package:chat_app/models/usuarios_response.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:http/http.dart' as http;
import 'package:chat_app/models/usuario.dart';

class UsuariosService {
  Future<List<Usuario>> getUsuarios() async {
    try {
      final resp = await http.get(Uri.parse('${Environments.apiUrl}/usuarios'),
          headers: {
            'Content-Type': 'application/json',
            'x-token': await AuthService.getToken()
          });
      final usuariosResponse = usuariosResponseFromJson(resp.body);
      return usuariosResponse.usuarios;
    } catch (e) {
      return [];
    }
  }
}
