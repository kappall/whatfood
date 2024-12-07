import 'package:flutter/material.dart'; // Importa il pacchetto Material per la UI
import 'package:firebase_core/firebase_core.dart'; // Importa Firebase
import 'firebase_options.dart'; // Importa il file generato automaticamente da FlutterFire CLI

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Necessario per operazioni asincrone prima di runApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Configura Firebase
  );
  runApp(MyApp()); // Avvia l'app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whatfood', // Titolo della tua app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema principale
      ),
      home: MyHomePage(), // Schermata iniziale della tua app
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'), // Titolo della barra
      ),
      body: Center(
        child: Text(
            'Benvenuto nella tua app con Firebase!'), // Contenuto della pagina
      ),
    );
  }
}
