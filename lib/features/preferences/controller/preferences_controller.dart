import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    required List<String> preferences,
  }) async {
    state = true;
    debugPrint('Saving preferences');
    final uid = (await Amplify.Auth.getCurrentUser()).userId;
    await _preferencesRepository.updateUserPreferences(
      uid: uid,
      newPreferences: preferences,
    );
    state = false;
  }
}
