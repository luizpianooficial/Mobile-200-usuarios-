import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(
    home: Handover(),
  ));
}

class Handover extends StatefulWidget {
  @override
  _HandoverState createState() => _HandoverState();
}

class _HandoverState extends State<Handover> {
  List<ChecklistItem> checklistItems = List.generate(
      5, (index) => ChecklistItem(name: index + 1, checked: false, observations: ""));

  String station = ""; // Armazene a estação inserida pelo usuário
  int uniqueIdentifier = Random().nextInt(100000);
  List<XFile>? selectedImages;

  Future<void> uploadImages(List<XFile> images) async {
  final url = 'API';
  final dio = Dio();

  for (var item in checklistItems) {
    if (item.checked) {
      final formData = FormData.fromMap({
        'uniqueIdentifier': uniqueIdentifier.toString(),
        'name': item.name.toString(),
        'checked': item.checked.toString(),
        'observations': item.observations,
        'estacao': station,
      });

      for (var image in images) {
        formData.files.add(MapEntry(
          'image[]',
          MultipartFile.fromFileSync(image.path, filename: 'image.jpg'),
        ));
      }

      final response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        print('Dados e imagens enviados com sucesso.');
      } else {
        print('Erro ao enviar os dados e imagens: ${response.statusCode}');
      }
    }
  }
}


  Future<void> selectImages() async {
    final picker = ImagePicker();
    final result = await picker.pickMultiImage(imageQuality: 50);

    if (result != null) {
      setState(() {
        selectedImages = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Handover'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(labelText: 'Estação'),
              onChanged: (text) {
                setState(() {
                  station = text;
                });
              },
            ),
          ),
          DataTable(
            columns: [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Check')),
              DataColumn(label: Text('Observations')),
            ],
            rows: checklistItems
                .asMap()
                .entries
                .map((entry) => DataRow(
                      cells: [
                        DataCell(Text(entry.value.name.toString())),
                        DataCell(
                          Checkbox(
                            value: entry.value.checked,
                            onChanged: (bool? value) {
                              setState(() {
                                checklistItems[entry.key] = ChecklistItem(
                                  name: entry.value.name,
                                  checked: value ?? false,
                                  observations: entry.value.observations,
                                );
                              });
                            },
                          ),
                        ),
                        DataCell(
                          entry.value.checked
                              ? TextFormField(
                                  decoration: InputDecoration(labelText: 'Observations'),
                                  onChanged: (text) {
                                    setState(() {
                                      checklistItems[entry.key] = ChecklistItem(
                                        name: entry.value.name,
                                        checked: entry.value.checked,
                                        observations: text,
                                      );
                                    });
                                  },
                                )
                              : Container(),
                        ),
                      ],
                    ))
                .toList(),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedImages != null) {
                await uploadImages(selectedImages!);
              }
            },
            child: Text('Enviar Imagens'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await selectImages();
        },
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}

class ChecklistItem {
  int name;
  bool checked;
  String observations;

  ChecklistItem({required this.name, required this.checked, required this.observations});
}
