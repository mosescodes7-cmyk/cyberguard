import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/sub_page.dart';

class PostAlertScreen extends StatefulWidget {
  const PostAlertScreen({super.key});

  @override
  State<PostAlertScreen> createState() => _PostAlertScreenState();
}

class _PostAlertScreenState extends State<PostAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  String _severity = 'warning';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final fs = context.read<FirestoreService>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final title = _title.text.trim();
    final body = _body.text.trim();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await fs.createAlert(title: title, body: body, severity: _severity);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not post the alert. Check your connection and admin access.';
      });
      return;
    }
    messenger.showSnackBar(const SnackBar(content: Text('Alert posted.')));
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hPad(context);
    return SubPage(
      title: 'Post alert',
      maxWidth: 640,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(pad, 12, pad, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text('Severity',
                    style: TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.muted)),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in const ['info', 'warning', 'critical'])
                    ChoicePill(
                      label: s[0].toUpperCase() + s.substring(1),
                      selected: _severity == s,
                      onTap: () => setState(() => _severity = s),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _title,
                label: 'Title',
                hint: 'Fake MTN reversal messages in Kakoba',
                maxLength: 100,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v ?? '').trim().length < 5 ? 'Enter a clear title' : null,
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _body,
                label: 'Message',
                hint: 'Describe the threat and what residents should do.',
                maxLength: 300,
                maxLines: 7,
                minLines: 4,
                keyboardType: TextInputType.multiline,
                validator: (v) =>
                    (v ?? '').trim().length < 15 ? 'Add more detail (15+ characters)' : null,
              ),
              const SizedBox(height: 14),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications_active_outlined, color: AppColors.accent),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Push to phones (optional)',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Publishing shows the alert inside the app straight away. To also send a '
                      'phone notification: Firebase console > Messaging > New campaign > '
                      'Notification, choose Topic "mbarara_alerts", and paste the text below.',
                      style: TextStyle(color: AppColors.muted, height: 1.45, fontSize: 13.5),
                    ),
                    const SizedBox(height: 12),
                    OutlineButtonX(
                      label: 'Copy title and message',
                      icon: Icons.copy,
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await Clipboard.setData(
                          ClipboardData(text: '${_title.text.trim()}\n${_body.text.trim()}'),
                        );
                        messenger.showSnackBar(const SnackBar(content: Text('Copied.')));
                      },
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                ErrorBanner(_error!),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Publish alert',
                icon: Icons.send_rounded,
                loading: _loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
