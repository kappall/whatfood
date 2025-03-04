import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BounceIconButton extends ConsumerStatefulWidget {
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
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white,
  });

  @override
  ConsumerState<BounceIconButton> createState() => BounceIconButtonState();
}

class BounceIconButtonState extends ConsumerState<BounceIconButton> {
  double _scale = 1.0;

  void _animate() async {
    setState(() {
      _scale = 1.2;
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
          widget.isActive ? widget.activeIcon : widget.inactiveIcon,
          color: widget.isActive ? widget.activeColor : widget.inactiveColor,
          size: 30,
        ),
      ),
    );
  }
}
