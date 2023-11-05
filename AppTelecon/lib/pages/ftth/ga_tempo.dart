import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moove/pages/ftth/puxacaixa.dart';

class ga_tempo extends StatefulWidget {
  final String loggedInUser;

  const ga_tempo({Key? key, required this.loggedInUser});

  @override
  State<ga_tempo> createState() => _CaixaState();
}

class _CaixaState extends State<ga_tempo> with SingleTickerProviderStateMixin {
  List<dynamic> registros = [];
  bool isLoading = true;
  bool hasError = false;
  String nomecoordenador = '';
  String nomeDoUsuario = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 650), // Duração de meio segundo
    );

    _animationController.repeat(reverse: true);
    carregarNomeDoUsuario();
    carregarRegistros();
    carregaracesso();
  }

  @override
  void dispose() {
    _animationController
        .dispose(); // Não esqueça de liberar o controller quando não for mais necessário
    super.dispose();
  }

  Future<void> carregaracesso() async {
    var url = Uri.parse(
        'https://sistema32.cloud/move/Api/VPS/RH/adm.php?id=${widget.loggedInUser}');
        // https://sistema32.cloud/move/Api/RH/adm.php?id=${widget.loggedInUser}');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        setState(() {
          nomeDoUsuario = userData['acesso'];
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

  Future<void> carregarNomeDoUsuario() async {
    var url = Uri.parse(
        'https://sistema32.cloud/move/Api/VPS/RH/puxanome.php?id=${widget.loggedInUser}');
        // 'https://sistema32.cloud/move/Api/RH/puxanome.php?id=${widget.loggedInUser}');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        setState(() {
          nomecoordenador = userData['nome_gestor'];
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
    if (nomecoordenador != null) {
      var url = Uri.parse(
          'https://sistema32.cloud/move/Api/VPS/RH/gestao/tempo_ba.php?user=${widget.loggedInUser}&$nomecoordenador');
          // 'https://sistema32.cloud/move/Api/FTTH/gestao/tempo_ba.php?user=${widget.loggedInUser}&$nomecoordenador');
      try {
        var response = await http.get(url);

        nomecoordenador;
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
  }

  void abrirPixaCaixa(String ba) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IdentidadeBaForm(
          ba: ba,
          loggedInUser: widget.loggedInUser,
        ),
      ),
    );
  }

  String calcularTempoDeVida(Map<String, dynamic> registro) {
    if (registro['status'] == 'EM ANDAMENTO') {
      // Verifique se 'data_atribuicao' é nulo antes de calcular a diferença de tempo
      if (registro['data_atribuicao'] != null) {
        DateTime dataAtribuicao = DateTime.parse(registro['data_atribuicao']);
        DateTime agora = DateTime.now();
        Duration diferenca = agora.difference(dataAtribuicao);

        // Formate o tempo de vida
        int horas = diferenca.inHours;
        int minutos = diferenca.inMinutes % 60;

        return '$horas h $minutos m';
      } else {
        return '0'; // Retorna "0" se 'data_atribuicao' for nulo
      }
    } else {
      // Verifique se registro['tempo_de_vida'] é nulo antes de usar o operador ??
      return registro['tempo_de_vida'] != null ? registro['tempo_de_vida'] : '';
    }
  }

  Color definirCorComBaseNoTempoDeVida(String tempoDeVida) {
    // Dividir o tempo de vida para obter as horas e minutos
    List<String> partes = tempoDeVida.split(' ');
    int horas = int.tryParse(partes[0]) ?? 0;
    int minutos = partes.length > 2 ? int.tryParse(partes[2]) ?? 0 : 0;

    // Defina as cores com base nas condições
    if (horas <= 1 && horas <= 2) {
      return Color.fromARGB(255, 113, 198, 3); // Verde
    } else if (horas <= 2 && horas <= 3) {
      return Color.fromARGB(255, 255, 196, 0); // Laranja
    } else if (horas >= 4) {
      return Color.fromARGB(255, 241, 10, 10); // Vermelho
    } else {
      return Color.fromARGB(255, 113, 198, 3); // Verde
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controle de tempo'),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Coloque aqui a lógica para recarregar os registros
              carregarRegistros();
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return ListView(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('BA')),
                    DataColumn(label: Text('TEMPO DE VIDA')),
                    DataColumn(label: Text('NOME DO TEC')),
                    DataColumn(label: Text('PRIORIDADE')),
                    DataColumn(label: Text('COORDENADOR')),
                    DataColumn(label: Text('STATUS')),
                  ],
                  rows: registros.map((registro) {
                    String tempoDeVida = calcularTempoDeVida(registro);
                    Color cor = definirCorComBaseNoTempoDeVida(tempoDeVida);

                    // Use a opacidade baseada na animação
                    double opacity = _animationController.value;

                    return DataRow(cells: [
                      DataCell(
                        InkWell(
                          onTap: () {
                            abrirPixaCaixa(registro['ba'] ?? '');
                          },
                          child: Row(
                            children: [
                              Text(
                                registro['ba'] ?? '',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: cor, // Aplica a cor normalmente
                                ),
                              ),
                              SizedBox(width: 20),
                              Icon(
                                Icons.circle,
                                size: 30,
                                color: cor == Colors.green
                                    ? cor // Cor verde fica constante
                                    : cor == Color.fromARGB(255, 255, 196, 0) ||
                                            cor ==
                                                Color.fromARGB(255, 241, 10, 10)
                                        ? cor.withOpacity(
                                            opacity) // Aplica a opacidade apenas a laranja e vermelha
                                        : cor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(Text(tempoDeVida)),
                      DataCell(Text(registro['nome'] ?? '')),
                      DataCell(Text(registro['tipo'] ?? '')),
                      DataCell(Text(registro['nome_gestor'] ?? '')),
                      DataCell(Text(registro['status'] ?? '')),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
