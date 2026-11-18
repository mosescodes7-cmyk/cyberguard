import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/learning_resource.dart';
import '../models/official_alert.dart';
import '../models/scan_result.dart';
import '../models/threat_report.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _scans(String uid) =>
      _db.collection('users').doc(uid).collection('scans');

  Stream<List<ScanResult>> scans(String uid, {int limit = 100}) {
    return _scans(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(ScanResult.fromDoc).toList());
  }

  Future<void> saveScan(String uid, ScanResult r) async {
    await _scans(uid).add(r.toMap());
  }

  Future<void> deleteScan(String uid, String id) async {
    await _scans(uid).doc(id).delete();
  }

  Stream<List<ThreatReport>> reports({int limit = 100}) {
    return _db
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(ThreatReport.fromDoc).toList());
  }

  Future<void> createReport({
    required String uid,
    required String authorName,
    required String category,
    required String description,
    required String division,
  }) async {
    await _db.collection('reports').add({
      'uid': uid,
      'authorName': authorName,
      'category': category,
      'description': description,
      'division': division,
      'confirms': 0,
      'confirmedBy': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleConfirm(String reportId, String uid) async {
    final ref = _db.collection('reports').doc(reportId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data();
      if (data == null) return;
      final by = List<String>.from((data['confirmedBy'] as List?) ?? const []);
      if (by.contains(uid)) {
        by.remove(uid);
      } else {
        by.add(uid);
      }
      tx.update(ref, {'confirmedBy': by, 'confirms': by.length});
    });
  }

  Future<void> deleteReport(String id) async {
    await _db.collection('reports').doc(id).delete();
  }

  Stream<List<OfficialAlert>> alerts({int limit = 30}) {
    return _db
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(OfficialAlert.fromDoc).toList());
  }

  // ---- Learning resources (posted by admins) ----

  Stream<List<LearningResource>> resources({int limit = 50}) {
    return _db
        .collection('resources')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(LearningResource.fromDoc).toList());
  }

  Future<void> createResource({
    required String uid,
    required String authorName,
    required String title,
    required String description,
    required String body,
    required String category,
    required String type,
    required String fileUrl,
    required String thumbnailUrl,
  }) async {
    await _db.collection('resources').add({
      'uid': uid,
      'authorName': authorName,
      'title': title,
      'description': description,
      'body': body,
      'category': category,
      'type': type,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteResource(String id) async {
    await _db.collection('resources').doc(id).delete();
  }

  // ---- Official alerts (posted by admins) ----

  Future<void> createAlert({
    required String title,
    required String body,
    required String severity,
  }) async {
    await _db.collection('alerts').add({
      'title': title,
      'body': body,
      'severity': severity,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAlert(String id) async {
    await _db.collection('alerts').doc(id).delete();
  }
}
