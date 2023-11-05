import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IdentidadeBaFormba extends StatefulWidget {
  final String ba;

  const IdentidadeBaFormba({Key? key, required this.ba});

  @override
  _IdentidadeBaFormState createState() => _IdentidadeBaFormState();
}

class _IdentidadeBaFormState extends State<IdentidadeBaFormba> {
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
        'https://sistema32.cloud/move/Api/puxacaixa.php?ba=${widget.ba}');
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
                  ],
                ),
              ),
            ),
    );
  }
}
