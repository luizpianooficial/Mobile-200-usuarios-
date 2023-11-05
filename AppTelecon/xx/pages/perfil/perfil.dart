import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final String loggedInUser;

  ProfilePage({required this.loggedInUser});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _gestorController = TextEditingController();
  TextEditingController _areaAtuacaoController = TextEditingController();
  File? _selectedImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String nameKey = '${widget.loggedInUser}_name';
    String gestorKey = '${widget.loggedInUser}_gestor';
    String areaAtuacaoKey = '${widget.loggedInUser}_area_atuacao';
    String imagePathKey = '${widget.loggedInUser}_image_path';

    setState(() {
      _nameController.text = prefs.getString(nameKey) ?? '';
      _gestorController.text = prefs.getString(gestorKey) ?? '';
      _areaAtuacaoController.text = prefs.getString(areaAtuacaoKey) ?? '';
      String imagePath = prefs.getString(imagePathKey) ?? '';
      if (imagePath.isNotEmpty) {
        _selectedImage = File(imagePath);
      }
    });
  }

  Future<void> _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String nameKey = '${widget.loggedInUser}_name';
    String gestorKey = '${widget.loggedInUser}_gestor';
    String areaAtuacaoKey = '${widget.loggedInUser}_area_atuacao';
    String imagePathKey = '${widget.loggedInUser}_image_path';

    await prefs.setString(nameKey, _nameController.text);
    await prefs.setString(gestorKey, _gestorController.text);
    await prefs.setString(areaAtuacaoKey, _areaAtuacaoController.text);
    if (_selectedImage != null) {
      await prefs.setString(imagePathKey, _selectedImage!.path);
    }

    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _selectProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Color.fromRGBO(13, 71, 161, 1),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_selectedImage != null)
                CircleAvatar(
                  radius: 60,
                  backgroundImage: FileImage(_selectedImage!),
                ),
              SizedBox(height: 16),
              if (_isEditing)
                ElevatedButton(
                    onPressed: _selectProfilePicture,
                    child: Text('Foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                      onPrimary: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    )),
              SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Seu nome',
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _gestorController,
                decoration: InputDecoration(
                  labelText: 'Nome do Gestor',
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _areaAtuacaoController,
                decoration: InputDecoration(
                  labelText: 'Área de Atuação',
                  border: OutlineInputBorder(),
                ),
                enabled: _isEditing,
              ),
              SizedBox(height: 16),
              if (_isEditing)
                ElevatedButton(
                  onPressed: () async {
                    await _saveProfileData();
                  },
                  child: Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                    onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: ProfilePage(loggedInUser: 'example_user'),
    ),
  );
}
