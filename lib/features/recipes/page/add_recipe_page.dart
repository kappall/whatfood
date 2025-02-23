import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/recipes/controller/recipe_controller.dart';
import 'package:whatfood/models/recipe_model.dart';

class AddRecipePage extends ConsumerStatefulWidget {
  const AddRecipePage({super.key});

  @override
  ConsumerState<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends ConsumerState<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingsController = TextEditingController();
  final _cookTimeController = TextEditingController();

  File? _image;
  List<String> _ingredients = [''];
  List<String> _instructions = [''];

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
    setState(() {
      _ingredients.add('');
    });
  }

  void _addInstruction() {
    setState(() {
      _instructions.add('');
    });
  }

  void _updateIngredient(int index, String value) {
    _ingredients[index] = value;
  }

  void _updateInstruction(int index, String value) {
    _instructions[index] = value;
  }

  void shareRecipe(BuildContext context) {
    if (_titleController.text.isEmpty) {
      showSnackBar(context, "Title missing");
      return;
    }
    if (ref.read(recipeControllerProvider)) return;

    if (_ingredients[0] != '' &&
        _instructions[0] != '' &&
        _descriptionController.text.isNotEmpty &&
        _cookTimeController.text.isNotEmpty &&
        _servingsController.text.isNotEmpty &&
        _image != null) {
      ref.read(recipeControllerProvider.notifier).shareRecipe(
          context: context,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          instructions: _instructions,
          ingredients: _ingredients,
          servings: _servingsController.text.trim(),
          cookTimeMinutes: _cookTimeController.text.trim(),
          image: _image!);
    } else {
      showSnackBar(context, "You must all fill the fields");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Recipe'),
        actions: [
          IconButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                shareRecipe(context);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
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
                    : const Icon(Icons.add_photo_alternate, size: 50),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
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
                  child: TextFormField(
                    initialValue: _ingredients[index],
                    decoration: InputDecoration(
                      labelText: 'Ingredient ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => _updateIngredient(index, value),
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
                  child: TextFormField(
                    initialValue: _instructions[index],
                    decoration: InputDecoration(
                      labelText: 'Step ${index + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (value) => _updateInstruction(index, value),
                  ),
                );
              },
            ),
          ],
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
