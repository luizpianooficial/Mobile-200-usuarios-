import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class nomess extends StatefulWidget {
  final String nu_solicitacao;

  const nomess({Key? key, required this.nu_solicitacao}) : super(key: key);

  @override
  _IdentidadeBaFormState createState() => _IdentidadeBaFormState();
}

class _IdentidadeBaFormState extends State<nomess> {
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

  void _mostrarMensagemAceitacao(BuildContext context) {
    // Coloque aqui o código para mostrar a mensagem de aceitação, como um AlertDialog ou SnackBar.
    // Por exemplo:
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mensagem de Aceitação'),
          content: Text('A solicitação foi aceita com sucesso.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController idController =
        TextEditingController(text: baData['nu_solicitacao']);
    return Scaffold(
        appBar: AppBar(
          title: Text('Painel de solicitação'),
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
                        initialValue: baData['nu_solicitacao'],
                        decoration: InputDecoration(labelText: 'N'),
                        enabled: false,
                      ),
                      TextFormField(
                        initialValue: baData['motivo'],
                        decoration: InputDecoration(labelText: 'Motivo'),
                        enabled: false,
                      ),
                      TextFormField(
                        initialValue: baData['descricao'],
                        decoration: InputDecoration(labelText: 'Descrição'),
                        enabled: false,
                      ),
                      TextFormField(
                        initialValue: baData['numero_cdoe'],
                        decoration:
                            InputDecoration(labelText: 'Número de Cdoe'),
                        enabled: false,
                      ),
                      TextFormField(
                        initialValue: baData['numero_ba'],
                        decoration: InputDecoration(labelText: 'BA'),
                        enabled: false,
                      ),
                      TextFormField(
                        initialValue: baData['tempo_extra'],
                        decoration: InputDecoration(labelText: 'Tempo Extra'),
                        enabled: false,
                      ),
                      TextFormField(
                        initialValue: baData['status'],
                        decoration: InputDecoration(labelText: 'Status'),
                        enabled: false,
                      ),
                      TextFormField(
                        initialValue: baData['data_solicitacao'],
                        decoration:
                            InputDecoration(labelText: 'Data da solicitação'),
                        enabled: false,
                      ),
                      TextFormField(
                        controller: idController,
                        decoration: InputDecoration(labelText: 'ID'),
                        enabled: false,
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                            top: 20.0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      aceite = true;
                                      _envioEmProgresso = true;
                                    });

                                    // Chame a função para atualizar o status para "NÃO AUTORIZADO" aqui
                                    var url = Uri.parse(
                                        'API');
                                    var response = await http.post(url, body: {
                                      'id':
                                          baData['id'], // Use o ID do registro
                                      'novo_status': 'NÃO AUTORIZADO',
                                    });

                                    print(
                                        'Código de Status da Resposta: ${response.statusCode}');
                                    print(
                                        'Conteúdo da Resposta: ${response.body}');

                                    if (response.statusCode == 200) {
                                      // Status atualizado com sucesso
                                      _mostrarMensagemAceitacao(context);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    } else {
                                      // Tratar erro ao atualizar o status, exibindo uma mensagem de erro, por exemplo.
                                      print('Erro ao atualizar o status');
                                    }

                                    setState(() {
                                      _envioEmProgresso = false;
                                    });
                                  },
                                  child: _envioEmProgresso
                                      ? CircularProgressIndicator()
                                      : Text('Nao autorizar'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                    minimumSize: Size(170, 50),
                                  ),
                                ),
                              ),

                              SizedBox(width: 30), // Espaço entre os botões
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    setState(() {
                                      aceite = true;
                                      _envioEmProgresso = true;
                                    });

                                    // Chame a função para atualizar o status para "NÃO AUTORIZADO" aqui
                                    var url = Uri.parse(
                                        'API');
                                    var response = await http.post(url, body: {
                                      'id':
                                          baData['id'], // Use o ID do registro
                                      'novo_status': 'AUTORIZADO',
                                    });

                                    print(
                                        'Código de Status da Resposta: ${response.statusCode}');
                                    print(
                                        'Conteúdo da Resposta: ${response.body}');

                                    if (response.statusCode == 200) {
                                      // Status atualizado com sucesso
                                      _mostrarMensagemAceitacao(context);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    } else {
                                      // Tratar erro ao atualizar o status, exibindo uma mensagem de erro, por exemplo.
                                      print('Erro ao atualizar o status');
                                    }

                                    setState(() {
                                      _envioEmProgresso = false;
                                    });
                                  },
                                  child: _envioEmProgresso
                                      ? CircularProgressIndicator()
                                      : Text('Autorizar'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.green,
                                    minimumSize: Size(150, 50),
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
                // SizedBox(height: 16),
              ));
  }
}
