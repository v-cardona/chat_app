import 'package:chat_app/models/usuario.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({Key? key}) : super(key: key);

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final _refreshController = RefreshController(initialRefresh: false);
  final usuarios = [
    Usuario(
      email: 'maria@test.com',
      nombre: 'Maria',
      online: true,
      uid: '1',
    ),
    Usuario(
      email: 'melissa@test.com',
      nombre: 'Melissa',
      online: true,
      uid: '2',
    ),
    Usuario(
      email: 'fer@test.com',
      nombre: 'Fer',
      online: false,
      uid: '3',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final usuario = authService.usuario;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          usuario.nombre,
          style: TextStyle(color: Colors.black87),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            // todo, desconectarnos del socket server
            Navigator.pushReplacementNamed(context, 'login');
            AuthService.deleteToken();
          },
          icon: const Icon(
            Icons.exit_to_app,
            color: Colors.black87,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Icon(
              Icons.check_circle,
              color: Colors.blue[400],
            ),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        child: ListViewUsuarios(usuarios: usuarios),
        header: WaterDropHeader(
          complete: Icon(Icons.check, color: Colors.blue[400]),
          waterDropColor: Colors.blue[400]!,
        ),
        onRefresh: _cargarUsuarios,
      ),
    );
  }

  void _cargarUsuarios() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
}

class ListViewUsuarios extends StatelessWidget {
  const ListViewUsuarios({
    Key? key,
    required this.usuarios,
  }) : super(key: key);

  final List<Usuario> usuarios;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, index) =>
          UsuarioListTile(usuario: usuarios[index]),
      separatorBuilder: (context, index) => Divider(),
      itemCount: usuarios.length,
    );
  }
}

class UsuarioListTile extends StatelessWidget {
  final Usuario usuario;

  const UsuarioListTile({
    Key? key,
    required this.usuario,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(usuario.nombre),
      subtitle: Text(usuario.email),
      leading: CircleAvatar(
        child: Text(usuario.nombre.substring(0, 2)),
        backgroundColor: Colors.blue[100],
      ),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: usuario.online ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
