import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:moove/pages/ftth/homeftth.dart';
import 'package:moove/pages/preventivas/preventivas.dart';
import 'package:moove/pages/ocorrencias/homeoc.dart';
import 'package:moove/pages/hc/caixa.dart';
import 'package:moove/pages/perfil/perfil.dart';
import 'package:moove/pages/poste/registros.dart'; /*  */
import 'package:moove/pages/backbone/homebk.dart';
import 'package:moove/pages/rh/homehr.dart';
// import 'package:moove/pages/gerencia/gestores_ba_97.dart';

class HomeScreen extends StatefulWidget {
  final String loggedInUser;

  HomeScreen({
    Key? key,
    required this.loggedInUser,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _pages = [];
  List<File> _selectedImages = [];

  final ImagePicker _imagePicker = ImagePicker();
  File? _pickedImage;

  List<String> listaDeImagens = [
    'assets/imagens/doação.png',
    'assets/imagens/05.jpg',
    // 'assets/imagens/04.jpg',
    // 'assets/imagens/01.png',

    // Adicione mais caminhos de imagens conforme necessário
  ];

  Future<void> _pickImage() async {
    final permissionStatus = await Permission.storage.request();

    if (permissionStatus.isGranted) {
      final pickedImages = await _imagePicker.pickMultiImage();

      if (pickedImages != null && pickedImages.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(
              pickedImages.map((pickedImage) => File(pickedImage.path)));
        });
      }
    } else {
      // Handle permission denial
    }
  }

  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pages = [
      buildFeedPage(),
      Container(), // Placeholder for other pages, you can replace with your pages
      // buildProfilePage(),
    ];
  }

  Widget buildFeedPage() {
    // Replace this with your actual feed content
    return Scaffold(
  appBar: AppBar(
    title: Text('Feed',
    style: TextStyle(
      color: Colors.white,
      fontSize: 20,
    ),
    ),
    backgroundColor: Color.fromRGBO(13, 71, 161, 1),
    iconTheme: IconThemeData(color: Colors.white), // Defina a cor do ícone para br
  ),
      drawer: SideBar(
        loggedInUser: widget.loggedInUser,
        menuItems: [
          SideBarItem(
            icon: Icons.close_fullscreen,
            title: 'FTTH',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      homeftth(loggedInUser: widget.loggedInUser),
                ),
              );
            },
          ), // Existing sidebar items
          SideBarItem(
            icon: Icons.construction_outlined,
            title: 'Preventivas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      preventivas(loggedInUser: widget.loggedInUser),
                ),
              );
            },
          ),
          SideBarItem(
            icon: Icons.edit_square,
            title: 'Ocorrência',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      homeoc(loggedInUser: widget.loggedInUser),
                ),
              );
            },
          ),
          SideBarItem(
            icon: Icons.verified,
            title: 'HC',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Caixahc(
                    loggedInUser: widget.loggedInUser,
                    status: widget.loggedInUser,
                  ),
                ),
              );
            },
          ),

          // SideBarItem(
          //   icon: Icons.electric_bolt_outlined,
          //   title: 'Desligamento Copel',
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => FormularioPage(),
          //       ),
          //     );
          //   },
          // ),

          SideBarItem(
            icon: Icons.broadcast_on_home_outlined,
            title: 'Backbone',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      homebackbone(loggedInUser: widget.loggedInUser),
                ),
              );
            },
          ),
          SideBarItem(
            icon: Icons.schedule_outlined,
            title: 'Área do ponto',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      homerh(loggedInUser: widget.loggedInUser),
                ),
              );
            },
          ),
          SideBarItem(
            icon: Icons.account_circle_outlined,
            title: 'Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilePage(loggedInUser: widget.loggedInUser),
                ),
              );
            },
          ),
          // SideBarItem(
          //   icon: Icons.account_circle_outlined,
          //   title: 'TESTE',
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => MyApp(),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: ListView.builder(
        itemCount: listaDeImagens.length,
        itemBuilder: (context, index) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(listaDeImagens[
                    index]), // Use o caminho relativo correto para cada imagem
                SizedBox(
                    height:
                        10), // Espaçamento entre as imagens, ajuste conforme necessário
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateCurrentIndex(int index) {
    setState(() {
      _currentIndex = index.clamp(0, _pages.length - 2);
    });

    if (index == 1) {
      // Navigate to Search screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(loggedInUser: widget.loggedInUser),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Home'),
      //   backgroundColor: Color(0xFF335486),
      // ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _updateCurrentIndex,
        items: [
          BottomNavigationBarItem(
            icon: IconTheme(
              data: IconThemeData(
                color: Color.fromRGBO(13, 71, 161, 1),
              ), // Substitua pela cor desejada
              child: Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconTheme(
              data: IconThemeData(
                  color: Color.fromRGBO(
                      13, 71, 161, 1)), // Substitua pela cor desejada
              child: Icon(Icons.account_circle_outlined),
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class SideBar extends StatelessWidget {
  final String loggedInUser;
  final List<SideBarItem> menuItems;

  SideBar({
    required this.loggedInUser,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 100,
            color: Color.fromRGBO(13, 71, 161, 1),
            alignment: Alignment.center,
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (var item in menuItems)
                  ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.title),
                    onTap: item.onPressed,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SideBarItem {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  SideBarItem({
    required this.icon,
    required this.title,
    required this.onPressed,
  });
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(loggedInUser: 'example_user'),
  ));
}
