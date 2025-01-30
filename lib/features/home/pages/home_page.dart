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

class _HomePage extends State<HomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey;
  UserModel? userModel;
  late TabController _tabController;

  _HomePage(this.scaffoldKey);

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _tabController = TabController(length: 2, vsync: this);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.white,
          bottom: TabBar(
            splashFactory: NoSplash.splashFactory,
            controller: _tabController,
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.filter_list, color: Colors.black),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "For You",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _tabController.index == 0
                              ? Colors.black
                              : Colors.black26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Align(
                  widthFactor: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Inspiration",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _tabController.index == 1
                          ? Colors.black
                          : Colors.black26,
                    ),
                  ),
                ),
              ),
            ],
            isScrollable: false,
            onTap: (index) {
              setState(() {});
            },
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForYouPage(),
          _buildInspirationPage(),
        ],
      ),
    );
  }

  Widget _buildForYouPage() {
    return Center(
      child: Text('Contenuto per "For You"'),
    );
  }

  Widget _buildInspirationPage() {
    return Center(
      child: Text('Contenuto per "Inspiration"'),
    );
  }
}
