import 'package:moove/pages/preventivas/mantas.dart';
import 'package:flutter/material.dart';
// import 'package:aplicativomanutencao/pages/caixatec.dart';
import 'package:moove/pages/preventivas/Diario.dart';
import 'package:moove/pages/ftth/encerramento.dart';

class preventivas extends StatelessWidget {
  final String loggedInUser;

  preventivas({required this.loggedInUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Inicial - RE: $loggedInUser'),
        backgroundColor: Color(0xFF335486), // Cor de fundo da app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preventivas',
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
                    Icons.close_fullscreen,
                    'Mantas',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => mantas()),
                      );
                    },
                  ),
                  _buildDeviceCard(
                    Icons.cancel,
                    'EM CONSTRUÇÃO',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Diario()),
                      );
                    },
                  ),
                  _buildDeviceCard(
                    Icons.cancel,
                    'EM CONSTRUÇÃO',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => mantas()),
                      );
                    },
                  ),
                  _buildDeviceCard(
                    Icons.cancel,
                    'EM CONSTRUÇÃO',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => mantas()),
                      );
                    },
                  ),
                  _buildDeviceCard(
                    Icons.cancel,
                    'EM CONSTRUÇÃO',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                encerramento(loggedInUser: loggedInUser)),
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
              color: Color(0xFF335486),
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
