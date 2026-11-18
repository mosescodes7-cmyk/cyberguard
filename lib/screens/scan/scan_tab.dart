import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../models/scan_result.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/groq_service.dart';
import '../../widgets/common.dart';
import '../../widgets/form_widgets.dart';
import 'scan_result_screen.dart';

class ScanTab extends StatefulWidget {
  const ScanTab({super.key, required this.kindNotifier});
  final ValueNotifier<ScanKind> kindNotifier;

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  final _controller = TextEditingController();
  late ScanKind _kind = widget.kindNotifier.value;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.kindNotifier.addListener(_onKindChanged);
  }

  @override
  void dispose() {
    widget.kindNotifier.removeListener(_onKindChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onKindChanged() {
    setState(() {
      _kind = widget.kindNotifier.value;
      _error = null;
    });
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && text.trim().isNotEmpty) {
      setState(() {
        _controller.text = text.trim();
        _error = null;
      });
    }
  }

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = _kind == ScanKind.link
          ? 'Paste or type the link you want to check.'
          : 'Paste the message you want to check.');
      return;
    }
    FocusScope.of(context).unfocus();
    final analyzer = context.read<ThreatAnalyzer>();
    final fs = context.read<FirestoreService>();
    final uid = context.read<AuthProvider>().uid;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await analyzer.analyze(kind: _kind, input: text);
    // Do not await: Firestore queues the write while offline.
    fs.saveScan(uid, result).catchError((_) {});
    if (!mounted) return;
    setState(() => _loading = false);
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ScanResultScreen(result: result)),
    );
    if (mounted) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isLink = _kind == ScanKind.link;
    return TabScroll(
      maxWidth: 640,
      children: [
        const MixedTitle('Scan for **threats**', size: 30),
        const SizedBox(height: 8),
        const Text(
          'Check a link or a message before you open, reply or pay.',
          style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w300, height: 1.4),
        ),
        const SizedBox(height: 22),
        PillToggle(
          labels: const ['Link', 'Message'],
          index: isLink ? 0 : 1,
          onChanged: (i) => setState(() {
            _kind = i == 0 ? ScanKind.link : ScanKind.message;
            _error = null;
          }),
        ),
        const SizedBox(height: 20),
        AppTextField(
          controller: _controller,
          label: isLink ? 'Link or web address' : 'Message text',
          hint: isLink
              ? 'https://example.com/verify-account'
              : 'Paste the SMS, WhatsApp or email text here',
          icon: isLink ? Icons.link : Icons.sms_outlined,
          keyboardType: isLink ? TextInputType.url : TextInputType.multiline,
          maxLines: isLink ? 3 : 8,
          minLines: isLink ? 2 : 6,
          maxLength: 2000,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            TextButton.icon(
              onPressed: _loading ? null : _paste,
              icon: const Icon(Icons.content_paste, size: 18, color: AppColors.accent),
              label: const Text('Paste', style: TextStyle(color: AppColors.accent)),
            ),
            TextButton.icon(
              onPressed: _loading
                  ? null
                  : () => setState(() {
                        _controller.clear();
                        _error = null;
                      }),
              icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
              label: const Text('Clear', style: TextStyle(color: AppColors.muted)),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          ErrorBanner(_error!),
        ],
        const SizedBox(height: 16),
        PrimaryButton(
          label: _loading ? 'Analysing' : 'Analyse now',
          icon: Icons.shield_outlined,
          loading: _loading,
          onPressed: _analyze,
        ),
        const SizedBox(height: 22),
        AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: AppColors.accent),
              SizedBox(width: Responsive.width(context) < 360 ? 8 : 12),
              const Expanded(
                child: Text(
                  'Never type your PIN or a one-time code into a link you were sent. '
                  'No tool is perfect, so when in doubt, do not click and do not pay.',
                  style: TextStyle(height: 1.45, color: AppColors.muted, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
