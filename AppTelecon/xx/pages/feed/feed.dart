import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
        backgroundColor: Color(0xFF335486),
      ),
      body: ListView.builder(
        itemCount: 10, // Número de elementos no feed
        itemBuilder: (context, index) {
          // Retorne um elemento de feed com uma imagem (substitua pela lógica real)
          return FeedItem(
              imageUrl:
                  'http://intranet.icomon.com.vc/PaginaPouso/Leitura-de-Artigo/12712');
        },
      ),
    );
  }
}

class FeedItem extends StatelessWidget {
  final String imageUrl;

  FeedItem({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageUrl), // Exibe a imagem do feed
          SizedBox(height: 8),
          Text('Descrição da imagem xx'), // Adicione a descrição do feed
          Divider(), // Adicione uma linha divisória entre os itens do feed
        ],
      ),
    );
  }
}
