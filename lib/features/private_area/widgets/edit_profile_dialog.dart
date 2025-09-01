import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/private_area/controllers/user_profile_controller.dart';

Future<void> showEditProfileDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (_) => const _EditProfileDialog(),
  );
}

class _EditProfileDialog extends ConsumerStatefulWidget {
  const _EditProfileDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<_EditProfileDialog> {
  late final _nameCtrl =
      TextEditingController(text: ref.read(userProvider)?.name ?? '');
  late final _emailCtrl =
      TextEditingController(text: ref.read(userProvider)?.email ?? '');

  final List<String> _preferences = [];
  final List<String> _allergies = [];
  final List<String> _dislikes = [];

  String? _dietaryGoal;
  String? _cookingSkill;
  final List<String> _cookingFor = [];
  static const _prefOptions = [
    'Vegetarian',
    'Vegan',
    'Pescatarian',
    'No Red Meat',
    'Kosher',
    'Halal',
    'Other'
  ];

  static const _allergyOptions = [
    'Gluten',
    'Lactose / Diary',
    'Nuts (Peanuts, Tree Nuts)',
    'Eggs',
    'Soy',
    'Shellfish',
    'Fish',
    'Other'
  ];

  static const _goalDietaryOptions = [
    'Weight Loss',
    'Muscle Gain',
    'Eat Healthier Generally',
    'Manage a specific condition (e.g., Diabetes)'
  ];

  static const _goalAudienceOptions = [
    'Just myself',
    'Adults',
    'Young Children (1-5 years)',
    'Older Children (6-12 years)',
    'Teenagers',
  ];

  static const _skillOptions = [
    'Beginner (I need simple steps)',
    'Intermediate (Comfortable with basics)',
    'Advanced (I love a challenge!)'
  ];

  @override
  void initState() {
    super.initState();
    final u = ref.read(userProvider)!;
    _preferences.addAll(u.preferences);
    _allergies.addAll(u.allergies);
    _dislikes.addAll(u.dislikes);

    final goals = u.goals;
    for (final g in goals) {
      if (_goalDietaryOptions.contains(g)) {
        _dietaryGoal = g;
      } else if (_skillOptions.contains(g)) {
        _cookingSkill = g;
      } else if (_goalAudienceOptions.contains(g)) {
        _cookingFor.add(g);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: DefaultTabController(
            length: 5,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Edit profile'),
                leading: const SizedBox(),
                bottom: const TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Basic'),
                    Tab(text: 'Preferences'),
                    Tab(text: 'Allergies'),
                    Tab(text: 'Goals'),
                    Tab(text: 'Dislikes'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _BasicTab(),
                  _MultiTab(
                    title: 'Dietary preferences',
                    options: _prefOptions,
                    selected: _preferences,
                  ),
                  _MultiTab(
                    title: 'Allergies & intolerances',
                    options: _allergyOptions,
                    selected: _allergies,
                  ),
                  _GoalsTab(),
                  _DislikesTab(),
                ],
              ),
              persistentFooterButtons: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Routemaster.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final user = ref.read(userProvider)!;

    final goals = <String>[
      if (_dietaryGoal != null) _dietaryGoal!,
      if (_cookingSkill != null) _cookingSkill!,
      ..._cookingFor,
    ];

    await ref.read(userProfileControllerProvider.notifier).updateUserProfile(
          context: context,
          user: user.copyWith(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
          ),
          preferences: _preferences,
          allergies: _allergies,
          goals: goals,
          dislikes: _dislikes,
        );
    ref.invalidate(userProfileControllerProvider);
    if (mounted) Navigator.of(context).pop();
  }

  Widget _BasicTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _emailCtrl,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _MultiTab({
    required String title,
    required List<String> options,
    required List<String> selected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: ListView(
            children: options
                .map(
                  (e) => CheckboxListTile(
                    title: Text(e),
                    value: selected.contains(e),
                    onChanged: (_) {
                      setState(() {
                        selected.contains(e)
                            ? selected.remove(e)
                            : selected.add(e);
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _GoalsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Primary dietary goal'),
        ..._goalDietaryOptions.map(
          (e) => RadioListTile<String>(
            title: Text(e),
            value: e,
            groupValue: _dietaryGoal,
            onChanged: (v) => setState(() => _dietaryGoal = v),
          ),
        ),
        const Divider(height: 32),
        const Text('Who are you cooking for?'),
        ..._goalAudienceOptions.map(
          (e) => CheckboxListTile(
            title: Text(e),
            value: _cookingFor.contains(e),
            onChanged: (_) => setState(() {
              _cookingFor.contains(e)
                  ? _cookingFor.remove(e)
                  : _cookingFor.add(e);
            }),
          ),
        ),
        const Divider(height: 32),
        const Text('Cooking skill level'),
        ..._skillOptions.map(
          (e) => RadioListTile<String>(
            title: Text(e),
            value: e,
            groupValue: _cookingSkill,
            onChanged: (v) => setState(() => _cookingSkill = v),
          ),
        ),
      ],
    );
  }

  Widget _DislikesTab() {
    final ctrl = TextEditingController();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    hintText: 'Add ingredient you dislike',
                    counterText: '',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final t = ctrl.text.trim();
                  if (t.isNotEmpty && !_dislikes.contains(t)) {
                    setState(() => _dislikes.add(t));
                    ctrl.clear();
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            children: _dislikes
                .map((e) => Chip(
                      label: Text(e),
                      onDeleted: () => setState(() => _dislikes.remove(e)),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }
}
