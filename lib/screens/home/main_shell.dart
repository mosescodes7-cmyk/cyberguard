import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/keys.dart';
import '../../core/theme.dart';
import '../../models/scan_result.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/gradient_background.dart';
import '../community/community_tab.dart';
import '../learn/learn_tab.dart';
import '../profile/profile_tab.dart';
import '../scan/scan_tab.dart';
import 'home_tab.dart';

class _Dest {
  const _Dest(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const _dests = [
  _Dest(Icons.home_outlined, Icons.home_rounded, 'Home'),
  _Dest(Icons.document_scanner_outlined, Icons.document_scanner, 'Scan'),
  _Dest(Icons.groups_outlined, Icons.groups, 'Community'),
  _Dest(Icons.school_outlined, Icons.school, 'Learn'),
  _Dest(Icons.person_outline, Icons.person, 'Profile'),
];

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final ValueNotifier<ScanKind> _scanKind = ValueNotifier(ScanKind.link);

  StreamSubscription? _alertSub;
  String? _lastAlertId;

  @override
  void initState() {
    super.initState();
    NotificationService.init(rootMessengerKey);
    // Shows a banner when an admin posts a new alert while the app is open.
    _alertSub = context.read<FirestoreService>().alerts(limit: 1).listen((list) {
      if (list.isEmpty) return;
      final a = list.first;
      if (_lastAlertId == null) {
        _lastAlertId = a.id;
        return;
      }
      if (a.id != _lastAlertId) {
        _lastAlertId = a.id;
        rootMessengerKey.currentState?.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 7),
            content: Text('${a.title}\n${a.body}', maxLines: 4, overflow: TextOverflow.ellipsis),
          ),
        );
      }
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _alertSub?.cancel();
    _scanKind.dispose();
    super.dispose();
  }

  void _go(int i) => setState(() => _index = i);

  void _openScan(ScanKind kind) {
    _scanKind.value = kind;
    _go(1);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 860;
    final body = IndexedStack(
      index: _index,
      children: [
        HomeTab(onScan: _openScan, onOpenTab: _go),
        ScanTab(kindNotifier: _scanKind),
        const CommunityTab(),
        const LearnTab(),
        const ProfileTab(),
      ],
    );

    if (wide) {
      return Scaffold(
        body: GradientBackground(
          child: Row(
            children: [
              NavigationRail(
                backgroundColor: AppColors.alpha(AppColors.night, 0.6),
                selectedIndex: _index,
                onDestinationSelected: _go,
                labelType: NavigationRailLabelType.all,
                indicatorColor: AppColors.alpha(Colors.white, 0.16),
                selectedIconTheme: const IconThemeData(color: Colors.white),
                unselectedIconTheme: const IconThemeData(color: AppColors.muted),
                selectedLabelTextStyle:
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                unselectedLabelTextStyle: const TextStyle(color: AppColors.muted),
                destinations: [
                  for (final d in _dests)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.activeIcon),
                      label: Text(d.label),
                    ),
                ],
              ),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: GradientBackground(child: body),
      bottomNavigationBar: _NavBar(index: _index, onTap: _go),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.black,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: Material(
            color: AppColors.navy,
            elevation: 6,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                children: [
                  for (var i = 0; i < _dests.length; i++)
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () => onTap(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: i == index
                                ? AppColors.alpha(Colors.white, 0.16)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                i == index ? _dests[i].activeIcon : _dests[i].icon,
                                size: 24,
                                color: i == index ? Colors.white : AppColors.muted,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _dests[i].label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      i == index ? FontWeight.w600 : FontWeight.w400,
                                  color: i == index ? Colors.white : AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
