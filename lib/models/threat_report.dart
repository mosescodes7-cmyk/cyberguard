import 'package:cloud_firestore/cloud_firestore.dart';

class ThreatReport {
  const ThreatReport({
    required this.id,
    required this.uid,
    required this.authorName,
    required this.category,
    required this.description,
    required this.division,
    required this.createdAt,
    required this.confirms,
    required this.confirmedBy,
  });

  final String id;
  final String uid;
  final String authorName;
  final String category;
  final String description;
  final String division;
  final DateTime createdAt;
  final int confirms;
  final List<String> confirmedBy;

  factory ThreatReport.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final by = (d['confirmedBy'] is List)
        ? (d['confirmedBy'] as List).map((e) => e.toString()).toList()
        : <String>[];
    return ThreatReport(
      id: doc.id,
      uid: (d['uid'] ?? '').toString(),
      authorName: (d['authorName'] ?? 'Anonymous resident').toString(),
      category: (d['category'] ?? 'Other').toString(),
      description: (d['description'] ?? '').toString(),
      division: (d['division'] ?? 'Other area').toString(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      confirms: (d['confirms'] as num?)?.toInt() ?? by.length,
      confirmedBy: by,
    );
  }
}
