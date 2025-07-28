import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/profile/controller/user_profile_controller.dart';
import 'package:whatfood/l10n/app_localizations.dart';

/// A widget that wraps every onboarding page so we only have to
/// maintain the layout once.
class _OnboardingLayout extends StatelessWidget {
  const _OnboardingLayout({
    required this.illustration,
    required this.title,
    required this.body,
    required this.pageIndex,
    required this.totalPages,
  });

  final Widget illustration;
  final String title;
  final String body;
  final int pageIndex;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: 'Onboarding page ${pageIndex + 1} of $totalPages',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: illustration,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text(
                      title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      body,
                      style: textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  static const _kDuration = Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  late final PageController _pageController;
  int _currentIndex = 0;

  /// We also animate the progress bar & buttons with a small fade.
  late final AnimationController _fadeController;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fade = Tween<double>(begin: 1, end: 0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.ease));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Helper to go forward with haptic feedback.
  Future<void> _next() async {
    await HapticFeedback.lightImpact();
    if (_currentIndex == _pages(context).length - 1) {
      await _finishOnboarding();
    } else {
      await _pageController.nextPage(duration: _kDuration, curve: _kCurve);
    }
  }

  /// Helper to go back.
  Future<void> _prev() async {
    await HapticFeedback.lightImpact();
    unawaited(
        _pageController.previousPage(duration: _kDuration, curve: _kCurve));
  }

  /// Finish onboarding and navigate to home.
  Future<void> _finishOnboarding() async {
    await HapticFeedback.heavyImpact();
    await ref
        .read(userProfileControllerProvider.notifier)
        .markOnboardingComplete(context);
  }

  /// Skip entirely.
  Future<void> _skip() async {
    await HapticFeedback.mediumImpact();
    await _finishOnboarding();
  }

  /// The actual page data. We keep it here so localisation rebuilds
  /// automatically when the locale changes.
  List<Map<String, dynamic>> _pages(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'illustration': Image.asset(
          'assets/images/onboarding1.png',
          semanticLabel: l10n.onboardingIllustrationLabel1,
        ),
        'title': l10n.onboardingTitle1,
        'body': l10n.onboardingBody1,
      },
      {
        'illustration': Image.asset(
          'assets/images/onboarding2.png',
          semanticLabel: l10n.onboardingIllustrationLabel2,
        ),
        'title': l10n.onboardingTitle2,
        'body': l10n.onboardingBody2,
      },
      {
        'illustration': Image.asset(
          'assets/images/onboarding3.png',
          semanticLabel: l10n.onboardingIllustrationLabel3,
        ),
        'title': l10n.onboardingTitle3,
        'body': l10n.onboardingBody3,
      },
      {
        'illustration': Image.asset(
          'assets/images/onboarding4.png',
          semanticLabel: l10n.onboardingIllustrationLabel4,
        ),
        'title': l10n.onboardingTitle4,
        'body': l10n.onboardingBody4,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _pages(context);

    // Show a loader while user is still null (rare race condition).
    final user = ref.watch(userProvider);
    if (user == null) return const Loader();

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              _fadeController.forward().then((_) => _fadeController.reverse());
            },
            itemBuilder: (context, index) {
              final p = pages[index];
              return _OnboardingLayout(
                illustration: p['illustration'] as Widget,
                title: p['title'] as String,
                body: p['body'] as String,
                pageIndex: index,
                totalPages: pages.length,
              );
            },
          ),
          // Skip button (top-right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Semantics(
                  button: true,
                  label: l10n.onboardingSkip,
                  child: TextButton(
                    onPressed: _skip,
                    child: Text(
                      l10n.onboardingSkip,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Back / Next buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  FadeTransition(
                    opacity: _fade,
                    child: _currentIndex == 0
                        ? const SizedBox(width: 64)
                        : Semantics(
                            button: true,
                            label: l10n.onboardingBack,
                            child: TextButton.icon(
                              onPressed: _prev,
                              icon: const Icon(Icons.chevron_left),
                              label: Text(l10n.onboardingBack),
                            ),
                          ),
                  ),
                  // Next / Start button
                  ElevatedButton.icon(
                    onPressed: _next,
                    icon: _currentIndex == pages.length - 1
                        ? const Icon(Icons.celebration)
                        : const Icon(Icons.chevron_right),
                    label: Text(
                      _currentIndex == pages.length - 1
                          ? l10n.onboardingStart
                          : l10n.onboardingNext,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
