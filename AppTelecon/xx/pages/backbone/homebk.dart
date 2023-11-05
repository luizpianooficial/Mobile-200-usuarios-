import 'package:moove/pages/BACKBONE/pesquisa.dart';
import 'package:moove/pages/backbone/bareatroativo.dart';
import 'package:flutter/material.dart';
import 'package:moove/pages/backbone/caixatec.dart';
import 'package:moove/pages/BACKBONE/ba_apoio.dart';
import 'package:moove/pages/BACKBONE/encerramento.dart';

class homebackbone extends StatelessWidget {
  final String loggedInUser;

  homebackbone({required this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Inicial - RE: $loggedInUser'),
        backgroundColor:
            Color.fromRGBO(13, 71, 161, 1), // Cor de fundo da app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backbone',
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
                    Icons.dns_outlined,
                    'Caixa',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Caixabk(loggedInUser: loggedInUser)),
                      );
                    },
                  ),
                  _buildDeviceCard(
                    Icons.track_changes_outlined,
                    'Ba em andamento',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                pesquisa(loggedInUser: loggedInUser)),
                      );
                    },
                  ),
                  _buildDeviceCard(
                    Icons.create_outlined,
                    'Encerrar ba',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                encerramento(loggedInUser: loggedInUser)),
                      );
                    },
                  ),
                  _buildDeviceCard(
                    Icons.handshake_outlined,
                    'Ba Apoio',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ba_apoio(loggedInUser: loggedInUser)),
                      );
                    },
                  ),
                  _buildDeviceCard(
                    Icons.assured_workload_outlined,
                    'Historico ba',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BaRetro()),
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
