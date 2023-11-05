

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moove/pages/RH/analisetec.dart';

class pontotec extends StatefulWidget {
  final String loggedInUser;
  

  const pontotec({Key? key, required this.loggedInUser});

  @override
  State<pontotec> createState() => _CaixaState();
}

class _CaixaState extends State<pontotec> {
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

  void abrirPixaCaixa(String loggedInUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => analisetec(
          // id_usu: widget.id_usu,
          loggedInUser: widget.loggedInUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      appBar: AppBar(
        title: Text('Caixa', 
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
                              DataColumn(label: Text('RE')),
                              DataColumn(label: Text('TEC')),
                              DataColumn(label: Text('COORDENADOR')),
                              // DataColumn(label: Text('JUSTIFICATIVA')),
                              DataColumn(label: Text('MOTIVO')),
                              DataColumn(label: Text('SUB-MOTIVO')),
                              
                              // Adicione mais DataColumn para as colunas adicionais que deseja exibir
                            ],
                            rows: registros.map((registro) {
                              return DataRow(cells: [
                                DataCell(
                                  InkWell(
                                    onTap: () {
                                      abrirPixaCaixa(registro['matricula']);
                                    },
                                    child: Text(
                                      registro['matricula'] ?? '',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Color(0xFF335486),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(registro['nome'] ?? '')),
                                DataCell(Text(registro['coordenador'] ?? '')),
                                // DataCell(Text(registro[''] ?? '')),
                                DataCell(Text(registro['status_batida'] ?? '')),
                                DataCell(Text(registro['status_batida_2'] ?? '')),
                               
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
