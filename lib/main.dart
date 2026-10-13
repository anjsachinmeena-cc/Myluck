import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

const purple = Color(0xFF9D4EDD);

// ---------------- Languages ----------------

class AppLanguage {
  const AppLanguage(this.code, this.name);
  final String code, name;
}

// Nayi language jodni ho to yahan ek line aur neeche _strings me ek block add karo.
const languages = <AppLanguage>[
  AppLanguage('en', 'English'),
  AppLanguage('hi', 'हिन्दी'),
  AppLanguage('zh', '简体中文'),
];

const _strings = <String, Map<String, String>>{
  'en': {
    'welcomeBack': 'Welcome back',
    'createAccount': 'Create a new account',
    'email': 'Email',
    'password': 'Password',
    'confirmPassword': 'Re-enter password',
    'errEmail': 'Enter a valid email',
    'errPwShort': 'At least 6 characters',
    'errPwMatch': 'Passwords do not match',
    'login': 'Log in',
    'signUp': 'Sign up',
    'haveAccount': 'Already have an account? Log in',
    'noAccount': 'New here? Sign up',
    'guest': 'Continue as guest',
    'localNote':
        'Your account is saved only on this phone. It will be lost if you uninstall the app or switch phones.',
    'errExists': 'An account with this email already exists. Please log in.',
    'errNoAccount': 'No account found for this email. Please sign up first.',
    'errWrongPw': 'Wrong password.',
    'guestName': 'Guest',
    'loading': 'Loading…',
    'videoFailed': 'Video failed to load. Tap to try again.',
    'like': 'Like',
    'liked': 'Liked',
    'language': 'Language',
  },
  'hi': {
    'welcomeBack': 'वापस आने पर स्वागत है',
    'createAccount': 'नया अकाउंट बनाएँ',
    'email': 'ईमेल',
    'password': 'पासवर्ड',
    'confirmPassword': 'पासवर्ड दोबारा लिखें',
    'errEmail': 'सही ईमेल डालें',
    'errPwShort': 'कम से कम 6 अक्षर चाहिए',
    'errPwMatch': 'दोनों पासवर्ड मेल नहीं खाते',
    'login': 'लॉग इन',
    'signUp': 'साइन अप',
    'haveAccount': 'पहले से अकाउंट है? लॉग इन करें',
    'noAccount': 'नए हैं? साइन अप करें',
    'guest': 'गेस्ट के रूप में देखें',
    'localNote':
        'अकाउंट सिर्फ़ इसी फ़ोन में सेव होता है। ऐप अनइंस्टॉल करने पर या दूसरे फ़ोन में यह नहीं मिलेगा।',
    'errExists': 'इस ईमेल से अकाउंट पहले से बना है। लॉग इन करें।',
    'errNoAccount': 'इस ईमेल का अकाउंट नहीं मिला। पहले साइन अप करें।',
    'errWrongPw': 'पासवर्ड गलत है।',
    'guestName': 'गेस्ट',
    'loading': 'लोड हो रहा है…',
    'videoFailed': 'वीडियो लोड नहीं हुआ। दोबारा कोशिश के लिए टैप करें।',
    'like': 'पसंद',
    'liked': 'पसंद किया',
    'language': 'भाषा',
  },
  'zh': {
    'welcomeBack': '欢迎回来',
    'createAccount': '创建新账号',
    'email': '邮箱',
    'password': '密码',
    'confirmPassword': '再次输入密码',
    'errEmail': '请输入有效的邮箱',
    'errPwShort': '至少需要 6 个字符',
    'errPwMatch': '两次输入的密码不一致',
    'login': '登录',
    'signUp': '注册',
    'haveAccount': '已有账号？去登录',
    'noAccount': '没有账号？去注册',
    'guest': '以游客身份浏览',
    'localNote': '账号仅保存在这部手机上。卸载应用或更换手机后将无法找回。',
    'errExists': '该邮箱已注册，请直接登录。',
    'errNoAccount': '未找到该邮箱的账号，请先注册。',
    'errWrongPw': '密码错误。',
    'guestName': '游客',
    'loading': '加载中…',
    'videoFailed': '视频加载失败，点击重试。',
    'like': '点赞',
    'liked': '已赞',
    'language': '语言',
  },
};

