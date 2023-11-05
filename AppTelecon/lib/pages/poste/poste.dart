import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:convert';

class City {
  final String id;
  final String name;

  City({required this.id, required this.name});
}

class FormularioPage extends StatefulWidget {
  @override
  _FormularioPageState createState() => _FormularioPageState();
}

class _FormularioPageState extends State<FormularioPage> {
  bool _envioEmProgresso = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _numeroCdoeController = TextEditingController();
  final TextEditingController _quantidadePosteController =
      TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _telefone = TextEditingController();
  City? _selectedCity;
  String? _tipoPoste;
  String? _ocorrencia;
  String? _tipoRede;
  String? _status;
  File? _foto1;
  File? _foto2;
  String? _latitude;
  String? _longitude;

  final List<String> _tipoPosteOptions = ['Passagem', 'CDOE'];
  final List<String> _ocorrenciaOptions = [
    'Troca de Poste',
    'Ação de Terceiros'
  ];
  final List<String> _tipoRedeOptions = ['Primário', 'Secundário'];
  final List<String> _statusOptions = ['Em Andamento', 'Encerrado'];
  String? _selectedUF;
  List<String> _ufOptions = []; // Lista de estados
  List<City> _cities = []; // Lista de cidades

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _getStates().then((states) {
      setState(() {
        _ufOptions = states; // Atualiza a lista de estados
      });
    });
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

  Future<List<String>> _getStates() async {
    final response = await http.get(
      Uri.parse('https://servicodados.ibge.gov.br/api/v1/localidades/estados'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      final states = data.map((state) => state['sigla'] as String).toList();
      return states;
    } else {
      throw Exception('Erro ao buscar os estados');
    }
  }

  Future<void> _updateCities(String selectedUF) async {
    setState(() {
      _selectedUF = selectedUF;
      _selectedCity = null;
      _cities = []; // Limpa a lista de cidades ao alterar o estado
    });

    if (_selectedUF != null) {
      final cities = await _getCities(_selectedUF!);
      setState(() {
        _cities = cities;
      });
    }
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

    _formKey.currentState!.save();

    final url = Uri.parse('API');
    final request = http.MultipartRequest('POST', url);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateTime dataSelecionada = formatter.parse(_dataController.text);
    final String formattedData = formatter.format(dataSelecionada);

    request.fields['endereco'] = _enderecoController.text;
    request.fields['cidade'] =
        _selectedCity!.name; // Corrigido para acessar o nome da cidade
    request.fields['data'] = formattedData;
    request.fields['nome'] = _nomeController.text;
    request.fields['tipo_poste'] = _tipoPoste!;
    request.fields['numero_cdoe'] = _numeroCdoeController.text;
    request.fields['uf'] = _selectedUF!; // Use o valor UF selecionado
    request.fields['ocorrencia'] = _ocorrencia!;
    request.fields['tipo_rede'] = _tipoRede!;
    request.fields['latitude'] = _latitude!;
    request.fields['longitude'] = _longitude!;
    request.fields['quantidade_poste'] = _quantidadePosteController.text;
    request.fields['descricao'] = _descricaoController.text;
    request.fields['status'] = _status!;
    request.fields['telefone'] = _telefone.text;

    if (_foto1 != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto1',
          _foto1!.path,
          filename: 'foto1.jpg',
        ),
      );
    }

    if (_foto2 != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto2',
          _foto2!.path,
          filename: 'foto2.jpg',
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
      _nomeController.clear();
      _numeroCdoeController.clear();
      _quantidadePosteController.clear();
      _descricaoController.clear();
      _telefone.clear();
      _tipoPoste = null;
      _ocorrencia = null;
      _tipoRede = null;
      _status = null;
      _foto1 = null;
      _foto2 = null;
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
          _foto1 = File(pickedFile.path);
        } else if (fotoIndex == 2) {
          _foto2 = File(pickedFile.path);
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

  void _exibirMensagemCadastro() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso'),
          content: const Text('Missão cadastrada com sucesso!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
          title: const Text('Desligamento copel'),
          backgroundColor: const Color.fromRGBO(13, 71, 161, 1),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira o nome';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _telefone,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira o seu Telefone';
                    }
                    return null;
                  },
                ),
                //
                DropdownButtonFormField<String>(
                  value: _selectedUF,
                  decoration: const InputDecoration(labelText: 'UF'),
                  items: _ufOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    _updateCities(
                        newValue!); // Atualiza as cidades quando o estado é alterado
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione o estado';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<City>(
                  value: _selectedCity,
                  decoration: const InputDecoration(labelText: 'Cidade'),
                  items: _cities.map((City city) {
                    return DropdownMenuItem<City>(
                      value: city,
                      child: Text(city.name),
                    );
                  }).toList(),
                  onChanged: (City? newValue) {
                    setState(() {
                      _selectedCity = newValue;
                    });
                  },
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
                  value: _tipoPoste,
                  decoration: const InputDecoration(labelText: 'Tipo de Poste'),
                  items: _tipoPosteOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _tipoPoste = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione o tipo de poste';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _numeroCdoeController,
                  decoration: const InputDecoration(labelText: 'Número CDOE'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira o número CDOE';
                    }
                    return null;
                  },
                ),

                DropdownButtonFormField<String>(
                  value: _ocorrencia,
                  decoration: const InputDecoration(labelText: 'Ocorrência'),
                  items: _ocorrenciaOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _ocorrencia = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione a ocorrência';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _tipoRede,
                  decoration: const InputDecoration(labelText: 'Tipo de Rede'),
                  items: _tipoRedeOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _tipoRede = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione o tipo de rede';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _quantidadePosteController,
                  decoration:
                      const InputDecoration(labelText: 'Quantidade de Poste'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, insira a quantidade de poste';
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
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: _statusOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _status = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecione o status';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _selecionarFoto(1),
                  child: const Text('Foto Antes'),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(13, 71, 161, 1),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _selecionarFoto(2),
                  child: const Text('Foto Depois'),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(13, 71, 161, 1),
                  ),
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

                    _exibirMensagemCadastro();
                  },
                  child: _envioEmProgresso
                      ? CircularProgressIndicator() // Exibe o indicador de progresso se o envio estiver em andamento
                      : Text('Cadastrar'),
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

void main() {
  runApp(MaterialApp(
    home: FormularioPage(),
  ));
}
