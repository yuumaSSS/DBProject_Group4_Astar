import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInButton extends StatefulWidget {
  final TextEditingController email;
  final TextEditingController pass;
  final bool dark;

  const SignInButton({
    super.key,
    required this.email,
    required this.pass,
    required this.dark,
  });

  @override
  State<SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<SignInButton> {
  bool _isLoading = false;

  String _sanitizeError(String error) {
    final lowerError = error.toLowerCase();
    if (lowerError.contains("http") ||
        lowerError.contains("vercel") ||
        lowerError.contains("supabase") ||
        lowerError.contains("postgrest") ||
        lowerError.contains("failed host lookup") ||
        lowerError.contains("xmlhttprequest")) {
      return "NETWORK ERROR: CHECK YOUR SIGNAL";
    }
    if (lowerError.contains("invalid login credentials")) {
      return "INVALID EMAIL OR PASSWORD";
    }
    if (lowerError.contains("user not found")) {
      return "ACCOUNT NOT REGISTERED";
    }
    return error;
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    final email = widget.email.text.trim();
    final pass = widget.pass.text;

    try {
      final supabase = Supabase.instance.client;
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: pass,
      );

      if (res.user == null) throw "User not found";

      final userRoleData = await supabase
          .from('users')
          .select('role')
          .eq('user_id', res.user!.id)
          .single();

      if (userRoleData['role'] != 'admin') {
        await supabase.auth.signOut();
        throw "Not an Admin";
      }

      if (mounted) context.go('/loading');
    } on SocketException {
      _showSnackBar("NO INTERNET CONNECTION", isError: true);
    } on AuthException catch (e) {
      _showSnackBar(_sanitizeError(e.message), isError: true);
    } catch (e) {
      _showSnackBar(_sanitizeError(e.toString()), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Monocraft',
            color: widget.dark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3,
      height: 55,
      child: Material(
        color: const Color(0xFF5B6EE1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _isLoading ? null : _handleSignIn,
          splashColor: Colors.white.withAlpha(50),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'SIGN IN',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Monocraft',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
