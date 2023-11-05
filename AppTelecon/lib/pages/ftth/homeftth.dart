import 'package:flutter/material.dart';
import 'package:moove/pages/ftth/pesquisa.dart';
import 'package:moove/pages/ftth/vistoria.dart';
import 'package:moove/pages/ftth/caixatec.dart';
import 'package:moove/pages/ftth/ba_apoio.dart';
import 'package:moove/pages/ftth/encerramento.dart';
import 'package:moove/pages/ftth/BAREATROATIVO.dart';
// import 'package:moove/pages/ftth/historico_m.dart';
import 'package:moove/pages/ftth/ga_tempo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class homeftth extends StatefulWidget {
  final String loggedInUser;

  homeftth({required this.loggedInUser});

  @override
  _homeftthState createState() => _homeftthState();
}

class _homeftthState extends State<homeftth> {
  String? nomeDoUsuario;
  String nomecoordenador = '';
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    carregarNomeDoUsuario();
  }

  Future<void> carregarNomeDoUsuario() async {
    var url = Uri.parse(

        'API');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        setState(() {
          nomeDoUsuario = userData['acesso'];
          nomecoordenador = userData['nome_gestor'];
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
  appBar: AppBar(
    title: Text('Bem vindo 👷',
    style: TextStyle(
      color: Colors.white,
      fontSize: 20,
    ),
    ),
    backgroundColor: Color.fromRGBO(13, 71, 161, 1),
    iconTheme: IconThemeData(color: Colors.white), // Defina a cor do ícone para br
  ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : hasError
              ? Center(
                  child: Text('Ocorreu um erro ao carregar os dados.'),
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FTTH',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Recursos',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          children: [
                            if (nomeDoUsuario == 'Tec')
                              _buildDeviceCard(
                                Icons.dns_outlined,
                                'Caixa',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Caixa(
                                          loggedInUser: widget.loggedInUser),
                                    ),
                                  );
                                },
                              ),
                            if (nomeDoUsuario == 'Tec')
                              _buildDeviceCard(
                                Icons.outbox_outlined,
                                'BA em andamento',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => pesquisa(
                                          loggedInUser: widget.loggedInUser),
                                    ),
                                  );
                                },
                              ),
                            if (nomeDoUsuario == 'Tec')
                              _buildDeviceCard(
                                Icons.create_outlined,
                                'Encerrar ba',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => encerramento(
                                          loggedInUser: widget.loggedInUser),
                                    ),
                                  );
                                },
                              ),
                            if (nomeDoUsuario == 'ADM')
                              _buildDeviceCard(
                                Icons.nature_people_outlined,
                                'Vistoria',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => vistoria_ba(
                                          loggedInUser: widget.loggedInUser),
                                    ),
                                  );
                                },
                              ),
                            if (nomeDoUsuario == 'Tec')
                              _buildDeviceCard(
                                Icons.handshake_outlined,
                                'Ba Apoio',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ba_apoio(
                                          loggedInUser: widget.loggedInUser),
                                    ),
                                  );
                                },
                              ),
                            _buildDeviceCard(
                              Icons.assured_workload_outlined,
                              'Historico BA',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BaRetro()),
                                );
                              },
                            ),
                            if (nomeDoUsuario == 'ADM')
                              _buildDeviceCard(
                                Icons.running_with_errors_outlined,
                                'BA 97',
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ga_tempo(
                                            loggedInUser: widget.loggedInUser)),
                                  );
                                },
                              ),
                            // _buildDeviceCard(
                            //   Icons.running_with_errors_outlined,
                            //   'TESTE',
                            //   () {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (context) => historicoa(
                            //               loggedInUser: widget.loggedInUser)),
                            //     );
                            //   },
                            // ),
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