final langNotifier = ValueNotifier<String>('en');

class LangScope extends InheritedNotifier<ValueNotifier<String>> {
  const LangScope({super.key, required ValueNotifier<String> notifier, required super.child})
      : super(notifier: notifier);
}

String tr(BuildContext context, String key) {
  final code = context.dependOnInheritedWidgetOfExactType<LangScope>()?.notifier?.value ?? 'en';
  return _strings[code]?[key] ?? _strings['en']![key] ?? key;
}

class LangStore {
  static const _key = 'lang';

  static Future<String?> saved() async {
    final p = await SharedPreferences.getInstance();
    final c = p.getString(_key);
    return languages.any((l) => l.code == c) ? c : null;
  }

  static Future<void> set(String code) async {
    langNotifier.value = code;
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, code);
  }
}

// ---------------- Reels data ----------------

class Reel {
  const Reel(this.creator, this.caption, this.url);
  final String creator, caption, url;
}

// Yahan apni videos ke direct .mp4 links add karo.
const reels = <Reel>[
  Reel('@myluck_demo', 'Welcome to Myluck ✨',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
  Reel('@creator_one', 'Discover something new 🦋',
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
];

// ---------------- Account storage (sirf is phone me) ----------------

class AuthStore {
  static const _accountsKey = 'accounts';
  static const _sessionKey = 'session';

  static Map<String, dynamic> _readAccounts(SharedPreferences p) {
    final raw = p.getString(_accountsKey);
    if (raw == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  static String _salt() {
    final r = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  static String _hash(String salt, String pw) =>
      sha256.convert(utf8.encode('$salt:$pw')).toString();

  static Future<String?> currentUser() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_sessionKey);
    if (s == null) return null;
    return _readAccounts(p).containsKey(s) ? s : null;
  }

  // Error ki key wapas deta hai (screen par translate hoti hai), sab theek ho to null.
  static Future<String?> signUp(String email, String pw) async {
    final p = await SharedPreferences.getInstance();
    final key = email.trim().toLowerCase();
    final accounts = _readAccounts(p);
    if (accounts.containsKey(key)) return 'errExists';
    final salt = _salt();
    accounts[key] = {'salt': salt, 'hash': _hash(salt, pw)};
    await p.setString(_accountsKey, jsonEncode(accounts));
    await p.setString(_sessionKey, key);
    return null;
  }

  static Future<String?> login(String email, String pw) async {
    final p = await SharedPreferences.getInstance();
    final key = email.trim().toLowerCase();
    final entry = _readAccounts(p)[key];
    if (entry == null) return 'errNoAccount';
    final m = Map<String, dynamic>.from(entry as Map);
    if (_hash(m['salt'] as String, pw) != m['hash']) return 'errWrongPw';
    await p.setString(_sessionKey, key);
    return null;
  }

  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_sessionKey);
  }
}

// ---------------- App ----------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final lang = await LangStore.saved();
  final user = await AuthStore.currentUser();
  if (lang != null) langNotifier.value = lang;
  runApp(MyluckApp(hasLang: lang != null, startUser: user));
}

class MyluckApp extends StatelessWidget {
  const MyluckApp({super.key, required this.hasLang, this.startUser});
  final bool hasLang;
  final String? startUser;

  @override
  Widget build(BuildContext context) {
    final u = startUser;
    final Widget home = !hasLang
        ? LanguageScreen(firstRun: true, startUser: u)
        : (u == null ? const AuthScreen() : ReelsScreen(userName: u));
    return LangScope(
      notifier: langNotifier,
      child: ValueListenableBuilder<String>(
        valueListenable: langNotifier,
        builder: (_, code, __) => MaterialApp(
          title: 'Myluck',
          debugShowCheckedModeBanner: false,
          locale: Locale(code),
          supportedLocales: [for (final l in languages) Locale(l.code)],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(seedColor: purple, brightness: Brightness.dark),
            scaffoldBackgroundColor: Colors.black,
            useMaterial3: true,
          ),
          home: home,
        ),
      ),
    );
  }
}

