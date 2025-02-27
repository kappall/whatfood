import 'package:flutter/material.dart';

class BounceIconButton extends StatefulWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final bool isActive;
  final VoidCallback onPressed;
  final Color activeColor;
  final Color inactiveColor;

  const BounceIconButton({
    super.key,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.isActive,
    required this.onPressed,
    this.activeColor = Colors.red,
    this.inactiveColor = Colors.white,
  });

  @override
  _BounceIconButtonState createState() => _BounceIconButtonState();
}

class _BounceIconButtonState extends State<BounceIconButton> {
  double _scale = 1.0;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.isActive;
  }

  void _animate() async {
    setState(() {
      _scale = 1.2;
      _isActive = !_isActive;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      _scale = 1.0;
    });

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _animate,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
        child: Icon(
          _isActive ? widget.activeIcon : widget.inactiveIcon,
          color: _isActive ? widget.activeColor : widget.inactiveColor,
          size: 30,
        ),
      ),
    );
  }
}
