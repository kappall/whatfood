import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/community/widgets/community_postcard.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final postsAsync = ref.watch(postsProvider);

    if (user == null) return const Loader();
    final uid = user.id;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          elevation: 0,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: _isSearching
              ? _buildSearchBar()
              : Text('Community',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchController.clear();
                });
              },
            ),
          ],
        ),
        body: postsAsync.when(
          data: (posts) {
            final filteredPosts = _searchQuery.isEmpty
                ? posts
                : posts.where((post) {
                    final title = post.title.toLowerCase();
                    final content = post.content?.toLowerCase() ?? '';
                    return title.contains(_searchQuery) ||
                        content.contains(_searchQuery);
                  }).toList();

            debugPrint(filteredPosts.toString());
            if (filteredPosts.isEmpty) {
              return Center(
                child: Text('No posts found'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: filteredPosts.length,
              itemBuilder: (_, index) {
                final post = filteredPosts[index];
                final hasImage = post.imageUrl != null;
                return FutureBuilder(
                  future: hasImage
                      ? Amplify.Storage.getUrl(
                          path: StoragePath.fromString(post.imageUrl!),
                        ).result
                      : null,
                  builder: (_, snapshot) {
                    final imageUrl =
                        snapshot.hasData ? snapshot.data!.url.toString() : null;

                    return CommunityPostCard(
                      title: post.title,
                      text: post.content,
                      imageUrl: imageUrl,
                      authorName: post.authorname,
                      createdAt: post.createdAt.getDateTimeInUtc(),
                      currentUid: uid,
                      votes: post.votes,
                      onVote: () {
                        ref
                            .read(postControllerProvider.notifier)
                            .likeOrUnlike(post, uid);
                        ref.invalidate(postsProvider);
                      },
                    );
                  },
                );
              },
            );
          },
          error: (e, _) => ErrorText(error: e.toString()),
          loading: () => const Loader(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Routemaster.of(context).push('create-post'),
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search posts...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      style: const TextStyle(fontSize: 18),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
    );
  }
}
