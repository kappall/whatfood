import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/core/utils.dart';
import 'package:whatfood/features/recipes/controller/recipe_controller.dart';

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController();
  final _cookTimeCtrl = TextEditingController();

  File? _image;
  final List<TextEditingController> _ingredientCtrls = [];
  final List<TextEditingController> _instructionCtrls = [];

  @override
  void initState() {
    super.initState();
    _addIngredient();
    _addInstruction();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _servingsCtrl.dispose();
    _cookTimeCtrl.dispose();
    for (final c in [..._ingredientCtrls, ..._instructionCtrls]) c.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  void _addIngredient() => _ingredientCtrls.add(TextEditingController());
  void _addInstruction() => _instructionCtrls.add(TextEditingController());

  void _removeIngredient(int i) {
    _ingredientCtrls[i].dispose();
    _ingredientCtrls.removeAt(i);
    setState(() {});
  }

  void _removeInstruction(int i) {
    _instructionCtrls[i].dispose();
    _instructionCtrls.removeAt(i);
    setState(() {});
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      showSnackBar(context, 'Pick a cover image');
      return;
    }
    if (_ingredientCtrls.any((c) => c.text.trim().isEmpty)) {
      showSnackBar(context, 'Fill every ingredient');
      return;
    }
    if (_instructionCtrls.any((c) => c.text.trim().isEmpty)) {
      showSnackBar(context, 'Fill every step');
      return;
    }

    ref
        .read(recipeControllerProvider.notifier)
        .shareRecipe(
          context: context,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          instructions: _instructionCtrls.map((c) => c.text.trim()).toList(),
          ingredients: _ingredientCtrls.map((c) => c.text.trim()).toList(),
          servings: _servingsCtrl.text.trim(),
          cookTimeMinutes: _cookTimeCtrl.text.trim(),
          image: _image!,
        )
        .then((_) {
      ref.invalidate(recipesProvider);
      if (mounted) Routemaster.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(recipeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create recipe'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Routemaster.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ImagePicker(image: _image, onTap: _pickImage),
              const SizedBox(height: 16),
              _TextInput(label: 'Title', ctrl: _titleCtrl),
              const SizedBox(height: 16),
              _TextInput(label: 'Description', ctrl: _descCtrl, maxLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _TextInput(
                          label: 'Servings',
                          ctrl: _servingsCtrl,
                          keyboard: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _TextInput(
                          label: 'Cook time (min)',
                          ctrl: _cookTimeCtrl,
                          keyboard: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Ingredients', onAdd: _addIngredient),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredientCtrls.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _ingredientCtrls.removeAt(oldIndex);
                    _ingredientCtrls.insert(newIndex, item);
                  });
                },
                itemBuilder: (_, i) => _Row(
                  key: ValueKey('ing-$i'),
                  ctrl: _ingredientCtrls[i],
                  hint: 'Ingredient ${i + 1}',
                  onDelete: () => _removeIngredient(i),
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: 'Instructions', onAdd: _addInstruction),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _instructionCtrls.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _instructionCtrls.removeAt(oldIndex);
                    _instructionCtrls.insert(newIndex, item);
                  });
                },
                itemBuilder: (_, i) => _Row(
                  key: ValueKey('step-$i'),
                  ctrl: _instructionCtrls[i],
                  hint: 'Step ${i + 1}',
                  onDelete: () => _removeInstruction(i),
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: loading ? null : _submit,
        icon: loading ? const Loader() : const Icon(Icons.check),
        label: const Text('Save recipe'),
      ),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({this.image, required this.onTap});
  final File? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          image: image != null
              ? DecorationImage(image: FileImage(image!), fit: BoxFit.cover)
              : null,
        ),
        child: image == null
            ? const Icon(Icons.add_photo_alternate,
                size: 48, color: Colors.grey)
            : null,
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput(
      {required this.label, required this.ctrl, this.keyboard, this.maxLines});
  final String label;
  final TextEditingController ctrl;
  final TextInputType? keyboard;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines ?? 1,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onAdd});
  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        IconButton(icon: const Icon(Icons.add_circle), onPressed: onAdd),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.ctrl,
    required this.hint,
    required this.onDelete,
    this.maxLines,
  });
  final TextEditingController ctrl;
  final String hint;
  final VoidCallback onDelete;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: ctrl,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
