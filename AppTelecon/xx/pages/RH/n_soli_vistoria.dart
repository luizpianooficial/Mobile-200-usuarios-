import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:moove/pages/ftth/encerramento.dart';

class vistoriaposba extends StatefulWidget {
  final String nu_solicitacao;
  final String loggedInUser;

  const vistoriaposba(
      {Key? key, required this.nu_solicitacao, required this.loggedInUser});

  @override
  _IdentidadeBaFormState createState() => _IdentidadeBaFormState();
}

class _IdentidadeBaFormState extends State<vistoriaposba> {
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
  TextEditingController obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarBaData();
  }

  Future<void> carregarBaData() async {
    var url = Uri.parse(
        'https://sistema32.cloud/move/Api/puxacaixa.php?ba=${widget.nu_solicitacao}');
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
        title: Text('Identidade BA'),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1),
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
                      initialValue: baData['ba_comum'],
                      decoration: InputDecoration(labelText: 'BA Comum'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['uf'],
                      decoration: InputDecoration(labelText: 'UF'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['localidade'],
                      decoration: InputDecoration(labelText: 'Localidade'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['estacao'],
                      decoration: InputDecoration(labelText: 'Estação'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['endereco'],
                      decoration: InputDecoration(labelText: 'Endereço'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['celula'],
                      decoration: InputDecoration(labelText: 'Célula'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['cdoe'],
                      decoration: InputDecoration(labelText: 'CDOE'),
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
                      initialValue: baData['id_usu'],
                      decoration: InputDecoration(labelText: 'ID do Usuário'),
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
                      initialValue: baData['obs_cl'],
                      maxLines: 5, // Define o número de linhas
                      decoration: InputDecoration(labelText: 'Observações'),
                      enabled: false,
                    ),
                    TextFormField(
                      controller: obsController,
                      maxLines: 5,
                      decoration:
                          InputDecoration(labelText: 'Observações TEC - APOIO'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        processarAceite();
                      },
                      child: _envioEmProgresso
                          ? CircularProgressIndicator()
                          : Text('Salvar'),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(13, 71, 161, 1),
                      ),
                    ),
                    if (aceite)
                      Container(
                        color: Colors.grey[200],
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                processarAceite();
                              },
                              child: _envioEmProgresso
                                  ? CircularProgressIndicator()
                                  : Text('Aceite'),
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

  Future<void> processarAceite() async {
    await pegarPosicao();
    setState(() {
      aceite = true;
      _envioEmProgresso = true;
    });
    await atualizarDados();
    setState(() {
      _envioEmProgresso = false;
    });
    if (mounted) {
      _mostrarMensagemAceitacao(context);
      Navigator.pop(context);
      Navigator.pop(context);
    }
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
    String obs_ba_apoio = obsController.text;

    Map<String, dynamic> dadosAtualizados = {
      'ba': widget.nu_solicitacao,
      'obs_ba_apoio': obs_ba_apoio,
    };

    var url = Uri.parse('https://sistema32.cloud/move/Api/pos_ba/pos_ba.php');

    try {
      var response = await http.post(
        url,
        body: dadosAtualizados,
      );

      if (response.statusCode == 200) {
        print('Dados atualizados no banco com sucesso!');
        if (mounted) {
          setState(() {
            // Atualize o estado somente se o widget ainda estiver montado
          });
        }
      } else {
        print('Erro ao atualizar dados no banco: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao atualizar dados: $error');
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
