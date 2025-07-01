import 'package:flutter/material.dart';
import 'package:whatfood/features/profile/controller/user_profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      'title': 'Understand Labels Instantly',
      'description':
          'Scan barcodes to get clear, personalized insights on ingredients and nutrition.',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Food Choices Just Got Easier',
      'description':
          'Tell us your allergies, preferences, and goals for personalized recommendations',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': "Discover Recipes You'll Love",
      'description':
          'Explore delicious recipes based on your ingredients and dietary profile',
      'image': 'assets/images/onboarding3.png',
    },
    {
      'title': 'Your Journey to Healthier Eating Starts Here',
      'description':
          'Whatfood helps you make informed decisions for yourself and your family',
      'image': 'assets/images/onboarding4.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(page['image']!, height: 250),
                const SizedBox(height: 32),
                Text(page['title']!,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Text(page['description']!, textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _currentIndex == 0
                  ? null
                  : () => _controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_currentIndex == pages.length - 1) {
                  debugPrint('starting app');
                  ref
                      .read(userProfileControllerProvider.notifier)
                      .markOnboardingComplete(context);
                } else {
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease);
                }
              },
              child: Text(_currentIndex == pages.length - 1 ? 'Start' : 'Next'),
            )
          ],
        ),
      ),
    );
  }
}
