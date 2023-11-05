import 'package:flutter/material.dart';
import 'package:moove/pages/ocorrencias/cadastrooc.dart';
import 'package:moove/pages/ocorrencias/caixaoc.dart';

class homeoc extends StatelessWidget {
  final String loggedInUser;

  homeoc({required this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Você é nota 10'),
        backgroundColor:
            Color.fromRGBO(13, 71, 161, 1), // Cor de fundo da app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ocorrências',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Recursos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildDeviceCard(
                    Icons.control_point_duplicate,
                    'Registrar',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CadastroOC(loggedInUser: loggedInUser)),
                      );
                    },
                  ),
                  _buildDeviceCard(
                    Icons.search,
                    'Cosultar',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Caixaoc(loggedInUser: loggedInUser)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(IconData icon, String title, VoidCallback onPressed) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Color.fromRGBO(13, 71, 161, 1),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
