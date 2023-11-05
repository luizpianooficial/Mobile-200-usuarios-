import 'dart:io';
import 'package:moove/pages/ftth/baixa.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class MascaraDeEncerramentoPage extends StatefulWidget {
  final String ba;

  MascaraDeEncerramentoPage({required this.ba});

  @override
  _MascaraDeEncerramentoPageState createState() =>
      _MascaraDeEncerramentoPageState();
}

class _MascaraDeEncerramentoPageState extends State<MascaraDeEncerramentoPage> {
  bool _envioEmProgresso = false;
  final TextEditingController _subController = TextEditingController();
  final TextEditingController _roController = TextEditingController();
  final TextEditingController _cisController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();

  String? _selectedCausa;
  String? _selectedSubCausa;
  List<String> _causasDisponiveis = [];
  List<String> _subcausasDisponiveis = [];
  File? foto_antes;
  File? foto_depois;
  String? _fotoAntesPath;
  String? _fotoDepoisPath;

  @override
  void initState() {
    super.initState();
    _buscarCausas();
  }

  Future<void> _buscarCausas() async {
    String apiUrl = 'https://sistema32.cloud/move/Api/causa.php';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);

        setState(() {
          _causasDisponiveis = List<String>.from(data);

          if (_causasDisponiveis.isNotEmpty) {
            _selectedCausa = _causasDisponiveis[0];
            _buscarSubCausas(_selectedCausa!);
          }
        });
      } else {
        throw Exception('Erro ao buscar as causas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar as causas: $e');
    }
  }

  Future<void> _buscarSubCausas(String causaSelecionada) async {
    String apiUrl =
        'https://sistema32.cloud/move/Api/subcausa.php?causa=$causaSelecionada';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        if (response.body != null && response.body.isNotEmpty) {
          List<dynamic> data = json.decode(response.body);
          setState(() {
            _subcausasDisponiveis = List<String>.from(data);

            if (_subcausasDisponiveis.isNotEmpty) {
              _selectedSubCausa = _subcausasDisponiveis[0];
            }
          });
        } else {
          setState(() {
            _subcausasDisponiveis = [];
            _selectedSubCausa = null;
          });
        }
      } else {
        throw Exception('Erro ao buscar as subcausas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar as subcausas: $e');
    }
  }

  Future<File> _resizeImage(File originalImage, int maxSize) async {
    final bytes = await originalImage.readAsBytes();
    img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;

    // Calcule as novas dimensões mantendo a proporção original
    int newWidth, newHeight;
    if (image.width > image.height) {
      newWidth = maxSize;
      newHeight = (image.height * maxSize / image.width).round();
    } else {
      newHeight = maxSize;
      newWidth = (image.width * maxSize / image.height).round();
    }

    img.Image resizedImage =
        img.copyResize(image, width: newWidth, height: newHeight);

    // Salve a imagem redimensionada em um novo arquivo
    final resizedFile =
        File(originalImage.path.replaceAll('.jpg', '_resized.jpg'));
    await resizedFile.writeAsBytes(img.encodeJpg(resizedImage, quality: 90));

    return resizedFile;
  }

  Future<void> _selecionarFoto(int fotoIndex) async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File resizedImage = await _resizeImage(
          File(pickedFile.path), 1024); // Redimensione para 1 MB (1024 KB)
      setState(() {
        if (fotoIndex == 1) {
          foto_antes = resizedImage;
        } else if (fotoIndex == 2) {
          foto_depois = resizedImage;
        }
      });
    }
  }

  bool _validateForm() {
    if (_selectedCausa == null || _selectedCausa!.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Causa não selecionada'),
            content: Text('Por favor, selecione a causa.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return false;
    } else if (_selectedSubCausa == null || _selectedSubCausa!.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Subcausa não selecionada'),
            content: Text('Por favor, selecione a subcausa.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return false;
    } else if (_roController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Campo RO vazio'),
            content: Text('Por favor, preencha o campo RO.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return false;
    } else if (_cisController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Campo CIS vazio'),
            content: Text('Por favor, preencha o campo CIS.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return false;
    } else if (_obsController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Campo OBS vazio'),
            content: Text('Por favor, preencha o campo OBS.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return false;
    }
    return true;
  }

  Future<void> _submitForm() async {
    if (_validateForm()) {
      String apiUrl =
          'https://sistema32.cloud/move/Api/mascara.php?ba=${widget.ba}'; // Substitua pelo URL do seu arquivo PHP

      try {
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.fields['ba'] = widget.ba;
        request.fields['causa'] = _selectedCausa!;
        request.fields['sub'] = _selectedSubCausa!;
        request.fields['ro'] = _roController.text;
        request.fields['cis'] = _cisController.text;
        request.fields['obs'] = _obsController.text;

        if (foto_antes != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'foto_antes', foto_antes!.path));
        }

        if (foto_depois != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'foto_depois', foto_depois!.path));
        }

        var response = await request.send();
        if (response.statusCode == 200) {
          // Sucesso, você pode mostrar uma mensagem ou fazer algo aqui
        } else {
          throw Exception('Erro ao enviar os dados: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Erro ao enviar os dados: $e');
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => baixa(ba: widget.ba),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Máscara de Encerramento'),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCausa,
              onChanged: (newValue) {
                setState(() {
                  _selectedCausa = newValue;
                  _selectedSubCausa = null;
                  _subcausasDisponiveis = [];
                  _buscarSubCausas(_selectedCausa!);
                });
              },
              items: _causasDisponiveis.map((causa) {
                return DropdownMenuItem<String>(
                  value: causa,
                  child: Text(causa),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Causa'),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedSubCausa,
              onChanged: (newValue) {
                setState(() {
                  _selectedSubCausa = newValue;
                });
              },
              items: _subcausasDisponiveis.map((subcausa) {
                return DropdownMenuItem<String>(
                  value: subcausa,
                  child: Text(subcausa),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Subcausa'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _roController,
              decoration: InputDecoration(labelText: 'RO'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _cisController,
              decoration: InputDecoration(labelText: 'CIS'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _obsController,
              decoration: InputDecoration(labelText: 'Observação'),
              maxLines: 3,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selecionarFoto(1),
                    child: Text('Foto 1°'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                      onPrimary: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selecionarFoto(2),
                    child: Text('Foto 2°'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                      onPrimary: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (foto_antes != null)
              Image.file(
                foto_antes!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 12),
            if (foto_depois != null)
              Image.file(
                foto_depois!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _envioEmProgresso = true;
                });
                _submitForm();
              },
              child: _envioEmProgresso
                  ? CircularProgressIndicator()
                  : Text('Cadastrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(13, 71, 161, 1),
              ),
            )
          ],
        ),
      ),
    );
  }
}
