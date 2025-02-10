import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/home/pages/for_you.dart';
import 'package:whatfood/models/user_model.dart';
import 'package:whatfood/features/post/pages/add_post_page.dart';
import 'package:whatfood/theme/theme.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  UserModel? userModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          titleTextStyle: Theme.of(context).textTheme.headlineMedium,
          bottom: TabBar(
            splashFactory: NoSplash.splashFactory,
            labelColor: Theme.of(context).textTheme.bodyLarge?.color,
            controller: _tabController,
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.filter_list,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "For You",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _tabController.index == 0
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Inspiration",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _tabController.index == 1
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Colors.grey,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => themeNotifier.toggleTheme(),
                      icon: Icon(
                        Icons.brightness_6,
                      ),
                    )
                  ],
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
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () {
          Routemaster.of(context).push('/add_post');
        },
        backgroundColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildForYouPage() {
    return ForYou();
  }

  Widget _buildInspirationPage() {
    return ForYou();
  }
}
