import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/constants/costants.dart';
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

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
    bioController = TextEditingController(text: ref.read(userProvider)!.bio);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    bioController.dispose();
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
        profileFile: profileFile);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ref.watch(getUserDataProvider(widget.uid)).when(
            data: (user) => Scaffold(
              appBar: AppBar(
                title: const Text('Edit User'),
                centerTitle: false,
                actions: [
                  TextButton(
                    onPressed: save,
                    child: const Text('Save'),
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: GestureDetector(
                                onTap: selectProfileImage,
                                child: profileFile != null
                                    ? CircleAvatar(
                                        backgroundImage:
                                            FileImage(profileFile!),
                                        radius: 32,
                                      )
                                    : CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(user.profilePic),
                                        radius: 32,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                            filled: true,
                            hintText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: EdgeInsets.all(20)),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: bioController,
                        decoration: InputDecoration(
                          hintText: "Enter Description here",
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.all(20),
                        ),
                        maxLines: 3,
                        maxLength: 100,
                      )
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
    );
  }
}
