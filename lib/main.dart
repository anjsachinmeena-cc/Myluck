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

// ---------------- App + main ----------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedLang = await LangStore.saved();
  if (savedLang != null) langNotifier.value = savedLang;
  final user = await AuthStore.currentUser();
  runApp(MyluckApp(initialUser: user));
}

class MyluckApp extends StatelessWidget {
  const MyluckApp({super.key, this.initialUser});
  final String? initialUser;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: langNotifier,
      builder: (context, code, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Myluck',
          locale: Locale(code),
          supportedLocales: languages.map((l) => Locale(l.code)).toList(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: purple,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: Colors.black,
          ),
          builder: (context, child) =>
              LangScope(notifier: langNotifier, child: child ?? const SizedBox()),
          home: initialUser != null
              ? ReelsScreen(userName: initialUser)
              : const AuthScreen(),
        );
      },
    );
  }
}

// ---------------- Language screen ----------------

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final current = langNotifier.value;
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'language'))),
      body: ListView(
        children: [
          for (final l in languages)
            ListTile(
              title: Text(l.name),
              trailing: l.code == current
                  ? const Icon(Icons.check, color: purple)
                  : null,
              onTap: () async {
                await LangStore.set(l.code);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
        ],
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
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _signUp = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  bool _validEmail(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = _signUp
        ? await AuthStore.signUp(_email.text, _pw.text)
        : await AuthStore.login(_email.text, _pw.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _busy = false;
        _error = err;
      });
      return;
    }
    final name = _email.text.trim().toLowerCase();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ReelsScreen(userName: name)),
    );
  }

  void _guest() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ReelsScreen()),
    );
  }

  void _openLanguage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LanguageScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _openLanguage,
                        tooltip: tr(context, 'language'),
                        icon: const Icon(Icons.language),
                      ),
                    ),
                    const Text(
                      'myluck',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr(context, _signUp ? 'createAccount' : 'welcomeBack'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: tr(context, 'email'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          _validEmail(v ?? '') ? null : tr(context, 'errEmail'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pw,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: tr(context, 'password'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => (v ?? '').length < 6
                          ? tr(context, 'errPwShort')
                          : null,
                    ),
                    if (_signUp) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pw2,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: tr(context, 'confirmPassword'),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v != _pw.text ? tr(context, 'errPwMatch') : null,
                      ),
                    ],
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          tr(context, _error!),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    const SizedBox(height: 20),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(tr(context, _signUp ? 'signUp' : 'login')),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                                _signUp = !_signUp;
                                _error = null;
                              }),
                      child: Text(
                        tr(context, _signUp ? 'haveAccount' : 'noAccount'),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: _busy ? null : _guest,
                      child: Text(tr(context, 'guest')),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr(context, 'localNote'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
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

// ---------------- ReelCard ----------------

class ReelCard extends StatefulWidget {
  const ReelCard({
    super.key,
    required this.reel,
    required this.active,
    required this.muted,
    required this.liked,
    required this.onLike,
  });

  final Reel reel;
  final bool active;
  final bool muted;
  final bool liked;
  final VoidCallback onLike;

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard> {
  VideoPlayerController? _c;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final c = VideoPlayerController.networkUrl(Uri.parse(widget.reel.url));
    _c = c;
    try {
      await c.initialize();
      if (!mounted) return;
      await c.setLooping(true);
      await c.setVolume(widget.muted ? 0 : 1);
      if (widget.active) await c.play();
      if (!mounted) return;
      setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _retry() {
    _c?.dispose();
    _c = null;
    setState(() {
      _failed = false;
      _ready = false;
    });
    _init();
  }

  @override
  void didUpdateWidget(ReelCard old) {
    super.didUpdateWidget(old);
    final c = _c;
    if (!_ready || c == null) return;
    c.setVolume(widget.muted ? 0 : 1);
    if (widget.active) {
      c.play();
    } else {
      c.pause();
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final Widget content;
    if (_failed) {
      content = GestureDetector(
        onTap: _retry,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              tr(context, 'videoFailed'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    } else if (!_ready || c == null) {
      content = Center(
        child: Text(
          tr(context, 'loading'),
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else {
      content = SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: c.value.size.width,
            height: c.value.size.height,
            child: VideoPlayer(c),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(fit: StackFit.expand, children: [
        content,
        Positioned(
          right: 16,
          bottom: 80,
          child: IconButton(
            onPressed: widget.onLike,
            tooltip: tr(context, widget.liked ? 'liked' : 'like'),
            icon: Icon(
              widget.liked ? Icons.favorite : Icons.favorite_border,
              color: widget.liked ? Colors.red : Colors.white,
              size: 36,
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 80,
          bottom: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.reel.creator,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.reel.caption,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
