import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moove/pages/backbone/puxacaixa.dart';

class Caixabk extends StatefulWidget {
  final String loggedInUser;

  const Caixabk({Key? key, required this.loggedInUser});

  @override
  State<Caixabk> createState() => _CaixaState();
}

class _CaixaState extends State<Caixabk> {
  List<dynamic> registros = [];
  bool isLoading = true;
  bool hasError = false;
  String? nomeDoUsuario;

  @override
  void initState() {
    super.initState();
    carregarNomeDoUsuario();
    carregarRegistros();
  }

  Future<void> carregarNomeDoUsuario() async {
    var url = Uri.parse(
        'API');
        
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        setState(() {
          nomeDoUsuario = userData['nome'];
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

  Future<void> carregarRegistros() async {
    var url = Uri.parse(
        'API');
     
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          registros = json.decode(response.body);
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

  void abrirPixaCaixa(String ba) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdentidadeBaFormbk(
          ba: ba,
          loggedInUser: widget.loggedInUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text('Caixa $nomeDoUsuario' , 
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
          : hasError
              ? Center(
                  child: Text('Sem registros.'),
                )
              : registros.isEmpty
                  ? Center(
                      child: Text('Sem registros'),
                    )
                  : ListView(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('BA')),
                              DataColumn(label: Text('PRIORIDADE')),
                              DataColumn(label: Text('COORDENADOR')),
                              DataColumn(label: Text('STATUS')),
                              DataColumn(label: Text('ESTAÇÃO')),
                              DataColumn(label: Text('DATA ABERTURA')),

                              // Adicione mais DataColumn para as colunas adicionais que deseja exibir
                            ],
                            rows: registros.map((registro) {
                              return DataRow(cells: [
                                DataCell(
                                  InkWell(
                                    onTap: () {
                                      abrirPixaCaixa(registro['ba']);
                                    },
                                    child: Text(
                                      registro['ba'] ?? '',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Color.fromRGBO(13, 71, 161, 1),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(registro['tipo'] ?? '')),
                                DataCell(Text(registro['nome_gestor'] ?? '')),
                                DataCell(Text(registro['status'] ?? '')),
                                DataCell(Text(registro['estacao'] ?? '')),
                                DataCell(Text(registro['data_abertura'] ?? '')),

                                // Adicione mais DataCell para as células adicionais que deseja exibir
                              ]);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
