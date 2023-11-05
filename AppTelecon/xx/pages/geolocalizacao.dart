import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class loca extends StatefulWidget {
  const loca({Key? key}) : super(key: key);

  @override
  State<loca> createState() => _locaState();
}

class _locaState extends State<loca> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          child: Text('Pegar posição'),
          onPressed: () {
            pegarPosicao();
          },
        ),
      ),
    );
  }

  pegarPosicao() async {
    // Verifica se a permissão de localização foi concedida
    bool permissao = await Geolocator.isLocationServiceEnabled();
    if (permissao) {
      Position posicao = await Geolocator.getCurrentPosition();
      print('Latitude: ${posicao.latitude}');
      print('Longitude: ${posicao.longitude}');
      // Faça algo com a posição obtida, como enviar para o servidor
    } else {
      // A permissão de localização não foi concedida
      print('Permissão de localização não concedida.');
    }
  }
}
