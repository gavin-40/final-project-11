import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

void main() => runApp(const NoteFlowApp());

const _ink = Color(0xFF131B2E);
const _muted = Color(0xFF3C4A42);
const _green = Color(0xFF10B981);
const _bg = Color(0xFFFAF8FF);
final ValueNotifier<bool> _appDarkMode = ValueNotifier(false);
final Map<String, ({String password, String name})> _accounts = {
  'rizwan@example.com': (password: 'password123', name: 'Rizwan'),
  'alex@noteflow.com': (password: 'password123', name: 'Alex'),
};
String _activeUserName = 'Rizwan';
String _activeUserEmail = 'rizwan@example.com';

class NoteFlowApp extends StatelessWidget {
  const NoteFlowApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: _appDarkMode,
        builder: (context, dark, _) => MaterialApp(
          title: 'NoteFlow',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: dark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: dark ? const Color(0xFF101820) : _bg,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006C49), brightness: dark ? Brightness.dark : Brightness.light),
            fontFamily: 'Roboto',
          ),
          home: const LoginPage(),
        ),
      );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  bool _remember = true;
  bool _loading = false;
  String? _authError;

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  void _fillDemo() => setState(() { _email.text = 'rizwan@example.com'; _password.text = 'password123'; _authError = null; });

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _authError = null; });
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final email = _email.text.trim().toLowerCase();
    final account = _accounts[email];
    if (account == null) {
      setState(() { _loading = false; _authError = 'Account does not exist. Please check your email or create an account.'; });
      return;
    }
    if (_password.text != account.password) {
      setState(() { _loading = false; _authError = 'Incorrect password. Please try again.'; });
      return;
    }
    _activeUserName = account.name;
    _activeUserEmail = email;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const NotesHomePage()));
  }

  void _showInfo(String title, String message) => showDialog<void>(context: context, builder: (context) => AlertDialog(title: Text(title), content: Text(message), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 14, 24, 22), child: Column(children: [
      Row(children: [Text(TimeOfDay.now().format(context), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _ink)), const Spacer(), const Icon(Icons.signal_cellular_alt, size: 17), const SizedBox(width: 6), const Icon(Icons.wifi, size: 17), const SizedBox(width: 6), const Icon(Icons.battery_full, size: 18)]),
      const SizedBox(height: 26),
      Container(width: 76, height: 76, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: _green.withValues(alpha: .14), blurRadius: 24, offset: const Offset(0, 8))]), child: const Icon(Icons.edit_note, size: 46, color: Color(0xFF006C49))),
      const SizedBox(height: 9), Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('NoteFlow', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _ink)), const SizedBox(width: 5), Container(width: 7, height: 7, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle))]),
      const SizedBox(height: 15), const Text('Welcome Back!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -.5, color: _ink)),
      const SizedBox(height: 5), const Text('Sign in to continue organizing your thoughts seamlessly.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF64748B))),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: const Color(0xFFEAFBF2), border: Border.all(color: const Color(0xFFD1FAE5)), borderRadius: BorderRadius.circular(16)), child: Row(children: [const Icon(Icons.circle, size: 8, color: _green), const SizedBox(width: 7), const Expanded(child: Text('Demo: rizwan@example.com / password123', maxLines: 2, style: TextStyle(fontSize: 10, color: Color(0xFF047857), fontWeight: FontWeight.w600))), TextButton(onPressed: _fillDemo, style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 5), minimumSize: Size.zero), child: const Text('Auto Fill', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)))])),
      if (_authError != null) Container(width: double.infinity, margin: const EdgeInsets.only(top: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF1F0), border: Border.all(color: const Color(0xFFFFC9C5)), borderRadius: BorderRadius.circular(16)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.error_outline, size: 17, color: Colors.red), const SizedBox(width: 8), Expanded(child: Text(_authError!, style: const TextStyle(fontSize: 12, color: Color(0xFFB42318))))])),
      const SizedBox(height: 14),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), border: Border.all(color: const Color(0xFFE8EDF3)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 25, offset: const Offset(0, 12))]), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: Color(0xFF64748B))),
        const SizedBox(height: 7),
        TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.email], onChanged: (_) { if (_authError != null) setState(() => _authError = null); }, validator: (value) { final email = value?.trim() ?? ''; if (email.isEmpty) return 'Email is required'; if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) return 'Please enter a valid email address'; return null; }, decoration: InputDecoration(prefixIcon: const Icon(Icons.mail_outline, size: 20), hintText: 'name@example.com', filled: true, fillColor: const Color(0xFFF8FAFC), contentPadding: const EdgeInsets.symmetric(vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE2E8F0))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE2E8F0))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _green, width: 1.5)))),
        const SizedBox(height: 15),
        const Text('PASSWORD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1, color: Color(0xFF64748B))),
        const SizedBox(height: 7),
        TextFormField(controller: _password, obscureText: !_showPassword, textInputAction: TextInputAction.done, onFieldSubmitted: (_) => _login(), onChanged: (_) { if (_authError != null) setState(() => _authError = null); }, validator: (value) => value == null || value.isEmpty ? 'Password is required' : null, decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline, size: 20), suffixIcon: IconButton(onPressed: () => setState(() => _showPassword = !_showPassword), icon: Icon(_showPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 19)), hintText: '••••••••', filled: true, fillColor: const Color(0xFFF8FAFC), contentPadding: const EdgeInsets.symmetric(vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE2E8F0))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFE2E8F0))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _green, width: 1.5)))),
        const SizedBox(height: 10),
        Row(children: [SizedBox(width: 20, height: 20, child: Checkbox(value: _remember, activeColor: _green, onChanged: (value) => setState(() => _remember = value ?? false))), const SizedBox(width: 5), const Text('Remember me', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))), const Spacer(), TextButton(onPressed: () => _showInfo('Forgot Password?', 'Password reset is not connected in this demo.'), child: const Text('Forgot Password?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _green)))]),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, height: 49, child: FilledButton(onPressed: _loading ? null : _login, style: FilledButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4), child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Log In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 17)]))),
        const SizedBox(height: 21),
        Row(children: [const Expanded(child: Divider(color: Color(0xFFE8EDF3))), Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('OR CONTINUE WITH', style: TextStyle(fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w700, color: Colors.blueGrey.shade300))), const Expanded(child: Divider(color: Color(0xFFE8EDF3)))]),
        const SizedBox(height: 14),
        Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => _showInfo('Google Sign In', 'Google sign in is not connected in this demo.'), icon: const Icon(Icons.g_mobiledata, size: 23), label: const Text('Google', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1E293B), side: const BorderSide(color: Color(0xFFE2E8F0)), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: () => _showInfo('Apple Sign In', 'Apple sign in is not connected in this demo.'), icon: const Icon(Icons.apple, size: 19), label: const Text('Apple', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1E293B), side: const BorderSide(color: Color(0xFFE2E8F0)), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))))]),
      ]))),
      const SizedBox(height: 14),
      Wrap(alignment: WrapAlignment.center, children: [const Text("Don't have an account? ", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))), GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())), child: const Text('Create Account', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _green)))]),
      const SizedBox(height: 13), Container(width: 110, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(8))),
    ]))))),
  );
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _showPassword = false;
  bool _showConfirm = false;
  bool _loading = false;

  @override
  void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); _confirm.dispose(); super.dispose(); }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final name = _name.text.trim();
    final email = _email.text.trim().toLowerCase();
    _accounts[email] = (password: _password.text, name: name);
    _activeUserName = name;
    _activeUserEmail = email;
    await showDialog<void>(context: context, barrierDismissible: false, builder: (context) => AlertDialog(icon: const CircleAvatar(backgroundColor: Color(0xFF85F8C4), child: Icon(Icons.check, color: Color(0xFF006C49))), title: const Text('Account Created'), content: Text('Welcome to NoteFlow, $name!'), actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Continue'))]));
    if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const NotesHomePage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Column(children: [
      SizedBox(height: 60, child: Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: _muted)), const Expanded(child: Text('Sign Up', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink))), const SizedBox(width: 48)])),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 24), child: Column(children: [
        Container(width: 64, height: 64, decoration: const BoxDecoration(color: Color(0xFFEAEDFF), shape: BoxShape.circle), child: const Icon(Icons.edit_note, size: 40, color: Color(0xFF006C49))),
        const SizedBox(height: 9), Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('NoteFlow', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink)), const SizedBox(width: 5), Container(width: 6, height: 6, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle))]),
        const SizedBox(height: 8), const Text('Create Account', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700, letterSpacing: -.4, color: _ink)),
        const SizedBox(height: 4), const Text('Create your account and start organizing your notes.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: _muted)),
        const SizedBox(height: 20),
        Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(26), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .045), blurRadius: 18, offset: const Offset(0, 8))]), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('FULL NAME'),
          _input(_name, hint: 'e.g. Rizwan', icon: Icons.person_outline, textCapitalization: TextCapitalization.words, validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null),
          const SizedBox(height: 13),
          _label('EMAIL ADDRESS'),
          _input(_email, hint: 'name@example.com', icon: Icons.mail_outline, keyboardType: TextInputType.emailAddress, validator: (value) { final email = value?.trim() ?? ''; if (email.isEmpty) return 'Email is required'; if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) return 'Enter a valid email address'; return null; }),
          const SizedBox(height: 13),
          _label('PASSWORD'),
          _input(_password, hint: 'At least 8 characters', icon: Icons.lock_outline, obscure: !_showPassword, suffix: IconButton(onPressed: () => setState(() => _showPassword = !_showPassword), icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, size: 19)), validator: (value) => value == null || value.length < 8 ? 'Use at least 8 characters' : null),
          const SizedBox(height: 13),
          _label('CONFIRM PASSWORD'),
          _input(_confirm, hint: 'Re-enter your password', icon: Icons.lock_outline, obscure: !_showConfirm, suffix: IconButton(onPressed: () => setState(() => _showConfirm = !_showConfirm), icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility, size: 19)), validator: (value) => value != _password.text ? 'Passwords do not match' : null),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: _loading ? null : _register, style: FilledButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white, shape: const StadiumBorder(), elevation: 4), child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Create Account', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)), SizedBox(width: 7), Icon(Icons.arrow_forward, size: 19)]))),
        ]))),
        const SizedBox(height: 18),
        Wrap(alignment: WrapAlignment.center, children: [const Text('Already have an account? ', style: TextStyle(fontSize: 13, color: _muted)), GestureDetector(onTap: () => Navigator.pop(context), child: const Text('Log In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF006C49))))]),
      ]))),
    ])),
  );

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: _muted)));

  Widget _input(TextEditingController controller, {required String hint, required IconData icon, String? Function(String?)? validator, bool obscure = false, Widget? suffix, TextInputType? keyboardType, TextCapitalization textCapitalization = TextCapitalization.none}) => TextFormField(controller: controller, validator: validator, obscureText: obscure, keyboardType: keyboardType, textCapitalization: textCapitalization, decoration: InputDecoration(prefixIcon: Icon(icon, size: 19, color: const Color(0xFF6C7A71)), suffixIcon: suffix, hintText: hint, hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9BA69F)), filled: true, fillColor: const Color(0xFFF2F3FF), contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _green.withValues(alpha: .4), width: 1.5)), errorStyle: const TextStyle(fontSize: 10)));
}

