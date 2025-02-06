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

import 'package:whatfood/features/scanner/painters/barcode_detector_painter.dart';
import 'package:whatfood/features/scanner/product_modal.dart';
import 'package:whatfood/features/scanner/widgets/detection_toggle.dart';
import 'package:whatfood/features/scanner/widgets/zoom_control.dart';

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
      rethrow;
    }
  }

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];

    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      _controller?.initialize().then((_) {
        if (!mounted) return;

        _controller?.getMinZoomLevel().then((value) {
          _currentZoomLevel = value;
          _minAvailableZoom = value;
        });

        _controller?.getMaxZoomLevel().then((value) {
          _maxAvailableZoom = min(value, 3.0);
        });
        _controller?.startImageStream(_processCameraImage);
        setState(() {});
      });
    } catch (e) {
      return;
    }
  }

  void _processCameraImage(CameraImage image) {
    if (_isBusy || _isModalVisible || _controller == null || !mounted) {
      return;
    }
    _isBusy = true;
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage != null) {
        _processImage(inputImage);
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
      rethrow;
    }
  }

  Future<void> _processImage(InputImage image) async {
    if (_debounceTimer?.isActive ?? false) return;
    _debounceTimer = Timer(const Duration(seconds: 1), () {});

    final barcodes = await _barcodeScanner.processImage(image);

    if (barcodes.isNotEmpty &&
        barcodes.first.rawValue != null &&
        image.metadata?.size != null &&
        image.metadata?.rotation != null) {
      if (_scannedCode != barcodes.first.rawValue) {
        if (!_isGalleryMode) {
          final painter = BarcodeDetectorPainter(
            barcodes,
            image.metadata!.size,
            image.metadata!.rotation,
          );
          setState(() {
            _customPaint = CustomPaint(painter: painter);
          });
        }
        _scannedCode = barcodes.first.rawValue!;
        await _showProductModal();
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showProductModal() async {
    if (!mounted || _isModalVisible) return;

    setState(() => _isModalVisible = true);

    try {
      final url = Uri.https(
        'world.openfoodfacts.org',
        '/api/v2/product/$_scannedCode?fields=product_name,nutriscore_data,nutriments,nutrition_grades',
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
          builder: (context) => ProductModal(productData: productData),
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
    await _controller?.stopImageStream();
    await Future.delayed(Duration(milliseconds: 1500));
    await _controller?.startImageStream(_processCameraImage);
  }

  Future<void> _showErrorDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product not found'),
        content: Text(
          'Product not found in the database.',
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
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);

    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
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

  final Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  bool _isGalleryMode = false;

  @override
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
              child:
                  !_isGalleryMode ? (_customPaint ?? Container()) : Container(),
            ),
          ),
          DetectionToggle(
            onPressed: _getImage,
          ),
          ZoomControl(
            currentZoomLevel: _currentZoomLevel,
            minAvailableZoom: _minAvailableZoom,
            maxAvailableZoom: _maxAvailableZoom,
            onZoomChanged: (value) async {
              setState(() {
                _currentZoomLevel = value;
              });
              await _controller?.setZoomLevel(value);
            },
          ),
        ],
      ),
    );
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _isGalleryMode = true;
      _customPaint = null;
    });
    try {
      final pickedFile = await _imagePicker?.pickImage(source: source);
      if (pickedFile != null) {
        _processFile(pickedFile.path);
      }
    } catch (e) {
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isGalleryMode = false;
        });
      }
    }
  }

  Future _processFile(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    await _processImage(inputImage);
  }
}
