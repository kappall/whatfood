import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';

class HomePage extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomePage({
    super.key,
    required this.scaffoldKey,
  });

  void displayEndDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;

    return Column(
      children: [
        AppBar(
          title: const Text('Home'),
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
                icon: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePic),
                  radius: 20,
                ),
                onPressed: () {
                  scaffoldKey.currentState?.openEndDrawer();
                },
              );
            }),
          ],
        ),
        Expanded(child: Text('data'))
      ],
    );
  }
}
