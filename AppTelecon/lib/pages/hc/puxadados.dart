import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class IdentidadeBaFormhc extends StatefulWidget {
  final String sa;
  final String loggedInUser;

  const IdentidadeBaFormhc({
    Key? key,
    required this.sa,
    required this.loggedInUser,
  });

  @override
  _IdentidadeBaFormState createState() => _IdentidadeBaFormState();
}

class _IdentidadeBaFormState extends State<IdentidadeBaFormhc> {
  Map<String, dynamic> baData = {
    'latitude': 0.0,
    'longitude': 0.0,
  };
  bool isLoading = true;
  bool aceite = false;
  TextEditingController obsController = TextEditingController();
  String? selectedOption1;
  String? selectedOption3;
  List<File?> images = []; // List to store the picked images

  @override
  void initState() {
    super.initState();
    // Initialize the images list with null values
    images = List.generate(3, (_) => null);
    carregarBaData();
  }

  Future<void> carregarBaData() async {
    var url = Uri.parse(
        'https://sistema32.cloud/move/Api/VPS/HC/puxacaixa.php?sa=${widget.sa}');
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

  Future<void> pegarPosicao() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print('Permissão de localização não concedida.');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    double latitude = position.latitude;
    double longitude = position.longitude;
    print('Latitude: $latitude');
    print('Longitude: $longitude');

    if (mounted) {
      setState(() {
        baData['latitude'] = latitude.toString();
        baData['longitude'] = longitude.toString();
      });
    }
  }

  // Function to save the "obs_tec" value to the database
  Future<void> salvarObservacaoTecnico() async {
    String obsTec = obsController.text;

    Map<String, dynamic> dadosObservacao = {
      'sa': widget.sa,
      'obs_tec': obsTec,
    };

    var url = Uri.parse('https://sistema32.cloud/move/Api/VPS/RH/updatehv.php');

    try {
      var response = await http.post(
        url,
        body: dadosObservacao,
      );

      if (response.statusCode == 200) {
        print('Observação técnico saved successfully!');
      } else {
        print('Error saving observation: ${response.statusCode}');
      }
    } catch (error) {
      print('An error occurred while saving the observation: $error');
    }
  }

  Future<void> enviarDadosViaAPI(String obsTec, String idUsu) async {
    Map<String, dynamic> dadosParaEnviar = {
      'obs_tec': obsTec,
      'id_usu': idUsu,
    };

    var url = Uri.parse('https://sistema32.cloud/move/Api/VPS/HC/update.php');

    try {
      var response = await http.post(
        url,
        body: dadosParaEnviar,
      );

      if (response.statusCode == 200) {
        print('Data sent successfully!');
      } else {
        print('Error sending data: ${response.statusCode}');
      }
    } catch (error) {
      print('An error occurred while sending the data: $error');
    }
  }

