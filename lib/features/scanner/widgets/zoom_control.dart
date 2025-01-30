import 'package:flutter/material.dart';

class ZoomControl extends StatelessWidget {
  final double currentZoomLevel;
  final double minAvailableZoom;
  final double maxAvailableZoom;
  final Function(double) onZoomChanged;

  const ZoomControl({
    super.key,
    required this.currentZoomLevel,
    required this.minAvailableZoom,
    required this.maxAvailableZoom,
    required this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
                  value: currentZoomLevel,
                  min: minAvailableZoom,
                  max: maxAvailableZoom,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white30,
                  onChanged: onZoomChanged,
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
                      '${currentZoomLevel.toStringAsFixed(1)}x',
                      style: const TextStyle(color: Colors.white),
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
}
