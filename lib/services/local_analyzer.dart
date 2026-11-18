import '../models/scan_result.dart';

/// Lightweight on-device rules. They add context for the AI model and keep
/// the app useful when the network or the AI service is unavailable.
class LocalAnalysis {
  const LocalAnalysis(this.score, this.signals);
  final int score;
  final List<String> signals;

  ScanResult toResult({required ScanKind kind, required String input}) {
    final s = score.clamp(0, 100).toInt();
    final verdict = VerdictX.fromScore(s);
    String category;
    String summary;
    List<String> actions;
    switch (verdict) {
      case Verdict.dangerous:
        category = kind == ScanKind.link ? 'Possible phishing link' : 'Possible scam message';
        summary = 'Several strong warning signs were found. Treat this as a scam.';
        actions = [
          'Do not click, reply or send any money.',
          'Never share your PIN or one-time codes.',
          'Report it in the Community tab and delete it.',
        ];
        break;
      case Verdict.suspicious:
        category = 'Needs caution';
        summary = 'Some warning signs were found. Verify before you act.';
        actions = [
          'Do not act until you confirm with the real organisation.',
          'Use an official website, app or number you already trust.',
          'Ask someone you trust if you are unsure.',
        ];
        break;
      case Verdict.safe:
        category = 'No clear threat found';
        summary = 'No common warning signs were found by the on-device rules. '
            'This is not a guarantee of safety.';
        actions = [
          'Stay alert. Never share your PIN or codes.',
          'If anything feels wrong, do not proceed.',
        ];
        break;
    }
    return ScanResult(
      kind: kind,
      input: input,
      verdict: verdict,
      riskScore: s,
      category: category,
      summary: summary,
      reasons: signals.isEmpty
          ? ['No common warning signs were detected.']
          : signals,
      actions: actions,
      source: 'On-device rules (AI service not reached)',
      createdAt: DateTime.now(),
    );
  }
}

class LocalAnalyzer {
  LocalAnalyzer._();

  static LocalAnalysis analyze(ScanKind kind, String input) =>
      kind == ScanKind.link ? _link(input) : _message(input);

  static const _shorteners = [
    'bit.ly', 'tinyurl.com', 't.co', 'goo.gl', 'is.gd', 'cutt.ly',
    'rb.gy', 'ow.ly', 'shorturl.at', 'tiny.cc',
  ];

  static const _riskyTlds = [
    '.xyz', '.top', '.click', '.tk', '.ml', '.gq', '.cf', '.work',
    '.zip', '.loan', '.icu', '.cyou', '.monster',
  ];

  static const Map<String, List<String>> _brands = {
    'mtn': ['mtn.co.ug', 'mtn.com'],
    'airtel': ['airtel.co.ug', 'airtel.com'],
    'momo': ['mtn.co.ug', 'mtn.com'],
    'stanbic': ['stanbicbank.co.ug'],
    'absa': ['absa.co.ug'],
    'dfcu': ['dfcugroup.com'],
    'centenary': ['centenarybank.co.ug'],
    'paypal': ['paypal.com'],
    'facebook': ['facebook.com'],
    'whatsapp': ['whatsapp.com'],
  };

  static LocalAnalysis _link(String input) {
    final raw = input.trim();
    final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://').hasMatch(raw);
    final uri = Uri.tryParse(hasScheme ? raw : 'http://$raw');
    if (uri == null || uri.host.isEmpty || !uri.host.contains('.')) {
      return const LocalAnalysis(40, ['This does not look like a valid web address.']);
    }
    final host = uri.host.toLowerCase();
    var score = 0;
    final signals = <String>[];

    if (RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(host)) {
      score += 30;
      signals.add('It uses a raw IP address instead of a normal website name.');
    }
    if (_shorteners.any((s) => host == s || host.endsWith('.$s'))) {
      score += 15;
      signals.add('It is a shortened link, so the real destination is hidden.');
    }
    if (hasScheme && raw.toLowerCase().startsWith('http://')) {
      score += 10;
      signals.add('It does not use a secure connection (https).');
    }
    if (raw.contains('@')) {
      score += 20;
      signals.add('It contains an @ symbol, a trick used to disguise the real site.');
    }
    if (host.contains('xn--')) {
      score += 25;
      signals.add('The address uses look-alike characters (punycode).');
    }
    if (host.split('.').length >= 5) {
      score += 10;
      signals.add('It has an unusually long chain of sub-domains.');
    }
    if ('-'.allMatches(host).length >= 3) {
      score += 10;
      signals.add('The address has many hyphens, common in fake sites.');
    }
    if (_riskyTlds.any(host.endsWith)) {
      score += 15;
      signals.add('It ends with an extension often used in scam websites.');
    }
    for (final entry in _brands.entries) {
      if (host.contains(entry.key)) {
        final official = entry.value.any((d) => host == d || host.endsWith('.$d'));
        if (!official) {
          score += 25;
          signals.add('The name "${entry.key}" appears in the address but it is not the official website.');
          break;
        }
      }
    }
    final path = (uri.path + (uri.hasQuery ? '?${uri.query}' : '')).toLowerCase();
    const words = [
      'login', 'signin', 'verify', 'secure', 'update', 'confirm', 'account',
      'password', 'bonus', 'prize', 'free', 'claim', 'pin',
    ];
    final hits = words.where(path.contains).length;
    if (hits > 0) {
      score += (hits * 5).clamp(5, 15).toInt();
      signals.add('The address contains words often used to trick people into logging in.');
    }
    return LocalAnalysis(score.clamp(0, 100).toInt(), signals);
  }

  static LocalAnalysis _message(String input) {
    final t = input.toLowerCase();
    var score = 0;
    final signals = <String>[];

    bool any(List<String> keys) => keys.any(t.contains);

    if (any(['urgent', 'immediately', 'within 24 hours', 'act now', 'last warning',
        'suspended', 'blocked', 'deactivated', 'expires today'])) {
      score += 15;
      signals.add('It creates urgency or threatens to block something.');
    }
    if (any(['you have won', 'congratulations', 'prize', 'lottery', 'jackpot',
        'claim your', 'bonus'])) {
      score += 25;
      signals.add('It promises a prize or reward.');
    }
    if (any(['sent by mistake', 'sent in error', 'wrong number', 'reverse the',
        'send back', 'return the money'])) {
      score += 30;
      signals.add('It matches the "money sent in error" trick used in mobile money fraud.');
    }
    if (any(['processing fee', 'registration fee', 'pay a fee', 'loan approved',
        'send a fee', 'activation fee'])) {
      score += 30;
      signals.add('It asks for a fee before giving you money or a service.');
    }
    if (any(['your pin', 'confirm pin', 'enter pin', 'password', 'otp',
        'verification code', 'secret code'])) {
      score += 35;
      signals.add('It asks for a PIN, password or code. Genuine services never do.');
    }
    final links = RegExp(r'(https?://|www\.)\S+').allMatches(t).length;
    if (links > 0) {
      score += 10;
      signals.add('It contains a link you are asked to open.');
    }
    if (_shorteners.any(t.contains)) {
      score += 10;
      signals.add('It contains a shortened link that hides the destination.');
    }
    return LocalAnalysis(score.clamp(0, 100).toInt(), signals);
  }
}
