import 'dart:convert';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';

import 'package:whatfood/features/recipes/controller/recipe_controller.dart';
import 'package:whatfood/models/Recipe.dart';

class EditRecipeView extends ConsumerStatefulWidget {
  final String encodedRecipe;
  const EditRecipeView({super.key, required this.encodedRecipe});

  @override
  ConsumerState<EditRecipeView> createState() => _EditRecipeViewState();
}

class _EditRecipeViewState extends ConsumerState<EditRecipeView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingsController = TextEditingController();
  final _cookTimeController = TextEditingController();

  File? _image;
  String? _existingImageUrl;
  List<String> _ingredients = [''];
  List<String> _instructions = [''];
  bool _isLoading = true;
  late Recipe recipe;

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
  }

  Future<void> _loadRecipeData() async {
    final decodedString = Uri.decodeComponent(widget.encodedRecipe);
    final jsonMap = jsonDecode(decodedString);
    recipe = Recipe.fromJson(jsonMap as Map<String, dynamic>);

    setState(() {
      _titleController.text = recipe.title;
      _descriptionController.text = recipe.description;
      _servingsController.text = recipe.servings.toString();
      _cookTimeController.text = recipe.cookTimeMinutes.toString();
      _ingredients = List.from(recipe.ingredients);
      _instructions = List.from(recipe.instructions);
      _existingImageUrl = recipe.coverImage;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _addIngredient() {
    if (_ingredients[_ingredients.length - 1].isNotEmpty) {
      setState(() {
        _ingredients.add('');
      });
    }
  }

  void _addInstruction() {
    if (_instructions[_instructions.length - 1].isNotEmpty) {
      setState(() {
        _instructions.add('');
      });
    }
  }

  void _updateIngredient(int index, String value) {
    _ingredients[index] = value;
  }

  void _updateInstruction(int index, String value) {
    _instructions[index] = value;
  }

  void _removeIngredient(int index) {
    if (_ingredients.length > 1) {
      setState(() {
        _ingredients.removeAt(index);
      });
    }
  }

  void _removeInstruction(int index) {
    if (_instructions.length > 1) {
      setState(() {
        _instructions.removeAt(index);
      });
    }
  }

  Future<void> _updateRecipe(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(recipeControllerProvider.notifier).updateRecipe(
      context: context,
      recipeId: recipe.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      instructions: _instructions,
      ingredients: _ingredients,
      servings: _servingsController.text.trim(),
      cookTimeMinutes: _cookTimeController.text.trim(),
      newImage: _image,
      existingImageUrl: _existingImageUrl,
      likes: [],
    );
    ref.invalidate(recipesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(recipeControllerProvider);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Routemaster.of(context).pop(),
        ),
        title: const Text('Edit Recipe'),
        actions: [
          IconButton(
            onPressed: isLoading ? null : () => _updateRecipe(context),
            icon: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: Loader(),
                  )
                : const Icon(Icons.check),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image != null
                      ? Image.file(_image!, fit: BoxFit.cover)
                      : _existingImageUrl != null
                          ? FutureBuilder(
                              future: Amplify.Storage.getUrl(
                                path:
                                    StoragePath.fromString(_existingImageUrl!),
                              ).result,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Loader();
                                }
                                if (snapshot.hasError) {
                                  return ErrorText(
                                      error: snapshot.error.toString());
                                }
                                if (!snapshot.hasData) {
                                  return const Loader();
                                }
                                String imageUrl = snapshot.data!.url.toString();
                                return Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image,
                                          size: 50),
                                    );
                                  },
                                );
                              },
                            )
                          : const Icon(Icons.add_photo_alternate, size: 50),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                autocorrect: false,
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      autocorrect: false,
                      controller: _servingsController,
                      decoration: const InputDecoration(
                        labelText: 'Servings',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      autocorrect: false,
                      controller: _cookTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Cook Time',
                        border: OutlineInputBorder(),
                        suffixText: 'm',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Ingredients'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addIngredient,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            autocorrect: false,
                            initialValue: _ingredients[index],
                            decoration: InputDecoration(
                              labelText: 'Ingredient ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) =>
                                _updateIngredient(index, value),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter an ingredient';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.red,
                          onPressed: _ingredients.length > 1
                              ? () => _removeIngredient(index)
                              : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Instructions'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addInstruction,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _instructions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            autocorrect: false,
                            initialValue: _instructions[index],
                            decoration: InputDecoration(
                              labelText: 'Step ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            maxLines: 2,
                            onChanged: (value) =>
                                _updateInstruction(index, value),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter an instruction';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Colors.red,
                          onPressed: _instructions.length > 1
                              ? () => _removeInstruction(index)
                              : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    _cookTimeController.dispose();
    super.dispose();
  }
}
