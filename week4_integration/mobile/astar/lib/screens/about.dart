import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';
import '../widgets/header.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _player.setVolume(5.0);
      await _player.setAsset('assets/sounds/mc-hurt.mp3');
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  Future<void> _playSound() async {
    try {
      await _player.seek(Duration.zero);
      if (!_player.playing) {
        await _player.play();
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  Future<void> _launchGithub(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Failed to connect: $url');
    }
  }

  @override
  void dispose() {
    _player.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Header(title: 'About Us', dark: isDarkMode,),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProfileItem(
                    name: 'Thufail\nBahir Al Bariq',
                    roles: '@UI/UX\n@MobApps_Dev\n@Backend_Dev',
                    imagePath: 'assets/images/icons/thufail.png',
                    githubUrl: 'https://github.com/yuumaSSS',
                    isImageLeft: true,
                    onUrlTap: _launchGithub,
                    onSoundTap: _playSound, 
                  ),
                  const SizedBox(height: 40),
                  _ProfileItem(
                    name: 'Dhimas\nPutra Sulistio',
                    roles: '@UI/UX\n@Frontend_Dev',
                    imagePath: 'assets/images/icons/dhimas.png',
                    githubUrl: 'https://github.com/muddglobb',
                    isImageLeft: false,
                    onUrlTap: _launchGithub,
                    onSoundTap: _playSound,
                  ),
                  const SizedBox(height: 40),
                  _ProfileItem(
                    name: 'Maulana Faris\nAl Ghifari',
                    roles: '@UI/UX\n@Frontend_Dev',
                    imagePath: 'assets/images/icons/faris.png',
                    githubUrl: 'https://github.com/MaulanaFarisA',
                    isImageLeft: true,
                    onUrlTap: _launchGithub,
                    onSoundTap: _playSound,
                  ),
                  const SizedBox(height: 40)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String name;
  final String roles;
  final String imagePath;
  final String githubUrl;
  final bool isImageLeft;
  final Function(String) onUrlTap;
  final VoidCallback onSoundTap;

  const _ProfileItem({
    required this.name,
    required this.roles,
    required this.imagePath,
    required this.githubUrl,
    required this.isImageLeft,
    required this.onUrlTap,
    required this.onSoundTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onLongPress: () => onUrlTap(githubUrl),
                  splashColor: Colors.red.withAlpha(128),
                  enableFeedback: false,
                  onTap: onSoundTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Widget textWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 15,
            fontFamily: 'Monocraft',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          roles,
          style: const TextStyle(
            fontSize: 15,
            fontFamily: 'Monocraft',
            color: Color(0xFF455CE7),
          ),
        ),
      ],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: isImageLeft
          ? [imageWidget, textWidget]
          : [textWidget, imageWidget],
    );
  }
}