import 'package:flutter/material.dart';

class IntollerancesList extends StatefulWidget {
  final List<String> intollerances;
  const IntollerancesList({super.key, required this.intollerances});

  static const List<String> foodIntolerances = [
    // Latticini e Proteine Animali
    "Milk",
    "Eggs",
    "Fish",
    "Shellfish",
    "Mollusks",
    "Crustaceans",
    "Tree Nuts",

    // Legumi, Cereali e Condimenti
    "Peanuts",
    "Soy",
    "Wheat",
    "Gluten",
    "Sesame",
    "Mustard",
    "Sulfites",

    // Cereali e Frutti di Mare
    "Lupin",
    "Celery",
    "Corn",
    "Rice",
    "Barley",
    "Rye"
  ];

  @override
  State<IntollerancesList> createState() => _IntollerancesListState();
}

class _IntollerancesListState extends State<IntollerancesList>
    with SingleTickerProviderStateMixin {
  late List<ScrollController> _scrollControllers;
  late AnimationController _animationController;
  final List<double> _scrollOffsets = [0, 0, 0];
  final List<bool> _isManualScrolling = [false, false, false];
  final double _autoScrollSpeed = 1;
  final List<double> _scrollSpeeds = [1, 1, 1];

  @override
  void initState() {
    super.initState();
    _scrollControllers = List.generate(3, (index) {
      final controller = ScrollController();
      controller.addListener(() {
        _handleManualScroll(index);
      });
      return controller;
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _animationController.addListener(_updateScroll);
  }

  void _handleManualScroll(int index) {
    if (_scrollControllers[index].hasClients &&
        _scrollControllers[index].position.isScrollingNotifier.value) {
      setState(() {
        _isManualScrolling[index] = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isManualScrolling[index] = false;
          });
        }
      });
    }
  }

  void _updateScroll() {
    for (int i = 0; i < 3; i++) {
      if (!_scrollControllers[i].hasClients || _isManualScrolling[i]) continue;

      _scrollOffsets[i] += _scrollSpeeds[i] * _autoScrollSpeed;
      final maxScroll = _scrollControllers[i].position.maxScrollExtent;

      if (_scrollOffsets[i] > maxScroll) {
        _scrollOffsets[i] = 0;
        _scrollControllers[i].jumpTo(0);
      } else {
        _scrollControllers[i].jumpTo(_scrollOffsets[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsPerRow = (IntollerancesList.foodIntolerances.length / 3).ceil();

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[100],
        border: Border.all(
          color: Colors.green,
          width: 1,
        ),
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white.withValues(alpha: 0.0),
              Colors.white,
              Colors.white,
              Colors.white.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.1, 0.9, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int row = 0; row < 3; row++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    controller: _scrollControllers[row],
                    scrollDirection: Axis.horizontal,
                    reverse: row == 1,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: itemsPerRow,
                    itemBuilder: (context, index) {
                      final actualIndex =
                          (row * itemsPerRow + (index % itemsPerRow)) %
                              IntollerancesList.foodIntolerances.length;
                      final intolerance =
                          IntollerancesList.foodIntolerances[actualIndex];
                      final isSelected =
                          widget.intollerances.contains(intolerance);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: FilterChip(
                          label: Text(
                            intolerance,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                widget.intollerances.add(intolerance);
                              } else {
                                widget.intollerances.remove(intolerance);
                              }
                            });
                          },
                          selectedColor: Colors.green,
                          checkmarkColor: Colors.white,
                          backgroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color:
                                  isSelected ? Colors.green : Colors.grey[400]!,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _scrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
