import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moove/pages/ftth/puxavistoria.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class vistoria_ba extends StatefulWidget {
  final String loggedInUser;

  const vistoria_ba({Key? key, required this.loggedInUser});

  @override
  State<vistoria_ba> createState() => _vistoria_baState();
}

class _vistoria_baState extends State<vistoria_ba> {
  List<dynamic> registros = [];
  bool isLoading = true;
  bool hasError = false;
  String? nomeDoUsuario;
  late String currentMonth;

  @override
  void initState() {
    super.initState();
    carregarNomeDoUsuario();
    carregarRegistros();
    initializeDateFormatting('pt_BR', null);

    // Descomente a chamada abaixo
    obterEMostrarNomeGestor();
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
        builder: (context) => IdentidadeBaFormV(
          ba: ba,
        ),
      ),
    );
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

  Future<void> obterEMostrarNomeGestor() async {
    // final nomeGestor = await carregarNomeGestor();
    setState(() {
      currentMonth = DateFormat('MMMM', 'pt_BR').format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    int recordCount = registros.length;
    int recordCount2 = 20;
    int calc = recordCount2 - recordCount;
    String emoji = '';

    if (recordCount > 30) {
      emoji = '😭'; // More than 30 records
    } else if (recordCount >= 20 && recordCount <= 20) {
      emoji = '😪'; // 20-29 records
    } else if (recordCount >= 15 && recordCount <= 15) {
      emoji = '😮‍💨'; // 15-20 records
    } else if (recordCount >= 10 && recordCount <= 10) {
      emoji = '😅'; // 10-14 records
    } else if (recordCount >= 5 && recordCount <= 9) {
      emoji = '🥰'; // 5-9 records
    } else if (recordCount >= 1 && recordCount <= 5) {
      emoji = '🤩'; // 1-4 records
    } else {
      emoji = '🏆'; // 0 records
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Vistorias',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : hasError
              ? Center(
                  child: Text(
                    'Parabéns $nomeDoUsuario você \n vistorio 100% em $currentMonth 🏆'
                        .toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color.fromRGBO(13, 71, 161, 1),
                    ),
                  ),
                )
              : registros.isEmpty
                  ? Center(
                      child: Text('Sem registros para $nomeDoUsuario'),
                    )
                  : ListView(
                      // Use ListView para habilitar a barra de rolagem vertical
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          // child: Text(
                          //   'Bem-vindo,',
                          //   style: TextStyle(fontWeight: FontWeight.bold),
                          // ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Vistorias pendentes: $emoji ($recordCount)          Você realizou: 🏆 ($calc)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('BA')),
                              DataColumn(label: Text('NOME')),
                              DataColumn(label: Text('CAUSA')),
                              DataColumn(label: Text('ESTAÇÃO')),
                              DataColumn(label: Text('ENDEREÇO')),
                              DataColumn(label: Text('DESCRIÇÃO')),
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
                                DataCell(Text(registro['nome'] ?? '')),
                                DataCell(Text(registro['causa'] ?? '')),
                                DataCell(Text(registro['estacao'] ?? '')),
                                DataCell(Text(registro['endereco'] ?? '')),
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
