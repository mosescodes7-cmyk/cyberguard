import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../models/learning_resource.dart';
import '../../models/official_alert.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common.dart';
import '../../widgets/dialogs.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/sub_page.dart';
import 'post_alert_screen.dart';
import 'resource_editor_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late final Stream<List<LearningResource>> _resources;
  late final Stream<List<OfficialAlert>> _alerts;
  int _view = 0;

  @override
  void initState() {
    super.initState();
    final fs = context.read<FirestoreService>();
    _resources = fs.resources();
    _alerts = fs.alerts();
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _deleteResource(LearningResource r) async {
    final fs = context.read<FirestoreService>();
    final ok = await confirmAction(
      context,
      title: 'Delete resource?',
      message: '"${r.title}" will be removed for all users.',
    );
    if (!ok) return;
    try {
      await fs.deleteResource(r.id);
    } catch (_) {
      _snack('Could not delete. Check your connection and permissions.');
    }
  }

  Future<void> _deleteAlert(OfficialAlert a) async {
    final fs = context.read<FirestoreService>();
    final ok = await confirmAction(
      context,
      title: 'Delete alert?',
      message: '"${a.title}" will be removed for all users.',
    );
    if (!ok) return;
    try {
      await fs.deleteAlert(a.id);
    } catch (_) {
      _snack('Could not delete. Check your connection and permissions.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final pad = Responsive.hPad(context);

    if (!auth.isAdmin) {
      return const SubPage(
        title: 'Admin panel',
        child: EmptyState(
          icon: Icons.lock_outline,
          title: 'Admins only',
          message: 'Your account does not have admin access.',
        ),
      );
    }

    return SubPage(
      title: 'Admin panel',
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, 10, pad, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MixedTitle('Manage **content**', size: 28),
            const SizedBox(height: 8),
            const Text(
              'Everything you publish here appears instantly in the Learn and '
              'Community tabs of every user.',
              style: TextStyle(color: AppColors.muted, height: 1.45, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 20),
            PillToggle(
              labels: const ['Resources', 'Alerts'],
              index: _view,
              onChanged: (i) => setState(() => _view = i),
            ),
            const SizedBox(height: 18),
            if (_view == 0) ...[
              PrimaryButton(
                label: 'New resource',
                icon: Icons.add,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ResourceEditorScreen()),
                ),
              ),
              const SizedBox(height: 18),
              StreamBuilder<List<LearningResource>>(
                stream: _resources,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const ErrorBanner('Could not load resources.');
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
                      icon: Icons.folder_open,
                      title: 'No resources yet',
                      message: 'Tap New resource to publish your first one.',
                    );
                  }
                  return Column(
                    children: [
                      for (final r in items)
                        AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: const BoxDecoration(
                                    color: Colors.white, shape: BoxShape.circle),
                                child: Icon(r.icon, color: AppColors.navy),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 15.5, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${r.typeLabel}  -  ${r.category}  -  ${timeAgo(r.createdAt)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12.5, color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _deleteResource(r),
                                icon: const Icon(Icons.delete_outline, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ] else ...[
              PrimaryButton(
                label: 'Post alert',
                icon: Icons.campaign_outlined,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PostAlertScreen()),
                ),
              ),
              const SizedBox(height: 18),
              StreamBuilder<List<OfficialAlert>>(
                stream: _alerts,
                builder: (context, snap) {
                  if (snap.hasError) return const ErrorBanner('Could not load alerts.');
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
                      title: 'No alerts posted',
                      message: 'Post a warning to alert residents of Mbarara City.',
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
                                  IconButton(
                                    onPressed: () => _deleteAlert(a),
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppColors.mutedInk, size: 22),
                                  ),
                                ],
                              ),
                              Text(a.title,
                                  style: const TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink)),
                              const SizedBox(height: 6),
                              Text(a.body,
                                  style: const TextStyle(
                                      color: AppColors.mutedInk, height: 1.45)),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
