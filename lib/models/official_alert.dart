import 'package:cloud_firestore/cloud_firestore.dart';

class OfficialAlert {
  const OfficialAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;

  /// One of: info, warning, critical
  final String severity;
  final DateTime createdAt;

  factory OfficialAlert.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return OfficialAlert(
      id: doc.id,
      title: (d['title'] ?? '').toString(),
      body: (d['body'] ?? '').toString(),
      severity: (d['severity'] ?? 'info').toString(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
