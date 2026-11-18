import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/format.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../models/learning_resource.dart';
import '../../widgets/common.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/sub_page.dart';

class ResourceScreen extends StatelessWidget {
  const ResourceScreen({super.key, required this.resource});
  final LearningResource resource;

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(resource.fileUrl);
    var ok = false;
    if (uri != null) {
      try {
        ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open the file on this device.')),
      );
    }
  }

  String get _buttonLabel {
    switch (resource.type) {
      case 'pdf':
        return 'Open PDF';
      case 'video':
        return 'Watch video';
      case 'image':
        return 'Open full image';
      default:
        return 'Open link';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hPad(context);
    final r = resource;
    final preview = r.type == 'image' ? r.fileUrl : r.thumbnailUrl;
    final hasFile = r.fileUrl.isNotEmpty;

    return SubPage(
      title: 'Resource',
      maxWidth: 680,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(pad, 10, pad, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Tag(r.typeLabel, filled: true),
                Tag(r.category),
              ],
            ),
            const SizedBox(height: 16),
            Text(r.title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2)),
            const SizedBox(height: 8),
            Text('${r.authorName}  -  ${formatDate(r.createdAt)}',
                style: const TextStyle(color: AppColors.muted, fontSize: 13.5)),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      preview,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 180,
                          color: AppColors.alpha(Colors.white, 0.06),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stack) => const SizedBox.shrink(),
                    ),
                    if (r.type == 'video')
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.alpha(Colors.black, 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, size: 40),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(r.description,
                style: const TextStyle(fontSize: 16.5, height: 1.55, fontWeight: FontWeight.w300)),
            if (hasFile) ...[
              const SizedBox(height: 22),
              PrimaryButton(
                label: _buttonLabel,
                icon: resource.icon,
                onPressed: () => _open(context),
              ),
            ],
            if (r.body.isNotEmpty) ...[
              const SizedBox(height: 24),
              AppCard(
                child: SelectableText(
                  r.body,
                  style: const TextStyle(fontSize: 15.5, height: 1.65),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
