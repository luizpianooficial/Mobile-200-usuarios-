import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:moove/pages/ftth/puxacaixa.dart';

class ga_tempos extends StatefulWidget {
  final String loggedInUser;

  const ga_tempos({Key? key, required this.loggedInUser});

  @override
  State<ga_tempos> createState() => _CaixaState();
}

class _CaixaState extends State<ga_tempos> with SingleTickerProviderStateMixin {
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
        'API');
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
        'API');
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
          'API');
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

  Color definirCorComBaseNoTempoDeVidaEHorario(Map<String, dynamic> registro) {
    if (registro['status'] == 'DESPTEC') {
      // Verifique se 'data_atribuicao' é nulo
      if (registro['data_atribuicao'] == null) {
        DateTime agora = DateTime.now();
        DateTime horaLimiteAmarela =
            DateTime(agora.year, agora.month, agora.day, 8, 15);
        DateTime horaLimiteVermelha =
            DateTime(agora.year, agora.month, agora.day, 8, 30);

        if (agora.isAfter(horaLimiteVermelha) ||
            agora.isAtSameMomentAs(horaLimiteVermelha)) {
          // Horário igual ou após 08:30, retorne cor vermelha
          return Colors.red;
        } else if (agora.isAfter(horaLimiteAmarela) ||
            agora.isAtSameMomentAs(horaLimiteAmarela)) {
          // Horário igual ou após 08:15, retorne cor amarela
          return Colors.yellow;
        }
      } else {
        DateTime agora = DateTime.now();
        DateTime horaLimiteVermelha =
            DateTime(agora.year, agora.month, agora.day, 8, 30);

        if (agora.isAfter(horaLimiteVermelha) ||
            agora.isAtSameMomentAs(horaLimiteVermelha)) {
          // Horário igual ou após 08:30, retorne cor vermelha
          return Colors.red;
        }
      }
    }

    return Colors.green; // Cor padrão para outros casos
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
                    // DataColumn(label: Text('TEMPO DE VIDA')),
                    DataColumn(label: Text('NOME DO TEC')),
                    DataColumn(label: Text('PRIORIDADE')),
                    DataColumn(label: Text('COORDENADOR')),
                    DataColumn(label: Text('STATUS')),
                  ],
                  rows: registros.map((registro) {
                    String tempoDeVida = calcularTempoDeVida(registro);
                    Color cor =
                        definirCorComBaseNoTempoDeVidaEHorario(registro);

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
                                color: cor.withOpacity(opacity),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // DataCell(Text(tempoDeVida)),
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
