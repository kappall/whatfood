import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/firebase_options.dart';
import 'package:whatfood/pages/camera_scanner.dart';
import 'package:whatfood/pages/scanner_page.dart';
import 'package:whatfood/views/login_view.dart';
import 'package:whatfood/views/register_view.dart';
import 'user_page.dart';
import 'guest_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        title: const Text(
          "Welcome in Whatfood",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                final user = FirebaseAuth.instance.currentUser;
                if (user?.emailVerified ?? false) {
                  print(
                      'You are a verified user\n ${user!.email}\n ${user.uid}');
                } else {
                  print('You need to verify your email');
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterView()));
                      },
                      style: ButtonStyles.elevatedButtonStyle(
                          backgroundColor: Colors.green),
                      child: const Text('Register'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginView()));
                      },
                      style: ButtonStyles.elevatedButtonStyle(
                          backgroundColor: Colors.green),
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 20),
                    const GuestAccessWidget(),
                  ],
                );
              default:
                return const Text("Loading...");
            }
          },
        ),
      ),
    );
  }
}

/// Widget separato per l'accesso come ospite
class GuestAccessWidget extends StatelessWidget {
  const GuestAccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        try {
          // Effettua il login anonimo
          await FirebaseAuth.instance.signInAnonymously();
          // Naviga alla pagina principale come ospite
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MainPage(isGuest: true),
            ),
          );
        } catch (e) {
          // Gestione degli errori
          print('Errore durante il login anonimo: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Errore durante l\'accesso anonimo: $e',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      style: ButtonStyles.textButtonStyle(textColor: Colors.blue),
      child: const Text(
        'Enter as guest',
        style: TextStyle(fontSize: 16),
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
  int _selectedIndex = 2; // Home di default

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // In base a isGuest, carica le pagine appropriate
    _pages = widget.isGuest
        ? [
            CameraScanner(),
            GuestRecipePage(),
            GuestHomePage(),
            GuestShopPage(),
          ]
        : [
            CameraScanner(),
            RecipePage(),
            HomePage(),
            ShopPage(),
          ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: const Text(
          'Whatfood',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(3, 2), // Posizione dell'ombra
                blurRadius: 1.0, // Sfocatura
                color: Colors.black, // Colore dell'ombra
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => widget.isGuest
                        ? const GuestProfilePage()
                        : const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner_outlined),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Ricette',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Shop',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white, // Colore delle icone selezionate
        unselectedItemColor: Colors.black, // Colore delle icone non selezionate
        onTap: _onItemTapped,
        type:
            BottomNavigationBarType.fixed, // per applicare i colori di sofondo
      ),
    );
  }
}
