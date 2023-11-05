import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moove/pages/RH/n_soli_vistoria.dart';

class Historico extends StatefulWidget {
  final String loggedInUser;

  const Historico({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  State<Historico> createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
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
        'https://sistema32.cloud/move/Api/RH/puxa_solicitacao_tec.php?user=${widget.loggedInUser}');
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
        builder: (context) => vistoriaposba(
          nu_solicitacao: nu_solicitacao,
          loggedInUser: widget.loggedInUser,
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'PENDENTE':
        return Color.fromARGB(255, 4, 19, 224);
      case 'APROVADO':
        return Colors.green;
      case 'NÃO AUTORIZADO':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SOLICITAÇÕES'),
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
                  : Column(
                      children: [
                        DropdownButton<String>(
                          value: selectedStatus,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedStatus = newValue!;
                            });
                          },
                          items: <String>[
                            'TODOS',
                            'PENDENTE',
                            'APROVADO',
                            'NÃO AUTORIZADO'
                          ].map<DropdownMenuItem<String>>(
                            (String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            },
                          ).toList(),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(label: Text('N° SOLICITAÇÃO')),
                                DataColumn(label: Text('STATUS')),
                                DataColumn(label: Text('DATA RESPOSTA')),
                                DataColumn(label: Text('DATA SOLICITAÇÃO')),
                                DataColumn(label: Text('NOME')),
                                DataColumn(label: Text('TEMPO_EXTRA')),
                                DataColumn(label: Text('MOTIVO')),
                                DataColumn(label: Text('DESCRICAO')),
                              ],
                              rows: registros
                                  .where((registro) =>
                                      selectedStatus == 'TODOS' ||
                                      registro['status'] == selectedStatus)
                                  .map<DataRow>((registro) {
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
                                          color: getStatusColor(
                                              registro['status'] ?? ''),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(registro['status'] ?? '')),
                                  DataCell(Text(registro['data'] ?? '')),
                                  DataCell(
                                      Text(registro['data_solicitacao'] ?? '')),
                                  DataCell(Text(registro['nome'] ?? '')),
                                  DataCell(Text(registro['tempo_extra'] ?? '')),
                                  DataCell(Text(registro['motivo'] ?? '')),
                                  DataCell(Text(registro['descricao'] ?? '')),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
