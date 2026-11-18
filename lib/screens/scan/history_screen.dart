import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../models/scan_result.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common.dart';
import '../../widgets/scan_tile.dart';
import '../../widgets/sub_page.dart';
import 'scan_result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final Stream<List<ScanResult>> _stream;
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = context.read<AuthProvider>().uid;
    _stream = context.read<FirestoreService>().scans(_uid);
  }

  Future<void> _confirmDelete(ScanResult r) async {
    final fs = context.read<FirestoreService>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navy,
        title: const Text('Delete this scan?'),
        content: const Text('It will be removed from your history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) {
      fs.deleteScan(_uid, r.id).catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hPad(context);
    return SubPage(
      title: 'Scan history',
      child: StreamBuilder<List<ScanResult>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return Padding(
              padding: EdgeInsets.all(pad),
              child: const ErrorBanner('Could not load your history.'),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              title: 'Nothing here yet',
              message: 'Links and messages you scan are saved here.',
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(pad, 10, pad, 28),
            itemCount: items.length,
            itemBuilder: (_, i) => ScanTile(
              result: items[i],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ScanResultScreen(result: items[i])),
              ),
              onDelete: () => _confirmDelete(items[i]),
            ),
          );
        },
      ),
    );
  }
}
