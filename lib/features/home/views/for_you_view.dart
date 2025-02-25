import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/home/widgets/home_post_card.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';

class ForYouView extends ConsumerWidget {
  const ForYouView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(postsProvider).when(
          data: (data) {
            return PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                final post = data[index];
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: HomePostCard(post: post),
                );
              },
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
