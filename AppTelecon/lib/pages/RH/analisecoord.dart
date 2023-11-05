import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class analisecoord extends StatefulWidget {
  final String loggedInUser;

  const analisecoord({Key? key, required this.loggedInUser});

  @override
  _IdentidadeBaFormState createState() => _IdentidadeBaFormState();
}

class _IdentidadeBaFormState extends State<analisecoord> {
  Map<String, dynamic> baData = {
    'latitude': 0.0,
    'longitude': 0.0,
  };
  bool isLoading = true;
  bool _envioEmProgresso = false;
  final List<String> _motivo = ['AFASTADO', 'ACIDENTE', 'ATESTADO','ESQUECIMENTO','FOLGA','FALHA NO APP','INTERJORNADA','SEM APARELHO CELULAR','CELUALR DANIFICADO'];// Declare a variável selectedOption aqui

  // Adicione um TextEditingController para o campo "obs"
  TextEditingController obsController = TextEditingController();

  // Adicione dois campos para armazenar os caminhos dos arquivos das fotos
  String? foto1Path;
  String? foto2Path;
  String? _motivoo;

  @override
  void initState() {
    super.initState();
    carregarBaData();
  }

  Future<void> carregarBaData() async {
    var url = Uri.parse(
        'https://sistema32.cloud/move/Api/VPS/PONTO/justificativacoord.php?id_coordenador=${widget.loggedInUser}');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        baData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      // Exibir mensagem de erro ou tomar uma ação apropriada
    }
  }

  Future<void> justificar() async {
  // String obs = obsController.text;

  // Construa a URL para enviar os dados e as imagens
  var updateUrl =
      Uri.parse('https://sistema32.cloud/move/Api/VPS/PONTO/analisecoord.php');

  var request = http.MultipartRequest('POST', updateUrl);

  // Adicione os campos de texto
  request.fields['id_coordenador'] = widget.loggedInUser;
  
  if (_motivoo != null) {
    request.fields['justificativa'] = _motivoo!;
  } else {
   print("oi");
  }

  // Adicione a opção selecionada

  var response = await request.send();

  if (response.statusCode == 200) {
    print('Dados e imagens enviados com sucesso.');
  } else {
    print('Erro ao enviar dados e imagens: ${response.reasonPhrase}');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analise Coordenador',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: baData['matricula'],
                      decoration: InputDecoration(labelText: 'RE'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['nome'],
                      decoration: InputDecoration(labelText: 'NOME'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['data_curta'],
                      decoration: InputDecoration(labelText: 'DATA_OCORRIDO'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['status_batida'],
                      decoration: InputDecoration(labelText: 'MOTIVO'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['status_batida_2'],
                      decoration: InputDecoration(labelText: 'SUB-MOTIVO'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['obs'],
                      decoration: InputDecoration(labelText: 'JUSTIFICATIVA TEC'),
                      enabled: false,
                    ),
                   DropdownButtonFormField<String>(
  value: _motivoo,
  decoration: const InputDecoration(labelText: 'Motivo'),
  items: _motivo.map((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList(),
  onChanged: (String? newValue) {
    setState(() {
      _motivoo = newValue;
    });
  },
  validator: (value) {
    if (value == null) {
      return 'Por favor, selecione o tipo de rede';
    }
    return null;
  },
),

                     // Defina um valor inicial válido

// ...



                    // TextFormField(
                    //   controller: obsController,
                    //   decoration: InputDecoration(labelText: 'JUSTIFICATIVA'),
                    // )
                    SizedBox(height: 15),
                    ElevatedButton(
  onPressed: () async {
    await justificar();
    // Navegue de volta duas páginas
    Navigator.pop(context);
    Navigator.pop(context);
  },
  style: ElevatedButton.styleFrom(
    primary: Color.fromRGBO(13, 71, 161, 1),
    minimumSize: Size(double.infinity, 50), // Defina a altura desejada
  ),
  child: _envioEmProgresso
      ? CircularProgressIndicator()
      : Text(
          'Justificar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18, // Tamanho da fonte
          ),
        ),
)

                  ],
                ),
              ),
            ),
    );
  }
}
