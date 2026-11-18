class AppConfig {
  AppConfig._();

  /// Change the name here and the whole app follows.
  static const String appName = 'CyberGuard';
  static const String tagline = 'Detect. Protect. Stay aware.';

  /// A phone number becomes an email for Firebase Auth:
  /// 0761502754 -> 0761502754@cyberguard.app
  static const String authDomain = 'cyberguard.app';

  /// Groq API key for AI-powered threat analysis
  static const String groqApiKey = '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';
  static const String groqEndpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String scanModel = 'openai/gpt-oss-120b';
  static const String chatModel = 'openai/gpt-oss-120b';

  static const String alertsTopic = 'mbarara_alerts';

  /// Cloudinary unsigned uploads (set the preset to "Unsigned" in Cloudinary).
  static const String cloudinaryCloudName = 'dwtluzyrl';
  static const String cloudinaryPreset = 'cyber34';

  static const List<String> resourceCategories = [
    'General awareness',
    'Phishing',
    'Mobile money safety',
    'Passwords and PINs',
    'Privacy and data',
    'Business security',
    'Reporting and response',
  ];

  static const List<String> divisions = [
    'Kakoba',
    'Kamukuzi',
    'Nyamitanga',
    'Kakiika',
    'Nyakayojo',
    'Other area',
  ];

  static const List<String> userTypes = [
    'Resident',
    'Student',
    'Small business owner',
    'Mobile money agent',
    'Local government staff',
  ];

  static const List<String> reportCategories = [
    'Phishing link',
    'Mobile money fraud',
    'SIM swap attempt',
    'Fake loan app',
    'Fake job or prize offer',
    'Impersonation call',
    'Malware or fake app',
    'Other',
  ];

  static String guessCategory(String aiCategory) {
    final c = aiCategory.toLowerCase();
    if (c.contains('mobile money') || c.contains('momo')) {
      return 'Mobile money fraud';
    }
    if (c.contains('phish')) return 'Phishing link';
    if (c.contains('loan')) return 'Fake loan app';
    if (c.contains('prize') || c.contains('job')) {
      return 'Fake job or prize offer';
    }
    if (c.contains('sim')) return 'SIM swap attempt';
    if (c.contains('imperson')) return 'Impersonation call';
    if (c.contains('malware')) return 'Malware or fake app';
    return 'Other';
  }
}
