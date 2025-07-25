import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:routemaster/routemaster.dart';
import 'package:whatfood/main.dart';
import 'package:whatfood/models/diary_entry.dart';

class PrivateAreaScreen extends StatelessWidget {
  const PrivateAreaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Area'),
        actions: [
          IconButton(
              onPressed: () => Routemaster.of(context).push('settings'),
              icon: Icon(Icons.settings_outlined))
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileCard(),
          SizedBox(height: 16),
          StatisticsCard(),
          SizedBox(height: 16),
          DiaryCard(),
          SizedBox(height: 16),
          DocumentsCard(),
        ],
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({super.key});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  final _nameController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'john@example.com');

  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Profile",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              enabled: _editing,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              enabled: _editing,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _editing = !_editing);
                },
                child: Text(_editing ? 'Save' : 'Edit'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class StatisticsCard extends StatelessWidget {
  const StatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Your Food Stats",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text("• Most eaten ingredient: Tomato"),
            Text("• Avg meals per day: 3.2"),
            Text("• Health score (avg): 85%"),
            // Add charts or graphs here later
          ],
        ),
      ),
    );
  }
}

class DocumentsCard extends StatelessWidget {
  const DocumentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyFiles = ['VeganRecipes.pdf', 'BloodTestResults.pdf'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Health Documents",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...dummyFiles.map((file) => ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: Text(file),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Integrazione futura: apri file PDF
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class DiaryCard extends StatefulWidget {
  const DiaryCard({super.key});

  @override
  State<DiaryCard> createState() => _DiaryCardState();
}

class _DiaryCardState extends State<DiaryCard> {
  final _controller = TextEditingController();
  final _box = Hive.box<List>('foodDiary');

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  void _addEntry(String text) async {
    final newEntry = DiaryEntry(meal: text, timestamp: DateTime.now());

    final existing = _box.get(_todayKey)?.cast<DiaryEntry>() ?? [];
    final updated = [...existing, newEntry];

    await _box.put(_todayKey, updated);
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = _box.toMap().cast<String, List>().entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Food Diary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Add meal for today...',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  _addEntry(_controller.text.trim());
                }
              },
            ),
          ]),
          const SizedBox(height: 16),
          ...allEntries.map((entry) {
            final formattedDate = entry.key;
            final meals = entry.value.cast<DiaryEntry>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                ...meals.map((m) => Text(
                    '• ${m.meal} (${DateFormat.Hm().format(m.timestamp)})')),
                const SizedBox(height: 8),
              ],
            );
          }),
        ]),
      ),
    );
  }
}
