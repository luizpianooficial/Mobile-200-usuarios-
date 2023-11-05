import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moove/pages/rh/gestoraprova.dart';
import 'package:moove/pages/RH/historico_N.dart';
// import 'package:moove/pages/RH/graficos.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moove/pages/rh/horas.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class homerh extends StatefulWidget {
  final String loggedInUser;

  homerh({required this.loggedInUser});

  @override
  _homerhState createState() => _homerhState();
}

class _homerhState extends State<homerh> {
  String? nomeDoUsuario;
  List<dynamic> registros = [];
  bool isLoading = true;
  bool hasError = false; // Variável para armazenar o acesso do usuário

  @override
  void initState() {
    super.initState();
    carregarNomeDoUsuario();
  }

  Future<void> carregarNomeDoUsuario() async {
    var url = Uri.parse(
        'https://sistema32.cloud/move/Api/RH/adm.php?id=${widget.loggedInUser}');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        setState(() {
          nomeDoUsuario = userData['acesso'];
        });
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seu acesso é: $nomeDoUsuario'),
        backgroundColor:
            Color.fromRGBO(13, 71, 161, 1), // Cor de fundo da app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HORAS EXTRAS',
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
                    Icons.access_time_filled_outlined,
                    'Solicitação Extra',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HoraExtraForm(
                              loggedInUser: widget.loggedInUser), // Correção
                        ),
                      );
                    },
                  ),
                  _buildDeviceCard(
                    Icons.published_with_changes_outlined,
                    'Status',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Historico(
                              loggedInUser: widget.loggedInUser), // Correção
                        ),
                      );
                    },
                  ),
                  // _buildDeviceCard(
                  //   Icons.published_with_changes_outlined,
                  //   'gráfico',
                  //   () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => Historico(
                  //             loggedInUser: widget.loggedInUser), // Correção
                  //       ),
                  //     );
                  //   },
                  // ),
                  if (nomeDoUsuario == 'ADM')
                    _buildDeviceCard(
                      Icons.spatial_audio_outlined,
                      'Gestor',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => encerramento(
                                loggedInUser: widget.loggedInUser), // Correção
                          ),
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
