import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moove/pages/ftth/historico_ba.dart';

class pesquisa extends StatefulWidget {
  final String loggedInUser;

  const pesquisa({Key? key, required this.loggedInUser});

  @override
  State<pesquisa> createState() => _pesquisaState();
}

class _pesquisaState extends State<pesquisa> {
  List<dynamic> registros = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    carregarRegistros();
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
        builder: (context) => IdentidadeBaFormba(
          ba: ba,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historico ba ',
        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
                              DataColumn(label: Text('CDOE')),
                              DataColumn(label: Text('AFETAÇÃO')),
                              DataColumn(label: Text('CÉLULA')),
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
                                DataCell(Text(registro['cdoe'] ?? '')),
                                DataCell(Text(registro['afetacao'] ?? '')),
                                DataCell(Text(registro['celula'] ?? '')),
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