// ---------------- Language screen ----------------

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key, this.firstRun = false, this.startUser});
  final bool firstRun;
  final String? startUser;

  Future<void> pick(BuildContext context, String code) async {
    await LangStore.set(code);
    if (!context.mounted) return;
    if (firstRun) {
      final u = startUser;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => u == null ? const AuthScreen() : ReelsScreen(userName: u),
      ));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = langNotifier.value;
    return Scaffold(
      appBar: firstRun ? null : AppBar(title: Text(tr(context, 'language'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (firstRun) ...[
              const SizedBox(height: 24),
              const Text('myluck',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: purple)),
              const SizedBox(height: 14),
              const Text('Choose your language\nअपनी भाषा चुनें\n选择语言',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18, height: 1.5)),
              const SizedBox(height: 24),
            ],
            for (final l in languages)
              Card(
                child: ListTile(
                  title: Text(l.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: (!firstRun && l.code == current)
                      ? const Icon(Icons.check_circle, color: purple)
                      : null,
                  onTap: () => pick(context, l.code),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Login / Sign up ----------------

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool signUp = false;
  bool hide = true;
  bool busy = false;
  String? errorKey;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  void openReels(String? who) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ReelsScreen(userName: who)),
    );
  }

  void openLanguage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LanguageScreen()),
    );
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      busy = true;
      errorKey = null;
    });
    final e = email.text.trim();
    final key = signUp
        ? await AuthStore.signUp(e, password.text)
        : await AuthStore.login(e, password.text);
    if (!mounted) return;
    if (key != null) {
      setState(() {
        busy = false;
        errorKey = key;
      });
      return;
    }
    openReels(e.toLowerCase());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: openLanguage,
                        icon: const Icon(Icons.language),
                        label: Text(tr(context, 'language')),
                      ),
                    ),
                    const Text('myluck',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: purple)),
                    const SizedBox(height: 8),
                    Text(signUp ? tr(context, 'createAccount') : tr(context, 'welcomeBack'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: tr(context, 'email'),
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
                          return tr(context, 'errEmail');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: password,
                      obscureText: hide,
                      decoration: InputDecoration(
                        labelText: tr(context, 'password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => hide = !hide),
                          icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                      validator: (v) {
                        if ((v ?? '').length < 6) return tr(context, 'errPwShort');
                        return null;
                      },
                    ),
                    if (signUp) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirm,
                        obscureText: hide,
                        decoration: InputDecoration(
                          labelText: tr(context, 'confirmPassword'),
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v != password.text) return tr(context, 'errPwMatch');
                          return null;
                        },
                      ),
                    ],
                    if (errorKey != null) ...[
                      const SizedBox(height: 14),
                      Text(tr(context, errorKey!),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent)),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: busy ? null : submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: busy
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(signUp ? tr(context, 'signUp') : tr(context, 'login')),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() {
                        signUp = !signUp;
                        errorKey = null;
                      }),
                      child: Text(signUp ? tr(context, 'haveAccount') : tr(context, 'noAccount')),
                    ),
                    const Divider(height: 28),
                    OutlinedButton.icon(
                      onPressed: () => openReels(null),
                      icon: const Icon(Icons.person_outline),
                      label: Text(tr(context, 'guest')),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr(context, 'localNote'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

// ---------------- Reels ----------------

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key, this.userName});
  final String? userName; // null = guest
  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final controller = PageController();
  final Set<int> liked = {};
  int current = 0;
  bool muted = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> logout() async {
    await AuthStore.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  void openLanguage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LanguageScreen()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(children: [
          PageView.builder(
            controller: controller,
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            onPageChanged: (i) => setState(() => current = i),
            itemBuilder: (_, i) => ReelCard(
              reel: reels[i],
              active: i == current,
              muted: muted,
              liked: liked.contains(i),
              onLike: () => setState(() {
                if (!liked.add(i)) liked.remove(i);
              }),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
              child: Row(children: [
                const Text('myluck',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(widget.userName ?? tr(context, 'guestName'),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ),
                IconButton(
                  onPressed: openLanguage,
                  icon: const Icon(Icons.language),
                ),
                IconButton(
                  onPressed: () => setState(() => muted = !muted),
                  icon: Icon(muted ? Icons.volume_off : Icons.volume_up),
                ),
                IconButton(
                  onPressed: logout,
                  icon: const Icon(Icons.logout),
                ),
              ]),
            ),
          ),
        ]),
      );
}

cl
