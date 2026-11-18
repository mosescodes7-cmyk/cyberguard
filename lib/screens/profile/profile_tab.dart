import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/common.dart';
import '../../widgets/form_widgets.dart';
import '../admin/admin_screen.dart';
import '../scan/history_screen.dart';
import 'change_pin_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _alertsOn = true;

  @override
  void initState() {
    super.initState();
    NotificationService.isEnabled().then((v) {
      if (mounted) setState(() => _alertsOn = v);
    });
  }

  Future<void> _signOut() async {
    final auth = context.read<AuthProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navy,
        title: const Text('Sign out?'),
        content: const Text('You will need your phone number and PIN to sign in again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) await auth.signOut();
  }

  void _privacy() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navy,
        title: const Text('Privacy notice'),
        content: const SingleChildScrollView(
          child: Text(
            'We store your name, phone number, the links and messages you scan, '
            'and the reports you post. Scans are visible only to you. Reports are '
            'visible to other residents and can be posted anonymously. Content you '
            'scan may be sent to an AI service for analysis. Data is handled in line '
            'with the Data Protection and Privacy Act, 2019. You can delete your '
            'scans and reports at any time.',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return TabScroll(
      maxWidth: 640,
      children: [
        const SizedBox(height: 8),
        Center(child: InitialsAvatar(auth.displayName, size: 88)),
        const SizedBox(height: 16),
        Center(
          child: Text(
            auth.displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            formatPhone(auth.phone),
            style: const TextStyle(color: AppColors.muted, fontSize: 15),
          ),
        ),
        const SizedBox(height: 14),
        Center(child: Tag(auth.userType, filled: true)),
        if (auth.isAdmin) ...[
          const SectionHeader('Administration'),
          AppCard(
            padding: EdgeInsets.zero,
            child: _Tile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Admin panel',
              subtitle: 'Post resources and official alerts',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminScreen()),
              ),
            ),
          ),
        ],
        const SectionHeader('Account'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _Tile(
                icon: Icons.lock_outline,
                title: 'Change PIN',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChangePinScreen()),
                ),
              ),
              const _Divider(),
              _Tile(
                icon: Icons.history,
                title: 'Scan history',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
              ),
              const _Divider(),
              _Tile(
                icon: Icons.notifications_none,
                title: 'Threat alert notifications',
                trailing: Switch(
                  value: _alertsOn,
                  onChanged: (v) {
                    setState(() => _alertsOn = v);
                    NotificationService.setEnabled(v);
                  },
                  thumbColor: const WidgetStatePropertyAll(Colors.white),
                  trackColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.accent
                        : AppColors.alpha(Colors.white, 0.2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SectionHeader('About'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _Tile(icon: Icons.privacy_tip_outlined, title: 'Privacy notice', onTap: _privacy),
              const _Divider(),
              const _Tile(
                icon: Icons.info_outline,
                title: '${AppConfig.appName} 1.0.0',
                subtitle: 'Mobile threat detection and awareness for Mbarara City',
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        OutlineButtonX(
          label: 'Sign out',
          icon: Icons.logout,
          color: AppColors.danger,
          onPressed: _signOut,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: AppColors.alpha(Colors.white, 0.1), indent: 18, endIndent: 18);
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.muted),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15.5)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
                    ],
                  ],
                ),
              ),
              trailing ??
                  (onTap != null
                      ? const Icon(Icons.chevron_right, color: AppColors.muted)
                      : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}
