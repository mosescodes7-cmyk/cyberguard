import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon = Icons.arrow_forward_rounded,
    this.dark = false,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool dark;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? AppColors.navy : Colors.white;
    final fg = dark ? Colors.white : AppColors.navy;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg,
          disabledForegroundColor: fg,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        child: loading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 10),
                    Icon(icon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

class OutlineButtonX extends StatelessWidget {
  const OutlineButtonX({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = Colors.white,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          shape: const StadiumBorder(),
          side: BorderSide(color: AppColors.alpha(color, 0.6)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.suffix,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  static OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: c, width: w),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          maxLines: obscure ? 1 : maxLines,
          minLines: obscure ? 1 : minLines,
          onFieldSubmitted: onSubmitted,
          style: const TextStyle(fontSize: 16, color: Colors.white),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.alpha(Colors.white, 0.4)),
            prefixIcon: icon == null ? null : Icon(icon, color: AppColors.muted, size: 22),
            suffixIcon: suffix,
            counterText: '',
            filled: true,
            fillColor: AppColors.alpha(Colors.white, 0.08),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: _border(AppColors.alpha(Colors.white, 0.14)),
            enabledBorder: _border(AppColors.alpha(Colors.white, 0.14)),
            focusedBorder: _border(AppColors.accent, 1.6),
            errorBorder: _border(AppColors.danger),
            focusedErrorBorder: _border(AppColors.danger, 1.6),
            errorStyle: const TextStyle(color: Color(0xFFFF8A96)),
          ),
        ),
      ],
    );
  }
}

class PinField extends StatefulWidget {
  const PinField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PinField> createState() => _PinFieldState();
}

class _PinFieldState extends State<PinField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: '6-digit PIN',
      icon: Icons.lock_outline,
      obscure: _hidden,
      keyboardType: TextInputType.number,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      maxLength: 6,
      onSubmitted: widget.onSubmitted,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      suffix: IconButton(
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.muted,
          size: 22,
        ),
      ),
    );
  }
}

class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    this.textInputAction = TextInputAction.next,
  });
  final TextEditingController controller;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: 'Phone number',
      hint: '0761502754',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      maxLength: 16,
      validator: (v) {
        final t = v ?? '';
        if (t.trim().isEmpty) return 'Enter your phone number';
        return normalizePhoneOrMessage(t);
      },
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))],
    );
  }
}

String? normalizePhoneOrMessage(String t) {
  final d = t.replaceAll(RegExp(r'[^0-9+]'), '');
  var n = d;
  if (n.startsWith('+256')) {
    n = '0${n.substring(4)}';
  } else if (n.startsWith('00256')) {
    n = '0${n.substring(5)}';
  } else if (n.startsWith('256')) {
    n = '0${n.substring(3)}';
  }
  return RegExp(r'^07[0-9]{8}$').hasMatch(n)
      ? null
      : 'Enter a valid number, e.g. 0761502754';
}
