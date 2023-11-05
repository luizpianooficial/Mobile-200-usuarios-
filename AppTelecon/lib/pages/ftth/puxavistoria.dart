import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:maps_launcher/maps_launcher.dart';

class IdentidadeBaFormV extends StatefulWidget {
  final String ba;

  const IdentidadeBaFormV({Key? key, required this.ba});

  @override
  _IdentidadeBaFormState createState() => _IdentidadeBaFormState();
}

class _IdentidadeBaFormState extends State<IdentidadeBaFormV> {
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
  // late PickedFile _selectedImage;
  PickedFile? _selectedImage;
  String novaDescricao = '';
  String status = '';
  @override
  void initState() {
    super.initState();
    carregarBaData();
  }

  Future<void> carregarBaData() async {
    var url = Uri.parse(
        'API');
      
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

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Identidade BA'),
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
                    GestureDetector(
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: baData['ba']));
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Conteúdo copiado')));
                      },
                      child: TextFormField(
                        controller: TextEditingController(text: baData['ba']),
                        decoration: InputDecoration(labelText: 'BA'),
                        enabled: true, // Habilitar o campo para interação
                        readOnly: true, // Tornar o campo apenas leitura
                      ),
                    ),
                    TextFormField(
                      initialValue: baData['estacao'],
                      decoration: InputDecoration(labelText: 'Estação'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['endereco'],
                      decoration: InputDecoration(
                        labelText: 'Endereço',
                        suffixIcon: Icon(
                          Icons.map,
                          color: Color.fromRGBO(13, 71, 161, 1),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final String formattedAddress = baData['endereco'];
                        MapsLauncher.launchQuery(formattedAddress);
                      },
                    ),
                    TextFormField(
                      initialValue: baData['status'],
                      decoration: InputDecoration(labelText: 'status'),
                      enabled: false,
                      onChanged: (value) {
                        setState(() {
                          status = value;
                        });
                      },
                    ),
                    // TextFormField(
                    //   initialValue: baData['nome'],
                    //   decoration: InputDecoration(labelText: 'Nome'),
                    //   enabled: false,
                    // ),
                    TextFormField(
                      initialValue: baData['causa'],
                      decoration: InputDecoration(labelText: 'Causa'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['descricao'],
                      decoration: InputDecoration(labelText: 'Descrição'),
                      onChanged: (value) {
                        setState(() {
                          novaDescricao = value;
                        });
                      },
                    ),
                    _selectedImage != null
                        ? Column(
                            children: [
                              SizedBox(height: 12),
                              Text('Foto Selecionada:'),
                              Image.file(
                                File(_selectedImage!.path),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ],
                          )
                        : Container(),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly, // Adjust this alignment as needed
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await pegarPosicao();
                            setState(() {
                              aceite = true;
                              _envioEmProgresso = true;
                            });
                            if (_selectedImage != null) {
                              await enviarFoto();
                            }
                            if (novaDescricao.isNotEmpty) {
                              await atualizarDescricao();
                            }
                            setState(() {
                              _envioEmProgresso = false;
                            });
                            if (mounted) {
                              _mostrarMensagemAceitacao(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          },
                          child: _envioEmProgresso
                              ? CircularProgressIndicator() // Exibe o indicador de progresso se o envio estiver em andamento
                              : Text('Cadastrar'),
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromRGBO(13, 71, 161, 1),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromRGBO(13, 71, 161, 1),
                            onPrimary: Colors.white,
                          ),
                          child: Text('Anexar Foto'),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
    );
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

  Future<void> enviarDados() async {
    if (novaDescricao.isNotEmpty) {
      await atualizarDescricao();
    }

    if (_selectedImage != null) {
      await enviarFoto();
    }
  }

  Future<void> atualizarDescricao() async {
    Map<String, dynamic> dadosAtualizados = {
      'ba': widget.ba,
      'latitude': baData['latitude'],
      'longitude': baData['longitude'],
      'descricao': novaDescricao,
      'status': status,
    };

    var url = Uri.parse('API');
    

    try {
      var response = await http.post(
        url,
        body: dadosAtualizados,
      );

      if (response.statusCode == 200) {
        print('Descrição atualizada com sucesso no servidor!');
      } else {
        print('Erro ao atualizar a descrição: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao atualizar a descrição: $error');
    }
  }

  Future<void> enviarFoto() async {
  
     var url = Uri.parse('API');

    var request = http.MultipartRequest('POST', url);
    request.fields['ba'] = widget.ba;
    request.fields['descricao'] = novaDescricao;
    request.fields['latitude'] = baData['latitude']; // Add this line
    request.fields['longitude'] = baData['longitude']; // Add this line
    request.files.add(
      await http.MultipartFile.fromPath('photo', _selectedImage!.path),
    );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Foto enviada com sucesso!');
      } else {
        print('Erro ao enviar a foto: ${response.statusCode}');
      }
    } catch (error) {
      print('Erro ao enviar a foto: $error');
    }
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
                Navigator.pop(context); // Fechar o diálogo
              },
              child: Text('OK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(13, 71, 161, 1),
              ),
            ),
          ],
        );
      },
    );
  }
}
