import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progressValue = 0.0;
  String _statusText = "Loading data...";

  @override
  void initState() {
    super.initState();

    _startFakeJob();
  }

  // Nanti diganti pakai fetch data aseli
  void _startFakeJob() {
    // Simulasi loading selama 3 detik
    const oneSec = Duration(milliseconds: 100);
    Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        if (_progressValue >= 1.0) {
          timer.cancel();
          _statusText = "Selesai!";

          context.go('/stock');
        } else {
          _progressValue += 0.05; // Tambah 5% setiap 100ms

          // Ubah text status berdasarkan progress (Simulasi)
          if (_progressValue > 0.3) _statusText = "Processing data...";
          if (_progressValue > 0.7) _statusText = "Finalization...";
        }
      });
    });
  }

  Color _progressPercentColor(double progress) {
    if (progress < 0.3) {
      return Colors.red;
    } else if (progress < 0.7) {
      return Colors.orange; // Pertengahan oranye
    } else {
      return Colors.green[700]!; // Selesai hijau
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
                value: _progressValue, // Nilai progress 0.0 - 1.0
                backgroundColor: Colors.grey[200],
                color: Color(0xFF5B6EE1), // Warna bar
                minHeight: 10, // Ketebalan bar
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

              // Text Persentase
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
