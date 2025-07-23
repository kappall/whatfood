import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'dart:convert' as convert;

import 'package:whatfood/features/scanner/painters/barcode_detector_painter.dart';
import 'package:whatfood/features/scanner/product_modal.dart';
import 'package:whatfood/features/scanner/utils/ingridients_processor.dart';
import 'package:whatfood/features/scanner/widgets/detection_toggle.dart';
import 'package:whatfood/features/scanner/widgets/zoom_control.dart';

enum DetectorViewMode { liveFeed, gallery }

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ScanScreenState();
}

class ScanScreenState extends ConsumerState<ScanScreen> {
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

  static const unhealthyIngredients = {
    'hydrogenated fats',
    'glucose syrup',
    'aspartame',
    'monosodium glutamate',
    'artificial coloring',
    'palm oil',
    'sucrose',
    'preservative',
    'E621',
    'high fructose corn syrup'
  };

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
        } else {
          debugPrint('No back camera found');
        }
      }
      if (_cameraIndex != -1) {
        await _startLiveFeed();
      }
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Error initializing camera: ${e.toString()}');
    }
  }

  Future<void> _startLiveFeed() async {
    if (_controller != null) {
      try {
        await _stopLiveFeed();
      } catch (e) {
        debugPrint('Error stopping previous camera feed: ${e.toString()}');
      }
    }

    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      Platform.isAndroid ? ResolutionPreset.low : ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller?.initialize();
      if (!mounted) return;

      await _controller?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });

      await _controller?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = min(value, 3.0);
      });

      if (_controller != null && mounted) {
        await _controller!.startImageStream(_processCameraImage);
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error starting camera feed: ${e.toString()}');
      // Clean up on error
      await _stopLiveFeed();
    }
  }

  Future<void> _stopLiveFeed() async {
    if (_controller == null) return;

    try {
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
      await _controller!.dispose();
    } catch (e) {
      debugPrint('Error stopping camera feed: ${e.toString()}');
    } finally {
      _controller = null;
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

  Future<void> _processImage(InputImage image) async {
    if (_debounceTimer?.isActive ?? false) return;
    _debounceTimer = Timer(const Duration(seconds: 2), () {});

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
          'world.openfoodfacts.org', '/api/v2/product/$_scannedCode', {
        'fields': 'product_name,brands,ingredients_text,image_url,'
            'nutriscore_data,nutriments,nutrition_grades,'
            'nutriscore_grade,ingredients_text_en,quantity',
        'lc': 'en',
      });
      _scannedCode = '';

      final response = await http.get(url);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse =
            convert.jsonDecode(response.body) as Map<String, dynamic>;
        final productData = jsonResponse['product'];

        // Parse quantity
        final String quantityString =
            productData['quantity']?.toString().trim() ?? '100';
        final List<String> parts = quantityString.split(' ');
        int quantity = int.tryParse(parts[0]) ?? 100;
        if (parts.length > 1 && parts[1].toLowerCase() == 'kg') {
          quantity *= 1000;
        }

        final userIntolerances = ref.read(userProvider)!.preferences;
        // Process ingredients
        final ingredientsText = productData['ingredientes_text_en'] ??
            productData['ingredients_text'];
        List<String> processedIngredients = List.empty(),
            intolerableIngredients = List.empty(),
            unhealthyIngredients = List.empty();

        if (ingredientsText != null) {
          var (
            processedIngredients,
            intolerableIngredients,
            unhealthyIngredients
          ) = IngredientsProcessor.processIngredients(
              ingredientsText, userIntolerances);

          // Show warning for intolerances
          if (intolerableIngredients.isNotEmpty) {
            final shouldContinue =
                await _showIntoleranceWarningDialog(intolerableIngredients);
            if (!shouldContinue) return;
          }

          // Show warning for unhealthy ingredients
          if (unhealthyIngredients.isNotEmpty) {
            final shouldContinue =
                await _showUnhealthyWarningDialog(unhealthyIngredients);
            if (!shouldContinue) return;
          }
        }

        // Show product modal if user wants to continue
        if (!mounted) return;
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ProductModal(
            productData: productData,
            quantity: quantity,
            processedIngredients: processedIngredients,
            intolerableIngredients: intolerableIngredients,
            unhealthyIngredients: unhealthyIngredients,
          ),
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

  Future<bool> _showIntoleranceWarningDialog(
      List<String> intolerableIngredients) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
          size: 48,
        ),
        title: const Text(
          'Intolerance Warning!',
          style: TextStyle(color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...intolerableIngredients.map((ingredient) => Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    ingredient,
                    style: const TextStyle(color: Colors.black),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueGrey, // Colore del testo
              textStyle: const TextStyle(
                fontSize: 14, // Dimensione del testo
                fontWeight: FontWeight.bold, // Spessore del testo
              ),
            ),
            child: const Text(
              'Back',
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent, // Colore del testo
              textStyle: const TextStyle(
                fontSize: 16, // Dimensione del testo
                fontWeight: FontWeight.bold, // Spessore del testo
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Continue Anyway',
            ),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  Future<bool> _showUnhealthyWarningDialog(List<String> unhealthyIngredients) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning_rounded,
          color: Colors.orange,
          size: 48,
        ),
        title: const Text('Unhealthy Ingredients'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'This product contains potentially unhealthy ingredients:'),
            const SizedBox(height: 8),
            ...unhealthyIngredients.map((ingredient) => Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('• $ingredient',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Go Back'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue Anyway'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
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
    if (_isBusy) return;

    setState(() {
      _isGalleryMode = true;
      _customPaint = null;
    });

    try {
      final pickedFile = await _imagePicker?.pickImage(source: source);
      if (pickedFile != null) {
        await _processFile(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted && _scannedCode.isEmpty) {
        setState(() {
          _isGalleryMode = false;
        });
      }
    }
  }

  Future _processFile(String path) async {
    setState(() => _isBusy = true);
    try {
      final inputImage = InputImage.fromFilePath(path);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
        _scannedCode = barcodes.first.rawValue!;
        await _showProductModal();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No barcode found in the image'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _isGalleryMode = false;
        });
      }
    }
  }
}
