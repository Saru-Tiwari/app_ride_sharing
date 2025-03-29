import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'create_account_page.dart'; // Import the Create Account Page

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/intro_vid.mp4')
      ..initialize().then((_) {
        _controller.play();
        setState(() {});
      });

    // Listen for video completion
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        // Video ended, navigate to Create Account Page
        _navigateToCreateAccountPage();
      }
    });
  }

  void _navigateToCreateAccountPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CreateAccountPage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: TextButton(
              onPressed: _navigateToCreateAccountPage,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
