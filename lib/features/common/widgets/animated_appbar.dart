import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimatedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userName;

  const AnimatedAppBar({super.key, required this.userName});

  @override
  State<AnimatedAppBar> createState() => _AnimatedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _AnimatedAppBarState extends State<AnimatedAppBar> {
  bool hasSeenIntro = false;

  @override
  void initState() {
    super.initState();
    _loadSeenStatus();
  }

  Future<void> _loadSeenStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;
    });
  }

  Future<void> _markIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenIntro', true);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 0,
      toolbarHeight: 80,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🏷️ App Logo (Left side now)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.asset(
                'assets/images/logo.png',
                filterQuality: FilterQuality.high,
              ),
            ),
          ),

          // 👋 Greeting Text (Center)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${widget.userName}!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'What would you like to eat?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🍳 Chef Animation (Right side, increased size)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 80, // Increased from 72
              height: 80, // Increased from 72
              child: Lottie.asset(
                'assets/animations/chef_cooking.json',
                repeat: hasSeenIntro,
                animate: true,
                frameRate: FrameRate(60),
                onLoaded: (_) => _markIntroSeen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
