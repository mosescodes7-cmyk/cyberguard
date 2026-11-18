import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LearningResource {
  const LearningResource({
    required this.id,
    required this.title,
    required this.description,
    required this.body,
    required this.category,
    required this.type,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.authorName,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String body;
  final String category;

  /// article, pdf, video, image or link
  final String type;
  final String fileUrl;
  final String thumbnailUrl;
  final String authorName;
  final DateTime createdAt;

  String get typeLabel => resourceTypeLabel(type);
  IconData get icon => resourceTypeIcon(type);

  factory LearningResource.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return LearningResource(
      id: doc.id,
      title: (d['title'] ?? '').toString(),
      description: (d['description'] ?? '').toString(),
      body: (d['body'] ?? '').toString(),
      category: (d['category'] ?? 'General awareness').toString(),
      type: (d['type'] ?? 'article').toString(),
      fileUrl: (d['fileUrl'] ?? '').toString(),
      thumbnailUrl: (d['thumbnailUrl'] ?? '').toString(),
      authorName: (d['authorName'] ?? 'Admin').toString(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

const List<String> resourceTypes = ['article', 'pdf', 'video', 'image', 'link'];

String resourceTypeLabel(String type) {
  switch (type) {
    case 'pdf':
      return 'PDF';
    case 'video':
      return 'Video';
    case 'image':
      return 'Image';
    case 'link':
      return 'Link';
    default:
      return 'Article';
  }
}

IconData resourceTypeIcon(String type) {
  switch (type) {
    case 'pdf':
      return Icons.picture_as_pdf_outlined;
    case 'video':
      return Icons.play_circle_outline;
    case 'image':
      return Icons.image_outlined;
    case 'link':
      return Icons.open_in_new;
    default:
      return Icons.article_outlined;
  }
}
