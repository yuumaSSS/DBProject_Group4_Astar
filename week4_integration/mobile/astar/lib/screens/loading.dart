import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import '../services/api_service.dart';
import '../models/products.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isVisible = false;
  late AudioPlayer player;
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _preloadedData;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    _preloadedData = _apiService.fetchProducts().timeout(
      const Duration(seconds: 10),
      onTimeout: () => [],
    );
    _startSequence();
  }

  Future<void> _startSequence() async {
    _initAudio();

    if (mounted) {
      setState(() {
        _isVisible = true;
      });
    }

    await Future.delayed(const Duration(milliseconds: 4800));
    _handleNavigation();
  }

  Future<void> _initAudio() async {
    try {
      await player.setAsset(
        'assets/sounds/soul-calibur-ii-iii-secret-unlocked.mp3',
      );
      await player.setVolume(1.0);
      player.play();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> _handleNavigation() async {
    try {
      final products = await _preloadedData;
      if (mounted) {
        context.go('/manage', extra: products);
      }
    } catch (e) {
      if (mounted) {
        context.go('/manage');
      }
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: _isVisible ? 1.0 : 0.0,
          curve: Curves.easeIn,
          child: _isVisible
              ? SizedBox(
                  width: 250,
                  child: Image.asset(
                    'assets/gif/splash_unlock.gif',
                    key: const ValueKey('splash_animated_gif'),
                    fit: BoxFit.contain,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
