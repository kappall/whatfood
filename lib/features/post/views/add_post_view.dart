import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class AddPostView extends ConsumerWidget {
  const AddPostView({super.key});

  void navigateToType(BuildContext context, String type) {
    Routemaster.of(context).push('/home/add_post/add_post_type/$type');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardSize = 120;
    double iconSize = 60;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () =>
              Routemaster.of(context).popUntil((route) => route.path == '/'),
        ),
        title: Text("Add Post"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: GestureDetector(
                onTap: () => navigateToType(context, 'image'),
                child: Column(
                  children: [
                    Text(
                      'Add an Image Post',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12), // Space between text and card
                    SizedBox(
                      height: cardSize,
                      width: cardSize,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: iconSize,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 150,
            ),
            // Column for Text Post
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: GestureDetector(
                onTap: () => navigateToType(context, 'text'),
                child: Column(
                  children: [
                    Text(
                      'Add a Text Post',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12), // Space between text and card
                    SizedBox(
                      height: cardSize,
                      width: cardSize,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        child: Center(
                          child: Icon(
                            Icons.font_download_outlined,
                            size: iconSize,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
