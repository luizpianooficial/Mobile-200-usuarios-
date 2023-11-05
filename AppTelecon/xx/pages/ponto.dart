import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeuFormulario extends StatefulWidget {
  @override
  _MeuFormularioState createState() => _MeuFormularioState();
}

class _MeuFormularioState extends State<MeuFormulario> {
  TextEditingController entradaController = TextEditingController();
  TextEditingController saidaController = TextEditingController();
  DateFormat dateFormat = DateFormat('HH:mm');

  void calcularInterjornada() {
    DateTime entradaPadrao = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 0);
    DateTime saida = dateFormat.parse(saidaController.text);

    Duration jornadaTrabalho = Duration(hours: 8);
    Duration horasExtrasPermitidas = Duration(hours: 2);
    Duration descansoMinimo = Duration(hours: 11);

    DateTime proximaBatida;

    DateTime horarioSaidaCalculado =
        saida.add(Duration(hours: -1, minutes: -12));
    Duration horasTrabalhadas = horarioSaidaCalculado.difference(entradaPadrao);

    if (horasTrabalhadas > Duration(hours: 10)) {
      proximaBatida = horarioSaidaCalculado.add(descansoMinimo);
    } else {
      proximaBatida = entradaPadrao.add(jornadaTrabalho);
    }

    proximaBatida =
        proximaBatida.add(Duration(minutes: 5)); // Adicionar 5 minutos

    String proximaBatidaFormatada = dateFormat.format(proximaBatida);

    // Exibe os resultados
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resultado'),
          content: Text('Próxima batida: $proximaBatidaFormatada'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ponto'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: entradaController,
              decoration: InputDecoration(labelText: 'Horário de Entrada'),
            ),
            TextField(
              controller: saidaController,
              decoration: InputDecoration(labelText: 'Horário de Saída'),
            ),
            ElevatedButton(
              onPressed: calcularInterjornada,
              child: Text('Calcular'),
            ),
          ],
        ),
      ),
    );
  }
}
