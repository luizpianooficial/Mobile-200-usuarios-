import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class analisetec extends StatefulWidget {
  final String loggedInUser;

  const analisetec({Key? key, required this.loggedInUser});

  @override
  _IdentidadeBaFormState createState() => _IdentidadeBaFormState();
}

class _IdentidadeBaFormState extends State<analisetec> {
  Map<String, dynamic> baData = {
    'latitude': 0.0,
    'longitude': 0.0,
  };
  bool isLoading = true;
  bool aceite = false;
  bool _envioEmProgresso = false;
  List<bool> checkBoxValues1 = [false, false, false];
  List<bool> checkBoxValues2 = [false, false, false];
  List<bool> checkBoxValues3 = [false, false, false, false, false];
  String? selectedOption1;
  String? selectedOption3;

  // Adicione um TextEditingController para o campo "obs"
  TextEditingController obsController = TextEditingController();

  // Adicione dois campos para armazenar os caminhos dos arquivos das fotos
  String? foto1Path;
  String? foto2Path;

  @override
  void initState() {
    super.initState();
    carregarBaData();
  }

  Future<void> carregarBaData() async {
    var url = Uri.parse(
        'https://sistema32.cloud/move/Api/VPS/PONTO/justificativa.php?matricula=${widget.loggedInUser}');
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
  String obs = obsController.text;

  // Construa a URL para enviar os dados e as imagens
  var updateUrl = Uri.parse(
      'https://sistema32.cloud/move/Api/VPS/PONTO/tec.php');

  var request = http.MultipartRequest('POST', updateUrl);

  // Adicione os campos de texto
  request.fields['matricula'] = widget.loggedInUser;
  request.fields['obs'] = obs;

  // Adicione as imagens
  if (foto1Path != null) {
    var foto1File = await http.MultipartFile.fromPath(
      'foto1',
      foto1Path!,
      contentType: MediaType('image', 'jpg'),
    );
    request.files.add(foto1File);
  }

  if (foto2Path != null) {
    var foto2File = await http.MultipartFile.fromPath(
      'foto2',
      foto2Path!,
      contentType: MediaType('image', 'jpg'),
    );
    request.files.add(foto2File);
  }

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
          'Detalhe ponto ',
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
                      controller: obsController,
                      decoration: InputDecoration(labelText: 'JUSTIFICATIVA'),
                    ),
                    // Adicione campos para anexar fotos
                    Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Ajuste o alinhamento conforme necessário
  children: [
    ElevatedButton(
      onPressed: () async {
        final picker = ImagePicker();
        final pickedFile = await picker.getImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          setState(() {
            foto1Path = pickedFile.path;
          });
        }
      },
      child: Text('Evidência 1'),
    ),
    ElevatedButton(
      onPressed: () async {
        final picker = ImagePicker();
        final pickedFile = await picker.getImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          setState(() {
            foto2Path = pickedFile.path;
          });
        }
      },
      child: Text('Evidência 2'),
    ),
    ElevatedButton(
      onPressed: () async {
        await justificar();
        Navigator.pop(context);
        Navigator.pop(context);
      },
      child: _envioEmProgresso
          ? CircularProgressIndicator()
          : Text('Justificar'),
    ),
  ],
)


                  ],
                ),
              ),
            ),
    );
  }
}