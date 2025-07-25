import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shimmer/shimmer.dart';
import 'package:whatfood/core/common/error_text.dart';
import 'package:whatfood/core/common/loader.dart';
import 'package:whatfood/features/auth/controller/auth_controller.dart';
import 'package:whatfood/features/profile/controller/user_profile_controller.dart';
import 'package:whatfood/models/Post.dart';
import 'package:whatfood/models/User.dart';

enum Period { ever, lastWeek, lastMonth }

final reportProvider = StateProvider<Period>((_) => Period.ever);

class FoodReport {
  final int totalMeals;
  final int uniqueDishes;
  final int veggieMeals;
  FoodReport(this.totalMeals, this.uniqueDishes, this.veggieMeals);
}

FoodReport _fakeReport(Period p) {
  switch (p) {
    case Period.ever:
      return FoodReport(120, 45, 60);
    case Period.lastWeek:
      return FoodReport(21, 14, 12);
    case Period.lastMonth:
      return FoodReport(90, 30, 45);
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final period = ref.watch(reportProvider);
    final report = _fakeReport(period);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* ---------- 1.  USER CARD ---------- */
          GlassCard(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePic),
                  radius: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Text(user.bio!,
                            style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          /* ---------- 2.  PERIOD SELECTOR ---------- */
          GlassCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: Period.values.map((e) {
                final label = e.name.capitalize();
                return ChoiceChip(
                  label: Text(label),
                  selected: period == e,
                  onSelected: (_) =>
                      ref.read(reportProvider.notifier).state = e,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          /* ---------- 3.  FOOD REPORT ---------- */
          GlassCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ReportTile(report.totalMeals, 'Meals'),
                _ReportTile(report.uniqueDishes, 'Unique'),
                _ReportTile(report.veggieMeals, 'Veggie'),
              ],
            ),
          ),
          const SizedBox(height: 30),

          /* ---------- 4.  DIARY SECTION ---------- */
          Text('Daily log', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const DiaryList(),
        ],
      ),
    );
  }
}

/* ---------- helpers ---------- */
class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(.15),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final int value;
  final String label;
  const _ReportTile(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
      ],
    );
  }
}

class DiaryList extends ConsumerWidget {
  const DiaryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diary = ref.watch(diaryProvider);
    if (diary.isEmpty) {
      return const Center(child: Text('Nothing logged yet'));
    }
    return Column(
      children: diary.map((e) => _DiaryTile(e)).toList(),
    );
  }

  Widget _DiaryTile(FoodEntry e) => ListTile(
        leading: const Icon(Icons.fastfood, color: Colors.green),
        title: Text(e.name),
        subtitle: Text('${e.date.day}/${e.date.month}/${e.date.year}'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white.withOpacity(.08),
      );
}

extension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
