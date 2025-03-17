import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/common/provider.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/features/profile/controller/user_profile_controller.dart';
import 'package:whatfood/core/common/post_card_for_list.dart';

class PostList extends ConsumerWidget {
  final String uid;
  const PostList({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Routemaster.of(context).pop(),
          ),
          title: const Text('Post List'),
        ),
      ),
      body: ref.watch(getUserPostsProvider(uid)).when(
            data: (data) {
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext content, int indez) {
                    final post = data[indez];
                    final controller =
                        MyProvider.of<PostController>(context)?.value;
                    if (controller == null) {
                      return Scaffold(
                          body: Center(child: Text('Controller not found')));
                    }
                    return PostCard(post: post, controller: controller);
                  });
            },
            error: (error, stackTrace) {
              debugPrint(stackTrace.toString());
              return ErrorText(error: error.toString());
            },
            loading: () => const Loader(),
          ),
    );
  }
}
