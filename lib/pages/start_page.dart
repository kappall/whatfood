import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/google_signin_button.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/home/views/home_view.dart';
import 'package:whatfood/features/profile/views/profile_view.dart';
import 'package:whatfood/features/recipes/views/recipes_view.dart';
import 'package:whatfood/features/report/views/report_view.dart';
import 'package:whatfood/features/scanner/camera_scanner.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'guest_page.dart';

class StartPage extends ConsumerWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Welcome to Whatfood",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Routemaster.of(context).push('/register/'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 30,
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton(
                    onPressed: () => Routemaster.of(context).push('/login/'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.lightGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 30,
                      ),
                    ),
                    child: const Text(
                      'Already registered? Login here!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.lightGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  //const GoogleSigninButton(),
                  const SizedBox(height: 30),
                  const GuestAccessWidget(),
                  const Spacer(),
                ],
              ),
            ),
    );
  }
}

class GuestAccessWidget extends ConsumerStatefulWidget {
  const GuestAccessWidget({super.key});

  @override
  ConsumerState<GuestAccessWidget> createState() => _GuestAccessWidgetState();
}

class _GuestAccessWidgetState extends ConsumerState<GuestAccessWidget> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        try {
          ref.read(authControllerProvider.notifier).signInAsGuest(context);
          if (!context.mounted) return;
          Routemaster.of(context).push('/main_guest/');
        } catch (e) {
          showSnackBar(context, 'Error during guest login: ${e.toString()}');
        }
      },
      child: const Text(
        'Enter as Guest',
        style: TextStyle(
          fontSize: 16,
          color: Colors.black,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final bool isGuest;
  const MainPage({super.key, required this.isGuest});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;
  late final List<Widget> _pages;
  @override
  void initState() async {
    super.initState();

    if (widget.isGuest) {
      _selectedIndex = 1;
      _pages = [
        CameraScanner(),
        GuestHomePage(),
      ];
    } else {
      _selectedIndex = 2;
      _pages = [
        CameraScanner(),
        RecipesView(),
        HomeView(),
        ReportView(),
        ProfileView(
          uid: (await Amplify.Auth.getCurrentUser()).userId,
          public: false,
        ),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SafeArea(
        child: Scaffold(
          body: _pages[_selectedIndex],
          backgroundColor: Colors.black,
          bottomNavigationBar: SizedBox(
            height: 50,
            child: BottomNavigationBar(
              iconSize: 28,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.document_scanner_outlined),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_outlined),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outlined),
                  label: '',
                ),
              ],
              currentIndex: _selectedIndex,
              backgroundColor: Colors.black,
              selectedItemColor:
                  Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
              unselectedItemColor: Theme.of(context)
                  .bottomNavigationBarTheme
                  .unselectedItemColor,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedFontSize: 0,
              unselectedFontSize: 0,
            ),
          ),
        ),
      ),
    );
  }
}
