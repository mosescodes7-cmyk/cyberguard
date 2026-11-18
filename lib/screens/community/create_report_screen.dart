import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/sub_page.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({
    super.key,
    this.initialCategory,
    this.initialDescription,
  });
  final String? initialCategory;
  final String? initialDescription;

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _desc =
      TextEditingController(text: widget.initialDescription ?? '');
  late String _category = AppConfig.reportCategories.contains(widget.initialCategory)
      ? widget.initialCategory!
      : AppConfig.reportCategories.first;
  String _division = AppConfig.divisions.first;
  bool _anonymous = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final fs = context.read<FirestoreService>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });
    String message = 'Report submitted. Thank you for warning others.';
    try {
      await fs
          .createReport(
            uid: auth.uid,
            authorName: _anonymous ? 'Anonymous resident' : auth.displayName,
            category: _category,
            description: _desc.text.trim(),
            division: _division,
          )
          .timeout(const Duration(seconds: 8));
    } on TimeoutException {
      message = 'You seem to be offline. Your report will be sent when you reconnect.';
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not submit the report. Please try again.';
      });
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hPad(context);
    return SubPage(
      title: 'Report a threat',
      maxWidth: 640,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(pad, 10, pad, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share what happened so others in Mbarara City can stay safe. '
                'Never include PINs, passwords or full ID numbers.',
                style: TextStyle(color: AppColors.muted, height: 1.45, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 22),
              const _Label('What kind of threat was it?'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in AppConfig.reportCategories)
                    ChoicePill(
                      label: c,
                      selected: _category == c,
                      onTap: () => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              const _Label('Where did it happen?'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in AppConfig.divisions)
                    ChoicePill(
                      label: d,
                      selected: _division == d,
                      onTap: () => setState(() => _division = d),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              AppTextField(
                controller: _desc,
                label: 'Describe what happened',
                hint: 'What did the message or caller say? What did they ask for?',
                maxLines: 6,
                minLines: 4,
                maxLength: 500,
                keyboardType: TextInputType.multiline,
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.length < 15) return 'Please add a little more detail (15+ characters)';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_off_outlined, color: AppColors.muted),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Post as anonymous resident',
                          style: TextStyle(fontSize: 15)),
                    ),
                    Switch(
                      value: _anonymous,
                      onChanged: (v) => setState(() => _anonymous = v),
                      thumbColor: const WidgetStatePropertyAll(Colors.white),
                      trackColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? AppColors.accent
                            : AppColors.alpha(Colors.white, 0.2),
                      ),
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
                label: 'Submit report',
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

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.muted),
      ),
    );
  }
}
