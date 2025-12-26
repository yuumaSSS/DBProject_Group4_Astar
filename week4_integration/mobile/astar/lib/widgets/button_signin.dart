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

      if (mounted) {
        context.go('/loading');
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
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
    return Material(
      color: Color(0xFF5B6EE1),
      borderRadius: BorderRadius.all(Radius.zero),
      child: InkWell(
        onTap: _isLoading ? null : _handleSignIn,
        splashColor: const Color.fromARGB(255, 216, 216, 216),
        borderRadius: BorderRadius.all(Radius.zero),
        enableFeedback: false,
        child: Padding(
          padding: EdgeInsetsGeometry.directional(
            start: 10,
            end: 10,
            top: 5,
            bottom: 5,
          ),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Monocraft',
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
