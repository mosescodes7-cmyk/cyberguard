import 'package:flutter/material.dart';

import '../core/responsive.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import '../widgets/form_widgets.dart';
import '../widgets/gradient_background.dart';

class _Page {
  const _Page(this.asset, this.title, this.body);
  final String asset;
  final String title;
  final String body;
}

const _pages = [
  _Page(
    'assets/images/onboarding_1.jpg',
    'Stay **safe online** and keep being **aware**',
    'Phishing, fake mobile money messages and scam links are everywhere. '
        'Learn to recognise them before they cost you money.',
  ),
  _Page(
    'assets/images/onboarding_2.jpg',
    'Scan **links** and **messages** before you tap',
    'Paste anything suspicious and get a clear verdict, a risk score and '
        'simple advice in seconds.',
  ),
  _Page(
    'assets/images/onboarding_3.jpg',
    'Real-time **alerts** for **Mbarara City**',
    'Share scams you meet, confirm reports from neighbours and receive '
        'warnings the moment a new threat appears.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});
  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _pages.length - 1) {
      widget.onFinished();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;
    final pad = Responsive.hPad(context);
    return Scaffold(
      body: GradientBackground(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.deep, AppColors.deep, AppColors.black],
          stops: [0.0, 0.5, 1.0],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => _OnboardPage(page: _pages[i]),
                  ),
                  if (!last)
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8, right: pad - 8),
                          child: TextButton(
                            onPressed: widget.onFinished,
                            child: const Text(
                              'Skip',
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 8, pad, 20),
                child: ResponsiveCenter(
                  maxWidth: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < _pages.length; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: i == _index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: i == _index
                                    ? Colors.white
                                    : AppColors.alpha(Colors.white, 0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      PrimaryButton(
                        label: last ? 'Get Started' : 'Next',
                        onPressed: _next,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.page});
  final _Page page;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hPad(context);
    return LayoutBuilder(
      builder: (context, c) {
        final landscape = c.maxWidth > c.maxHeight * 1.15 && c.maxWidth > 700;
        final image = Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(page.asset, fit: BoxFit.cover, alignment: Alignment.topCenter),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.alpha(AppColors.skyTop, 0.45),
                    AppColors.alpha(AppColors.deep, 0.25),
                    AppColors.deep,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
        );
        final text = SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: ResponsiveCenter(
            maxWidth: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MixedTitle(page.title, size: 30, align: TextAlign.center),
                const SizedBox(height: 16),
                Text(
                  page.body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15.5,
                    height: 1.5,
                    fontWeight: FontWeight.w300,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        );
        if (landscape) {
          return Row(
            children: [
              Expanded(child: image),
              Expanded(child: Center(child: text)),
            ],
          );
        }
        return Column(
          children: [
            SizedBox(height: c.maxHeight * 0.52, width: double.infinity, child: image),
            Expanded(child: Center(child: text)),
          ],
        );
      },
    );
  }
}
