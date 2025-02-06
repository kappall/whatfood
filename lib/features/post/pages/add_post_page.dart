import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class AddPostPage extends ConsumerWidget {
  const AddPostPage({super.key});

  void navigateToType(BuildContext context, String type) {
    Routemaster.of(context).push('/add_post/add_post_type/$type');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardSize = 120;
    double iconSize = 60;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Post"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => navigateToType(context, 'image'),
                child: SizedBox(
                  height: cardSize,
                  width: cardSize,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 16,
                    child: Icon(
                      Icons.image_outlined,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => navigateToType(context, 'text'),
                child: SizedBox(
                  height: cardSize,
                  width: cardSize,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 16,
                    child: Icon(
                      Icons.font_download_outlined,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => navigateToType(context, 'link'),
                child: SizedBox(
                  height: cardSize,
                  width: cardSize,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 16,
                    child: Icon(
                      Icons.link_outlined,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
