import 'package:flutter/material.dart';
import 'package:whatfood/pages/start_page.dart';

class GuestHomePage extends StatelessWidget {
  const GuestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Home',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Center(
            child: const Text(
              'Benvenuto nella Home',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}

class GuestShopPage extends StatelessWidget {
  const GuestShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Shop',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    'To access this function you need an accout',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20), // Spazio tra il testo e i pulsanti
                ElevatedButton(
                  onPressed: () {
                    // Naviga alla pagina di accesso
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StartPage()),
                    );
                  },
                  child: const Text('Return to start page'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GuestRecipePage extends StatelessWidget {
  const GuestRecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Ricette',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Text(
                    'To access this function you need an accout',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20), // Spazio tra il testo e i pulsanti
                ElevatedButton(
                  onPressed: () {
                    // Naviga alla pagina di accesso
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StartPage()),
                    );
                  },
                  child: const Text('Return to start page'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GuestProfilePage extends StatelessWidget {
  const GuestProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Account'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Text(
                      'To access this function you need an accout',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                      height: 20), // Spazio tra il testo e i pulsanti
                  ElevatedButton(
                    onPressed: () {
                      // Naviga alla pagina di accesso
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StartPage()),
                      );
                    },
                    child: const Text('Return to start page'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
