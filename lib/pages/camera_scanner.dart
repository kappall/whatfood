import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert' as convert;

import 'package:whatfood/pages/painters/barcode_detector_painter.dart';

enum DetectorViewMode { liveFeed, gallery }

class CameraScanner extends StatefulWidget {
  const CameraScanner({super.key});
  @override
  State<StatefulWidget> createState() => CameraScannerState();
}

class CameraScannerState extends State<CameraScanner> {
  late final BarcodeScanner _barcodeScanner;
  CustomPaint? _customPaint;
  CameraController? _controller;
  int _cameraIndex = -1;
  static List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isBusy = false;
  String _scannedCode = '';
  Timer? _debounceTimer;
  bool _isModalVisible = false;
  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  ImagePicker? _imagePicker;

  @override
  void initState() {
    super.initState();
    _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
    _imagePicker = ImagePicker();
    _customPaint = CustomPaint(painter: null);
    _initialize();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    _debounceTimer?.cancel();
    _barcodeScanner.close();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      for (var i = 0; i < _cameras.length; i++) {
        if (_cameras[i].lensDirection == CameraLensDirection.back) {
          _cameraIndex = i;
          break;
        }
      }
      if (_cameraIndex != -1) {
        _startLiveFeed();
      }
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];

    // Usiamo yuv420 per Android per maggiore compatibilità
    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller?.initialize();
      if (!mounted) return;

