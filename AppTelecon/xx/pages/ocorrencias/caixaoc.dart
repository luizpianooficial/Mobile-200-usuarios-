import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moove/pages/hc/puxadados.dart';

class Caixaoc extends StatefulWidget {
  final String loggedInUser;

  const Caixaoc({Key? key, required this.loggedInUser});

  @override
  State<Caixaoc> createState() => _CaixaState();
}

class _CaixaState extends State<Caixaoc> {
  List<dynamic> registros = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    carregarRegistros();
  }

  Future<void> carregarRegistros() async {
    var url =
        Uri.parse('https://sistema32.cloud/move/Api/ocorrencias/caixaoc.php');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ocorrências',
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
                              DataColumn(label: Text('CIDADE')),
                              DataColumn(label: Text('TIPO')),
                              DataColumn(label: Text('ENDEREÇO')),
                              DataColumn(label: Text('STATUS')),
                              DataColumn(label: Text('DATA')),
                            ],
                            rows: registros.map((registro) {
                              return DataRow(cells: [
                                DataCell(Text(registro['cidade'] ?? '')),
                                DataCell(Text(registro['tipo'] ?? '')),
                                DataCell(Text(registro['endereco'] ?? '')),
                                DataCell(Text(registro['status'] ?? '')),
                                DataCell(Text(registro['data'] ?? '')),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
