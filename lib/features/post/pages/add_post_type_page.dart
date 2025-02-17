import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';

class AddPostTypePage extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypePage({required this.type, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypePageState();
}

class _AddPostTypePageState extends ConsumerState<AddPostTypePage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final List<File> images = [];
  final List<String> tags = [];
  final FocusNode _tagFocusNode = FocusNode();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void selectImage() async {
    if (images.length == 4) return;

    final res = await pickImage(context);

    if (res != null) {
      setState(() {
        images.add(res);
      });
    }
  }

  void removeImage(File file) {
    setState(() {
      images.remove(file);
    });
  }

  void selectTag(String tag) async {
    if (tags.length == 8) return;
    setState(() {
      tags.add(tag);
    });
  }

  void removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  void _showAddTagBottomSheet(BuildContext context) {
    if (tags.length == 8) return;
    final TextEditingController tagController = TextEditingController();
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tagController,
                enableSuggestions: true,
                autofocus: true,
                focusNode: _tagFocusNode,
                decoration: const InputDecoration(
                  labelText: "Enter tag",
                ),
                maxLength: 16,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final newTag = tagController.text.trim();
                  if (newTag.isNotEmpty) {
                    setState(() {
                      tags.add(newTag);
                    });
                    Navigator.of(context).pop();
                    FocusScope.of(context).unfocus();
                  }
                },
                child: const Text("Add Tag"),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void sharePost(BuildContext context) {
    if (titleController.text.isEmpty) {
      showSnackBar(context, "Title missing");
      return;
    }
    if (ref.read(postControllerProvider)) return;

    if (widget.type == 'image' && images.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareimagePost(
          context: context,
          title: titleController.text.trim(),
          tags: tags,
          files: images);
    } else if (widget.type == 'text') {
      ref.read(postControllerProvider.notifier).shareTextPost(
          context: context,
          title: titleController.text.trim(),
          tags: tags,
          description: descriptionController.text.trim());
    } else {
      showSnackBar(context, "You must all fill the fields");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == "image";
    final isTypeText = widget.type == "text";
    final isLoading = ref.watch(postControllerProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Post ${widget.type}'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          titleTextStyle: Theme.of(context).textTheme.headlineMedium,
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => sharePost(context),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: Loader(),
                    )
                  : const Text('Share'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  textCapitalization: TextCapitalization.sentences,
                  enableSuggestions: true,
                  autocorrect: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Enter Title here",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  maxLength: 30,
                ),
                const SizedBox(height: 10),
                if (isTypeImage)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...images.map(
                        (file) => Stack(
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () => removeImage(file),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (images.length < 4)
                        GestureDetector(
                          onTap: selectImage,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(10),
                              dashPattern: const [10, 4],
                              strokeCap: StrokeCap.round,
                              color: Theme.of(context).primaryColor,
                              child: const Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                if (isTypeText)
                  TextField(
                    controller: descriptionController,
                    textCapitalization: TextCapitalization.sentences,
                    enableSuggestions: true,
                    autocorrect: true,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: "Enter Description here",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    maxLines: 8,
                    maxLength: 300,
                  ),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: const Text(
                    'Tags:',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...tags.map(
                      (tag) => Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            tags.remove(tag);
                          });
                        },
                      ),
                    ),
                    if (tags.length < 8)
                      ActionChip(
                        label: const Icon(Icons.add),
                        onPressed: () {
                          _showAddTagBottomSheet(context);
                        },
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
