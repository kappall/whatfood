import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/profile/controller/user_profile_controller.dart';

class EditProfileView extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileView({
    super.key,
    required this.uid,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  File? profileFile;
  late TextEditingController nameController;
  late TextEditingController bioController;
  late TextEditingController dailyIntakeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
    bioController = TextEditingController(text: ref.read(userProvider)!.bio);
    dailyIntakeController = TextEditingController(
        text: ref.read(userProvider)!.dailyIntake.toString());
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    bioController.dispose();
    dailyIntakeController.dispose();
  }

  void selectProfileImage() async {
    final res = await pickImage(context);

    if (res != null) {
      setState(() {
        profileFile = res;
      });
    }
  }

  void save() {
    ref.read(userProfileControllerProvider.notifier).updateUserProfile(
        context: context,
        name: nameController.text.trim(),
        bio: bioController.text.trim(),
        dailyIntake: int.parse(dailyIntakeController.text.trim()),
        profileFile: profileFile);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? suffixText,
    int? maxLines,
    int? maxLength,
    TextInputType? keyboardType,
    bool? enableInteractiveSelection,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            style: TextStyle(color: Colors.white),
            controller: controller,
            keyboardType: keyboardType,
            enableInteractiveSelection: enableInteractiveSelection,
            decoration: InputDecoration(
              label: Text(label),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.indigo),
              suffixText: suffixText,
              suffixStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ref.watch(getUserDataProvider).when(
              data: (user) => Scaffold(
                appBar: AppBar(
                  title: const Text('Edit Profile'),
                  centerTitle: true,
                  actions: [
                    TextButton.icon(
                      onPressed: save,
                      icon: const Icon(Icons.check, color: Colors.indigoAccent),
                      label: const Text(
                        'Save',
                        style: TextStyle(color: Colors.indigoAccent),
                      ),
                    ),
                  ],
                ),
                body: Container(
                  decoration: BoxDecoration(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: profileFile != null
                                    ? Image.file(
                                        profileFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        user!.profilePic,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: selectProfileImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.indigo,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 64),
                        Stack(
                          children: [
                            Positioned(
                              child: _buildTextField(
                                controller: nameController,
                                label: 'Username',
                                hint: 'Enter your username',
                              ),
                            ),
                            Positioned(
                              right: 0,
                              left: 0,
                              bottom: 1,
                              child: Divider(
                                color: Colors.white,
                                thickness: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Stack(
                          children: [
                            _buildTextField(
                              controller: bioController,
                              label: 'Bio',
                              hint: 'Tell us about yourself',
                              maxLines: 3,
                              maxLength: 100,
                            ),
                            Positioned(
                              right: 0,
                              left: 0,
                              bottom: 1,
                              child: Divider(
                                color: Colors.white,
                                thickness: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Stack(
                          children: [
                            _buildTextField(
                              controller: dailyIntakeController,
                              label: 'Dayly goal',
                              hint: 'Enter your daily goal',
                              suffixText: 'kcal',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: false,
                              ),
                              maxLength: 4,
                              enableInteractiveSelection: false,
                            ),
                            Positioned(
                              right: 0,
                              left: 0,
                              bottom: 1,
                              child: Divider(
                                color: Colors.white,
                                thickness: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              loading: () => const Loader(),
              error: (error, stackTrace) => ErrorText(
                error: error.toString(),
              ),
            ),
      ),
    );
  }
}
