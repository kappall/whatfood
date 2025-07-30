import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/private_area/widgets/edit_profile_dialog.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.read(userProvider)!.id;

    return ref.watch(getUserDataProvider(uid)).when(
          data: (user) {
            String _safeList(List<String>? list) =>
                (list == null || list.isEmpty) ? '—' : list.join(', ');

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: user.profilePic != null
                      ? NetworkImage(user.profilePic!)
                      : null,
                  child: user.profilePic != null
                      ? null
                      : Text(
                          user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 48)),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Center(child: Text(user.email)),
                const SizedBox(height: 24),
                const Divider(),
                _SectionHeader('Basic info'),
                _Tile('Name', user.name),
                _Tile('Email', user.email),
                _Tile('Daily intake (kcal)', user.dailyIntake.toString()),
                const SizedBox(height: 8),
                const Divider(),
                _SectionHeader('Preferences'),
                _Tile(null, _safeList(user.preferences)),
                _SectionHeader('Allergies'),
                _Tile(null, _safeList(user.allergies)),
                _SectionHeader('Goals'),
                _Tile(null, _safeList(user.goals)),
                _SectionHeader('Dislikes'),
                _Tile(null, _safeList(user.dislikes)),
                const SizedBox(height: 8),
                const Divider(),
                _SectionHeader('Metadata'),
                _Tile('Created at', user.createdAt?.format() ?? '-'),
                _Tile('Updated at', user.updatedAt?.format() ?? '-'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _openEditDialog(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit profile'),
                ),
              ],
            );
          },
          error: (error, stackTrace) {
            debugPrint(stackTrace.toString());
            return ErrorText(error: error.toString());
          },
          loading: () => const Loader(),
        );
  }

  void _openEditDialog(BuildContext ctx) => showEditProfileDialog(ctx);
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              )),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.label, this.value);
  final String? label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: label == null
          ? Text(value, style: const TextStyle(fontSize: 14))
          : Text(label!, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: label == null ? null : Text(value),
    );
  }
}
