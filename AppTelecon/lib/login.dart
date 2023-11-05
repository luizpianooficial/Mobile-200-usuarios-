import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moove/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF335486);

    return MaterialApp(
      title: 'Login Move',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          primaryColor.value,
          <int, Color>{
            50: primaryColor.withOpacity(0.1),
            100: primaryColor.withOpacity(0.2),
            200: primaryColor.withOpacity(0.3),
            300: primaryColor.withOpacity(0.4),
            400: primaryColor.withOpacity(0.5),
            500: primaryColor.withOpacity(0.6),
            600: primaryColor.withOpacity(0.7),
            700: primaryColor.withOpacity(0.8),
            800: primaryColor.withOpacity(0.9),
            900: primaryColor.withOpacity(1.0),
          },
        ),
        fontFamily: 'Montserrat',
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _saveCredentials = false;
  String _loggedInUser = '';

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _login() async {
    
    final String apiUrl = 'MINHA API';
    final String login = _usernameController.text;
    final String senha = _passwordController.text;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cachedLogin = prefs.getString('login') ?? '';
    final String cachedSenha = prefs.getString('senha') ?? '';

    if (login.isEmpty || senha.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login ou senha Vazia'),
            content: Text('Por favor, preencha todos os campos.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (_saveCredentials) {
      prefs.setString('login', login);
      prefs.setString('senha', senha);
    }

    if (login == cachedLogin && senha == cachedSenha) {
      setState(() {
        _loggedInUser = login;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            loggedInUser: _loggedInUser,
          ),
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'login': login,
          'senha': senha,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final bool success = responseData['success'] ?? false;

        if (success) {
          final String name = responseData['name'] ?? '';

          setState(() {
            _loggedInUser = login;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                loggedInUser: _loggedInUser,
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Login Failed'),
                content: Text('Incorrect username or password.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Connection Error'),
              content: Text('Could not connect to the API.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Verifique'),
            content: Text('Entre em contato com a equipe responsavel pelo APP'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _checkAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cachedLogin = prefs.getString('login') ?? '';
    final String cachedSenha = prefs.getString('senha') ?? '';

    if (cachedLogin.isNotEmpty && cachedSenha.isNotEmpty) {
      // Auto-login the user if credentials are saved
      _usernameController.text = cachedLogin;
      _passwordController.text = cachedSenha;
      _login();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [
                Color.fromRGBO(13, 71, 161, 1),
                const Color.fromARGB(255, 12, 84, 166),
                const Color.fromARGB(255, 52, 86, 115),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 60),
                child: Image.asset(
                  'assets/imagens/logo.png',
                  width: 250,
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(40, 41, 43, 1),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 60),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(1, 12, 32, 1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(10),
                              child: TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  hintText: "Usuário",
                                  hintStyle: TextStyle(
                                    color: Color.fromRGBO(13, 71, 161, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: const Color.fromRGBO(13, 71, 161, 1),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  hintText: "Senha",
                                  hintStyle: TextStyle(
                                    color: Color.fromRGBO(13, 71, 161, 1),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  border: InputBorder.none,
                                ),
                                obscureText: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: _saveCredentials,
                            activeColor: Color.fromRGBO(13, 71, 161, 1),
                            onChanged: (value) {
                              setState(() {
                                _saveCredentials = value ?? false;
                              });
                            },
                          ),
                          Text(
                            "Salvar Login",
                            style: TextStyle(
                              color: Color.fromRGBO(13, 71, 161, 1),
                              fontWeight:
                                  FontWeight.bold, // Change the color here
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 4, 40, 248)
                                  .withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 2,
                              offset:
                                  Offset(0, -0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            _login();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromRGBO(13, 71, 161, 1),
                            onPrimary: Color.fromARGB(255, 246, 240, 240),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        "Segurança em 1° lugar",
                        style: TextStyle(
                          color: Color.fromRGBO(13, 71, 161, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 150),
                    ],
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
