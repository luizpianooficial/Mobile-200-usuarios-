import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:moove/pages/ftth/encerramento.dart';

class IdentidadeBaFormbk extends StatefulWidget {
  final String ba;
  final String loggedInUser;

  const IdentidadeBaFormbk(
      {Key? key, required this.ba, required this.loggedInUser});

  @override
  _IdentidadeBaFormState createState() => _IdentidadeBaFormState();
}

class _IdentidadeBaFormState extends State<IdentidadeBaFormbk> {
  Map<String, dynamic> baData = {
    'latitude': 0.0,
    'longitude': 0.0,
  };
  bool isLoading = true;
  bool aceite = false;
  bool _envioEmProgresso = false;
  List<bool> checkBoxValues1 = [false, false, false];
  List<bool> checkBoxValues2 = [false, false, false];
  List<bool> checkBoxValues3 = [false, false, false, false, false];
  String? selectedOption1;
  String? selectedOption3;
  @override
  void initState() {
    super.initState();
    carregarBaData();
  }

  Future<void> carregarBaData() async {
    var url = Uri.parse(
        'API');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        baData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      // Exibir mensagem de erro ou tomar uma ação apropriada
    }
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text('Identidade BA', 
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          )),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: baData['ba'],
                      decoration: InputDecoration(labelText: 'BA'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['localidade'],
                      decoration: InputDecoration(labelText: 'Localidade'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['endereco'],
                      decoration: InputDecoration(labelText: 'Endereço'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['data_abertura'],
                      decoration:
                          InputDecoration(labelText: 'Data de Abertura'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['data_vencimento'],
                      decoration:
                          InputDecoration(labelText: 'Data de Vencimento'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['tipo'],
                      decoration: InputDecoration(labelText: 'Tipo'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['data_despacho'],
                      decoration:
                          InputDecoration(labelText: 'Data de Despacho'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['status'],
                      decoration: InputDecoration(labelText: 'Status'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['eqp_a'],
                      decoration: InputDecoration(labelText: 'Equipamento A'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['eqp_b'],
                      decoration: InputDecoration(labelText: 'Equipamento B'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['cliente'],
                      decoration: InputDecoration(labelText: 'Cliente'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['ccto'],
                      decoration: InputDecoration(labelText: 'Circuito'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['prs'],
                      decoration: InputDecoration(labelText: 'PRS'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['rota'],
                      decoration: InputDecoration(labelText: 'Rota'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['barramento'],
                      decoration: InputDecoration(labelText: 'Barramento'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['estacao_a'],
                      decoration: InputDecoration(labelText: 'Estação A'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['estacao_b'],
                      decoration: InputDecoration(labelText: 'Estação B'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['obs_cl'],
                      maxLines: 10, // Define o número de linhas
                      decoration: InputDecoration(labelText: 'Observações'),
                      enabled: false,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          pegarPosicao();
                          setState(() {
                            aceite = true;
                          });
                        },
                        child: Text('Visualizar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                        )),
                    if (aceite)
                      Container(
                        color: Colors.grey[200],
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VOCÊ ESTÁ:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            DropdownButton<String>(
                              value: selectedOption1,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedOption1 = newValue!;
                                  baData['checkBox'] =
                                      newValue; // Definir o valor em baData
                                });
                              },
                              items: [
                                DropdownMenuItem(
                                  value: 'No local?',
                                  child: Text('No local?'),
                                ),
                                DropdownMenuItem(
                                  value:
                                      'Deslocamento para o ponto de rompimento?',
                                  child: Text(
                                      'Deslocamento para o ponto de rompimento?'),
                                ),
                                DropdownMenuItem(
                                  value: 'Deslocamento para a estação?',
                                  child: Text('Deslocamento para a estação?'),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'TEMPO DE DESLOCAMENTO',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            DropdownButton<String>(
                              value: selectedOption3,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedOption3 = newValue!;
                                  baData['checkBox2'] =
                                      newValue; // Definir o valor em baData
                                });
                              },
                              items: [
                                DropdownMenuItem(
                                  value: 'Já estou no local!',
                                  child: Text('Já estou no local!'),
                                ),
                                DropdownMenuItem(
                                  value: '00:30 minutos',
                                  child: Text('00:30 minutos'),
                                ),
                                DropdownMenuItem(
                                  value: '01:00 Hora',
                                  child: Text('01:00 Hora'),
                                ),
                                DropdownMenuItem(
                                  value: '01:30 Hora',
                                  child: Text('01:30 Hora'),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await pegarPosicao();
                                setState(() {
                                  aceite = true;
                                  _envioEmProgresso = true;
                                });
                                await atualizarDados();
                                setState(() {
                                  _envioEmProgresso =
                                      false; // Inicia o envio e exibe o indicador de progresso
                                });
                                if (mounted) {
                                  _mostrarMensagemAceitacao(context);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  // Navega para a tela home.dart
                                }
                              },
                              child: _envioEmProgresso
                                  ? CircularProgressIndicator() // Exibe o indicador de progresso se o envio estiver em andamento
                                  : Text('Aceite',style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),),
                              style: ElevatedButton.styleFrom(
                                primary: Color.fromRGBO(13, 71, 161, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> pegarPosicao() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Permissão de localização não concedida.');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    double latitude = position.latitude;
    double longitude = position.longitude;
    print('Latitude: $latitude');
    print('Longitude: $longitude');

    if (mounted) {
      setState(() {
        baData['latitude'] = latitude.toString();
        baData['longitude'] = longitude.toString();
      });
    }
  }

  Future<void> atualizarDados() async {
    String latitude = baData['latitude'];
    String longitude = baData['longitude'];
    String selectedOption1 = baData['checkBox'] ?? '';
    String selectedOption3 = baData['checkBox2'] ?? '';

    Map<String, dynamic> dadosAtualizados = {
      'ba': widget.ba,
      'latitude': latitude,
      'longitude': longitude,
      'checkBox': selectedOption1,
      'checkBox2': selectedOption3,
    };

    var url = Uri.parse('API');

    try {
      var response = await http.post(
        url,
        body: dadosAtualizados,
      );

      if (response.statusCode == 200) {
        print('Latitude and longitude updated in the database successfully!');
        if (mounted) {
          setState(() {
            // Atualize o estado somente se o widget ainda estiver montado
          });
        }
      } else {
        print(
            'Error updating latitude and longitude in the database: ${response.statusCode}');
      }
    } catch (error) {
      print('An error occurred while updating latitude and longitude: $error');
    }
  }

  void _mostrarMensagemAceitacao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Missão Aceitada'),
          content: Text('Obrigado'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Fechar o diálogo
              },
              child: Text('OK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(13, 71, 161, 1),
              ),
            ),
          ],
        );
      },
    );
  }
}
