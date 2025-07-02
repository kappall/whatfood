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

final getUserPostsProvider = StreamProvider.family((ref, String uid) {
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
    String? name,
    String? bio,
    int? dailyIntake,
    File? profileFile,
    List<String>? preferences,
    List<String>? allergies,
    List<String>? goals,
    List<String>? dislikes,
    User? user,
  }) async {
    state = true;

    User? currentUser = user ?? _ref.read(userProvider);
    if (currentUser == null) {
      showSnackBar(context, 'User not found');
      state = false;
      return;
    }

    if (profileFile != null) {
      final ris =
          await _storageRepository.uploadImage(profileFile, currentUser.id);
      currentUser = currentUser.copyWith(profilePic: ris);
    }

    currentUser = currentUser.copyWith(
      name: name ?? currentUser.name,
      bio: bio ?? currentUser.bio,
      dailyIntake: dailyIntake ?? currentUser.dailyIntake,
      preferences: preferences ?? currentUser.preferences,
      allergies: allergies ?? currentUser.allergies,
      goals: goals ?? currentUser.goals,
      dislikes: dislikes ?? currentUser.dislikes,
    );

    final res = await _userProfileRepository.editProfile(currentUser);
    state = false;

    res.fold(
      (l) => showSnackBar(context, l.message),
      (_) {
        _ref.read(userProvider.notifier).update((state) => currentUser!);
        Routemaster.of(context).popUntil((route) => route.path == '/');
      },
    );
  }

  Future<void> markOnboardingComplete(BuildContext context) async {
    state = true;

    final user = _ref.read(userProvider);
    if (user == null) {
      showSnackBar(context, 'User not found');
      state = false;
      return;
    }
    debugPrint(user.toString());
    final updatedUser = user.copyWith(isOnboarded: true);
    debugPrint('updatedUser: $updatedUser');
    final res =
        await _userProfileRepository.markOnboardingComplete(updatedUser);

    state = false;

    res.fold(
      (l) {
        debugPrint('error: ${l.message}');
        return showSnackBar(context, l.message);
      },
      (_) async {
        await _ref.read(authControllerProvider.notifier).refreshUser();
        if (context.mounted) {
          Routemaster.of(context).replace('/personalize/preferences');
        }
      },
    );
  }

  Stream<List<Post>> getUserPosts(String uid) {
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
