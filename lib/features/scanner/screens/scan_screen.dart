import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/private_area/controllers/food_suggestion_controller.dart';
import 'dart:convert' as convert;

import 'package:whatfood/features/scanner/painters/barcode_detector_painter.dart';
import 'package:whatfood/features/scanner/product_modal.dart';
import 'package:whatfood/features/scanner/utils/ingridients_processor.dart';
import 'package:whatfood/models/food_suggestion.dart';

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

  bool _isScanningActive = false;

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
    debugPrint("starting live feed");
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
    _isScanningActive = true;
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
      await _stopLiveFeed();
    }
  }

  Future<void> _stopLiveFeed() async {
    _isScanningActive = false;
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
    if (_isBusy ||
        _isModalVisible ||
        _controller == null ||
        !mounted ||
        !_isScanningActive) {
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
    _debounceTimer = Timer(const Duration(seconds: 20), () {});

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
        if (mounted) setState(() {});
        return;
      }
    }

    try {
      final imageLabeler = ImageLabeler(options: ImageLabelerOptions());
      final labels = await imageLabeler.processImage(image);
      imageLabeler.close();

      if (labels.isNotEmpty) {
        final candidates = labels
            .take(3)
            .map((l) => l.label)
            .where((l) => l.trim().isNotEmpty)
            .toList();

        for (final candidate in candidates) {
          final found = await _searchProductByName(candidate);
          if (found) return;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No product match found for the detected item.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Image labeling failed: ${e.toString()}');
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showProductModal() async {
    _isScanningActive = false;
    await _controller?.stopImageStream();
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

        final String quantityString =
            productData['quantity']?.toString().trim() ?? '100';
        final List<String> parts = quantityString.split(' ');
        int quantity = int.tryParse(parts[0]) ?? 100;
        if (parts.length > 1 && parts[1].toLowerCase() == 'kg') {
          quantity *= 1000;
        }

        final userIntolerances = ref.read(userProvider)!.preferences;

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

          if (intolerableIngredients.isNotEmpty) {
            final shouldContinue =
                await _showIntoleranceWarningDialog(intolerableIngredients);
            if (!shouldContinue) return;
          }

          if (unhealthyIngredients.isNotEmpty) {
            final shouldContinue =
                await _showUnhealthyWarningDialog(unhealthyIngredients);
            if (!shouldContinue) return;
          }
        }

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
          _isScanningActive = true;
        });
      }
      await _restartStream();
    }
  }

  Future<void> _restartStream() async {
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
              foregroundColor: Colors.blueGrey,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text(
              'Back',
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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

  bool _isGalleryMode = true;

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller?.value.isInitialized != true) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(
            _controller!,
            child:
                !_isGalleryMode ? (_customPaint ?? Container()) : Container(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 150,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Scan Product',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black54],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FloatingActionButton(
                      heroTag: 'galleryBtn',
                      onPressed: () => _getImage(ImageSource.gallery),
                      backgroundColor: Colors.white24,
                      child:
                          const Icon(Icons.photo_library, color: Colors.white),
                    ),
                    Material(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 48,
                        width: 150,
                        child: Row(
                          children: [
                            const Icon(Icons.zoom_out, color: Colors.white),
                            Expanded(
                              child: Slider(
                                value: _currentZoomLevel,
                                min: _minAvailableZoom,
                                max: _maxAvailableZoom,
                                activeColor: Colors.greenAccent,
                                inactiveColor: Colors.white30,
                                onChanged: (value) async {
                                  setState(() {
                                    _currentZoomLevel = value;
                                  });
                                  await _controller?.setZoomLevel(value);
                                },
                              ),
                            ),
                            const Icon(Icons.zoom_in, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
        return;
      }

      try {
        final base64Image = await imageFileToBase64(path);
        final concepts = await recognizeFoodWithClarifai(base64Image);

        if (concepts != null && concepts.isNotEmpty) {
          final filteredConcepts =
              concepts.where((c) => c['confidence'] > 0.02).toList();
          if (filteredConcepts.isNotEmpty) {
            for (final concept in filteredConcepts) {
              print('${concept['name']} : ${concept['confidence']}');
            }
          }
          final topConcepts =
              filteredConcepts.take(2).map((c) => c['name']).join(" ");
          final food = Map<String, String>();

          if (food != null) {
            _showProductModalFromData(food);
          }

          if (food == null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No matching product found'),
                duration: Duration(seconds: 6),
              ),
            );
          }
        } else if (mounted) {}
      } catch (e) {
        debugPrint('Image labeling failed for file: ${e.toString()}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error processing image: ${e.toString()}'),
              duration: const Duration(seconds: 2),
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

  Future<List<Map<String, dynamic>>?> recognizeFoodWithClarifai(
      String base64Image) async {
    final url = Uri.parse(
        'https://api.clarifai.com/v2/users/clarifai/apps/main/models/food-item-v1-recognition/versions/dfebc169854e429086aceb8368662641/outputs');
    final headers = {
      'Authorization': 'Key 310eeb39f0f84d70b373f439f396f3d1',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'inputs': [
        {
          'data': {
            'image': {
              'base64': base64Image,
            }
          }
        }
      ]
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final concepts =
          jsonResponse['outputs']?[0]?['data']?['concepts'] as List<dynamic>?;

      if (concepts == null) return null;

      return concepts
          .map((c) => {
                'name': c['name'],
                'confidence': c['value'],
              })
          .toList();
    } else {
      print('Clarifai API error: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<String> imageFileToBase64(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    return base64Encode(bytes);
  }

  Future<bool> _searchProductByName(String name) async {
    final query = name.trim();
    if (query.isEmpty) return false;

    try {
      final url = Uri.https(
        'world.openfoodfacts.org',
        '/cgi/search.pl',
        {
          'search_terms': query,
          'search_simple': '1',
          'json': '1',
          'page_size': '10',
          'fields':
              'product_name,brands,ingredients_text,image_url,nutriments,quantity',
        },
      );

      final response = await http.get(url);
      if (response.statusCode != 200) return false;

      final jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      final products = (jsonResponse['products'] as List<dynamic>?) ?? [];
      debugPrint("my products:  ${products.toString()}");

      if (products.isEmpty) return false;

      Map<String, String>? best;
      for (final p in products) {
        final pname = (p['product_name'] ?? '').toString();
        if (pname.toLowerCase() == query.toLowerCase()) {
          best = Map<String, String>.from(p as Map);
          break;
        }
      }
      best ??= Map<String, String>.from(products.first as Map);

      await _showProductModalFromData(best);
      return true;
    } catch (e) {
      debugPrint('Search by name failed: ${e.toString()}');
      return false;
    }
  }

  Future<void> _showProductModalFromData(
      Map<String, String> productData) async {
    if (!mounted || _isModalVisible) return;
    setState(() => _isModalVisible = true);

    try {
      final String quantityString = '100';
      final List<String> parts = quantityString.split(' ');
      int quantity = int.tryParse(parts[0]) ?? 100;
      if (parts.length > 1 && parts[1].toLowerCase() == 'kg') {
        quantity *= 1000;
      }

      final userIntolerances = ref.read(userProvider)!.preferences;

      final ingredientsText =
          productData['ingredients_text_en'] ?? productData['ingredients_text'];
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

        if (intolerableIngredients.isNotEmpty) {
          final shouldContinue =
              await _showIntoleranceWarningDialog(intolerableIngredients);
          if (!shouldContinue) return;
        }

        if (unhealthyIngredients.isNotEmpty) {
          final shouldContinue =
              await _showUnhealthyWarningDialog(unhealthyIngredients);
          if (!shouldContinue) return;
        }
      }

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
}
