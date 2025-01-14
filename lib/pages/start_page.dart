import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatfood/button_styles.dart';
import 'package:whatfood/firebase_options.dart';
import 'package:whatfood/pages/camera_scanner.dart';
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
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              if (user?.emailVerified ?? false) {
                print('You are a verified user\n ${user!.email}\n ${user.uid}');
              } else {
                print('You need to verify your email');
              }

              return Stack(
                children: [
                  Align(
                    alignment: const Alignment(0,
                        -0.75), // Coordinata Y negativa per la metà superiore
                    child: const Text(
                      "Welcome in Whatfood",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterView()));
                          },
                          style: ButtonStyles.elevatedButtonStyle(
                              backgroundColor: Colors.lightGreen),
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
                              backgroundColor: Colors.lightGreen),
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 20),
                        const GuestAccessWidget(),
                      ],
                    ),
                  ),
                ],
              );
            default:
              return const Center(child: Text("Loading..."));
          }
        },
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
  int _selectedIndex = 2; // Indice iniziale per la pagina "Home"

  late final List<Widget> _pages; // Pagine basate su isGuest

  @override
  void initState() {
    super.initState();

    // Inizializzazione condizionale per ospiti e utenti registrati
    if (widget.isGuest) {
      _pages = [
        CameraScanner(),
        GuestRecipePage(),
        GuestHomePage(),
        GuestShopPage(),
        GuestFavorites(),
      ];
    } else {
      _pages = [
        CameraScanner(),
        RecipePage(),
        HomePage(),
        ShopPage(),
        FavoritesPage(),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Aggiorna l'indice selezionato
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'Whatfood', // Mostra il titolo in base all'indice
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => widget.isGuest
                      ? const GuestProfilePage()
                      : const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Mostra la pagina corrispondente
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
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
