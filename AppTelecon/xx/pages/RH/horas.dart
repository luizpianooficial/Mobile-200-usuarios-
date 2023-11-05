import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// void main() => runApp(MaterialApp(home: HoraExtraForm()));

class HoraExtraForm extends StatefulWidget {
  final String loggedInUser;

  HoraExtraForm({
    Key? key,
    required this.loggedInUser,
  }) : super(key: key);

  @override
  _HoraExtraFormState createState() => _HoraExtraFormState();
}

class _HoraExtraFormState extends State<HoraExtraForm> {
  String? selectedMotivo;
  String descricao = '';
  bool? status;
  TimeOfDay selectedTime = TimeOfDay(hour: 0, minute: 0); // Hora inicial 00:00
  String? numeroCDOE;
  String? numeroBA;
  String nomeDoUsuario = '';
  String nomegestor = '';
  String nomecoordenador = '';
  List<dynamic> registros = [];
  bool isLoading = true;
  bool hasError = false;
  int selectedMinutes = 0;

  @override
  void initState() {
    super.initState();
    carregarNomeDoUsuario();
    // carregargestor();
  }

  Future<void> carregarNomeDoUsuario() async {
    var url = Uri.parse(
        'https://sistema32.cloud/move/Api/RH/puxanome.php?id=${widget.loggedInUser}');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        setState(() {
          nomeDoUsuario = userData['nome'];
          nomegestor = userData['id_gestor'];
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _cadastrarHoraExtra() async {
    if (selectedMotivo != null) {
      final url = 'https://sistema32.cloud/move/Api/RH/hora.php';

      final response = await http.post(
        Uri.parse(url),
        body: {
          'motivo': selectedMotivo!,
          'descricao': descricao,
          'tempo_extra': '${selectedTime.hour}:${selectedTime.minute}',
          'numero_cdoe': numeroCDOE ?? '',
          'numero_ba': numeroBA ?? '',
          'nome': nomeDoUsuario,
          'id_gestor': nomegestor,
          'id_usu': widget.loggedInUser,
          'nome_gestor': nomecoordenador,
        },
      );

      print('Resposta da API: ${response.body}');

      if (response.statusCode == 200) {
        print('Solicitação de hora extra cadastrada com sucesso. ');
        print('Nome do Usuário: $nomegestor');

        setState(() {
          selectedMotivo = null;
          descricao = '';
          numeroCDOE = null;
          numeroBA = null;
        });
      } else {
        print(
            'Erro ao cadastrar solicitação de hora extra. Status: ${response.statusCode}, Resposta: ${response.body}');
      }
    } else {
      print('Por favor, selecione um motivo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitar Hora Extra $nomecoordenador'),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedMotivo,
              onChanged: (value) {
                setState(() {
                  selectedMotivo = value;
                  numeroCDOE = null;
                  numeroBA = null;
                });
              },
              items: ['BA 7048', 'BA 97', 'BA 89', 'SOLICITAÇÃO DE PRIORIDADE']
                  .map((motivo) => DropdownMenuItem<String>(
                        value: motivo,
                        child: Text(motivo),
                      ))
                  .toList(),
              decoration: InputDecoration(labelText: 'Motivo'),
            ),
            if (selectedMotivo == 'BA 7048' ||
                selectedMotivo == 'SOLICITAÇÃO DE PRIORIDADE')
              TextFormField(
                decoration: InputDecoration(labelText: 'Número da CDOE'),
                onChanged: (value) {
                  setState(() {
                    numeroCDOE = value;
                  });
                },
              ),
            if (selectedMotivo == 'BA 97' || selectedMotivo == 'BA 89')
              TextFormField(
                decoration: InputDecoration(labelText: 'Número do BA'),
                onChanged: (value) {
                  setState(() {
                    numeroBA = value;
                  });
                },
              ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Descrição'),
              onChanged: (value) {
                setState(() {
                  descricao = value;
                });
              },
            ),
            Row(
              children: [
                Text(
                  ' Quantas horas precisa? 👉 ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _selectTime(context);
                  },
                  child: Text(
                    '${selectedTime.hour}:${selectedTime.minute}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Defina a cor desejada para o texto
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(
                        13, 71, 161, 1), // Defina a cor de fundo desejada
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedMinutes += 30;
                      if (selectedMinutes >= 60 * 24) {
                        selectedMinutes = 0;
                      }
                      selectedTime = TimeOfDay(
                        hour: selectedMinutes ~/ 60,
                        minute: selectedMinutes % 60,
                      );
                    });
                  },
                  icon: Icon(Icons.add),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedMinutes -= 30;
                      if (selectedMinutes < 0) {
                        selectedMinutes = 60 * 24 - 30;
                      }
                      selectedTime = TimeOfDay(
                        hour: selectedMinutes ~/ 60,
                        minute: selectedMinutes % 60,
                      );
                    });
                  },
                  icon: Icon(Icons.remove),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _cadastrarHoraExtra,
              child: Text(
                'Solicitar',
              ),
              style: ElevatedButton.styleFrom(
                primary: const Color.fromRGBO(13, 71, 161, 1),
                onPrimary: Color.fromARGB(255, 246, 240, 240),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: HoraExtraForm(loggedInUser: 'x')));
