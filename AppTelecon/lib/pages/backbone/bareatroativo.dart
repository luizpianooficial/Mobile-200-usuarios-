import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(BaRetro());
}

class BaRetro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BA Search',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _baController = TextEditingController();
  Map<String, dynamic> _baData = {};
  bool _baNotFound =
      false; // Variável para controlar se o BA não foi encontrado
  bool _loading = false; // Variável para controlar o estado de carregamento

  Future<void> fetchData(String ba) async {
    setState(() {
      _loading = true; // Define como verdadeiro durante o carregamento
      _baNotFound = false; // Reseta a variável _baNotFound
    });

    try {
      final response = await http.get(
        Uri.parse(
            API'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('ba')) {
          // Verifica se o BA foi encontrado na resposta da API
          setState(() {
            _baData = data;
          });
        } else {
          // BA não encontrado
          setState(() {
            _baData.clear(); // Limpa os dados anteriores
            _baNotFound =
                true; // Define como verdadeiro para indicar que o BA não foi encontrado
          });
        }
      } else {
        // Trate erros de solicitação HTTP aqui
        print('Erro na solicitação HTTP');
        _showErrorDialog();
      }
    } catch (error) {
      print('Erro na solicitação: $error');
      _showErrorDialog();
    } finally {
      setState(() {
        _loading = false; // Define como falso após o carregamento
      });
    }
  }

  // Função para mostrar um diálogo de erro
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('⚠️ BA NÃO ENCONTRADO ⚠️'),
          content: Text('Verifique o número do BA e digite novamente. '),
          actions: [
            TextButton(
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

  // Função para copiar os dados do BA
  void copyDataToClipboard() {
    String baData = '';

    if (!_baNotFound) {
      // Mostrar apenas os campos desejados se o BA foi encontrado
      baData += 'BA: ${_baData['ba']}\n';
      baData += 'Endereço: ${_baData['endereco']}\n';
      baData += 'Estação: ${_baData['estacao']}\n';
      baData += 'Tipo: ${_baData['tipo']}\n';
      baData += 'Data DESPTEC: ${_baData['data_desptec']}\n';
      baData += 'Data Atribuição: ${_baData['data_atribuicao']}\n';
      baData += 'Data Encerramento: ${_baData['data_encerramento']}\n';
      baData += 'Data Abertura: ${_baData['data_abertura']}\n';
      baData += 'Data Vencimento: ${_baData['data_vencimento']}\n';
      baData += 'Data Despacho: ${_baData['data_despacho']}\n';
      baData += 'Data Validação: ${_baData['data_validacao']}\n';
      baData += 'RE TEC: ${_baData['id_usu']}\n';
      baData += 'Status: ${_baData['status']}\n';
      baData += 'Obs_cl: ${_baData['obs_cl']}\n';
      baData += 'Causa: ${_baData['causa']}\n';
      baData += 'Subcausa: ${_baData['sub']}';
    }

    Clipboard.setData(ClipboardData(text: baData));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dados copiados para a área de transferência.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
return Scaffold(
      appBar: AppBar(
        title: Text('Pesquisa BA', 
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          )),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _baController,
                decoration: InputDecoration(labelText: 'Digite o BA'),
              ),
              ElevatedButton(
                onPressed: () {
                  final ba = _baController.text;
                  fetchData(ba);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromRGBO(13, 71, 161, 1),
                  ),
                ),
                child: Text('Pesquisar',
                style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),),
              ),
              if (_loading)
                CircularProgressIndicator(), // Mostrar um indicador de carregamento
              if (_baNotFound)
                Text(
                  'BA não encontrado.',
                  style: TextStyle(
                    color: Colors.red, // Cor vermelha para a mensagem de erro
                  ),
                ),
              if (_baData.isNotEmpty && !_baNotFound)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Text('Resultado da Pesquisa:'),
                    SizedBox(height: 12),
                    // Exibe apenas os campos desejados
                    Text('BA: ${_baData['ba']}'),
                    Text('Endereço: ${_baData['endereco']}'),
                    Text('Estação: ${_baData['estacao']}'),
                    Text('Tipo: ${_baData['tipo']}'),
                    Text('Data DESPTEC: ${_baData['data_desptec']}'),
                    Text('Data Atribuição: ${_baData['data_atribuicao']}'),
                    Text('Data Encerramento: ${_baData['data_encerramento']}'),
                    Text('Data Abertura: ${_baData['data_abertura']}'),
                    Text('Data Vencimento: ${_baData['data_vencimento']}'),
                    Text('Data Despacho: ${_baData['data_despacho']}'),
                    Text('Data Validação: ${_baData['data_validacao']}'),
                    Text('RE TEC: ${_baData['id_usu']}'),
                    Text('Status: ${_baData['status']}'),
                    Text('Obs_cl: ${_baData['obs_cl']}'),
                    Text('Causa: ${_baData['causa']}'),
                    Text('Subcausa: ${_baData['sub']}'),
                    SizedBox(height: 12),
                    // Botão para copiar os dados
                    ElevatedButton(
                      onPressed: copyDataToClipboard,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromRGBO(13, 71, 161, 1)),
                      ),
                      child: Text('Copiar Dados'),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
