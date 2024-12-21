import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  ScannerPageState createState() => ScannerPageState();
}

class ScannerPageState extends State<ScannerPage> {
  CameraController? _cameraController;
  late BarcodeScanner _barcodeScanner;
  bool _isBusy = false;
  String _scannedCode = "Nessun codice scannerizzato";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _barcodeScanner = BarcodeScanner();
  }

  @override
  void dispose() {
    _barcodeScanner.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController?.initialize();

    _cameraController?.startImageStream(_processImage);

    setState(() {});
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isBusy) return;

    _isBusy = true;

    try {
      // Converte CameraImage in InputImage
      final WriteBuffer allBytes = WriteBuffer();
      for (final plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize =
          Size(image.width.toDouble(), image.height.toDouble());
      final InputImageRotation imageRotation =
          InputImageRotation.rotation0deg; // Cambia se necessario
      final inputImageFormat =
          InputImageFormatValue.fromRawValue(image.format.raw);
      if (inputImageFormat == null) {
        debugPrint('Formato immagine non supportato');
        return;
      }

      final inputImageData = InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow,
      );

      final inputImage =
          InputImage.fromBytes(bytes: bytes, metadata: inputImageData);

      // Elaborazione del codice a barre
      final barcodes = await _barcodeScanner.processImage(inputImage);
      for (Barcode barcode in barcodes) {
        final BarcodeType type = barcode.type;

        // Gestione del tipo di codice a barre
        switch (type) {
          case BarcodeType.product:
            final productCode = barcode.rawValue;
            if (productCode != null) {
              _showBottomSheet(productCode); // Mostra il menu
            } else {
              setState(() {
                _scannedCode = 'Codice prodotto non valido';
              });
            }
            break;
          case BarcodeType.text:
            setState(() {
              _scannedCode = barcode.rawValue ?? 'Codice testo non valido';
            });
            break;
          case BarcodeType.url:
            setState(() {
              _scannedCode = barcode.rawValue ?? 'URL non valido';
            });
            break;
          default:
            setState(() {
              _scannedCode = 'Tipo di codice non supportato';
            });
            break;
        }
      }
    } catch (e) {
      debugPrint("Errore durante la scansione: $e");
    } finally {
      _isBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          // La fotocamera occupa tutto lo spazio disponibile tranne la barra superiore e inferiore
          Positioned(
            top: 0, // Posiziona la fotocamera sotto la barra
            left: 0,
            right: 0,
            bottom: 0, // La fotocamera occupa tutta la parte restante
            child: CameraPreview(_cameraController!),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _scannedCode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBottomSheet(String scannedCode) async {
    await _cameraController?.stopImageStream();

    if (!mounted) return;

    final http.Response response;
    var url = Uri.https('world.openfoodfacts.org',
        '/api/v2/product/$scannedCode.json'); // limite di 100 al minuto per user
    response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var itemCount = jsonResponse['totalItems'];
      print('Number of books about http: $itemCount.');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea:
          true, // Per garantire che occupi tutta la larghezza e tenga conto della safe area
      backgroundColor: Colors.transparent, // Elimina i bordi del bottom sheet
      builder: (BuildContext context) {
        return Container(
          width:
              MediaQuery.of(context).size.width, // Imposta larghezza completa
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 5,
                        width: 50,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Text(
                        'testo',
                        //response.toString(),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scannedCode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Chiudi'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (mounted) {
      await _cameraController?.startImageStream(_processImage);
    }
  }
}
