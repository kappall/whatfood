import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/google_signin_button.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/home/drawers/profile_drawer.dart';
import 'package:whatfood/features/home/pages/home_page.dart';
import 'package:whatfood/features/scanner/camera_scanner.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/models/user_model.dart';
import 'user_page.dart';
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
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil('/register', (_) => true),
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
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login/', (_) => true),
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
                  const GoogleSigninButton(),
                  const SizedBox(height: 30),
                  const GuestAccessWidget(),
                  const Spacer(),
                ],
              ),
            ),
    );
  }
}

class GuestAccessWidget extends StatelessWidget {
  const GuestAccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        try {
          await FirebaseAuth.instance.signInAnonymously();
          if (!context.mounted) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil('main_gurest', (_) => false);
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
  int _selectedIndex = 2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<Widget> _pages;
  UserModel? userModel; // Variabile per memorizzare i dati dell'utente

  @override
  void initState() {
    super.initState();
    if (!widget.isGuest) {
      _fetchUserData(); // Recupera i dati dell'utente solo se non è un guest
    }

    // Inizializza le pagine
    if (widget.isGuest) {
      _pages = [
        CameraScanner(),
        GuestRecipePage(scaffoldKey: _scaffoldKey),
        GuestHomePage(scaffoldKey: _scaffoldKey),
        GuestShopPage(scaffoldKey: _scaffoldKey),
        GuestFavorites(scaffoldKey: _scaffoldKey),
      ];
    } else {
      _pages = [
        CameraScanner(),
        RecipePage(scaffoldKey: _scaffoldKey),
        HomePage(scaffoldKey: _scaffoldKey),
        ShopPage(scaffoldKey: _scaffoldKey),
        FavoritesPage(scaffoldKey: _scaffoldKey),
      ];
    }
  }

  // Metodo per recuperare i dati dell'utente da Firestore
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color.fromARGB(255, 235, 235, 235),
        body: _pages[_selectedIndex],
        endDrawer: ProfileDrawer(
          user: widget.isGuest ? null : FirebaseAuth.instance.currentUser,
          userModel: userModel, // Passa i dati dell'utente al ProfileDrawer
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.document_scanner_outlined),
              label: 'Scanner',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              label: 'Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Report',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline),
              label: 'Favorites',
            ),
          ],
          currentIndex: _selectedIndex,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
