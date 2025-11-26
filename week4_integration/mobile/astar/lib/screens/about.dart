import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchGithub(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Failed to connect: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          const Header(title: 'About Us'),

          _ProfileItem(
            name: 'Thufail\nBahir Al Bariq',
            roles: '@UI/UX\n@MobApps_Dev\n@Backend_Dev',
            imagePath: 'assets/images/icons/thufail.png',
            githubUrl: 'https://github.com/yuumaSSS',
            isImageLeft: true, // Gambar di kiri
            onTap: _launchGithub,
          ),

          const SizedBox(height: 40),

          _ProfileItem(
            name: 'Dhimas\nPutra Sulistio',
            roles: '@UI/UX\n@Frontend_Dev',
            imagePath: 'assets/images/icons/dhimas.png',
            githubUrl: 'https://github.com/muddglobb',
            isImageLeft: false, // Gambar di kanan (Zigzag)
            onTap: _launchGithub,
          ),

          const SizedBox(height: 40),

          _ProfileItem(
            name: 'Maulana Faris\nAl Ghifari',
            roles: '@UI/UX\n@Frontend_Dev',
            imagePath: 'assets/images/icons/faris.png',
            githubUrl: 'https://github.com/MaulanaFarisA',
            isImageLeft: true, // Gambar di kiri
            onTap: _launchGithub,
          ),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String name;
  final String roles;
  final String imagePath;
  final String githubUrl;
  final bool isImageLeft;
  final Function(String) onTap;

  const _ProfileItem({
    required this.name,
    required this.roles,
    required this.imagePath,
    required this.githubUrl,
    required this.isImageLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = InkWell(
      onLongPress: () => onTap(githubUrl),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent), 
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );

    // Widget Text
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