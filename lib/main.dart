import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(AndroidCameraApp());
}

class AndroidCameraApp extends StatefulWidget {
  @override
  _AndroidCameraAppState createState() => _AndroidCameraAppState();
}

class _AndroidCameraAppState extends State<AndroidCameraApp> {
  int captureCount = 0;
  bool isCombining = false;
  final int maxCaptures = 3;
  final List<String> filters = ["azul", "verde", "vermelho"];
  List<bool> isLoading = [false, false, false];
  List<String?> imagePaths = [null, null, null];
  final ImagePicker _picker = ImagePicker();
  File? combinedImage;
  String statusMessage = "Solicitando permissões...";

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    if (statuses[Permission.camera]!.isGranted && statuses[Permission.storage]!.isGranted) {
      setState(() {
        statusMessage = "Toque para capturar: ${filters[captureCount]}";
      });
    } else {
      setState(() {
        statusMessage = "Permissões negadas. Não é possível usar a câmera.";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.camera.isGranted && await Permission.storage.isGranted) {
      setState(() {
        statusMessage = "Toque para capturar: ${filters[captureCount]}";
      });
    } else {
      _requestPermissions();
    }
  }

  Future<void> _captureImage(int index) async {
    if (captureCount >= maxCaptures) return;

    setState(() {
      isLoading[index] = true;
    });

    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) {
      setState(() {
        isLoading[index] = false;
      });
      return;
    }

    String savePath = await _processImage(photo.path, index);
    setState(() {
      imagePaths[index] = savePath;
      isLoading[index] = false;
      captureCount++;

      if (captureCount < maxCaptures) {
        statusMessage = "Toque para capturar: ${filters[captureCount]}";
      } else {
        statusMessage = "Capturas completas.";
      }
    });
  }

  Future<String> _processImage(String path, int index) async {
    final img.Image capturedImage = img.decodeImage(File(path).readAsBytesSync())!;
    img.Image filteredImage = img.Image.from(capturedImage);
    String canal = filters[index];

    for (int y = 0; y < capturedImage.height; y++) {
      for (int x = 0; x < capturedImage.width; x++) {
        int pixel = capturedImage.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);

        switch (canal) {
          case 'azul':
            r = 0;
            g = 0;
            break;
          case 'verde':
            r = 0;
            b = 0;
            break;
          case 'vermelho':
            g = 0;
            b = 0;
            break;
        }

        filteredImage.setPixel(x, y, img.getColor(r, g, b));
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final savePath = "${directory.path}/filtro_${canal}.png";
    File(savePath).writeAsBytesSync(img.encodePng(filteredImage));

    return savePath;
  }

  Future<void> _combineImages() async {
    setState(() {
      isCombining = true;
    });
    if (imagePaths.where((path) => path != null).length == 3) {
      final r = img.decodeImage(File(imagePaths[2]!).readAsBytesSync())!;
      final g = img.decodeImage(File(imagePaths[1]!).readAsBytesSync())!;
      final b = img.decodeImage(File(imagePaths[0]!).readAsBytesSync())!;
      final combined = img.Image(r.width, r.height);

      for (int y = 0; y < r.height; y++) {
        for (int x = 0; x < r.width; x++) {
          int red = img.getRed(r.getPixel(x, y));
          int green = img.getGreen(g.getPixel(x, y));
          int blue = img.getBlue(b.getPixel(x, y));

          combined.setPixel(x, y, img.getColor(red, green, blue));
        }
      }

      final directory = await getApplicationDocumentsDirectory();
      final savePath = "${directory.path}/imagem_combinada.png";
      File(savePath).writeAsBytesSync(img.encodePng(combined));

      setState(() {
        combinedImage = File(savePath);
        statusMessage = "Imagem combinada salva.";
        isCombining = false; // Finalizar carregamento
      });
    } else {
      setState(() {
        statusMessage = "Faltam imagens para combinar.";
        isCombining = false;
      });
    }
  }

  void _clearImages() {
    setState(() {
      imagePaths = [null, null, null];
      isLoading = [false, false, false];
      combinedImage = null;
      isCombining = false;
      captureCount = 0;
      _checkPermissions();
      statusMessage = "Toque para capturar: ${filters[captureCount]}";
    });
  }

  Widget buildImage(int index) {
    if (isLoading[index] || (index == 3 && isCombining)) {
      return Center(child: CircularProgressIndicator());
    } else if (imagePaths[index] == null && index < 3) {
      return Container();
    } else if (index == 3 && combinedImage == null) {
      return Container();
    } else {
      return Image.file(
        index < 3 ? File(imagePaths[index]!) : combinedImage!,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Unifei Camera App")),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4.0),
                          color: Colors.grey[300],
                          height: 200,
                          child: (index < 3)
                              ? buildImage(index)
                              : (combinedImage != null)
                              ? Image.file(combinedImage!)
                              : Container(),
                        ),
                        ElevatedButton(
                          onPressed: index < 3
                              ? () => _captureImage(index)
                              : (imagePaths.where((path) => path != null).length == 3
                              ? _combineImages
                              : null),
                          child: Text(index < 3 ? 'Capturar ${filters[index]}' : 'Combinar'),
                        ),
                      ],
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _clearImages,
                child: Text('Limpar Imagens'),
              ),
              Text(statusMessage),
            ],
          ),
        ),
      ),
    );
  }
}