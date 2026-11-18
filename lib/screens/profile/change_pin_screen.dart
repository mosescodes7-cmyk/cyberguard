import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/responsive.dart';
import '../../core/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/sub_page.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await auth.changePin(_current.text, _new.text);
    if (!mounted) return;
    if (err == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Your PIN has been changed.')));
      nav.pop();
      return;
    }
    setState(() {
      _loading = false;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hPad(context);
    return SubPage(
      title: 'Change PIN',
      maxWidth: 520,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(pad, 16, pad, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PinField(
                controller: _current,
                label: 'Current PIN',
                validator: Validators.pin,
              ),
              const SizedBox(height: 18),
              PinField(
                controller: _new,
                label: 'New PIN',
                validator: Validators.newPin,
              ),
              const SizedBox(height: 18),
              PinField(
                controller: _confirm,
                label: 'Confirm new PIN',
                validator: (v) => Validators.confirmPin(v, _new.text),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 18),
                ErrorBanner(_error!),
              ],
              const SizedBox(height: 26),
              PrimaryButton(
                label: 'Update PIN',
                icon: Icons.check_rounded,
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
