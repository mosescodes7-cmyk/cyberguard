import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/responsive.dart';
import '../core/theme.dart';

/// Card used across the app. Dark outlined by default, white when [light].
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.light = false,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.onTap,
  });

  final Widget child;
  final bool light;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(26);
    final content = Padding(padding: padding, child: child);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: light ? Colors.white : AppColors.alpha(Colors.white, 0.07),
        borderRadius: radius,
        border: light
            ? null
            : Border.all(color: AppColors.alpha(Colors.white, 0.14)),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: light ? AppColors.ink : Colors.white),
        child: onTap == null
            ? content
            : Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: radius,
                  onTap: onTap,
                  child: content,
                ),
              ),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag(
    this.label, {
    super.key,
    this.filled = false,
    this.lightSurface = false,
    this.color,
  });

  final String label;
  final bool filled;
  final bool lightSurface;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;
    if (color != null) {
      bg = AppColors.alpha(color!, 0.18);
      fg = color!;
      border = AppColors.alpha(color!, 0.45);
    } else if (lightSurface) {
      bg = filled ? AppColors.navy : Colors.transparent;
      fg = filled ? Colors.white : AppColors.navy;
      border = AppColors.navy;
    } else {
      bg = filled ? Colors.white : Colors.transparent;
      fg = filled ? AppColors.navy : Colors.white;
      border = AppColors.alpha(Colors.white, 0.55);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class MixedTitle extends StatelessWidget {
  const MixedTitle(
    this.text, {
    super.key,
    this.size = 30,
    this.align = TextAlign.start,
    this.color = Colors.white,
  });

  /// Wrap words in ** to make them bold: "Create **Tasks** And Keep"
  final String text;
  final double size;
  final TextAlign align;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final parts = text.split('**');
    final spans = <TextSpan>[];
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(fontWeight: i.isOdd ? FontWeight.w700 : FontWeight.w300),
      ));
    }
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: size, height: 1.2, color: color),
        children: spans,
      ),
      textAlign: align,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.actionLabel, this.onAction});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(color: AppColors.accent, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.4)),
        ],
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.alpha(AppColors.danger, 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.alpha(AppColors.danger, 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: Colors.white, height: 1.35)),
          ),
        ],
      ),
    );
  }
}

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(this.name, {super.key, this.size = 48});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Text(
        initialsOf(name),
        style: TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

/// Two or more options in a pill, like the Active / Done switch in the theme.
class PillToggle extends StatelessWidget {
  const PillToggle({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.alpha(Colors.white, 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.alpha(Colors.white, 0.12)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: i == index ? AppColors.navy : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Selectable pill used for categories, divisions and user types.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : AppColors.alpha(Colors.white, 0.07),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? Colors.white : AppColors.alpha(Colors.white, 0.25),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.navy : Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Scrollable tab body with safe area and a centred, max-width column.
class TabScroll extends StatelessWidget {
  const TabScroll({super.key, required this.children, this.maxWidth = 720});
  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hPad(context);
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, 14, pad, 28),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
