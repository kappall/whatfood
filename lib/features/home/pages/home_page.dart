import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatfood/core/constants/costants.dart';
import 'package:whatfood/models/user_model.dart';

class HomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomePage({
    super.key,
    required this.scaffoldKey,
  });

  @override
  State<StatefulWidget> createState() => _HomePage(scaffoldKey);
}

class _HomePage extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey;
  UserModel? userModel;

  _HomePage(this.scaffoldKey);
  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Recupera i dati dell'utente all'inizializzazione
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

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Home'),
          backgroundColor: Colors.lightGreen,
          titleTextStyle: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
              iconSize: 32,
            ),
            Builder(builder: (context) {
              return IconButton(
                icon: const CircleAvatar(
                  backgroundImage: NetworkImage(Constants.avatarDefault),
                  radius: 20,
                ),
                onPressed: () {
                  scaffoldKey.currentState?.openEndDrawer();
                },
              );
            }),
          ],
        ),
        Expanded(child: Text('text'))
      ],
    );
  }
}
