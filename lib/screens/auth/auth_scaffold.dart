import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/responsive.dart';
import '../../widgets/common.dart';
import '../../widgets/gradient_background.dart';

/// Shared layout for login and sign up: illustration panel plus form.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.form,
  });

  final String asset;
  final String title;
  final String subtitle;
  final Widget form;

  Widget _header() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MixedTitle(title, size: 32),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w300,
              color: Color(0xFFA9B6DC),
            ),
          ),
          const SizedBox(height: 26),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final wide = mq.size.width >= 860;
    final pad = Responsive.hPad(context);

    if (wide) {
      return Scaffold(
        body: GradientBackground(
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                  ),
                  padding: const EdgeInsets.all(40),
                  child: Image.asset(asset, fit: BoxFit.contain),
                ),
              ),
              Expanded(
                flex: 6,
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: pad + 12, vertical: 24),
                      child: ResponsiveCenter(
                        maxWidth: 440,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_header(), form],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final keyboardOpen = mq.viewInsets.bottom > 0;
    final heroHeight =
        keyboardOpen ? 0.0 : math.min(math.max(mq.size.height * 0.27, 140.0), 300.0);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GradientBackground(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: double.infinity,
                height: heroHeight + (keyboardOpen ? 0 : mq.padding.top + 12),
                clipBehavior: Clip.hardEdge,
                padding: EdgeInsets.only(top: keyboardOpen ? 0 : mq.padding.top + 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                ),
                child: Image.asset(asset, fit: BoxFit.contain),
              ),
              SafeArea(
                top: keyboardOpen,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad + 4, 26, pad + 4, 24),
                  child: ResponsiveCenter(
                    maxWidth: 460,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_header(), form],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
