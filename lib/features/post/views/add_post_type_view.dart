import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/common/provider.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/models/MealType.dart';

class AddPostTypeView extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeView({required this.type, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeViewState();
}

class _AddPostTypeViewState extends ConsumerState<AddPostTypeView> {
  final descriptionController = TextEditingController();
  File? image;
  final List<String> tags = [];
  final FocusNode _tagFocusNode = FocusNode();
  MealType? selectedMealType;

  @override
  void dispose() {
    descriptionController.dispose();
    _tagFocusNode.dispose();
    super.dispose();
  }

  void selectImage() async {
    final res = await pickImage(context);

    if (res != null) {
      setState(() {
        image = res;
      });
    }
  }

  void removeImage(File file) {
    setState(() {
      image = null;
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

  void sharePost(BuildContext context, PostController controller) {
    if (image == null) {
      showSnackBar(context, "Image missing");
      return;
    }
    if (descriptionController.text.isEmpty) {
      showSnackBar(context, "Description missing");
      return;
    }
    if (selectedMealType == null) {
      showSnackBar(context, "Please select a meal type");
      return;
    }

    controller.shareImagePost(
      context: context,
      description: descriptionController.text.trim(),
      tags: tags,
      image: image!,
      mealType: selectedMealType!,
    );
  }

  Widget _buildMealTypeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              'Meal Type:',
              style: TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: MealType.values.map((type) {
              final isSelected = selectedMealType == type;
              return IntrinsicWidth(
                child: FilterChip(
                  selected: isSelected,
                  showCheckmark: false,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getMealTypeIcon(type),
                        size: 20,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        type.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  selectedColor: Colors.green,
                  backgroundColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      selectedMealType = selected ? type : null;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.BREAKFAST:
        return Icons.breakfast_dining;
      case MealType.LUNCH:
        return Icons.lunch_dining;
      case MealType.DINNER:
        return Icons.dinner_dining;
      case MealType.SNACK:
        return Icons.cookie;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = MyProvider.of<PostController>(context)?.value;
    if (controller == null) {
      return Scaffold(body: Center(child: Text('Controller not found')));
    }
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
              onPressed: () => sharePost(context, controller),
              child: const Text('Share'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: selectImage,
                      child: Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: image != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  image!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : DottedBorder(
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
                    if (image != null)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => removeImage(image!),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Stack(
                  children: [
                    Positioned(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: descriptionController,
                              textCapitalization: TextCapitalization.sentences,
                              enableSuggestions: true,
                              autocorrect: true,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: "Enter Description here",
                                counterText: "",
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                contentPadding: const EdgeInsets.all(20),
                              ),
                              maxLines: 3,
                              maxLength: 70,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                _buildMealTypeSelector(),
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
