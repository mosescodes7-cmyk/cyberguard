import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

enum ScanKind { link, message }

enum Verdict { safe, suspicious, dangerous }

extension VerdictX on Verdict {
  String get label {
    switch (this) {
      case Verdict.safe:
        return 'Looks safe';
      case Verdict.suspicious:
        return 'Suspicious';
      case Verdict.dangerous:
        return 'Dangerous';
    }
  }

  Color get color {
    switch (this) {
      case Verdict.safe:
        return AppColors.safe;
      case Verdict.suspicious:
        return AppColors.warn;
      case Verdict.dangerous:
        return AppColors.danger;
    }
  }

  IconData get icon {
    switch (this) {
      case Verdict.safe:
        return Icons.gpp_good_outlined;
      case Verdict.suspicious:
        return Icons.gpp_maybe_outlined;
      case Verdict.dangerous:
        return Icons.gpp_bad_outlined;
    }
  }

  static Verdict fromScore(int s) {
    if (s >= 60) return Verdict.dangerous;
    if (s >= 30) return Verdict.suspicious;
    return Verdict.safe;
  }

  static Verdict parse(String? v, int score) {
    switch ((v ?? '').toLowerCase().trim()) {
      case 'safe':
        return Verdict.safe;
      case 'suspicious':
        return Verdict.suspicious;
      case 'dangerous':
        return Verdict.dangerous;
    }
    return fromScore(score);
  }
}

List<String> _strings(dynamic v) =>
    (v is List) ? v.map((e) => e.toString()).toList() : <String>[];

int _clampScore(num v) => v.round().clamp(0, 100).toInt();

class ScanResult {
  const ScanResult({
    this.id = '',
    required this.kind,
    required this.input,
    required this.verdict,
    required this.riskScore,
    required this.category,
    required this.summary,
    required this.reasons,
    required this.actions,
    required this.source,
    required this.createdAt,
  });

  final String id;
  final ScanKind kind;
  final String input;
  final Verdict verdict;
  final int riskScore;
  final String category;
  final String summary;
  final List<String> reasons;
  final List<String> actions;
  final String source;
  final DateTime createdAt;

  String get kindLabel => kind == ScanKind.link ? 'Link' : 'Message';

  factory ScanResult.fromAiJson(
    Map<String, dynamic> json, {
    required ScanKind kind,
    required String input,
  }) {
    final score = _clampScore((json['risk_score'] as num?) ?? 50);
    return ScanResult(
      kind: kind,
      input: input,
      verdict: VerdictX.parse(json['verdict']?.toString(), score),
      riskScore: score,
      category: (json['category'] ?? 'Unclassified').toString(),
      summary: (json['summary'] ?? '').toString(),
      reasons: _strings(json['reasons']),
      actions: _strings(json['recommended_actions']),
      source: 'AI analysis (Groq)',
      createdAt: DateTime.now(),
    );
  }

  factory ScanResult.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final score = _clampScore((d['riskScore'] as num?) ?? 0);
    return ScanResult(
      id: doc.id,
      kind: d['kind'] == 'message' ? ScanKind.message : ScanKind.link,
      input: (d['input'] ?? '').toString(),
      verdict: VerdictX.parse(d['verdict']?.toString(), score),
      riskScore: score,
      category: (d['category'] ?? '').toString(),
      summary: (d['summary'] ?? '').toString(),
      reasons: _strings(d['reasons']),
      actions: _strings(d['actions']),
      source: (d['source'] ?? '').toString(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'kind': kind == ScanKind.link ? 'link' : 'message',
        'input': input,
        'verdict': verdict.name,
        'riskScore': riskScore,
        'category': category,
        'summary': summary,
        'reasons': reasons,
        'actions': actions,
        'source': source,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