      await _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });

      _maxAvailableZoom = min(await _controller?.getMaxZoomLevel() ?? 3.0, 3.0);
      await _controller?.startImageStream(_processCameraImage);
      setState(() {});
    } catch (e) {
      // Errore di inizializzazione della fotocamera
      return;
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    // Preveniamo elaborazioni multiple
    if (_isBusy || _isModalVisible || _controller == null || !mounted) {
      return;
    }
    _isBusy = true;
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage != null) {
        await _processImage(inputImage);
      }
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _stopLiveFeed() async {
    try {
      await _controller?.stopImageStream();
      await _controller?.dispose();
      _controller = null;
    } catch (e) {
      debugPrint('Error stopping camera feed: $e');
    }
  }

  Future<void> _processImage(InputImage image) async {

    if (_debounceTimer?.isActive ?? false) return;
    _debounceTimer = Timer(const Duration(seconds: 1), () {});
    if (!mounted) return;

    final barcodes = await _barcodeScanner.processImage(image);

    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      // Aggiorniamo il codice scansionato solo se è diverso dal precedente
      if (_scannedCode != barcodes.first.rawValue) {
        if (!_isGalleryMode) {
          final painter = BarcodeDetectorPainter(
            barcodes,
            image.metadata?.size ?? const Size(400, 400),
            image.metadata?.rotation ?? InputImageRotation.rotation0deg,
          );
          setState(() {
            _customPaint = CustomPaint(painter: painter);
          });
        }
        setState(() {
          _scannedCode = barcodes.first.rawValue!;
        });
        await _showProductModal();
      }
    }
  }

  Future<void> _showProductModal() async {
    if (!mounted || _isModalVisible) return;

    setState(() => _isModalVisible = true);

    try {
      final url = Uri.https(
        'world.openfoodfacts.org',
        '/api/v2/product/$_scannedCode.json',
      );
      _scannedCode = '';

      final response = await http.get(url);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;
        final productData = jsonResponse['product'] ?? {};

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildProductModal(productData),
        );
      } else {
        await _showErrorDialog();
      }
    } catch (e) {
      if (mounted) {
        await _showErrorDialog();
      }
    } finally {
      if (mounted) {
        setState(() {
          _customPaint = null;
          _isModalVisible = false;
        });
      }
      await _restartStream();
    }
  }

  Future<void> _restartStream() async {
    debugPrint("imageStream restarting;");
    await _controller?.stopImageStream();
    debugPrint("imageStream stopped\n");
    await Future.delayed(
        Duration(milliseconds: 1500)); // Pausa prima di riavviare
    await _controller?.startImageStream(_processCameraImage);
    debugPrint("imageStream started\n\n\n");
  }

  Widget _buildProductModal(Map<String, dynamic> productData) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
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
                  productData['product_name'] ??
                      'Nome prodotto non disponibile',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (productData['image_url']?.isNotEmpty ?? false)
                  Image.network(productData['image_url']!),
                const SizedBox(height: 16),
                Text(
                  productData['ingredients_text'] ??
                      'Descrizione non disponibile',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Codice a barre: ${productData['code'] ?? 'Non disponibile'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
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
        ),
      ),
    );
  }

  Future<void> _showErrorDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prodotto non trovato'),
        content: Text(
          'Il prodotto che stai cercando non è presente nel nostro database.',
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) {
      return null;
    }

    final camera = _cameras[_cameraIndex];

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;

      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    // Gestione formato YUV_420_888 (Android)
    if (format == InputImageFormat.yuv_420_888 && Platform.isAndroid) {
      try {
        final Uint8List nv21Bytes = yuv420ToNv21(image);

        final sensorOrientation = camera.sensorOrientation;
        InputImageRotation? rotation =
            InputImageRotationValue.fromRawValue(sensorOrientation);

        if (rotation == null) {
          return null;
        }

        return InputImage.fromBytes(
          bytes: nv21Bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow:
                image.planes[0].bytesPerRow, // Solo il piano Y è rilevante
          ),
        );
      } catch (e) {
        return null;
      }
    }

    // Per NV21 o BGRA8888
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888) ||
        image.planes.length != 1) {
      return null;
    }

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// Funzione per convertire YUV_420_888 in BGRA8888
  Uint8List yuv420ToNv21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;

    // Luminanza (Y)
    final Uint8List nv21Bytes = Uint8List(ySize + (ySize ~/ 2));
    nv21Bytes.setRange(0, ySize, image.planes[0].bytes);

    // UV piani: li interleaviamo per creare il formato NV21
    final Uint8List uPlane = image.planes[1].bytes;
    final Uint8List vPlane = image.planes[2].bytes;

    for (int i = 0; i < uPlane.length; i++) {
      nv21Bytes[ySize + (i * 2) + 1] = uPlane[i]; // U
      nv21Bytes[ySize + (i * 2)] = vPlane[i]; // V
    }

    return nv21Bytes;
  }

  final Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  bool _isGalleryMode = false;

  @override
  Widget build(BuildContext context) {
      if (!_isInitialized || _controller?.value.isInitialized != true) {
        return const Center(child: CircularProgressIndicator());
      }

      return ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Center(
              child: CameraPreview(
                _controller!,
                child: !_isGalleryMode
                    ? (_customPaint ?? Container())
                    : Container(),
              ),
            ),
            _detectionViewModeToggle(),
            _zoomControl(),
          ],
        ),
      );
  }

  Widget _detectionViewModeToggle() => Positioned(
        bottom: 8,
        left: 8,
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: FloatingActionButton(
            heroTag: Object(),
            onPressed: () => _getImage(ImageSource.gallery),
            backgroundColor: Colors.black54,
            child: Icon(
              Icons.photo_library_outlined,
              size: 25,
            ),
          ),
        ),
      );
  Future _getImage(ImageSource source) async {
    setState(() {
      _isGalleryMode = true; // Imposta il flag quando usiamo la galleria
      _customPaint = null; // Rimuovi il CustomPaint esistente
    });
    try {
      final pickedFile = await _imagePicker?.pickImage(source: source);
      if (pickedFile != null) {
        _processFile(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGalleryMode = false; // Resetta il flag dopo aver finito
        });
      }
    }
  }

  Future _processFile(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    await _processImage(inputImage);
  }

  Widget _zoomControl() => Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Slider(
                    value: _currentZoomLevel,
                    min: _minAvailableZoom,
                    max: _maxAvailableZoom,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      setState(() {
                        _currentZoomLevel = value;
                      });
                      await _controller?.setZoomLevel(value);
                    },
                  ),
                ),
                Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        '${_currentZoomLevel.toStringAsFixed(1)}x',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
