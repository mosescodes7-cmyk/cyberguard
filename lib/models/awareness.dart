import 'package:flutter/material.dart';

class AwarenessArticle {
  const AwarenessArticle({
    required this.title,
    required this.tagline,
    required this.icon,
    required this.minutes,
    required this.intro,
    required this.points,
    required this.dos,
    required this.donts,
  });

  final String title;
  final String tagline;
  final IconData icon;
  final int minutes;
  final String intro;
  final List<String> points;
  final List<String> dos;
  final List<String> donts;
}

const List<AwarenessArticle> awarenessArticles = [
  AwarenessArticle(
    title: 'Spot phishing links and messages',
    tagline: 'Fake messages that try to make you click or reply',
    icon: Icons.link_off,
    minutes: 4,
    intro:
        'Phishing is when a criminal pretends to be a trusted company or person '
        'so that you click a link, open a file or share private details. It '
        'arrives by SMS, WhatsApp, email, social media and phone calls.',
    points: [
      'The message creates urgency: "your account will be blocked today".',
      'The link address does not match the real organisation website.',
      'It asks for a PIN, password or one-time code. Genuine companies never do.',
      'Shortened links hide where you will really land.',
      'Spelling mistakes and unusual sender numbers are common warning signs.',
    ],
    dos: [
      'Type the official website address yourself or use the official app.',
      'Scan any link in this app before you open it.',
      'Call the organisation on a number you already trust.',
    ],
    donts: [
      'Do not click links in unexpected messages.',
      'Do not share OTP codes, PINs or passwords with anyone.',
      'Do not forward suspicious links to friends without a warning.',
    ],
  ),
  AwarenessArticle(
    title: 'Mobile money fraud',
    tagline: 'Protect your MTN MoMo and Airtel Money',
    icon: Icons.account_balance_wallet_outlined,
    minutes: 5,
    intro:
        'Mobile money is a favourite target because money moves instantly and '
        'cannot easily be recovered. Fraudsters rely on pressure, trust and '
        'confusion rather than clever technology.',
    points: [
      'Fake "sent in error" messages ask you to send the money back. Check '
          'your real balance through the official USSD menu '
          '(*165# for MTN MoMo, *185# for Airtel Money) before you do anything.',
      'Callers pretend to be network or bank staff and ask for your PIN.',
      'Fake agents ask you to "verify" by sending small amounts first.',
      'Prize and bonus messages ask for a fee before you can "receive" money.',
    ],
    dos: [
      'Confirm transactions only from the official operator menu or app.',
      'Check the name shown before you approve any payment.',
      'Report fraud to your operator straight away.',
    ],
    donts: [
      'Do not reveal your mobile money PIN to anyone, even staff.',
      'Do not send money to receive money.',
      'Do not trust a confirmation message that came from a normal number.',
    ],
  ),
  AwarenessArticle(
    title: 'SIM swap attacks',
    tagline: 'When a criminal takes over your phone number',
    icon: Icons.sim_card_outlined,
    minutes: 3,
    intro:
        'In a SIM swap, a criminal convinces an operator or agent to move your '
        'number to a new SIM. They then receive your calls, SMS codes and may '
        'access your mobile money.',
    points: [
      'Sudden loss of network signal with no explanation is a warning sign.',
      'You may receive messages about a SIM change you did not request.',
      'Attackers often collect your personal details beforehand through calls and chats.',
    ],
    dos: [
      'Contact your operator immediately if your signal drops unexpectedly.',
      'Keep your national ID details private.',
      'Use a PIN lock on your SIM and on your mobile money account.',
    ],
    donts: [
      'Do not share your ID number or date of birth with unknown callers.',
      'Do not ignore a sudden "no service" message for hours.',
    ],
  ),
  AwarenessArticle(
    title: 'Strong PINs and passwords',
    tagline: 'Simple habits that stop most account takeovers',
    icon: Icons.lock_outline,
    minutes: 3,
    intro:
        'A weak PIN or a reused password is an open door. Strong habits take a '
        'few minutes to set up and protect you for years.',
    points: [
      'Avoid birth years, phone numbers, 123456 and repeated digits.',
      'Use a different password for every important account.',
      'Longer passphrases are stronger than short complex ones.',
      'Turn on two-step verification wherever it is offered.',
    ],
    dos: [
      'Use a password manager or a trusted notebook kept at home.',
      'Change a password at once if you think it was exposed.',
      'Lock your phone with a PIN, pattern or fingerprint.',
    ],
    donts: [
      'Do not write your PIN on your phone or ATM card.',
      'Do not let others watch you enter your PIN.',
      'Do not reuse your mobile money PIN for other services.',
    ],
  ),
  AwarenessArticle(
    title: 'Social engineering',
    tagline: 'Criminals who hack people instead of computers',
    icon: Icons.psychology_outlined,
    minutes: 4,
    intro:
        'Social engineering manipulates emotions such as fear, greed, kindness '
        'and respect for authority. The attacker may sound friendly and '
        'professional.',
    points: [
      'They pretend to be a boss, a bank officer, police or a relative in trouble.',
      'They rush you so you cannot think or ask someone else.',
      'They already know a few details about you, which makes them sound real.',
    ],
    dos: [
      'Pause and verify through a second channel before acting.',
      'Ask a trusted person when a request feels unusual.',
      'Tell colleagues and family about scams you encounter.',
    ],
    donts: [
      'Do not act on requests made under pressure.',
      'Do not confirm personal details to an unknown caller.',
    ],
  ),
  AwarenessArticle(
    title: 'Fake loans, jobs and prizes',
    tagline: 'Offers that are too good to be true',
    icon: Icons.request_quote_outlined,
    minutes: 4,
    intro:
        'Scammers advertise instant loans, easy jobs and big prizes. They '
        'collect "registration" or "processing" fees and then disappear, or '
        'they steal your personal data.',
    points: [
      'Real lenders do not ask for a fee before releasing a loan.',
      'Unknown loan apps may ask for access to your contacts and photos.',
      'Job offers that need payment to secure a place are almost always scams.',
      'You cannot win a competition you never entered.',
    ],
    dos: [
      'Check that a lender is licensed before you share any details.',
      'Read the permissions an app asks for before installing.',
      'Visit the company office when possible.',
    ],
    donts: [
      'Do not pay upfront fees to unknown people.',
      'Do not install apps from links sent in chats.',
    ],
  ),
  AwarenessArticle(
    title: 'Public Wi-Fi and shared devices',
    tagline: 'Stay safe in cafes, labs and on borrowed phones',
    icon: Icons.wifi,
    minutes: 3,
    intro:
        'Public networks and shared computers can expose your accounts. A few '
        'precautions greatly reduce the risk.',
    points: [
      'Open Wi-Fi networks can be watched or faked by attackers.',
      'Shared computers may keep your login or record what you type.',
      'Fake hotspots often copy the name of a real cafe or hotel.',
    ],
    dos: [
      'Prefer your own mobile data for banking and mobile money.',
      'Log out and clear browser history on shared computers.',
      'Confirm the exact network name with staff.',
    ],
    donts: [
      'Do not do banking on public Wi-Fi.',
      'Do not tick "remember me" on a shared device.',
    ],
  ),
  AwarenessArticle(
    title: 'Your data rights in Uganda',
    tagline: 'The Data Protection and Privacy Act, 2019',
    icon: Icons.verified_user_outlined,
    minutes: 3,
    intro:
        'The Data Protection and Privacy Act, 2019 gives you rights over your '
        'personal information and places duties on organisations that collect '
        'it.',
    points: [
      'Organisations should collect only the data they need and tell you why.',
      'You can ask what data is held about you and ask for corrections.',
      'Your information should be kept secure and not shared without a lawful reason.',
    ],
    dos: [
      'Read what you are agreeing to before sharing your ID or phone number.',
      'Ask organisations how they will protect your data.',
    ],
    donts: [
      'Do not post photos of IDs or bank cards online.',
      'Do not give personal data for a "free gift".',
    ],
  ),
  AwarenessArticle(
    title: 'What to do after an attack',
    tagline: 'Act quickly to limit the damage',
    icon: Icons.flag_outlined,
    minutes: 3,
    intro:
        'If you clicked a bad link, shared a PIN or sent money to a scammer, '
        'quick action can limit the loss. Do not feel ashamed. Many careful '
        'people are caught.',
    points: [
      'Contact your mobile operator or bank at once and ask to block or reverse where possible.',
      'Change passwords and PINs from a safe device.',
      'Keep screenshots, numbers and transaction messages as evidence.',
      'Report to the Uganda Police Force and, for serious incidents, CERT.UG.',
      'Warn others through the Community tab of this app.',
    ],
    dos: [
      'Act within minutes, not days.',
      'Tell a trusted person what happened.',
    ],
    donts: [
      'Do not delete evidence.',
      'Do not send more money to "recover" lost money.',
    ],
  ),
];

const List<String> dailyTips = [
  'Real companies never ask for your PIN or OTP code, whatever the reason.',
  'Pause before you tap. Urgency is the scammer\'s favourite tool.',
  'Check your balance through the official USSD menu, not an SMS.',
  'A prize you never entered for is not a prize.',
  'Use a different password for every important account.',
  'If your phone suddenly loses signal, call your operator right away.',
  'Do not pay a fee to receive a loan or a job.',
  'Log out of shared computers and clear the browser history.',
  'Tell a friend about every scam you see. Awareness spreads protection.',
];
