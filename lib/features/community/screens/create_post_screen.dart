import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/post/controller/post_controller.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';

final availableTags = [
  'nutrition',
  'recipes',
  'vegan',
  'intolerances',
  'fitness',
  'healthy',
  'quick meals',
];

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  List<String> selectedTags = [];

  void _toggleTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        if (selectedTags.length < 3) {
          selectedTags.add(tag);
        } else {
          showSnackBar(context, 'You can select up to 3 tags.');
        }
      }
    });
  }

  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _submitPost() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final user = ref.read(userProvider);

    if (user == null || title.isEmpty) {
      showSnackBar(context, 'Title is required');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await ref.read(postControllerProvider.notifier).createPost(
          title: title,
          content: content,
          imageFile: _imageFile,
          tags: selectedTags,
          context: context,
        );

    Routemaster.of(context).pop();
    ref.invalidate(postsProvider);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitPost,
          ),
        ],
      ),
      body: _isLoading
          ? const Loader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    maxLength: 80,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    maxLength: 1000,
                    decoration: const InputDecoration(
                      labelText: 'Optional content',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tags (max 3)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableTags.map((tag) {
                      final isSelected = selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (_) => _toggleTag(tag),
                        selectedColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 12),
                  if (_imageFile != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _imageFile = null),
                            child: CircleAvatar(
                              backgroundColor:
                                  Colors.black.withValues(alpha: 0.6),
                              child:
                                  const Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Add image'),
                  ),
                ],
              ),
            ),
    );
  }
}
