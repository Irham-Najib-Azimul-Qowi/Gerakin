import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/gamification_controller.dart';
import '../widgets/rehabilitation_journey_timeline.dart';
import '../../../user/presentation/controllers/profile_controller.dart';
import '../../../analytics/models/achievement.dart';
import '../../models/mission.dart';
import '../../models/challenge.dart';

/// Halaman Dashboard Utama Gamifikasi dan Misi pengguna.
class GamificationDashboardPage extends ConsumerWidget {
  const GamificationDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamificationControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final active = profileState.activeProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamifikasi & Misi', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: state.isLoading || active == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(gamificationControllerProvider.notifier)
                  .loadGamificationData(active.id),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── KATA MOTIVASI BANNER ────────────────────────
                    _buildMotivationCard(context, state.motivationMessage),
                    const SizedBox(height: 20),

                    // ── PROGRESS LEVEL & STREAK ─────────────────────
                    _buildLevelAndStreakCard(context, state),
                    const SizedBox(height: 24),

                    // ── DAILY MISSIONS ──────────────────────────────
                    _buildSectionHeader('Misi Hari Ini (Daily)'),
                    const SizedBox(height: 10),
                    _buildMissionsList(context, state.missions),
                    const SizedBox(height: 24),

                    // ── WEEKLY CHALLENGE ────────────────────────────
                    _buildSectionHeader('Tantangan Mingguan (Weekly)'),
                    const SizedBox(height: 10),
                    _buildChallengesList(context, state.challenges),
                    const SizedBox(height: 24),

                    // ── REHABILITATION JOURNEY TIMELINE ─────────────
                    RehabilitationJourneyTimeline(
                      mobilityLevel: active.mobilityLevel,
                      rehabilitationGoal: active.rehabilitationGoal,
                    ),
                    const SizedBox(height: 24),

                    // ── ACHIEVEMENTS ────────────────────────────────
                    _buildSectionHeader('Lencana Pencapaian'),
                    const SizedBox(height: 10),
                    _buildAchievementsGrid(context, state.achievements),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMotivationCard(BuildContext context, String message) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.lightbulb_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelAndStreakCard(BuildContext context, GamificationState state) {
    final lvl = state.level;
    final str = state.streak;

    final currentLevel = lvl?.currentLevel ?? 1;
    final currentXP = lvl?.currentXP ?? 0;
    final nextLevelXP = lvl?.nextLevelXP ?? 100;
    final progress = (currentXP / nextLevelXP).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $currentLevel',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentXP / $nextLevelXP XP',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '${str?.currentStreak ?? 0} HARI STREAK',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionsList(BuildContext context, List<Mission> missions) {
    if (missions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Tidak ada misi aktif saat ini.', style: TextStyle(fontSize: 12)),
        ),
      );
    }

    return Column(
      children: missions.map((m) {
        final progressPercent = (m.currentValue / m.targetValue).clamp(0.0, 1.0);
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              m.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(m.description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            m.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${m.currentValue.toStringAsFixed(0)}/${m.targetValue.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: m.isCompleted ? Colors.green.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: m.isCompleted ? Colors.green.shade200 : Colors.blue.shade200),
              ),
              child: Text(
                '+${m.xpReward} XP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: m.isCompleted ? Colors.green.shade800 : Colors.blue.shade800,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChallengesList(BuildContext context, List<Challenge> challenges) {
    if (challenges.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Tidak ada tantangan aktif.', style: TextStyle(fontSize: 12)),
        ),
      );
    }

    return Column(
      children: challenges.map((c) {
        final progressPercent = (c.currentValue / c.targetValue).clamp(0.0, 1.0);
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 0.8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              c.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(c.description, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            c.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${c.currentValue.toStringAsFixed(0)}/${c.targetValue.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: c.isCompleted ? Colors.green.shade50 : Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.isCompleted ? Colors.green.shade200 : Colors.purple.shade200),
              ),
              child: Text(
                '+${c.xpReward} XP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: c.isCompleted ? Colors.green.shade800 : Colors.purple.shade800,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementsGrid(BuildContext context, List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return const Center(child: Text('Belum ada lencana lencana terkunci.', style: TextStyle(fontSize: 12)));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final ach = achievements[index];
        return Card(
          elevation: 0,
          color: ach.isUnlocked
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: ach.isUnlocked ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
              width: 0.8,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  ach.isUnlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
                  color: ach.isUnlocked ? Colors.amber : Colors.grey,
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  ach.title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  ach.description,
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
