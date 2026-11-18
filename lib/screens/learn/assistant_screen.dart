import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/responsive.dart';
import '../../core/theme.dart';
import '../../services/groq_service.dart';
import '../../widgets/common.dart';
import '../../widgets/sub_page.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _messages = <ChatMessage>[];
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  static const _suggestions = [
    'How do I spot a fake mobile money message?',
    'What is SIM swap fraud?',
    'How do I create a strong PIN?',
    'I sent money to a scammer. What now?',
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty || _sending) return;
    final groq = context.read<GroqService>();
    _input.clear();
    setState(() {
      _messages.add(ChatMessage(isUser: true, text: text));
      _sending = true;
    });
    _toEnd();
    String reply;
    try {
      reply = await groq.chat(List.of(_messages));
    } catch (e) {
      // Log the actual error for debugging
      debugPrint('🔴 AI Error: $e');
      reply = groq.isConfigured
          ? 'I could not reach the AI service right now. Please check your '
              'connection and try again.\n\nError: ${e.toString()}'
          : 'The AI agent is not configured yet. The scanner and the '
              'guides in the Learn tab still work.';
    }
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(isUser: false, text: reply));
      _sending = false;
    });
    _toEnd();
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.hPad(context);
    final maxBubble = math.min(520.0, Responsive.width(context) * 0.82);
    return SubPage(
      title: 'AI Agent',
      maxWidth: 760,
      child: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(pad, 16, pad, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MixedTitle('Ask me about **online safety**', size: 28),
                        const SizedBox(height: 10),
                        const Text(
                          'I can explain scams, check your safety habits and tell you what to do after an incident.',
                          style: TextStyle(
                              color: AppColors.muted, height: 1.45, fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in _suggestions)
                              ChoicePill(label: s, selected: false, onTap: () => _send(s)),
                          ],
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(pad, 12, pad, 12),
                    itemCount: _messages.length + (_sending ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _messages.length) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          ),
                        );
                      }
                      final m = _messages[i];
                      return Align(
                        alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: maxBubble),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: m.isUser
                                ? Colors.white
                                : AppColors.alpha(Colors.white, 0.09),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(m.isUser ? 20 : 4),
                              bottomRight: Radius.circular(m.isUser ? 4 : 20),
                            ),
                            border: m.isUser
                                ? null
                                : Border.all(color: AppColors.alpha(Colors.white, 0.14)),
                          ),
                          child: SelectableText(
                            m.text,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              color: m.isUser ? AppColors.ink : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(pad, 6, pad, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 500,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      cursorColor: AppColors.accent,
                      decoration: InputDecoration(
                        hintText: 'Type your question',
                        hintStyle: TextStyle(color: AppColors.alpha(Colors.white, 0.4)),
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.alpha(Colors.white, 0.1),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _sending ? null : _send,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_upward_rounded, color: AppColors.navy),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
