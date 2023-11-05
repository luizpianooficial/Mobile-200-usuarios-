import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moove/pages/rh/mascara.dart';

class encerramento extends StatefulWidget {
  final String loggedInUser;

  const encerramento({Key? key, required this.loggedInUser});

  @override
  State<encerramento> createState() => _encerramentoState();
}

class _encerramentoState extends State<encerramento> {
  List<dynamic> registros = [];
  bool isLoading = true;
  bool hasError = false;
  String selectedStatus = 'TODOS';

  @override
  void initState() {
    super.initState();
    carregarRegistros();
  }

  Future<void> carregarRegistros() async {
    var url = Uri.parse(
        'https://sistema32.cloud/move/Api/RH/solicitacao_hr.php?user=${widget.loggedInUser}');
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

  void abrirPixaCaixa(String nu_solicitacao) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => nomess(nu_solicitacao: nu_solicitacao),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'PENDENTE':
        return Colors.yellow;
      case 'APROVADO':
        return Colors.green;
      case 'NÃO AUTORIZADO':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  List<dynamic> filtrarRegistrosPorStatus(String status) {
    if (status == 'TODOS') {
      return registros;
    } else {
      return registros
          .where((registro) => registro['status'] == status)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final registrosFiltrados = filtrarRegistrosPorStatus(selectedStatus);

    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitações'),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : hasError
              ? Center(
                  child: Text('Sem registros'),
                )
              : registros.isEmpty
                  ? Center(
                      child: Text('Sem registros'),
                    )
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.refresh),
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                carregarRegistros();
                              },
                            ),
                          ],
                        ),
                        DropdownButton<String>(
                          value: selectedStatus,
                          onChanged: (newValue) {
                            setState(() {
                              selectedStatus = newValue!;
                            });
                          },
                          items: [
                            'TODOS',
                            'PENDENTE',
                            'AUTORIZADO',
                            'NÃO AUTORIZADO'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('N° SOLICITAÇÃO')),
                              DataColumn(label: Text('GESTOR DO COLABORADOR')),
                              DataColumn(label: Text('NOME')),
                              DataColumn(label: Text('TEMPO_EXTRA')),
                              DataColumn(label: Text('DATA DA SOLICITAÇÃO')),
                              DataColumn(label: Text('STATUS')),
                              DataColumn(label: Text('MOTIVO')),
                              DataColumn(label: Text('DESCRICAO')),
                            ],
                            rows: registrosFiltrados.map((registro) {
                              return DataRow(cells: [
                                DataCell(
                                  InkWell(
                                    onTap: () {
                                      abrirPixaCaixa(
                                          registro['nu_solicitacao']);
                                    },
                                    child: Text(
                                      registro['nu_solicitacao'] ?? '',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: const Color.fromRGBO(
                                            51, 84, 134, 1),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(registro['nome_gestor'] ?? '')),
                                DataCell(Text(registro['nome'] ?? '')),
                                DataCell(Text(registro['tempo_extra'] ?? '')),
                                DataCell(
                                    Text(registro['data_solicitacao'] ?? '')),
                                DataCell(Text(registro['status'] ?? '')),
                                DataCell(Text(registro['motivo'] ?? '')),
                                DataCell(Text(registro['descricao'] ?? '')),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
