import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/preferences/repository/preferences_repository.dart';

final preferencesControllerProvider =
    StateNotifierProvider<PreferencesController, bool>((ref) {
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return PreferencesController(
    preferencesRepository: preferencesRepository,
    ref: ref,
  );
});

class PreferencesController extends StateNotifier<bool> {
  final PreferencesRepository _preferencesRepository;
  final Ref _ref;

  PreferencesController({
    required PreferencesRepository preferencesRepository,
    required Ref ref,
  })  : _preferencesRepository = preferencesRepository,
        _ref = ref,
        super(false);

  Future<void> savePreferences({
    required BuildContext context,
    required Set<String> preferences,
  }) async {
    state = true;
    debugPrint('Saving preferences');
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final res = await _preferencesRepository.updateUserPreferences(
      uid: uid,
      newPreferences: preferences,
    );
    state = false;
  }
}
