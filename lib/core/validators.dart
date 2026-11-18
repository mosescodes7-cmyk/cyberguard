/// Returns a normalised Ugandan mobile number like 0761502754, or null.
String? normalizePhone(String raw) {
  var d = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (d.startsWith('+256')) {
    d = '0${d.substring(4)}';
  } else if (d.startsWith('00256')) {
    d = '0${d.substring(5)}';
  } else if (d.startsWith('256')) {
    d = '0${d.substring(3)}';
  }
  return RegExp(r'^07[0-9]{8}$').hasMatch(d) ? d : null;
}

class Validators {
  Validators._();

  static String? name(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Enter your full name';
    if (t.length < 3) return 'Name is too short';
    return null;
  }

  static String? phone(String? v) {
    if (normalizePhone(v ?? '') == null) {
      return 'Enter a valid number, e.g. 0761502754';
    }
    return null;
  }

  static String? pin(String? v) {
    final t = v ?? '';
    if (!RegExp(r'^[0-9]{6}$').hasMatch(t)) return 'PIN must be 6 digits';
    return null;
  }

  static String? newPin(String? v) {
    final base = pin(v);
    if (base != null) return base;
    final t = v!;
    const weak = ['123456', '654321', '012345', '123123', '121212'];
    if (RegExp(r'^(\d)\1{5}$').hasMatch(t) || weak.contains(t)) {
      return 'Choose a PIN that is harder to guess';
    }
    return null;
  }

  static String? confirmPin(String? v, String original) {
    if (v != original) return 'PINs do not match';
    return null;
  }
}
