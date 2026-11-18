import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/official_alert.dart';
import '../../models/threat_report.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common.dart';
import 'create_report_screen.dart';

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  late final Stream<List<ThreatReport>> _reports;
  late final Stream<List<OfficialAlert>> _alerts;
  int _view = 0;
  String _division = 'All';

  @override
  void initState() {
    super.initState();
    final fs = context.read<FirestoreService>();
    _reports = fs.reports();
    _alerts = fs.alerts();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirm(ThreatReport r) async {
    final uid = context.read<AuthProvider>().uid;
    try {
      await context.read<FirestoreService>().toggleConfirm(r.id, uid);
    } catch (_) {
      if (!mounted) return;
      _snack('Could not update. Check your connection and try again.');
    }
  }

  Future<void> _delete(ThreatReport r) async {
    final fs = context.read<FirestoreService>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navy,
        title: const Text('Delete your report?'),
        content: const Text('Other residents will no longer see it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await fs.deleteReport(r.id);
      } catch (_) {
        if (!mounted) return;
        _snack('Could not delete the report.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthProvider>();
    final uid = authState.uid;
    final isAdmin = authState.isAdmin;
    return TabScroll(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: MixedTitle('Community **threat watch**', size: 28)),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateReportScreen()),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Report'),
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
        const SizedBox(height: 8),
        const Text(
          'Scams reported by residents of Mbarara City. Confirm what you have seen too.',
          style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w300, height: 1.4),
        ),
        const SizedBox(height: 20),
        PillToggle(
          labels: const ['Reports', 'Official alerts'],
          index: _view,
          onChanged: (i) => setState(() => _view = i),
        ),
        const SizedBox(height: 18),
        if (_view == 0) ...[
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final d in ['All', ...AppConfig.divisions])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoicePill(
                      label: d,
                      selected: _division == d,
                      onTap: () => setState(() => _division = d),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<ThreatReport>>(
            stream: _reports,
            builder: (context, snap) {
              if (snap.hasError) {
                return const ErrorBanner('Could not load reports. Check your connection.');
              }
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final items = snap.data!
                  .where((r) => _division == 'All' || r.division == _division)
                  .toList();
              if (items.isEmpty) {
                return const EmptyState(
                  icon: Icons.groups_outlined,
                  title: 'No reports yet',
                  message: 'Be the first to warn your neighbours about a scam.',
                );
              }
              return Column(
                children: [
                  for (final r in items)
                    _ReportCard(
                      report: r,
                      mine: r.uid == uid,
                      canDelete: r.uid == uid || isAdmin,
                      confirmed: r.confirmedBy.contains(uid),
                      onConfirm: () => _confirm(r),
                      onDelete: () => _delete(r),
                    ),
                ],
              );
            },
          ),
        ] else
          StreamBuilder<List<OfficialAlert>>(
            stream: _alerts,
            builder: (context, snap) {
              if (snap.hasError) {
                return const ErrorBanner('Could not load alerts. Check your connection.');
              }
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final items = snap.data!;
              if (items.isEmpty) {
                return const EmptyState(
                  icon: Icons.notifications_none,
                  title: 'No official alerts',
                  message: 'Warnings from the response team will appear here.',
                );
              }
              return Column(
                children: [
                  for (final a in items)
                    AppCard(
                      light: true,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Tag(
                                a.severity.toUpperCase(),
                                filled: true,
                                lightSurface: true,
                                color: a.severity == 'critical'
                                    ? AppColors.danger
                                    : a.severity == 'warning'
                                        ? AppColors.warn
                                        : AppColors.navy,
                              ),
                              const Spacer(),
                              Text(timeAgo(a.createdAt),
                                  style: const TextStyle(
                                      color: AppColors.mutedInk, fontSize: 12.5)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(a.title,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink)),
                          const SizedBox(height: 6),
                          Text(a.body,
                              style: const TextStyle(color: AppColors.mutedInk, height: 1.45)),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.mine,
    required this.canDelete,
    required this.confirmed,
    required this.onConfirm,
    required this.onDelete,
  });

  final ThreatReport report;
  final bool mine;
  final bool canDelete;
  final bool confirmed;
  final VoidCallback onConfirm;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      light: true,
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(child: Tag(report.category, filled: true, lightSurface: true)),
              const SizedBox(width: 8),
              Flexible(child: Tag(report.division, lightSurface: true)),
              const Spacer(),
              if (canDelete)
                InkWell(
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline, size: 20, color: AppColors.mutedInk),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            report.description,
            style: const TextStyle(fontSize: 15.5, height: 1.5, color: AppColors.ink),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${mine ? 'You' : report.authorName}  -  ${timeAgo(report.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.mutedInk, fontSize: 12.5),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: mine ? null : onConfirm,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: confirmed ? AppColors.navy : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.navy),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check,
                          size: 18, color: confirmed ? Colors.white : AppColors.navy),
                      const SizedBox(width: 6),
                      Text(
                        mine
                            ? '${report.confirms} confirmed'
                            : (confirmed ? 'Confirmed ${report.confirms}' : 'I saw this ${report.confirms}'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: confirmed ? Colors.white : AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
