import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormularioPage extends StatefulWidget {
  @override
  _FormularioPageState createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _ruaController = TextEditingController();
  final TextEditingController _tampaController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final String cacheKey = 'formularioCache';
  // String _selectedType = '';

  @override
  void initState() {
    super.initState();
    _sendCachedData(); // Call this method to send cached data to the API when the page is loaded.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sendToAPIFromCache(); // Call this method to send any data that was cached during the time when the page was not visible.
  }

  Future<void> _sendCachedData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await _sendToAPIFromCache();
    }
  }

  Future<void> _sendToAPIFromCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cachedData = prefs.getStringList(cacheKey);
    if (cachedData != null && cachedData.isNotEmpty) {
      for (String data in cachedData) {
        List<String> parts = data.split('|');
        if (parts.length == 5) {
          // Change the condition to 4
          String nome = parts[0];
          String tipo = parts[1];
          String bairro = parts[2];
          String rua = parts[3];
          String quantidade = parts[4];
          await _sendToAPI(nome, tipo, bairro, rua, quantidade);
        }
      }
      await _clearCache(); // Clear the cache after sending the data to the API.
    }
  }

  void _enviarFormulario() async {
    String nome = _nomeController.text;
    String bairro = _bairroController.text;
    String rua = _ruaController.text;
    String tipo = _tampaController.text;
    String quantidade = _quantidadeController.text;

    // Verificar a conectividade antes de enviar para a API
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Sem conexão, armazenar em cache
      await _storeInCache(nome, tipo, bairro, rua, quantidade);
      _showDialog('Aviso', 'Dados armazenados em cache.');
    } else {
      // Com conexão, enviar para a API
      await _sendToAPI(nome, tipo, bairro, rua, quantidade);
    }
  }

  Future<void> _storeInCache(String nome, String? tipo, String? bairro,
      String? rua, String quantidade) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cachedData = prefs.getStringList(cacheKey);
    if (cachedData == null) {
      cachedData = [];
    }
    String data = '$nome|$tipo|$bairro|$rua|$quantidade';
    cachedData.add(data);
    await prefs.setStringList(cacheKey, cachedData);
  }

  Future<void> _sendToAPI(String nome, String tipo, String bairro, String rua,
      String quantidade) async {
    String url = 'API';

    try {
      // Send the data to the API using the POST method.
      await http.post(
        Uri.parse(url),
        body: {
          'nome': nome,
          'tipo': tipo,
          'bairro': bairro,
          'rua': rua,
          'quantidade': quantidade
        },
      );
      // Data sent successfully, clear the cache
      await _clearCache();
      _showDialog('Sucesso', 'Dados enviados com sucesso!');
    } catch (e) {
      // If there's an error, show an error message.
      _showDialog('Erro', 'Ocorreu um erro ao enviar os dados.');
    }
  }

  Future<void> _clearCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(cacheKey);
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Ok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Your widget tree goes here
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de tampas'),
        backgroundColor: Color(0xFF335486),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _tampaController,
              decoration: InputDecoration(labelText: 'Tipo da tampa'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bairroController,
              decoration: InputDecoration(labelText: 'bairro'),
            ),
            TextField(
              controller: _ruaController,
              decoration: InputDecoration(labelText: 'rua'),
            ),
            TextField(
              controller: _quantidadeController,
              decoration: InputDecoration(labelText: 'quantiadade'),
            ),
            ElevatedButton(
              onPressed: _enviarFormulario,
              child: Text('Enviar'),
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFF335486),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FormularioPage(),
  ));
}
