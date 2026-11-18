import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../models/learning_resource.dart';
import '../../providers/auth_provider.dart';
import '../../services/cloudinary_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/sub_page.dart';

class ResourceEditorScreen extends StatefulWidget {
  const ResourceEditorScreen({super.key});

  @override
  State<ResourceEditorScreen> createState() => _ResourceEditorScreenState();
}

class _ResourceEditorScreenState extends State<ResourceEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _body = TextEditingController();
  final _link = TextEditingController();
  String _type = 'article';
  String _category = AppConfig.resourceCategories.first;
  PlatformFile? _file;
  bool _busy = false;
  String _busyLabel = 'Publishing';
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _body.dispose();
    _link.dispose();
    super.dispose();
  }

  bool get _needsFile => _type == 'pdf' || _type == 'video' || _type == 'image';

  List<String> get _extensions {
    switch (_type) {
      case 'pdf':
        return <String>['pdf'];
      case 'video':
        return <String>['mp4', 'mov', 'webm', 'mkv'];
      case 'image':
        return <String>['jpg', 'jpeg', 'png', 'webp'];
      default:
        return <String>[];
    }
  }

  Future<void> _pick() async {
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _extensions,
        withData: true,
      );
      if (res == null || res.files.isEmpty) return;
      final f = res.files.first;
      if (f.bytes == null) {
        setState(() => _error = 'Could not read that file. Try another one.');
        return;
      }
      if (f.size > CloudinaryService.maxBytes) {
        setState(() => _error = 'File is too large. The limit is 25 MB.');
        return;
      }
      setState(() {
        _file = f;
        _error = null;
      });
    } catch (_) {
      setState(() => _error = 'Could not open the file picker.');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_needsFile && _file == null) {
      setState(() => _error = 'Choose a file to upload.');
      return;
    }
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final fs = context.read<FirestoreService>();
    final cloud = context.read<CloudinaryService>();
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _busy = true;
      _busyLabel = _needsFile ? 'Uploading file' : 'Publishing';
      _error = null;
    });

    try {
      var fileUrl = '';
      var thumb = '';
      if (_needsFile) {
        final up = await cloud.upload(bytes: _file!.bytes!, fileName: _file!.name);
        fileUrl = up.url;
        thumb = up.thumbnailUrl;
        if (mounted) setState(() => _busyLabel = 'Publishing');
      } else if (_type == 'link') {
        fileUrl = _link.text.trim();
      }
      await fs.createResource(
        uid: auth.uid,
        authorName: auth.displayName,
        title: _title.text.trim(),
        description: _desc.text.trim(),
        body: _body.text.trim(),
        category: _category,
        type: _type,
        fileUrl: fileUrl,
        thumbnailUrl: thumb,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e is CloudinaryException
            ? 'Upload failed: ${e.message}'
            : 'Could not publish. Check your connection and admin access.';
      });
      return;
    }
    messenger.showSnackBar(const SnackBar(content: Text('Resource published.')));
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hPad(context);
    return SubPage(
      title: 'New resource',
      maxWidth: 680,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(pad, 12, pad, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Type'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in resourceTypes)
                    ChoicePill(
                      label: resourceTypeLabel(t),
                      selected: _type == t,
                      onTap: () => setState(() {
                        _type = t;
                        _file = null;
                        _error = null;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const _Label('Category'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in AppConfig.resourceCategories)
                    ChoicePill(
                      label: c,
                      selected: _category == c,
                      onTap: () => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _title,
                label: 'Title',
                hint: 'How to spot a fake MoMo message',
                maxLength: 100,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v ?? '').trim().length < 5 ? 'Enter a clear title' : null,
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _desc,
                label: 'Short description',
                hint: 'One or two sentences shown on the card',
                maxLength: 200,
                maxLines: 3,
                minLines: 2,
                validator: (v) =>
                    (v ?? '').trim().length < 10 ? 'Add a short description' : null,
              ),
              if (_type == 'article') ...[
                const SizedBox(height: 18),
                AppTextField(
                  controller: _body,
                  label: 'Article text',
                  hint: 'Write the full lesson here. Use blank lines between paragraphs.',
                  maxLength: 8000,
                  maxLines: 14,
                  minLines: 8,
                  keyboardType: TextInputType.multiline,
                  validator: (v) =>
                      (v ?? '').trim().length < 40 ? 'Write at least a few sentences' : null,
                ),
              ] else ...[
                const SizedBox(height: 18),
                AppTextField(
                  controller: _body,
                  label: 'Extra notes (optional)',
                  hint: 'Context or instructions to show with the file',
                  maxLength: 2000,
                  maxLines: 6,
                  minLines: 3,
                  keyboardType: TextInputType.multiline,
                ),
              ],
              if (_type == 'link') ...[
                const SizedBox(height: 18),
                AppTextField(
                  controller: _link,
                  label: 'Link',
                  hint: 'https://www.youtube.com/watch?v=...',
                  icon: Icons.link,
                  keyboardType: TextInputType.url,
                  validator: (v) {
                    final t = (v ?? '').trim();
                    final uri = Uri.tryParse(t);
                    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https') || uri.host.isEmpty) {
                      return 'Enter a full link starting with https://';
                    }
                    return null;
                  },
                ),
              ],
              if (_needsFile) ...[
                const SizedBox(height: 18),
                _Label('File (${_extensions.join(', ')}, max 25 MB)'),
                AppCard(
                  child: Row(
                    children: [
                      Icon(_file == null ? Icons.upload_file : Icons.check_circle,
                          color: _file == null ? AppColors.muted : AppColors.safe),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _file == null
                              ? 'No file chosen'
                              : '${_file!.name}  (${(_file!.size / 1024 / 1024).toStringAsFixed(1)} MB)',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _busy ? null : _pick,
                        child: Text(_file == null ? 'Choose' : 'Change',
                            style: const TextStyle(color: AppColors.accent)),
                      ),
                    ],
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                ErrorBanner(_error!),
              ],
              const SizedBox(height: 26),
              PrimaryButton(
                label: _busy ? _busyLabel : 'Publish resource',
                icon: Icons.cloud_upload_outlined,
                loading: _busy,
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
