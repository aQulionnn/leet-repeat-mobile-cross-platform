import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leet_repeat_mobile_cross_platform/data/clients/leetcode_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  final _client = LeetCodeClient();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final username = _controller.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profile = await _client.getUserPublicProfile(username);
      if (profile == null) {
        setState(() => _error = 'User not found');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', profile.username);

      if (!mounted) return;
      context.go('/problem-lists');
    } catch (e) {
      setState(() => _error = 'Something went wrong');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome',
                style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your LeetCode username to continue',
                style: tt.bodyMedium?.copyWith(color: cs.outline),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'LeetCode username',
                  errorText: _error,
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