  Future<void> sendMessageToTelegram(String message) async {
    final String botToken = '6433723961:AAEhEN9RAKGI0yPqdTyT7-rUs2RTxAMrTnI';
    final String chatId = '-1001613780681'; // The chat ID of your group

    final String apiUrl = 'https://api.telegram.org/bot$botToken/sendMessage';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> data = {
      'chat_id': chatId,
      'text': message,
    };

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Message sent successfully!');
      } else {
        print('Error sending message: ${response.statusCode}');
      }
    } catch (error) {
      print('An error occurred while sending the message: $error');
    }
  }

  Future<void> pickImage(int index) async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        images[index] = File(pickedImage.path);
      });
    }
  }

  Future<void> sendImagesToServer() async {
    String url = 'https://sistema32.cloud/move/Api/VPS/HC/foto.php';

    // Crie um objeto FormData para enviar as imagens como formulário multipart
    var formData = http.MultipartRequest('POST', Uri.parse(url));

    // Adicione a imagem "foto_antes" ao formulário multipart
    if (images[0] != null) {
      formData.files.add(
        await http.MultipartFile.fromPath('foto_antes', images[0]!.path),
      );
    }

    // Adicione a imagem "foto_depois" ao formulário multipart
    if (images[1] != null) {
      formData.files.add(
        await http.MultipartFile.fromPath('foto_depois', images[1]!.path),
      );
    }

    // Adicione a terceira imagem ao formulário multipart
    if (images[2] != null) {
      formData.files.add(
        await http.MultipartFile.fromPath('terceira_imagem', images[2]!.path),
      );
    }

    // Adicione outros campos necessários ao formulário
    formData.fields.addAll({
      'sa': widget.sa,
      // Adicione outros campos conforme necessário
    });

    try {
      var response = await formData.send();

      if (response.statusCode == 200) {
        print('Imagens enviadas com sucesso!');
        // Opcionalmente, você pode lidar com a resposta do servidor aqui
        // (por exemplo, obter as URLs das imagens retornadas pelo servidor).
      } else {
        print('Erro ao enviar as imagens: ${response.statusCode}');
      }
    } catch (error) {
      print('Ocorreu um erro ao enviar as imagens: $error');
    }
  }

 void _concluirAcao() async {
  // Check if all three images have been selected
  if (images[0] == null || images[1] == null || images[2] == null) {
    // Show an alert asking the user to attach all three photos
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Fotos Obrigatórias'),
          content: Text('Por favor, anexe as três fotos obrigatórias antes de concluir.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the alert
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  } 
  else {
    // Get the current date
    String currentDate = DateTime.now().toString();

    // Update the obs field and set the date and status fields
    setState(() {
      baData['obs_tec'] = obsController.text;
      baData['data_execucao'] = currentDate;
      baData['status'] = 'EM ANDAMENTO';
    });

    // Save the "obs_tec" value to the database
    await salvarObservacaoTecnico();

    // Call the function to update the data in the database

    // Send the "obs_tec" and "id_usu" values via API
    await enviarDadosViaAPI(baData['obs_tec'], baData['id_usu']);

    // Show the confirmation dialog
    _mostrarMensagemAceitacao(context);

    await sendImagesToServer();
  }
}



  void _enviarParaGrupo() async {
    // Send the form data to the Telegram group

    String message = '''
      ⚠️ ATENÇÃO - ${baData['coordenador']}, SEU TÉCNICO COM RE: 🪖 ${baData['id_usu']},

    🚙 - ESTÁ INDO RESOLVER O REPARANO NO ENDEREÇO: 
    🛣️ - ${baData['endereco']},

    🚨 - ${baData['sa']} 🚨 está com o STATUS 🚨 ${baData['status']} - 🚨,

    🛠️ - A DATA DE EXECUÇÃO FOI DIA: ${baData['data_execucao']} - 🛠️

    📡 - COMPANHIA: ${baData['companhia']}  📡

    🪖 - ÚLTIMO TÉCNICO A EXECUTA ESSE TRABALHO FOI O: ${baData['tecnico']} - 🪖 E O 

    ❤️ - CLIENTE RESPONSÁVEL É(O): ${baData['cliente']} - ❤️
    ''';

    sendMessageToTelegram(message);
    _mostrarMensagemAceitacao(context);
  }

  void _mostrarMensagemAceitacao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Missão Aceitada'),
          content: Text('Obrigado'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context);
                Navigator.pop(context); // Navigate back to HomeScreen
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
        title: Text(
          'Identidade SA',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1),
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
                      initialValue: baData['sa'],
                      decoration: InputDecoration(labelText: 'Sa'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['coordenador'],
                      decoration: InputDecoration(labelText: 'Coordeador'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['status'],
                      decoration: InputDecoration(labelText: 'Status'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['uf'],
                      decoration: InputDecoration(labelText: 'UF'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['data_execucao'],
                      decoration: InputDecoration(labelText: 'data_execucao'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['companhia'],
                      decoration: InputDecoration(labelText: 'companhia'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['tecnico'],
                      decoration: InputDecoration(labelText: 'tecnico'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['macro'],
                      decoration: InputDecoration(labelText: 'macro'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['cliente'],
                      decoration: InputDecoration(labelText: 'cliente'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['id_usu'],
                      decoration: InputDecoration(labelText: 'ID do Usuário'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['obs_contato1'],
                      decoration:
                          InputDecoration(labelText: 'Obs contato 1 CL'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['obs_contato2'],
                      decoration:
                          InputDecoration(labelText: 'Obs contato 2 CL'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['obs_contato3'],
                      decoration:
                          InputDecoration(labelText: 'Obs contato 3 CL'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['obs_contato4'],
                      decoration:
                          InputDecoration(labelText: 'Obs contato 4 CL'),
                      enabled: false,
                    ),
                    TextFormField(
                      controller: obsController,
                      decoration:
                          InputDecoration(labelText: 'Observação técnico'),
                          validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira uma observação';
                    }
                    return null;
                  },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => pickImage(0),
                            child: Text('Potência',style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => pickImage(1),
                            child: Text('Velocidade',style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => pickImage(2),
                            child: Text('Rat',style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _enviarParaGrupo();
                            },
                            child: Text('ACEITAR',style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _concluirAcao();
                              setState(() {
                                aceite = true;
                              });
                            },
                            child: Text('CONCLUIR',style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                            ),
                          ),
                          
                        ),
                        SizedBox(height: 16),
    
    
  
                      ],
                    ),
                    SizedBox(height: 18),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < images.length; i++)
          images[i] != null
              ? Image.file(
                  images[i]!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey,
                  alignment: Alignment.center,
                  child: Text('Foto $i', style: TextStyle(color: Colors.white)),
                ),
      ],
    ),
                  ],
                ),
              ),
            ),
    );
  }
}
