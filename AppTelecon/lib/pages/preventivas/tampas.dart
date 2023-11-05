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
  final String cacheKey = 'formularioCache';
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _checkAndSendCachedData();
  }

  Future<void> _checkAndSendCachedData() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await _sendCachedData();
    }
  }

  Future<void> _sendCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cachedData = prefs.getStringList(cacheKey);
    if (cachedData != null && cachedData.isNotEmpty) {
      for (String data in cachedData) {
        List<String> parts = data.split('|'); // Separar nome e tipo
        if (parts.length == 2) {
          String nome = parts[0];
          String tipo = parts[1];
          await _sendToAPI(nome, tipo);
        }
      }
      // Dados enviados com sucesso, limpar o cache
      await _clearCache();
    }
  }

  void _enviarFormulario() async {
    String nome = _nomeController.text;

    // Verificar a conectividade antes de enviar para a API
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Sem conexão, armazenar em cache
      await _storeInCache(nome, _selectedType);
      _showDialog('Aviso', 'Dados armazenados em cache.');
    } else {
      // Com conexão, enviar para a API
      await _sendToAPI(nome, _selectedType);
    }
  }

  Future<void> _storeInCache(String nome, String? tipo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cachedData = prefs.getStringList(cacheKey);
    if (cachedData == null) {
      cachedData = [];
    }
    String data = '$nome|$tipo';
    cachedData.add(data);
    await prefs.setStringList(cacheKey, cachedData);
  }

  Future<void> _sendToAPI(String nome, String? tipo) async {
    // Replace 'URL_TO_PHP_SCRIPT' with the URL to your PHP script on the server.
    String url = 'https://sistema32.cloud/move/Api/preventivas/tampas.php';

    try {
      // Send the data to the PHP script using the POST method.
      await http.post(
        Uri.parse(url),
        body: {'nome': nome, 'tipo': tipo},
      );
      // Data sent successfully, clear the cache
      await _clearCache();
      _showDialog('Success', 'Data sent successfully!');
    } catch (e) {
      // If there's an error, show an error message.
      _showDialog('Error', 'An error occurred while sending the data.');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário Flutter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              items: ['xx', 'yy'].map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Tipo'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _enviarFormulario,
              child: Text('Enviar'),
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
