import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/profile/controller/user_profile_controller.dart';

class DislikesScreen extends ConsumerStatefulWidget {
  const DislikesScreen({super.key});

  @override
  ConsumerState<DislikesScreen> createState() => _DislikesScreenState();
}

class _DislikesScreenState extends ConsumerState<DislikesScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _dislikes = [];

  void _addDislike() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && text.length <= 20 && !_dislikes.contains(text)) {
      setState(() {
        _dislikes.add(text);
        _controller.clear();
      });
    }
  }

  void _removeDislike(String item) {
    setState(() {
      _dislikes.remove(item);
    });
  }

  void _onContinue() async {
    final user = ref.read(userProvider)!;
    final preferencesList = user.preferences;
    final allergiesList = user.allergies;
    final goalsList = user.goals;
    final dislikesList = user.dislikes;

    await ref.read(userProfileControllerProvider.notifier).updateUserProfile(
          context: context,
          preferences: preferencesList,
          allergies: allergiesList,
          goals: goalsList,
          dislikes: dislikesList,
        );
    if (context.mounted) {
      Routemaster.of(context).replace('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Any Dislikes?"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Any ingredients you really dislike?"),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      hintText: "eg. Cilantro",
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addDislike,
                  child: const Text("Add"),
                )
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _dislikes.map((item) {
                return Chip(
                  label: Text(item),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () => _removeDislike(item),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onContinue,
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
