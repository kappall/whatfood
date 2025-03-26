import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/providers/aws_providers.dart';
import 'package:whatfood/core/providers/storage_repository_provider.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/profile/repository/user_profile_repository.dart';
import 'package:whatfood/models/Post.dart';
import 'package:whatfood/models/User.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = UserProfileRepository(auth: auth);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return UserProfileController(
    userProfileRepository: userProfileRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getUserPostsProvider = FutureProvider.family((ref, String uid) {
  return ref.read(userProfileControllerProvider.notifier).getUserPosts(uid);
});

final getUserSavedPostsProvider =
    FutureProvider.family<List<Post>, User>((ref, user) {
  final userProfileController =
      ref.read(userProfileControllerProvider.notifier);
  return userProfileController.getUserSavedPosts(user.savedPosts);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;

  UserProfileController({
    required UserProfileRepository userProfileRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _userProfileRepository = userProfileRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  Future<void> updateUserProfile({
    required BuildContext context,
    required String name,
    required String bio,
    required int dailyIntake,
    required File? profileFile,
    required User user,
  }) async {
    state = true;

    if (profileFile != null) {
      final ris = await _storageRepository.uploadImage(
        profileFile,
        user.id,
      );
      user = user.copyWith(profilePic: ris);
    }

    user = user.copyWith(name: name, bio: bio, dailyIntake: dailyIntake);
    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => user);
      Routemaster.of(context).popUntil((route) => route.path == '/');
    });
  }

  Future<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  Future<List<Post>> getUserSavedPosts(List<String> savedPosts) {
    return _userProfileRepository.getUserSavedPosts(savedPosts);
  }

  void logout() async {
    _userProfileRepository.logOut();
  }

  Future<void> deleteUser(BuildContext context) async {
    state = true;
    final res = await _userProfileRepository.deleteAccount();

    res.fold((l) {
      state = false;
      if (!context.mounted) return;
      showSnackBar(context, l.message);
    }, (r) {
      state = false;
      _ref.read(userProvider.notifier).update((state) => null);
      Routemaster.of(context).replace('/');
    });
  }

  void followOrUnfollowUser(BuildContext context, User user) {
    final uid = _ref.read(userProvider)!.id;
    _userProfileRepository.followOrUnfollowUser(uid, user);
  }
}
