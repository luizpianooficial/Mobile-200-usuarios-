import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class IdentidadeBaForms extends StatefulWidget {
  final String ba;
  final String loggedInUser;

  const IdentidadeBaForms(
      {Key? key, required this.ba, required this.loggedInUser});

  @override
  _IdentidadeBaFormState createState() => _IdentidadeBaFormState();
}

class _IdentidadeBaFormState extends State<IdentidadeBaForms> {
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
  @override
  void initState() {
    super.initState();
    carregarBaData();
  }

  Future<void> carregarBaData() async {
  var url = Uri.parse('API');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    setState(() {
      baData = json.decode(response.body);
      isLoading = false;
    });

    // Após obter os dados do BA, busque a lista de descrições associadas
    buscarDescricao(widget.ba).then((descricoes) {
      if (descricoes.isNotEmpty) {
        setState(() {
          // Aqui estamos pegando a primeira descrição da lista
          baData['descricao'] = descricoes[0];
        });
      } else {
        // Lidere com o caso em que a lista de descrições está vazia
      }
    });
  } else {
    // Trate os erros de solicitação aqui
  }
}


 Future<List<String>> buscarDescricao(String ba) async {
  var url = Uri.parse('API');

  try {
    var response = await http.get(url);

    if (response.statusCode == 200) {
      // Analise a resposta JSON para obter a lista de descrições associadas ao BA
      List<dynamic> data = json.decode(response.body);
      List<String> descricoes = data.cast<String>();
      return descricoes;
    } else {
      // Trate os erros de solicitação aqui
      print('Erro na solicitação HTTP: ${response.statusCode}');
      return [];
    }
  } catch (error) {
    // Trate os erros de exceção aqui
    print('Erro ao buscar descrição: $error');
    return [];
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
                      initialValue: baData['ba_comum'],
                      decoration: InputDecoration(labelText: 'BA Comum'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['uf'],
                      decoration: InputDecoration(labelText: 'UF'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['localidade'],
                      decoration: InputDecoration(labelText: 'Localidade'),
                      enabled: false,
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
                      readOnly: true, // Prevent user from editing
                      onTap: () async {
                        final String formattedAddress =
                            baData['endereco'].replaceAll(' ', '+');
                        final String googleMapsUrl =
                            'https://www.google.com/maps/dir/?api=1&destination=$formattedAddress';
                        if (await canLaunch(googleMapsUrl)) {
                          await launch(googleMapsUrl);
                        } else {
                          // Handle error if unable to launch Google Maps
                        }
                      },
                    ),
                    TextFormField(
                      initialValue: baData['celula'],
                      decoration: InputDecoration(labelText: 'Célula'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['cdoe'],
                      decoration: InputDecoration(labelText: 'CDOE'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['data_abertura'],
                      decoration:
                          InputDecoration(labelText: 'Data de Abertura'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['data_vencimento'],
                      decoration:
                          InputDecoration(labelText: 'Data de Vencimento'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['tipo'],
                      decoration: InputDecoration(labelText: 'Tipo'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['id_usu'],
                      decoration: InputDecoration(labelText: 'ID do Usuário'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['data_despacho'],
                      decoration:
                          InputDecoration(labelText: 'Data de Despacho'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['status'],
                      decoration: InputDecoration(labelText: 'Status'),
                      enabled: false,
                    ),
                    TextFormField(
                      initialValue: baData['obs_cl'],
                      maxLines: 5, // Define o número de linhas
                      decoration: InputDecoration(labelText: 'Observações'),
                      enabled: false,
                    ),
                    TextFormField(
  initialValue: baData['descricao'] ?? 'Carregando descrição...',
  decoration: InputDecoration(labelText: 'Descrição'),
  enabled: false,
),

                    ElevatedButton(
                        onPressed: () {
                          pegarPosicao();
                          setState(() {
                            aceite = true;
                          });
                        },
                        child: Text('Visualizar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                        )),
                    
                    SizedBox(height: 16),
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

  Future<void> atualizarDados() async {
    String latitude = baData['latitude'];
    String longitude = baData['longitude'];
    String selectedOption1 = baData['checkBox'] ?? '';
    String selectedOption3 = baData['checkBox2'] ?? '';

    Map<String, dynamic> dadosAtualizados = {
      'ba': widget.ba,
      'latitude': latitude,
      'longitude': longitude,
      'checkBox': selectedOption1,
      'checkBox2': selectedOption3,
    };

    var url = Uri.parse('API');

    try {
      var response = await http.post(
        url,
        body: dadosAtualizados,
      );

      if (response.statusCode == 200) {
        print('Latitude and longitude updated in the database successfully!');
        if (mounted) {
          setState(() {
            // Atualize o estado somente se o widget ainda estiver montado
          });
        }
      } else {
        print(
            'Error updating latitude and longitude in the database: ${response.statusCode}');
      }
    } catch (error) {
      print('An error occurred while updating latitude and longitude: $error');
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
