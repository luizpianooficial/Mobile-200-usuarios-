import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

// void main() {
//   runApp(MaterialApp(
//     home: CadastroOC(),
//   ));
// }

class City {
  final String id;
  final String name;

  City({required this.id, required this.name});
}

class CadastroOC extends StatefulWidget {
  final String loggedInUser;
  CadastroOC({
    Key? key,
    required this.loggedInUser,
  }) : super(key: key);

  @override
  _CadastroOCState createState() => _CadastroOCState();
}

class _CadastroOCState extends State<CadastroOC> {
  bool _envioEmProgresso = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _estacaooController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  String? _codigoBa;

  City? _selectedCity;
  String? _selectedUF;
  String? _tipoPoste;
  String? _estacaoz;
  String? _gaz;
  String? _latitude;
  String? _longitude;
  File? _fotoAntes;
  File? _fotoDepois;

  final List<String> _estacao = [
    'ACIDENTE',
    'ÁRVORE CAIDA',
    'CABO BAIXO',
    'CABO NO CHÃO',
    'VANDALISMO',
    'CDOE DANIFICADA',
    'CDOE SOLTA',
    'CABO PRIMÁRIO',
    'CABO SECUNDÁRIO',
    'DESLIGAMENTO COPEL',
    'POS BA',
    'TAMPA CS'
  ];

  final List<String> _ga = [
    'CRISTIANO SANTOS',
    'MARCIO ALVES',
    'MARLOS UELDES',
    'MATHEUS CAZATE',
    'MICHEL MUNIZ',
    'JEFFERSON CLERICI',
    'RODRIGO JORGE',
    'WAGNER MONTEIRO',
    'WESLEY BESSA',
  ];

