import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/form_widgets.dart';
import 'auth_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  String _userType = AppConfig.userTypes.first;
  bool _agree = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      setState(() => _error = 'Please accept the privacy notice to continue.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await context.read<AuthProvider>().signUp(
          name: _name.text.trim(),
          phone: normalizePhone(_phone.text)!,
          pin: _pin.text,
          userType: _userType,
        );
    if (!mounted) return;
    if (err == null) {
      // Sign out immediately after signup so user goes to login
      await context.read<AuthProvider>().signOut();
      if (!mounted) return;
      // Show success message and go back to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please sign in.'),
          backgroundColor: AppColors.safe,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop(); // Go back to login screen
      return;
    }
    setState(() {
      _loading = false;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      asset: 'assets/images/signup_art.png',
      title: 'Create your **account**',
      subtitle: 'Your phone number and a private 6-digit PIN are all you need.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _name,
              label: 'Full name',
              hint: 'Your full name',
              icon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              validator: Validators.name,
              maxLength: 60,
            ),
            const SizedBox(height: 18),
            PhoneField(controller: _phone),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _userType,
              decoration: InputDecoration(
                labelText: 'I am a',
                labelStyle: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.work_outline, color: AppColors.accent),
                filled: true,
                fillColor: AppColors.alpha(Colors.white, 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.alpha(Colors.white, 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.alpha(Colors.white, 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
              dropdownColor: AppColors.navy,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.accent),
              items: AppConfig.userTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _userType = newValue);
                }
              },
            ),
            const SizedBox(height: 18),
            PinField(
              controller: _pin,
              label: 'Create PIN',
              validator: Validators.newPin,
            ),
            const SizedBox(height: 18),
            PinField(
              controller: _confirm,
              label: 'Confirm PIN',
              validator: (v) => Validators.confirmPin(v, _pin.text),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _agree = !_agree),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                      activeColor: Colors.white,
                      checkColor: AppColors.navy,
                      side: BorderSide(color: AppColors.alpha(Colors.white, 0.6)),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'I agree that my reports and scans are stored securely '
                          'under the Data Protection and Privacy Act, 2019.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              ErrorBanner(_error!),
            ],
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Create Account',
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 18),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  GestureDetector(
                    onTap: _loading ? null : () => Navigator.of(context).maybePop(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
