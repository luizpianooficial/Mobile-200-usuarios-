import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moove/pages/ftth/bahistorico_mm.dart';
// import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
// Importe esta linha

class historicoa extends StatefulWidget {
  final String loggedInUser;
  

  const historicoa({Key? key, required this.loggedInUser});

  @override
  State<historicoa> createState() => _CaixaState();
}

class _CaixaState extends State<historicoa> {
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
      // 'https://sistema32.cloud/move/Api/listacaixa.php?user=${widget.loggedInUser}');
        'https://sistema32.cloud/move/Api/VPS/FTTH/historico/ba.php?user=${widget.loggedInUser}');
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
        builder: (context) => IdentidadeBaForms(
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
        title: Text('Caixa'),
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
                              DataColumn(label: Text('BA')),
                              DataColumn(label: Text('PRIORIDADE')),
                              DataColumn(label: Text('DATA_ENCERRAMENTO')),
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
                                        color: Color(0xFF335486),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(registro['tipo'] ?? '')),
                                DataCell(Text(registro['data_encerramento'] ?? '')),
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