  List<String> _ufOptions = ['PR', 'SC']; // Lista de estados limitados
  Map<String, List<City>> _citiesMap = {
    'PR': [], // Lista de cidades correspondentes ao estado PR
    'SC': [], // Lista de cidades correspondentes ao estado SC
  };

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionStatus();
    _updateCities(_ufOptions[0]);
    // Inicialmente, seleciona o primeiro estado da lista
  }

  Future<void> _checkLocationPermissionStatus() async {
    final status = await Permission.location.status;
    if (!status.isGranted) {
      _showLocationPermissionDialog();
    }
  }

  void _gerarCodigoBa() {
    String cidadeSigla = _selectedCity!.name.substring(0, 2).toUpperCase();
    String dataFormatada = DateFormat('yyyyMMdd').format(DateTime.now());
    String horaFormatada = DateFormat('HHmmss').format(DateTime.now());

    _codigoBa = cidadeSigla + dataFormatada + horaFormatada;
  }

  Future<void> _showLocationPermissionDialog() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permissão de Localização'),
          content: Text(
              'Para usar esta função, é necessário permitir o acesso à localização.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                final status = await Permission.location.request();
                if (status.isGranted) {
                  // Permission granted, continue with your logic here
                  // For example, you can call a function to obtain the location after getting permission
                  _obterLocalizacao();
                } else {
                  // Permission not granted
                  // You can display a message or handle the scenario accordingly
                  print('Permissão de localização não foi concedida.');
                }
              },
              child: Text('Permitir'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // User clicked on "Permitir," handle the permission request here
      // This block is optional since we're already handling it inside the dialog.
    }
  }

  Future<List<City>> _getCities(String selectedUF) async {
    final response = await http.get(
      Uri.parse(
          'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$selectedUF/municipios'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((city) => City(
                id: city['id'].toString(),
                name: city['nome'].toString(),
              ))
          .toList();
    } else {
      print('Erro ao obter a lista de cidades: ${response.statusCode}');
      return [];
    }
  }

  Future<void> _updateCities(String selectedUF) async {
    setState(() {
      _selectedUF = selectedUF;
      _selectedCity = null;
    });

    if (_citiesMap[selectedUF]!.isEmpty) {
      final cities = await _getCities(selectedUF);
      setState(() {
        _citiesMap[selectedUF] = cities;
      });
    }
  }

  Future<int> getFileSize(File? file) async {
    if (file == null) return 0;
    final stat = await file.stat();
    return stat.size;
  }

  Future<void> _exibirSelecionadorData() async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dataSelecionada != null) {
      final formattedData = DateFormat('yyyy-MM-dd').format(dataSelecionada);
      _dataController.text = formattedData;
    }
  }

  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_latitude == null || _longitude == null) {
      // Caso a localização não tenha sido obtida, exiba um aviso ou solicite novamente a localização.
      print(
          'Não foi possível obter a localização. Verifique as permissões de localização e tente novamente.');
      return;
    }
    _gerarCodigoBa();

    int fotoAntesSize = await getFileSize(_fotoAntes);
    int fotoDepoisSize = await getFileSize(_fotoDepois);

    _formKey.currentState!.save();

    final url = Uri.parse(
        'https://sistema32.cloud/move/Api/VPS/OCORRENCIA/cadastro.php');
    final request = http.MultipartRequest('POST', url);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateTime dataSelecionada = formatter.parse(_dataController.text);
    final String formattedData = formatter.format(dataSelecionada);

    request.fields['endereco'] = _enderecoController.text;
    request.fields['cidade'] = _selectedCity!
        .name; // Alterado para enviar o ID da cidade em vez do nome
    request.fields['data'] = formattedData;
    request.fields['ba'] = _codigoBa!;
    request.fields['uf'] = _selectedUF!;
    request.fields['tipo'] = _estacaoz!;
    request.fields['coordenador'] = _gaz!;
    request.fields['latitude'] = _latitude!;
    request.fields['longitude'] = _longitude!;
    request.fields['obs'] = _descricaoController.text;
    request.fields['bairro'] = _bairroController.text;
    request.fields['estacao'] = _estacaooController.text;
    // request.fields['id_usu'] = widget.loggedInUser; // Novo campo

    if (_fotoAntes != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto_antes',
          _fotoAntes!.path,
          filename: 'foto_antes.jpg',
        ),
      );
    }

    if (_fotoDepois != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto_depois',
          _fotoDepois!.path,
          filename: 'foto_depois.jpg',
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      // Sucesso ao enviar o formulário
      print('Formulário enviado com sucesso!');

      // Exibir mensagem de sucesso
      _scaffoldMessengerKey.currentState!.showSnackBar(
        SnackBar(
          content: const Text('Missão cadastrada com sucesso!'),
        ),
      );

      // Limpar o formulário
      _formKey.currentState!.reset();
      _enderecoController.clear();
      _dataController.clear();
      // _nomeController.clear();
      // _quantidadedemantasController.clear();
      _descricaoController.clear();
      _bairroController.clear(); // Limpa o campo do bairro
      _tipoPoste = null;
      // _fibraz = null;
      _estacaoz = null;
      _gaz = null; // _tipoRede = null;
      _fotoDepois = null;
      _fotoAntes = null;
      _latitude = null;
      _longitude = null;
    } else {
      // Erro ao enviar o formulário
      print('Erro ao enviar o formulário: ${response.reasonPhrase}');
    }
  }

  Future<void> _selecionarFoto(int fotoIndex) async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (fotoIndex == 1) {
          _fotoAntes = File(pickedFile.path);
        } else if (fotoIndex == 2) {
          _fotoDepois = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _obterLocalizacao() async {
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
      });
    } catch (e) {
      print('Erro ao obter a localização: $e');
    }
  }

  Future<bool> _verificarConexaoInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cadastro de ocorrências',
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
                DropdownButtonFormField<String>(
                  value: _selectedUF,
                  hint: Text('Selecione o estado'),
                  onChanged: (String? value) {
                    _updateCities(
                        value!); // Atualiza as cidades quando o estado é alterado
                  },
                  items: _ufOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione o estado';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<City>(
                  value: _selectedCity,
                  hint: Text('Selecione a cidade'),
                  onChanged: (City? value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                  items: _citiesMap[_selectedUF]!.map((City city) {
                    return DropdownMenuItem<City>(
                      value: city,
                      child: Text(city.name),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione a cidade';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _enderecoController,
                  decoration: const InputDecoration(labelText: 'Endereço'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira o endereço';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _bairroController,
                  decoration: const InputDecoration(labelText: 'Bairro'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira o bairro';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _estacaooController,
                  decoration: const InputDecoration(labelText: 'Estação'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira o estação';
                    }
                    return null;
                  },
                ),
                GestureDetector(
                  onTap: _exibirSelecionadorData,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dataController,
                      decoration: InputDecoration(
                        labelText: 'Data',
                        suffixIcon: IconButton(
                          onPressed: _exibirSelecionadorData,
                          icon: Icon(Icons.calendar_today),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, insira a data';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _estacaoz,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: _estacao.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _estacaoz = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione o tipo de rede';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _gaz,
                  decoration:
                      const InputDecoration(labelText: 'Coordenador da área'),
                  items: _ga.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _gaz = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione o coordenador';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira a descrição';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _selecionarFoto(1),
                  child: const Text('Evidência',
                  style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(13, 71, 161, 1),
                  ),
                ),
                SizedBox(height: 12),
                if (_fotoAntes != null)
                  Image.file(
                    _fotoAntes!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    final conexaoInternet = await _verificarConexaoInternet();
                    if (!conexaoInternet) {
                      // Caso não haja conexão com a internet, exiba uma mensagem de erro
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Sem conexão com a internet. Verifique sua conexão e tente novamente.'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _envioEmProgresso =
                          true; // Inicia o envio e exibe o indicador de progresso
                    });

                    await _obterLocalizacao();
                    await _enviarFormulario();

                    setState(() {
                      _envioEmProgresso =
                          false; // Finaliza o envio e remove o indicador de progresso
                    });
                  },
                  child: _envioEmProgresso
                      ? CircularProgressIndicator() // Exibe o indicador de progresso se o envio estiver em andamento
                      : Text('Cadastrar',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(13, 71, 161, 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