class TextFormatRange {
  const TextFormatRange(this.start, this.end, {this.bold = false, this.italic = false});
  final int start, end;
  final bool bold, italic;
}

class FormattedTextController extends TextEditingController {
  FormattedTextController({super.text}) { _lastText = text; addListener(_trackEdits); }
  final List<TextFormatRange> formats = [];
  String _lastText = '';

  void _trackEdits() {
    final current = text;
    if (current == _lastText) return;
    var prefix = 0;
    while (prefix < _lastText.length && prefix < current.length && _lastText.codeUnitAt(prefix) == current.codeUnitAt(prefix)) { prefix++; }
    var oldSuffix = _lastText.length, newSuffix = current.length;
    while (oldSuffix > prefix && newSuffix > prefix && _lastText.codeUnitAt(oldSuffix - 1) == current.codeUnitAt(newSuffix - 1)) { oldSuffix--; newSuffix--; }
    final delta = newSuffix - oldSuffix;
    final adjusted = <TextFormatRange>[];
    for (final range in formats) {
      if (range.end <= prefix) {
        adjusted.add(range);
      } else if (range.start >= oldSuffix) {
        adjusted.add(TextFormatRange(range.start + delta, range.end + delta, bold: range.bold, italic: range.italic));
      } else {
        final start = range.start < prefix ? range.start : prefix;
        final end = range.end > oldSuffix ? range.end + delta : newSuffix;
        if (start < end) adjusted.add(TextFormatRange(start, end, bold: range.bold, italic: range.italic));
      }
    }
    formats..clear()..addAll(adjusted);
    _lastText = current;
  }

  void format(int start, int end, {bool bold = false, bool italic = false}) {
    if (start < 0 || end > text.length || start >= end) return;
    final points = <int>{start, end};
    for (final range in formats) { points.add(range.start); points.add(range.end); }
    final sorted = points.toList()..sort();
    final rebuilt = <TextFormatRange>[];
    for (var i = 0; i < sorted.length - 1; i++) {
      final a = sorted[i], b = sorted[i + 1];
      if (a >= b || a < 0 || b > text.length) continue;
      final old = formats.where((range) => range.start <= a && range.end >= b);
      final isTarget = a >= start && b <= end;
      final nextBold = bold && isTarget || old.any((range) => range.bold);
      final nextItalic = italic && isTarget || old.any((range) => range.italic);
      if (!nextBold && !nextItalic) continue;
      if (rebuilt.isNotEmpty && rebuilt.last.end == a && rebuilt.last.bold == nextBold && rebuilt.last.italic == nextItalic) {
        final previous = rebuilt.removeLast();
        rebuilt.add(TextFormatRange(previous.start, b, bold: nextBold, italic: nextItalic));
      } else {
        rebuilt.add(TextFormatRange(a, b, bold: nextBold, italic: nextItalic));
      }
    }
    formats..clear()..addAll(rebuilt);
    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    if (text.isEmpty || formats.isEmpty) return TextSpan(style: style, text: text);
    final points = <int>{0, text.length};
    for (final range in formats) { points.add(range.start); points.add(range.end); }
    final sorted = points.toList()..sort();
    final spans = <InlineSpan>[];
    for (var i = 0; i < sorted.length - 1; i++) {
      final start = sorted[i], end = sorted[i + 1];
      if (start >= end) continue;
      final range = formats.where((r) => r.start <= start && r.end >= end);
      final bold = range.any((r) => r.bold);
      final italic = range.any((r) => r.italic);
      spans.add(TextSpan(text: text.substring(start, end), style: TextStyle(fontWeight: bold ? FontWeight.w700 : null, fontStyle: italic ? FontStyle.italic : null)));
    }
    return TextSpan(style: style, children: spans);
  }

