import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';

class FormData {
  String? descricao;
  int quantidade;

  FormData({this.descricao, required this.quantidade});
}

class baixa extends StatefulWidget {
  final String ba;

  baixa({required this.ba});

  @override
  _baixaPageState createState() => _baixaPageState();
}

class _baixaPageState extends State<baixa> {
  bool _envioEmProgresso = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _quantidadeController = TextEditingController();

  String? _selectedMaterial;
  List<String> _materiais = [];
  String? area; // Lista de materiais carregados da API

  List<FormData> formDataList = [FormData(quantidade: 0)];
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();

    // Carregue os materiais da API quando o widget for inicializado
    carregarMateriais();
  }

  Future<void> _enviarDadosParaBanco() async {
    final url = Uri.parse('https://sistema32.cloud/move/Api/VPS/BBK/baixa.php');
    try {
      for (var formData in formDataList) {
        final response = await http.post(
          url,
          body: {
            'ba': widget.ba,
            'descricao': formData.descricao,
            'quantidade': formData.quantidade.toString(),
          },
        );

        if (response.statusCode == 200) {
          print('Formulário enviado com sucesso!');
        } else {
          print('Erro ao enviar o formulário: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      print('Erro ao enviar o formulário: $e');
    }
  }

  Future<bool> _verificarConexaoInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }

  // Função para carregar os materiais da API
  Future<void> carregarMateriais() async {
    final url = Uri.parse('https://sistema32.cloud/move/Api/baixa/baixabk.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> materiais = json.decode(response.body);

        setState(() {
          _materiais.clear(); // Limpa a lista existente

          // Popula a lista _materiais com os materiais da API
          for (var material in materiais) {
            if (material is String) {
              _materiais.add(material);
            }
          }
          print(_materiais); // Adicione esta linha para depuração
        });
      } else {
        print('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar materiais: $e');
    }
  }

  Future<void> _obterCoordenadas() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Agora, você tem as coordenadas em 'position.latitude' e 'position.longitude'
    double latitude = position.latitude;
    double longitude = position.longitude;

    // Insira as coordenadas no banco de dados
    await _enviarCoordenadasParaBanco(latitude, longitude);

    print('Coordenadas obtidas: Latitude $latitude, Longitude $longitude');
  } catch (e) {
    print('Erro ao obter coordenadas: $e');
  }
}

 Future<void> _enviarCoordenadasParaBanco(double latitude, double longitude) async {
  final url = Uri.parse('https://sistema32.cloud/move/Api/VPS/BBK/geo.encerramento.php');

  try {
    final response = await http.post(
      url,
      body: {
        'ba': widget.ba,
        'latitude_final': latitude.toString(),
        'longitude_final': longitude.toString(),
      },
    );

    if (response.statusCode == 200) {
      print('Coordenadas inseridas no banco de dados com sucesso!');
    } else {
      print('Erro ao inserir coordenadas no banco de dados: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Erro ao inserir coordenadas no banco de dados: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Baixa de Material', 
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          )),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1),
        iconTheme: IconThemeData(color: Colors.white),
      ),

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                for (int index = 0; index < formDataList.length; index++)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: formDataList[index].descricao,
                        decoration:
                            const InputDecoration(labelText: 'Material'),
                        items: _materiais.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            formDataList[index].descricao = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor, selecione o tipo de material';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number, // Teclado numérico
                        controller: TextEditingController(
                          text: formDataList[index].quantidade.toString(),
                        ),
                        onChanged: (value) {
                          formDataList[index].quantidade =
                              int.tryParse(value) ?? 0;
                        },
                        decoration:
                            const InputDecoration(labelText: 'Quantidade'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor, insira a quantidade';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 16.0),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final conexaoInternet = await _verificarConexaoInternet();
                    if (!conexaoInternet) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Sem conexão com a internet. Verifique sua conexão e tente novamente.'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _envioEmProgresso = true;
                    });

                    await _enviarDadosParaBanco();
                    await _obterCoordenadas();

                    setState(() {
                      _envioEmProgresso = false;
                    });

                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: _envioEmProgresso
                      ? CircularProgressIndicator()
                      : Text('Cadastrar',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(13, 71, 161, 1),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      formDataList.add(FormData(quantidade: 0));
                    });
                  },
                  child: Text('+ Adicionar Material',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  ),
                   style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(224, 16, 1, 1),
                  ),
                  
                ),
              ],
            ),
          ),
        
      ),
    );
  }
}
