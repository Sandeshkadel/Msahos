import 'package:flutter/material.dart';

import '../core/services/mesh_controller.dart';
import '../features/ai/ai_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/home/home_screen.dart';
import '../features/map/map_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/transfer/transfer_screen.dart';
import '../features/users/users_screen.dart';
import 'theme.dart';

class MeshLinkApp extends StatefulWidget {
  const MeshLinkApp({super.key});

  @override
  State<MeshLinkApp> createState() => _MeshLinkAppState();
}

class _MeshLinkAppState extends State<MeshLinkApp> {
  final MeshController _controller = MeshController();
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.bootstrap();
    _controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(controller: _controller),
      UsersScreen(
        controller: _controller,
        onOpenChat: (userId) {
          _controller.selectChatUser(userId);
          setState(() {
            _tabIndex = 2;
          });
        },
      ),
      ChatScreen(controller: _controller),
      TransferScreen(controller: _controller),
      MapScreen(controller: _controller),
      AiScreen(controller: _controller),
      ProfileScreen(controller: _controller),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MeshLink',
      theme: buildMeshLinkTheme(),
      home: !_controller.hasProfile
          ? OnboardingScreen(controller: _controller)
          : Scaffold(
              body: SafeArea(child: pages[_tabIndex]),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _tabIndex,
                onDestinationSelected: (value) => setState(() => _tabIndex = value),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.people_alt_rounded), label: 'Find'),
                  NavigationDestination(icon: Icon(Icons.forum_rounded), label: 'Chat'),
                  NavigationDestination(icon: Icon(Icons.file_upload_rounded), label: 'Transfer'),
                  NavigationDestination(icon: Icon(Icons.map_rounded), label: 'Map'),
                  NavigationDestination(icon: Icon(Icons.memory_rounded), label: 'AI'),
                  NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
                ],
              ),
            ),
    );
  }
}
