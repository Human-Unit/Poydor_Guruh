import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 8),
            const Text('Profile', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 28),
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF49A8FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.4), blurRadius: 16)],
                    ),
                    child: Center(
                      child: Text(
                        (user?.name.isNotEmpty == true ? user!.name[0] : user?.email[0] ?? 'G').toUpperCase(),
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user?.name.isNotEmpty == true ? user!.name : 'Guest',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            if (user?.email != null) ...[
              const SizedBox(height: 4),
              Center(child: Text(user!.email, style: const TextStyle(color: Colors.grey, fontSize: 13))),
            ],
            const SizedBox(height: 32),
            // Progress card
            FutureBuilder<Map<String, dynamic>?>(
              future: ref.read(authProvider.notifier).getProgress(),
              builder: (context, snapshot) {
                int totalQuizzes = 0;
                String avgScore = '0';

                if (snapshot.hasData && snapshot.data != null) {
                  totalQuizzes = snapshot.data!['totalQuizzesTaken'] ?? 0;
                  avgScore = (snapshot.data!['averageScore'] ?? 0).toStringAsFixed(1);
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _StatCard(icon: Icons.quiz_outlined, label: 'Quizzes Taken', value: '$totalQuizzes', color: const Color(0xFF6C63FF))),
                        const SizedBox(width: 14),
                        Expanded(child: _StatCard(icon: Icons.bar_chart, label: 'Avg Score', value: '$avgScore%', color: const Color(0xFF49A8FF))),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            // Info tiles
            if (user != null) ...[
              _InfoTile(icon: Icons.badge_outlined, label: 'Username', value: '@${user.username}'),
              const SizedBox(height: 12),
              _InfoTile(icon: Icons.email_outlined, label: 'Email', value: user.email),
              const SizedBox(height: 12),
              _InfoTile(icon: Icons.shield_outlined, label: 'Role', value: user.role.toUpperCase()),
            ],
            const SizedBox(height: 36),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
