import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/awareness.dart';
import '../../models/official_alert.dart';
import '../../models/scan_result.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common.dart';
import '../../widgets/scan_tile.dart';
import '../learn/assistant_screen.dart';
import '../scan/history_screen.dart';
import '../scan/scan_result_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.onScan, required this.onOpenTab});
  final void Function(ScanKind kind) onScan;
  final void Function(int index) onOpenTab;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final Stream<List<ScanResult>> _scans;
  late final Stream<List<OfficialAlert>> _alerts;

  @override
  void initState() {
    super.initState();
    final fs = context.read<FirestoreService>();
    _scans = fs.scans(context.read<AuthProvider>().uid);
    _alerts = fs.alerts(limit: 3);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tip = dailyTips[DateTime.now().difference(DateTime(2026)).inDays.abs() % dailyTips.length];

    return TabScroll(
      children: [
        Row(
          children: [
            InitialsAvatar(auth.displayName, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Hi, ${firstName(auth.displayName)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w400),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => widget.onScan(ScanKind.link),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Scan Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.navy,
                elevation: 0,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        StreamBuilder<List<ScanResult>>(
          stream: _scans,
          builder: (context, snap) {
            final scans = snap.data ?? const <ScanResult>[];
            final title = scans.isEmpty
                ? 'Check anything **suspicious** before you tap'
                : 'You have checked **${scans.length} items** so far';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MixedTitle(title, size: 28),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: () => widget.onScan(ScanKind.link),
                  child: Container(
                    height: 58,
                    padding: const EdgeInsets.only(left: 18, right: 7),
                    decoration: BoxDecoration(
                      color: AppColors.alpha(Colors.white, 0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.alpha(Colors.white, 0.14)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.muted),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Paste a link or message to check',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, color: AppColors.muted),
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.document_scanner_outlined,
                              color: AppColors.navy, size: 22),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                AppCard(
                  child: Row(
                    children: [
                      _Stat(value: scans.length, label: 'Scanned', color: Colors.white),
                      _Stat(
                        value: scans.where((s) => s.verdict == Verdict.dangerous).length,
                        label: 'Dangerous',
                        color: AppColors.danger,
                      ),
                      _Stat(
                        value: scans.where((s) => s.verdict == Verdict.suspicious).length,
                        label: 'Suspicious',
                        color: AppColors.warn,
                      ),
                      _Stat(
                        value: scans.where((s) => s.verdict == Verdict.safe).length,
                        label: 'Safe',
                        color: AppColors.safe,
                      ),
                    ],
                  ),
                ),
                const SectionHeader('Quick actions'),
                Row(
                  children: [
                    _Quick(Icons.link, 'Scan a link', () => widget.onScan(ScanKind.link)),
                    const SizedBox(width: 10),
                    _Quick(Icons.sms_outlined, 'Scan a message',
                        () => widget.onScan(ScanKind.message)),
                    const SizedBox(width: 10),
                    _Quick(Icons.campaign_outlined, 'Report a scam', () => widget.onOpenTab(2)),
                    const SizedBox(width: 10),
                    _Quick(Icons.smart_toy_outlined, 'Ask the AI agent', () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AssistantScreen()),
                      );
                    }),
                  ],
                ),
                SectionHeader(
                  'Recent scans',
                  actionLabel: scans.isEmpty ? null : 'See all',
                  onAction: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                ),
                if (snap.hasError)
                  const ErrorBanner('Could not load your scans. Check your connection.')
                else if (scans.isEmpty)
                  const AppCard(
                    child: EmptyState(
                      icon: Icons.shield_outlined,
                      title: 'No scans yet',
                      message: 'Your checked links and messages will appear here.',
                    ),
                  )
                else
                  for (final s in scans.take(3))
                    ScanTile(
                      result: s,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ScanResultScreen(result: s)),
                      ),
                    ),
              ],
            );
          },
        ),
        const SectionHeader('Alerts for Mbarara City'),
        StreamBuilder<List<OfficialAlert>>(
          stream: _alerts,
          builder: (context, snap) {
            final alerts = snap.data ?? const <OfficialAlert>[];
            if (alerts.isEmpty) {
              return const AppCard(
                child: EmptyState(
                  icon: Icons.notifications_none,
                  title: 'No active alerts',
                  message: 'Official warnings will show up here and as notifications.',
                ),
              );
            }
            return Column(
              children: [
                for (final a in alerts)
                  AppCard(
                    light: true,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _AlertBody(alert: a),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppGradients.accent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tip of the day',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text(tip, style: const TextStyle(height: 1.45, fontSize: 14.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertBody extends StatelessWidget {
  const _AlertBody({required this.alert});
  final OfficialAlert alert;

  @override
  Widget build(BuildContext context) {
    final sevColor = alert.severity == 'critical'
        ? AppColors.danger
        : alert.severity == 'warning'
            ? AppColors.warn
            : AppColors.navy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Tag(alert.severity.toUpperCase(), filled: true, lightSurface: true, color: sevColor),
            const SizedBox(width: 8),
            const Tag('Mbarara', lightSurface: true),
            const Spacer(),
            Text(timeAgo(alert.createdAt),
                style: const TextStyle(color: AppColors.mutedInk, fontSize: 12.5)),
          ],
        ),
        const SizedBox(height: 12),
        Text(alert.title,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink)),
        const SizedBox(height: 6),
        Text(alert.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.mutedInk, height: 1.4)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 4),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: math.min(12.5, 13), color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  const _Quick(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.alpha(Colors.white, 0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.alpha(Colors.white, 0.14)),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.navy, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
