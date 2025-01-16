import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whatfood/firebase_options.dart';
import 'package:whatfood/pages/camera_scanner.dart';
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
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;

            if (user?.emailVerified ?? false) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/main_page/',
                (route) => false,
              );
            }
            return Scaffold(
              backgroundColor:
                  const Color(0xFFF5F5F5), // Sfondo chiaro e neutro
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/register/',
                          (route) => true,
                        );
                      },
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
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login/',
                          (route) => true,
                        );
                      },
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
                    TextButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signInAnonymously();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/main_page_guest/',
                            (route) => false,
                          );
                        } catch (e) {
                          print('Errore durante il login anonimo: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error during guest login: $e',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
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
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            );

          default:
            return const Scaffold(
              backgroundColor: Color(0xFFF5F5F5),
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
                ),
              ),
            );
        }
      },
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
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/main_page_guest/', (route) => false);
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
      child: const Text(
        'Enter as guest',
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