  @override
  void dispose() { removeListener(_trackEdits); super.dispose(); }
}

class Note {
  const Note({required this.title, required this.body, required this.category, required this.date, required this.color, required this.tagColor, this.pinned = false, this.mediaUrls = const [], this.voiceMemoPath, this.formats = const [], this.checklistItems = const []});
  final String title, body, category, date;
  final Color color, tagColor;
  final bool pinned;
  final List<String> mediaUrls;
  final String? voiceMemoPath;
  final List<TextFormatRange> formats;
  final List<String> checklistItems;
}

List<InlineSpan> _formattedSpans(String text, List<TextFormatRange> formats) {
  if (text.isEmpty) return const [];
  final points = <int>{0, text.length};
  for (final range in formats) { points.add(range.start.clamp(0, text.length)); points.add(range.end.clamp(0, text.length)); }
  final sorted = points.toList()..sort();
  return [for (var i = 0; i < sorted.length - 1; i++) if (sorted[i] < sorted[i + 1]) TextSpan(
    text: text.substring(sorted[i], sorted[i + 1]),
    style: TextStyle(
      fontWeight: formats.any((r) => r.bold && r.start <= sorted[i] && r.end >= sorted[i + 1]) ? FontWeight.w700 : null,
      fontStyle: formats.any((r) => r.italic && r.start <= sorted[i] && r.end >= sorted[i + 1]) ? FontStyle.italic : null,
    ),
  )];
}

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});
  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  final _search = TextEditingController();
  String _category = 'All';
  int _tab = 0;
  final List<Note> _notes = [
    Note(title: 'My Daily Plan', body: 'Morning routine, 3 core priorities, team sync at 2 PM, and evening review.', category: 'Personal', date: 'Today, 9:30 AM', color: Color(0xFFEAF7EE), tagColor: Color(0xFF006C49), pinned: true),
    Note(title: 'Project Ideas', body: 'Redesign onboarding flow, add quick voice capture, and sync with calendar widgets.', category: 'Ideas', date: 'Yesterday', color: Color(0xFFFEF4E8), tagColor: Color(0xFF92400E)),
    Note(title: 'Study Notes', body: 'Key concepts in UI typography scales, whitespace balance, and accessible contrast ratios.', category: 'Study', date: 'Oct 24', color: Color(0xFFEDF3FD), tagColor: Color(0xFF1E40AF)),
    Note(title: 'Important Tasks', body: 'Finalize client proposal, review quarterly roadmap, and renew domain names.', category: 'Work', date: 'Oct 21', color: Color(0xFFF8EEF8), tagColor: Color(0xFF6B21A8)),
  ];

  List<Note> get _visibleNotes => _notes.where((note) {
        final categoryMatches = _category == 'All' || note.category.toLowerCase() == _category.toLowerCase();
        final query = _search.text.toLowerCase();
        return categoryMatches && (query.isEmpty || note.title.toLowerCase().contains(query) || note.body.toLowerCase().contains(query));
      }).toList();

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  void _createNote() async {
    final note = await Navigator.push<Note>(context, MaterialPageRoute(builder: (_) => const NoteEditorPage()));
    if (note != null && mounted) setState(() => _notes.insert(0, note));
  }

  @override
  Widget build(BuildContext context) {
    if (_tab == 1) {
      return ProfilePage(
        notesCount: _notes.length,
        onHome: () => setState(() => _tab = 0),
      );
    }
    final categories = ['All', 'Personal', 'Work', 'Study', 'Ideas'];
    return Scaffold(
      body: SafeArea(bottom: false, child: Column(children: [
        _topBar(),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 112), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Good Morning!', style: TextStyle(fontSize: 28, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: -0.7, color: _ink)),
              SizedBox(height: 4), Text('What would you like to note today?', style: TextStyle(fontSize: 15, color: _muted)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: const Color(0x6682F5C1), borderRadius: BorderRadius.circular(24)), child: const Row(children: [Icon(Icons.eco, size: 16, color: Color(0xFF00714E)), SizedBox(width: 5), Text('Flowing', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF00714E)))])),
          ]),
          const SizedBox(height: 20),
          Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(30)), child: Row(children: [const Icon(Icons.search, color: Color(0xFF6C7A71), size: 21), const SizedBox(width: 10), Expanded(child: TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search your notes...', hintStyle: TextStyle(color: Color(0xFF6C7A71), fontSize: 15)), style: const TextStyle(fontSize: 15))), if (_search.text.isNotEmpty) IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close, size: 18))])),
          const SizedBox(height: 16),
          SizedBox(height: 38, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: categories.length, separatorBuilder: (_, _) => const SizedBox(width: 8), itemBuilder: (context, index) {
            final category = categories[index]; final selected = _category == category;
            return ChoiceChip(label: Text(category), selected: selected, onSelected: (_) => setState(() => _category = category), showCheckmark: false, labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : _muted), selectedColor: _green, backgroundColor: const Color(0xFFEAEDFF), side: BorderSide.none, padding: const EdgeInsets.symmetric(horizontal: 8), shape: const StadiumBorder());
          })),
          const SizedBox(height: 22),
          Row(children: [const Text('Recent Notes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink)), const SizedBox(width: 8), Text('${_visibleNotes.length} items', style: const TextStyle(fontSize: 11, color: Color(0xFF6C7A71))), const Spacer(), TextButton.icon(onPressed: () => setState(() => _category = 'All'), style: TextButton.styleFrom(foregroundColor: const Color(0xFF006C49), padding: EdgeInsets.zero), iconAlignment: IconAlignment.end, icon: const Icon(Icons.chevron_right, size: 18), label: const Text('See all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))]),
          const SizedBox(height: 4),
          if (_visibleNotes.isEmpty) Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 36), child: const Column(children: [Icon(Icons.sticky_note_2_outlined, size: 34, color: Color(0xFF6C7A71)), SizedBox(height: 8), Text('No notes found', style: TextStyle(color: _muted))])) else LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth > 600 ? 3 : 2;
            final cardWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _visibleNotes.map((note) => SizedBox(
                width: cardWidth,
                child: _NoteCard(
                  note: note,
                  onTap: () async {
                    final updated = await Navigator.push<Note>(context, MaterialPageRoute(builder: (_) => NoteDetailPage(note: note, onDeleted: () { if (mounted) setState(() => _notes.remove(note)); })));
                    if (updated != null && mounted) {
                      final index = _notes.indexWhere((item) => item.title == note.title && item.date == note.date);
                      if (index >= 0) setState(() => _notes[index] = updated);
                    }
                  },
                  onPin: () => setState(() {
                    final index = _notes.indexOf(note);
                    _notes[index] = Note(title: note.title, body: note.body, category: note.category, date: note.date, color: note.color, tagColor: note.tagColor, pinned: !note.pinned, mediaUrls: note.mediaUrls, voiceMemoPath: note.voiceMemoPath, formats: note.formats, checklistItems: note.checklistItems);
                  }),
                  onMore: () => showModalBottomSheet<void>(context: context, builder: (context) => SafeArea(child: Wrap(children: [ListTile(leading: const Icon(Icons.push_pin_outlined), title: Text(note.pinned ? 'Unpin note' : 'Pin note'), onTap: () { Navigator.pop(context); final index = _notes.indexOf(note); if (index >= 0) setState(() { _notes[index] = Note(title: note.title, body: note.body, category: note.category, date: note.date, color: note.color, tagColor: note.tagColor, pinned: !note.pinned, mediaUrls: note.mediaUrls, voiceMemoPath: note.voiceMemoPath, formats: note.formats, checklistItems: note.checklistItems); }); }), ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text('Delete note'), onTap: () { Navigator.pop(context); setState(() => _notes.remove(note)); })]))),
                ),
              )).toList(),
            );
          }),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(22)), child: Row(children: [Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0x9982F5C1), shape: BoxShape.circle), child: const Icon(Icons.lightbulb_outline, color: Color(0xFF006C49), size: 21)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Today's Reflection", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _ink)), SizedBox(height: 3), Text('“Clarity comes from creating, not waiting.”', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: _muted))])), const SizedBox(width: 8), TextButton(onPressed: _createNote, style: TextButton.styleFrom(backgroundColor: const Color(0xFFEAEDFF), foregroundColor: _ink, padding: const EdgeInsets.symmetric(horizontal: 13)), child: const Text('Draft', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))) ])),
        ]))),
      ])),
      floatingActionButton: FloatingActionButton(onPressed: _createNote, backgroundColor: _green, foregroundColor: Colors.white, elevation: 5, shape: const CircleBorder(), child: const Icon(Icons.add, size: 29)),
      bottomNavigationBar: SafeArea(top: false, child: Container(height: 66, decoration: BoxDecoration(color: _bg.withValues(alpha: .96), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 14, offset: const Offset(0, -3))]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_navItem(Icons.edit_note, 'Home', 0), _navItem(Icons.person_outline, 'Profile', 1)]))),
    );
  }

  Widget _topBar() => Container(height: 64, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: _bg.withValues(alpha: .94), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .025), blurRadius: 7)]), child: Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFDCF7E9), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.edit_note, color: Color(0xFF006C49), size: 24)), const SizedBox(width: 9), const Text('NoteFlow', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -.4, color: _ink)), const Spacer(), CircleAvatar(radius: 17, backgroundColor: const Color(0xFFDCE8E0), child: IconButton(padding: EdgeInsets.zero, onPressed: () => setState(() => _tab = 1), icon: const Icon(Icons.person, size: 18, color: Color(0xFF006C49))))]));

  Widget _navItem(IconData icon, String label, int index) { final selected = _tab == index; return InkWell(onTap: () => setState(() => _tab = index), borderRadius: BorderRadius.circular(28), child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9), decoration: BoxDecoration(color: selected ? const Color(0x9982F5C1) : Colors.transparent, borderRadius: BorderRadius.circular(28)), child: Row(children: [Icon(icon, size: 22, color: selected ? const Color(0xFF006C49) : _muted), const SizedBox(width: 5), Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? const Color(0xFF006C49) : _muted))]))); }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.notesCount, required this.onHome});
  final int notesCount;
  final VoidCallback onHome;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _darkMode = false;
  String _name = _activeUserName;
  String _email = _activeUserEmail;

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));

  void _openProfileDetail(String title, String subtitle) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ProfileDetailPage(title: title, subtitle: subtitle),
    ));
  }

  Future<void> _editProfile() async {
    final name = TextEditingController(text: _name);
    final email = TextEditingController(text: _email);
    final save = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Edit Profile'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')), TextField(controller: email, decoration: const InputDecoration(labelText: 'Email'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))]));
    if (save == true && mounted) setState(() { if (name.text.trim().isNotEmpty) _name = name.text.trim(); if (email.text.trim().isNotEmpty) _email = email.text.trim(); });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(bottom: false, child: Column(children: [
      Container(height: 64, padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [const Expanded(child: Text('Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _ink))), IconButton(onPressed: () => _message('Settings'), icon: const Icon(Icons.settings_outlined, color: _muted)), const CircleAvatar(radius: 16, backgroundColor: Color(0xFFDCE8E0), child: Icon(Icons.person, size: 18, color: Color(0xFF006C49)))])),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), child: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 12)]), child: Column(children: [
          Stack(alignment: Alignment.bottomRight, children: [Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF006C49), _green, Color(0xFF85F8C4)])), child: const CircleAvatar(radius: 43, backgroundColor: Color(0xFFEAF7EE), child: Icon(Icons.person, size: 52, color: Color(0xFF006C49)))), const CircleAvatar(radius: 13, backgroundColor: _green, child: Icon(Icons.spa, size: 14, color: Colors.white))]),
          const SizedBox(height: 14), Text(_name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _ink)), const SizedBox(height: 4), Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.mail_outline, size: 14, color: _muted), const SizedBox(width: 5), Text(_email, style: const TextStyle(fontSize: 12, color: _muted))]),
          const SizedBox(height: 18), Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(18)), child: Row(children: [_stat(Icons.description, '${widget.notesCount}', 'Notes'), _stat(Icons.folder, '4', 'Spaces'), _stat(Icons.local_fire_department, '12d', 'Flow Streak')])),
          const SizedBox(height: 14), OutlinedButton.icon(onPressed: _editProfile, icon: const Icon(Icons.edit, size: 16, color: Color(0xFF006C49)), label: const Text('Edit Profile'), style: OutlinedButton.styleFrom(foregroundColor: _ink, backgroundColor: const Color(0xFFEAEDFF), side: BorderSide.none)),
        ])),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(20)), child: const Row(children: [CircleAvatar(radius: 20, backgroundColor: Color(0xFF82F5C1), child: Icon(Icons.spa, color: Color(0xFF006C49))), SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Mindful Routine', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _ink)), SizedBox(height: 3), Text('Daily reflection completed at 08:30 AM', style: TextStyle(fontSize: 12, color: _muted))])), Icon(Icons.check_circle, color: Color(0xFF006C49))])),
        const SizedBox(height: 18),
        _section('ACCOUNT', [
          _row(Icons.badge_outlined, 'Personal Information', 'Name, role & contact channels', () => _openProfileDetail('Personal Information', 'Manage the details connected to your NoteFlow account.')),
          _row(Icons.shield_outlined, 'Security & Passkeys', 'Biometrics and session locks', () => _openProfileDetail('Security & Passkeys', 'Review the security options available for your account.')),
        ]),
        _section('PREFERENCES', [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Row(children: [const CircleAvatar(radius: 18, backgroundColor: Color(0xFFEAEDFF), child: Icon(Icons.dark_mode_outlined, size: 20, color: _muted)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Dark Appearance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _ink)), Text('Balanced for evening thoughts', style: TextStyle(fontSize: 12, color: _muted))])), Switch(value: _darkMode, activeThumbColor: _green, onChanged: (value) { setState(() => _darkMode = value); _appDarkMode.value = value; })])),
          _row(Icons.notifications_none, 'Notifications', 'Daily mindful prompts', () => _openProfileDetail('Notifications', 'Choose which reminders NoteFlow can send you.'), trailing: 'Active'),
          _row(Icons.language, 'Language', 'System writing locale', () => _openProfileDetail('Language', 'Choose the language used throughout NoteFlow.'), trailing: 'English (US)'),
        ]),
        _section('ABOUT', [
          _row(Icons.eco, 'About NoteFlow', 'Crafted for mindful creators', () => _openProfileDetail('About NoteFlow', 'A calmer space for capturing thoughts and organizing your work.'), trailing: 'v2.4.0'),
          _row(Icons.lock_outline, 'Privacy Policy', 'Zero-knowledge local encryption', () => _openProfileDetail('Privacy Policy', 'Your notes stay on this device in this demo. Account and privacy services are not connected.')),
          _row(Icons.description_outlined, 'Terms & Conditions', 'Service agreements & usage', () => _openProfileDetail('Terms & Conditions', 'NoteFlow is provided as a demonstration app. Use it to organize your notes and ideas.')),
        ]),
        const SizedBox(height: 10), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => showDialog<void>(context: context, builder: (context) => AlertDialog(title: const Text('Log Out'), content: const Text('Are you sure you want to log out?'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () { Navigator.pop(context); _appDarkMode.value = false; Navigator.of(this.context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false); }, child: const Text('Log Out'))])), icon: const Icon(Icons.logout), label: const Text('Log Out'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFFDAD6), foregroundColor: const Color(0xFF93000A), padding: const EdgeInsets.symmetric(vertical: 14)))),
        const SizedBox(height: 12), const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.eco, size: 15, color: Color(0xFF6C7A71)), SizedBox(width: 5), Text('NoteFlow • Calmer Mind, Sharper Work', style: TextStyle(fontSize: 11, color: Color(0xFF6C7A71)))]),
      ]))),
    ])),
    bottomNavigationBar: SafeArea(top: false, child: Container(height: 70, decoration: BoxDecoration(color: _bg.withValues(alpha: .96), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 14, offset: const Offset(0, -3))]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [TextButton.icon(onPressed: widget.onHome, icon: const Icon(Icons.sticky_note_2_outlined), label: const Text('Home')), TextButton.icon(onPressed: () {}, icon: const Icon(Icons.account_circle), label: const Text('Profile'), style: TextButton.styleFrom(foregroundColor: const Color(0xFF006C49), backgroundColor: const Color(0xFF82F5C1)))]))),
  );

  Widget _stat(IconData icon, String value, String label) => Expanded(child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 16, color: const Color(0xFF006C49)), const SizedBox(width: 4), Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _ink))]), const SizedBox(height: 3), Text(label, style: const TextStyle(fontSize: 10, color: _muted))]));

  Widget _section(String title, List<Widget> children) => Container(width: double.infinity, margin: const EdgeInsets.only(top: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 5, bottom: 8), child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: _muted))), Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .03), blurRadius: 7)]), child: Column(children: children))]));

  Widget _row(IconData icon, String title, String subtitle, VoidCallback onTap, {String? trailing}) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), child: Row(children: [CircleAvatar(radius: 18, backgroundColor: const Color(0xFFEAEDFF), child: Icon(icon, size: 19, color: const Color(0xFF006C49))), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)), const SizedBox(height: 2), Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: _muted))])), if (trailing != null) Padding(padding: const EdgeInsets.only(right: 5), child: Text(trailing, style: const TextStyle(fontSize: 11, color: _muted))), const Icon(Icons.chevron_right, size: 20, color: Color(0xFFBBcabf))])));
}

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  bool _enabled = true;
  String _language = 'English (US)';

  @override
  Widget build(BuildContext context) {
    final isNotifications = widget.title == 'Notifications';
    final isLanguage = widget.title == 'Language';
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: _ink)),
            const SizedBox(height: 8),
            Text(widget.subtitle, style: const TextStyle(fontSize: 14, height: 1.5, color: _muted)),
          ]),
        ),
        const SizedBox(height: 16),
        if (isNotifications)
          SwitchListTile(
            value: _enabled,
            activeThumbColor: _green,
            title: const Text('Daily mindful prompts'),
            subtitle: Text(_enabled ? 'Notifications are enabled' : 'Notifications are disabled'),
            onChanged: (value) => setState(() => _enabled = value),
          ),
        if (isLanguage)
          ...['English (US)', 'Bahasa Indonesia'].map((language) => RadioListTile<String>(
                value: language,
                groupValue: _language,
                activeColor: _green,
                title: Text(language),
                onChanged: (value) => setState(() => _language = value!),
              )),
        if (!isNotifications && !isLanguage)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(18)),
            child: Text(
              widget.title == 'About NoteFlow' ? 'NoteFlow • v2.4.0' : widget.subtitle,
              style: const TextStyle(fontSize: 13, height: 1.5, color: _muted),
            ),
          ),
      ]),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onTap, required this.onPin, required this.onMore});
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onMore;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: note.color,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .72),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    note.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: note.tagColor,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: note.pinned ? onPin : onMore,
                tooltip: note.pinned ? 'Unpin note' : 'More actions',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 26, height: 26),
                icon: Icon(note.pinned ? Icons.push_pin : Icons.more_horiz, size: 17, color: const Color(0xFF6C7A71)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            note.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -.2,
              color: _ink,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            note.body,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.45, color: _muted),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.schedule, size: 13, color: Color(0xFF6C7A71)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  note.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF6C7A71)),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({super.key, required this.note, required this.onDeleted});
  final Note note;
  final VoidCallback onDeleted;

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final List<bool> _done = [true, false, false];
  final AudioPlayer _voicePlayer = AudioPlayer();
  late final List<bool> _noteChecklistDone;
  bool _bookmarked = false;
  bool _playingVoice = false;

  @override
  void initState() { super.initState(); _noteChecklistDone = List<bool>.filled(widget.note.checklistItems.length, false); }

  @override
  void dispose() { _voicePlayer.dispose(); super.dispose(); }

  Future<void> _playVoiceMemo() async {
    final path = widget.note.voiceMemoPath;
    if (path == null) return;
    if (_playingVoice) {
      await _voicePlayer.stop();
      if (mounted) setState(() => _playingVoice = false);
    } else {
      await _voicePlayer.play(DeviceFileSource(path));
      if (mounted) setState(() => _playingVoice = true);
      _voicePlayer.onPlayerComplete.first.then((_) { if (mounted) setState(() => _playingVoice = false); });
    }
  }

  void _toast(String text) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      icon: const Icon(Icons.delete_forever, color: Colors.red),
      title: const Text('Delete Note?'),
      content: Text('Are you sure you want to delete “${widget.note.title}”? This action cannot be undone.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))],
    ));
    if (confirmed == true && mounted) { widget.onDeleted(); Navigator.pop(context); }
  }

  void _edit() {
    final title = TextEditingController(text: widget.note.title);
    final body = TextEditingController(text: widget.note.body);
    showDialog<void>(context: context, builder: (context) => AlertDialog(
      title: const Text('Edit Note'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')), TextField(controller: body, maxLines: 4, decoration: const InputDecoration(labelText: 'Content'))]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () {
        final updated = Note(title: title.text.trim().isEmpty ? widget.note.title : title.text.trim(), body: body.text.trim(), category: widget.note.category, date: widget.note.date, color: widget.note.color, tagColor: widget.note.tagColor, pinned: widget.note.pinned, mediaUrls: widget.note.mediaUrls, voiceMemoPath: widget.note.voiceMemoPath, formats: widget.note.formats, checklistItems: widget.note.checklistItems);
        Navigator.pop(context);
        Navigator.pop(this.context, updated);
      }, child: const Text('Save'))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    return Scaffold(
      body: SafeArea(bottom: false, child: Column(children: [
        Container(height: 64, padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)), Expanded(child: Text(note.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _ink))), IconButton(onPressed: () => _toast('More options'), icon: const Icon(Icons.more_vert)), const CircleAvatar(radius: 16, backgroundColor: Color(0xFFDCE8E0), child: Icon(Icons.person, size: 18, color: Color(0xFF006C49)))])),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 105), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0x6682F5C1), borderRadius: BorderRadius.circular(24)), child: Text(note.category, style: const TextStyle(fontSize: 11, color: Color(0xFF00714E), fontWeight: FontWeight.w700))), const Spacer(), if (note.pinned) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFEAEDFF), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.push_pin, size: 15, color: Color(0xFF006C49)), SizedBox(width: 4), Text('Pinned', style: TextStyle(fontSize: 11, color: Color(0xFF006C49)))])), IconButton(onPressed: () => setState(() => _bookmarked = !_bookmarked), icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_border, color: _bookmarked ? _green : _muted))]),
          const SizedBox(height: 8),
          Text(note.title, style: const TextStyle(fontSize: 28, height: 1.25, fontWeight: FontWeight.w700, letterSpacing: -.6, color: _ink)),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.schedule, size: 14, color: _muted), const SizedBox(width: 6), Expanded(child: Text('${note.date} • 450 words • 2 min read', style: const TextStyle(fontSize: 11, color: _muted)))]),
          const SizedBox(height: 20),
          ClipRRect(borderRadius: BorderRadius.circular(22), child: Stack(alignment: Alignment.bottomRight, children: [Image.network('https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1200&q=80', width: double.infinity, height: 176, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(height: 176, color: const Color(0xFFEAF7EE), child: const Center(child: Icon(Icons.spa, size: 48, color: Color(0xFF006C49))))), Container(margin: const EdgeInsets.all(12), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: _bg.withValues(alpha: .92), borderRadius: BorderRadius.circular(20)), child: const Text('Morning Clarity', style: TextStyle(fontSize: 10, color: _ink)))])),
          const SizedBox(height: 20),
          Text.rich(TextSpan(children: _formattedSpans(note.title == 'My Daily Plan' ? 'Today I want to focus on completing my tasks, improving my skills, and organizing my daily activities. Cultivating a calm mind while sustaining high creative output throughout the day.' : note.body, note.formats)), style: const TextStyle(fontSize: 17, height: 1.55, color: _muted)),
          if (note.mediaUrls.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Attachments', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
            const SizedBox(height: 10),
            ...note.mediaUrls.map((imageData) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(base64Decode(imageData.split(',').last), width: double.infinity, height: 180, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox(height: 70, child: Center(child: Text('Image unavailable'))))))),
          ],
          if (note.checklistItems.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text('Checklist', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink)),
            ...note.checklistItems.asMap().entries.map((entry) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: _green,
              value: entry.key < _noteChecklistDone.length ? _noteChecklistDone[entry.key] : false,
              title: Text(entry.value),
              onChanged: (value) => setState(() => _noteChecklistDone[entry.key] = value ?? false),
            )),
          ],
          if (note.voiceMemoPath != null) Padding(padding: const EdgeInsets.only(top: 16), child: Card(child: ListTile(leading: IconButton(onPressed: _playVoiceMemo, icon: Icon(_playingVoice ? Icons.stop_circle : Icons.play_circle, color: _green, size: 32)), title: const Text('Voice memo'), subtitle: const Text('Recorded with this note'), trailing: const Icon(Icons.mic_none, color: _muted)))),
          const SizedBox(height: 22),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(22)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.wb_sunny, size: 20, color: Color(0xFF006C49)), const SizedBox(width: 8), const Expanded(child: Text('Morning Routine & Focus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF006C49)))), Text('${_done.where((v) => v).length}/3', style: const TextStyle(fontSize: 11, color: Color(0xFF00714E)))]), const SizedBox(height: 10), _task(0, '07:30 AM', 'Morning stretches & mindful meditation', 'Completed'), _task(1, '08:30 AM', 'Review prioritized sprints & client deliverables', '45 min'), _task(2, '10:00 AM', 'Deep work block: finalize NoteFlow UI interaction states', 'Deep Work')])),
          const SizedBox(height: 22),
          const Row(children: [Icon(Icons.wb_twilight, size: 20, color: Color(0xFF006C49)), SizedBox(width: 8), Text('Afternoon Targets', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink))]),
          const SizedBox(height: 8),
          const Text('Sync with the design systems team at 2:00 PM regarding token alignment, test responsive mobile layouts across varying viewports, and reserve 30 minutes for quiet journaling before wrapping up.', style: TextStyle(fontSize: 16, height: 1.55, color: _ink)),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0x3382F5C1), borderRadius: BorderRadius.circular(20)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 18, backgroundColor: Color(0xFF006C49), child: Icon(Icons.lightbulb, size: 18, color: Colors.white)), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Mindful Note', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF006C49))), SizedBox(height: 4), Text('Remember to keep hydrated between blocks and take a brief screen respite at 3:30 PM.', style: TextStyle(fontSize: 13, height: 1.4, color: _muted))]))]))
        ]))),
      ])),
      bottomNavigationBar: SafeArea(top: false, child: Container(padding: const EdgeInsets.fromLTRB(20, 10, 20, 10), decoration: BoxDecoration(color: _bg.withValues(alpha: .97), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 14, offset: const Offset(0, -3))]), child: Row(children: [IconButton.filledTonal(onPressed: _delete, icon: const Icon(Icons.delete_outline), tooltip: 'Delete note'), const SizedBox(width: 6), IconButton.filledTonal(onPressed: () => _toast('Voice memo is ready'), icon: const Icon(Icons.mic_none), tooltip: 'Voice memo'), const SizedBox(width: 6), IconButton.filledTonal(onPressed: () => _toast('Share link copied'), icon: const Icon(Icons.share_outlined), tooltip: 'Share note'), const SizedBox(width: 10), Expanded(child: FilledButton.icon(onPressed: _edit, icon: const Icon(Icons.edit, size: 18), label: const Text('Edit Note'), style: FilledButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48))))]))),
    );
  }

  Widget _task(int index, String time, String label, String status) => InkWell(
        onTap: () => setState(() => _done[index] = !_done[index]),
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
              width: 21,
              height: 21,
              decoration: BoxDecoration(color: _done[index] ? _green : const Color(0xFFEAEDFF), borderRadius: BorderRadius.circular(6)),
              child: _done[index] ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF006C49))),
                const Spacer(),
                Text(_done[index] ? 'Completed' : status, style: const TextStyle(fontSize: 10, color: _muted)),
              ]),
              Text(label, style: TextStyle(fontSize: 13, color: _done[index] ? _muted : _ink, decoration: _done[index] ? TextDecoration.lineThrough : null)),
            ])),
          ]),
        ),
      );
}

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key});
  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _title = TextEditingController();
  final _body = FormattedTextController();
  final _voiceRecorder = AudioRecorder();
  final _voicePreviewPlayer = AudioPlayer();
  String _category = 'Personal';
  Color _accent = const Color(0xFF85F8C4);
  bool _showTitleError = false;
  final List<bool> _checklistDone = [false, false];
  final List<String> _checklistItems = [];
  final List<bool> _customChecklistDone = [];
  final List<String> _mediaUrls = [];
  bool _recordingVoiceMemo = false;
  int _voiceMemoSeconds = 0;
  String? _voiceMemoPath;
  Timer? _voiceMemoTimer;
  final _categories = const ['Personal', 'Work', 'Study', 'Ideas'];
  final _accents = const [Color(0xFF85F8C4), Color(0xFFFEF4E8), Color(0xFFE2E7FF), Color(0xFFFFDAD6), Colors.white];

  @override
  void dispose() { _title.dispose(); _body.dispose(); _voiceMemoTimer?.cancel(); unawaited(_voiceRecorder.dispose()); unawaited(_voicePreviewPlayer.dispose()); super.dispose(); }

  void _insertAtSelection(String value, {String? selectionText}) {
    final text = _body.text;
    final selection = _body.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final selected = selectionText ?? text.substring(start, end);
    final insertion = value.replaceAll('{selection}', selected);
    final nextText = text.replaceRange(start, end, insertion);
    final cursor = start + insertion.length;
    _body.value = TextEditingValue(text: nextText, selection: TextSelection.collapsed(offset: cursor));
    setState(() {});
  }

  void _formatSelection({bool bold = false, bool italic = false}) {
    final selection = _body.selection;
    if (!selection.isValid || selection.isCollapsed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih tulisan yang ingin diformat terlebih dahulu.')));
      return;
    }
    _body.format(selection.start, selection.end, bold: bold, italic: italic);
    setState(() {});
  }

  Future<void> _addMedia() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90);
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      final mimeType = picked.mimeType ?? 'image/jpeg';
      final imageData = 'data:$mimeType;base64,${base64Encode(bytes)}';
      if (mounted) setState(() => _mediaUrls.add(imageData));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menambahkan gambar: $error')));
    }
  }

  Future<void> _addChecklistItem() async {
    final controller = TextEditingController();
    final label = await showDialog<String>(context: context, builder: (context) => AlertDialog(
      title: const Text('Checklist item'),
      content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Tulis tugas atau item')),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Tambah'))],
    ));
    controller.dispose();
    if (label == null || label.isEmpty || !mounted) return;
    setState(() { _checklistItems.add(label); _customChecklistDone.add(false); });
  }

  Future<void> _toggleVoiceMemo() async {
    try {
      if (_recordingVoiceMemo) {
        _voiceMemoTimer?.cancel();
        final path = await _voiceRecorder.stop();
        if (!mounted) return;
        setState(() { _recordingVoiceMemo = false; _voiceMemoPath = path; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(path == null ? 'Voice memo tidak tersimpan.' : 'Voice memo tersimpan dan akan disertakan di catatan.')));
        return;
      }
      if (!await _voiceRecorder.hasPermission()) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin mikrofon diperlukan untuk merekam voice memo.')));
        return;
      }
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}${Platform.pathSeparator}noteflow_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _voiceRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      if (!mounted) return;
      setState(() { _recordingVoiceMemo = true; _voiceMemoSeconds = 0; _voiceMemoPath = null; });
      _voiceMemoTimer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() => _voiceMemoSeconds++); });
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal merekam voice memo: $error')));
    }
  }

  Future<void> _previewVoiceMemo() async {
    final path = _voiceMemoPath;
    if (path == null) return;
    try {
      await _voicePreviewPlayer.play(DeviceFileSource(path));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voice memo tidak dapat diputar: $error')));
    }
  }

  int get _wordCount => _body.text.trim().isEmpty ? 0 : _body.text.trim().split(RegExp(r'\s+')).length;

  Future<void> _save() async {
    if (_recordingVoiceMemo) {
      await _toggleVoiceMemo();
      if (!mounted) return;
    }
    if (_title.text.trim().isEmpty) {
      setState(() => _showTitleError = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a note title before saving'), behavior: SnackBarBehavior.floating));
      return;
    }
    final categoryColors = {'Personal': const Color(0xFF006C49), 'Work': const Color(0xFF6B21A8), 'Study': const Color(0xFF1E40AF), 'Ideas': const Color(0xFF92400E)};
    final note = Note(title: _title.text.trim(), body: _body.text.trim().isEmpty ? 'No content yet.' : _body.text.trim(), category: _category, date: 'Today, ${TimeOfDay.now().format(context)}', color: _accent, tagColor: categoryColors[_category]!, pinned: true, mediaUrls: List.unmodifiable(_mediaUrls), voiceMemoPath: _voiceMemoPath, formats: List.unmodifiable(_body.formats), checklistItems: List.unmodifiable(_checklistItems));
    final goHome = await showDialog<bool>(context: context, barrierDismissible: false, builder: (context) => AlertDialog(
      icon: const CircleAvatar(backgroundColor: Color(0xFF85F8C4), child: Icon(Icons.task_alt, color: Color(0xFF006C49))),
      title: const Text('Note Saved!'),
      content: Text('“${note.title}” has been saved and added to Recent Notes.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Continue Editing')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('View in Home Page'))],
    ));
    if (mounted && goHome == true) Navigator.pop(context, note);
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now().format(context);
    return Scaffold(
      body: SafeArea(bottom: false, child: Column(children: [
        Container(height: 64, padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)), const Expanded(child: Text('Create Note', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _ink))), IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft auto-saved on this device'))), icon: const Icon(Icons.more_vert)), const CircleAvatar(radius: 16, backgroundColor: Color(0xFFDCE8E0), child: Icon(Icons.person, size: 18, color: Color(0xFF006C49)))])),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 10, 20, 110), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFEAEDFF), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.circle, size: 8, color: _green), SizedBox(width: 6), Text('Draft auto-saved', style: TextStyle(fontSize: 11, color: _muted))])), const Spacer(), FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check, size: 18), label: const Text('Save'), style: FilledButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 19)))]),
          const SizedBox(height: 18),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 8)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.calendar_today, size: 15, color: Color(0xFF006C49)), const SizedBox(width: 7), Text('Today, $now', style: const TextStyle(fontSize: 11, color: _muted)), Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFBBcabf), shape: BoxShape.circle)), Text('$_wordCount ${_wordCount == 1 ? 'word' : 'words'}', style: const TextStyle(fontSize: 11, color: _muted)), const Spacer(), const Icon(Icons.cloud_done, size: 15, color: _muted), const SizedBox(width: 4), const Text('Synced', style: TextStyle(fontSize: 11, color: _muted))]),
            TextField(controller: _title, onChanged: (_) => setState(() { if (_title.text.trim().isNotEmpty) _showTitleError = false; }), style: const TextStyle(fontSize: 28, height: 1.25, fontWeight: FontWeight.w700, letterSpacing: -.6, color: _ink), decoration: const InputDecoration(hintText: 'Enter note title...', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.only(top: 20, bottom: 8))),
            if (_showTitleError) const Padding(padding: EdgeInsets.only(bottom: 8), child: Row(children: [Icon(Icons.error_outline, size: 15, color: Colors.red), SizedBox(width: 5), Text('Please enter a note title before saving', style: TextStyle(fontSize: 11, color: Colors.red))])),
            const SizedBox(height: 10),
            const Text('CATEGORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: _muted)),
            const SizedBox(height: 9),
            Wrap(spacing: 7, runSpacing: 7, children: _categories.map((category) { final selected = _category == category; final icon = {'Personal': Icons.person, 'Work': Icons.business_center, 'Study': Icons.school, 'Ideas': Icons.lightbulb}[category]!; return ChoiceChip(avatar: Icon(icon, size: 15, color: selected ? Colors.white : _muted), label: Text(category), selected: selected, onSelected: (_) => setState(() => _category = category), showCheckmark: false, labelStyle: TextStyle(fontSize: 11, color: selected ? Colors.white : _ink, fontWeight: FontWeight.w600), selectedColor: _green, backgroundColor: const Color(0xFFF2F3FF), side: BorderSide.none); }).toList()),
            const SizedBox(height: 18),
            const Text('BACKGROUND ACCENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: _muted)),
            const SizedBox(height: 10),
            Row(children: _accents.map((color) => GestureDetector(onTap: () => setState(() => _accent = color), child: Container(width: 31, height: 31, margin: const EdgeInsets.only(right: 11), decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.black.withValues(alpha: .09)), boxShadow: [if (color == _accent) BoxShadow(color: Colors.black.withValues(alpha: .12), blurRadius: 4)]), child: color == _accent ? const Icon(Icons.check, size: 16, color: _ink) : null))).toList()),
            const SizedBox(height: 16),
            TextField(controller: _body, onChanged: (_) => setState(() {}), minLines: 6, maxLines: null, style: const TextStyle(fontSize: 16, height: 1.55, color: _ink), decoration: const InputDecoration(hintText: 'Start writing your thoughts, paste inspirations, or jot down daily reflections...', hintStyle: TextStyle(color: Color(0xFF9BA69F)), border: InputBorder.none)),
            const SizedBox(height: 8),
            _editorTask('Capture moodboard ideas & color references', 0),
            _editorTask('Create fresh sprint checklist', 1),
            ..._checklistItems.asMap().entries.map((entry) => CheckboxListTile(contentPadding: EdgeInsets.zero, activeColor: _green, value: _customChecklistDone[entry.key], title: Text(entry.value), onChanged: (value) => setState(() => _customChecklistDone[entry.key] = value ?? false))),
          ])),
          const SizedBox(height: 22),
          Row(children: [const Expanded(child: Text('Visual Attachments', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _ink))), TextButton.icon(onPressed: _addMedia, icon: const Icon(Icons.add_photo_alternate, size: 17), label: const Text('Add Media'))]),
          if (_mediaUrls.isNotEmpty) ..._mediaUrls.asMap().entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Stack(alignment: Alignment.topRight, children: [ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.memory(base64Decode(entry.value.split(',').last), width: double.infinity, height: 150, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(width: double.infinity, height: 90, color: const Color(0xFFF2F3FF), alignment: Alignment.center, child: const Text('Image could not be loaded')))), IconButton.filledTonal(onPressed: () => setState(() => _mediaUrls.removeAt(entry.key)), icon: const Icon(Icons.close))]))),
          Row(children: [Expanded(child: Container(height: 112, decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(18)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton(onPressed: _recordingVoiceMemo ? _toggleVoiceMemo : _voiceMemoPath != null ? _previewVoiceMemo : _toggleVoiceMemo, icon: Icon(_recordingVoiceMemo ? Icons.stop_circle_outlined : _voiceMemoPath != null ? Icons.play_circle : Icons.mic, size: 28, color: _recordingVoiceMemo ? Colors.red : _green)), Text(_recordingVoiceMemo ? 'Recording…' : _voiceMemoPath != null ? 'Memo ready • tap to play' : 'Voice Note', style: const TextStyle(fontSize: 12, color: _ink)), Text('${_voiceMemoSeconds ~/ 60}:${(_voiceMemoSeconds % 60).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10, color: _muted))]))), const SizedBox(width: 12), Expanded(child: OutlinedButton.icon(onPressed: _addMedia, icon: const Icon(Icons.add_photo_alternate_outlined), label: const Text('Add image'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48))))]),
        ]))),
      ])),
      bottomNavigationBar: SafeArea(top: false, child: Container(margin: const EdgeInsets.fromLTRB(12, 4, 12, 10), padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .98), borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .1), blurRadius: 16)]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [IconButton(onPressed: () => _formatSelection(bold: true), tooltip: 'Bold', icon: const Icon(Icons.format_bold)), IconButton(onPressed: () => _formatSelection(italic: true), tooltip: 'Italic', icon: const Icon(Icons.format_italic)), IconButton(onPressed: _addChecklistItem, tooltip: 'Checklist item', icon: const Icon(Icons.check_box_outlined)), IconButton(onPressed: () => _insertAtSelection('• '), tooltip: 'Bullet list', icon: const Icon(Icons.format_list_bulleted)), IconButton(onPressed: _addMedia, tooltip: 'Add image', icon: const Icon(Icons.image_outlined)), IconButton(onPressed: _toggleVoiceMemo, tooltip: _recordingVoiceMemo ? 'Stop voice memo' : 'Record voice memo', icon: Icon(_recordingVoiceMemo ? Icons.stop_circle_outlined : Icons.mic_none)), IconButton(onPressed: () => _insertAtSelection('#'), tooltip: 'Add tag', icon: const Icon(Icons.sell_outlined, color: Color(0xFF006C49)))]))),
    );
  }

  Widget _editorTask(String label, int index) { final checked = _checklistDone[index]; return InkWell(onTap: () => setState(() => _checklistDone[index] = !checked), child: Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [Container(width: 21, height: 21, decoration: BoxDecoration(color: checked ? _green : const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(6)), child: checked ? const Icon(Icons.check, size: 15, color: Colors.white) : null), const SizedBox(width: 10), Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: checked ? _muted : _ink, decoration: checked ? TextDecoration.lineThrough : null))) ]))); }
}

