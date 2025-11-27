import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progressValue = 0.0;
  String _statusText = "Loading data...";
  late AudioPlayer player;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    _initAudio(); 
    _startFakeJob();
  }

  Future<void> _initAudio() async {
    try {
      await player.setAsset('assets/sounds/anime-chill-music-remix.mp3');
      await player.setVolume(5.0); 
      player.play();
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  void _startFakeJob() {
    const oneSec = Duration(milliseconds: 1000);
    Timer.periodic(oneSec, (Timer timer) async {
      if (mounted) {
        setState(() {
          if (_progressValue >= 1.0) {
            timer.cancel();
            _statusText = "Done!";
            
            player.stop();
            context.go('/stock');
          } else {
            _progressValue += 0.05; 

            if (_progressValue > 0.3) _statusText = "Processing data...";
            if (_progressValue > 0.7) _statusText = "Finalization...";
          }
        });
      }
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Color _progressPercentColor(double progress) {
    if (progress < 0.3) {
      return Colors.red;
    } else if (progress < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 180,
                child: Image.asset(
                  'assets/images/icons/logo_login.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),

              LinearProgressIndicator(
                value: _progressValue,
                backgroundColor: Colors.grey[200],
                color: const Color(0xFF5B6EE1),
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),

              const SizedBox(height: 20),

              Text(
                _statusText,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontFamily: 'Monocraft',
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "${(_progressValue * 100).clamp(0, 100).toInt()}%",
                style: TextStyle(
                  color: _progressPercentColor(_progressValue),
                  fontSize: 14,
                  fontFamily: 'Monocraft',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}