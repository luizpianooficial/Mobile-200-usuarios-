import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moove/pages/hc/puxadados.dart';

class Caixahc extends StatefulWidget {
  final String loggedInUser;

  final String status;

  const Caixahc({Key? key, required this.loggedInUser, required this.status});

  @override
  State<Caixahc> createState() => _CaixaState();
}

class _CaixaState extends State<Caixahc> {
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

  void abrirPixaCaixa(String sa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdentidadeBaFormhc(
          sa: sa,
          loggedInUser: widget.loggedInUser,
          // status: widget.status,
          // status: widget.loggedInUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HC',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1),
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
                              DataColumn(label: Text('SA')),
                              DataColumn(label: Text('STATUS')),
                              DataColumn(label: Text('COORDENADOR')),
                              DataColumn(label: Text('ENDEREÇO')),
                              DataColumn(label: Text('DATA_EXECUÇÃO')),
                              DataColumn(label: Text('COMPAINHA')),
                              DataColumn(label: Text('TECNICO')),
                              DataColumn(label: Text('MACRO')),
                              DataColumn(label: Text('CLIENTE')),
                              DataColumn(label: Text('UF')),

                              // Adicione mais DataColumn para as colunas adicionais que deseja exibir
                            ],
                            rows: registros.map((registro) {
                              return DataRow(cells: [
                                DataCell(
                                  InkWell(
                                    onTap: () {
                                      abrirPixaCaixa(registro['sa']);
                                    },
                                    child: Text(
                                      registro['sa'] ?? '',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Color.fromRGBO(13, 71, 161, 1),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(registro['status'] ?? '')),
                                DataCell(Text(registro['coordenador'] ?? '')),
                                DataCell(Text(registro['endereco'] ?? '')),
                                DataCell(Text(registro['data_execucao'] ?? '')),
                                DataCell(Text(registro['companhia'] ?? '')),
                                DataCell(Text(registro['tecnico'] ?? '')),
                                DataCell(Text(registro['macro'] ?? '')),
                                DataCell(Text(registro['cliente'] ?? '')),
                                DataCell(Text(registro['uf'] ?? '')),

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
