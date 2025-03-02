import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/providers/storage_repository_provider.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/profile/repository/user_profile_repository.dart';
import 'package:whatfood/models/post_model.dart';
import 'package:whatfood/models/user_model.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return UserProfileController(
    userProfileRepository: userProfileRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getUserPostsProvider = StreamProvider.family((ref, String uid) {
  return ref.read(userProfileControllerProvider.notifier).getUserPosts(uid);
});

final getUserSavedPostsProvider =
    StreamProvider.family<List<Post>, UserModel>((ref, user) {
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
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;

    if (profileFile != null) {
      final ris = await _storageRepository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: profileFile,
      );
      ris.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(profilePic: r),
      );
    }

    user = user.copyWith(name: name, bio: bio, dailyIntake: dailyIntake);
    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => user);
      Routemaster.of(context).popUntil((route) => route.path == '/');
    });
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  Stream<List<Post>> getUserSavedPosts(Set<String> savedPosts) {
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

  void followOrUnfollowUser(BuildContext context, UserModel user) {
    final uid = _ref.read(userProvider)!.uid;
    _userProfileRepository.followOrUnfollowUser(uid, user);
  }
}
