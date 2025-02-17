import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/common/post_card.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';

class ForYouPage extends ConsumerWidget {
  const ForYouPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(postsProvider).when(
          data: (data) {
            return ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext content, int indez) {
                  final post = data[indez];
                  return PostCard(post: post);
                });
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
