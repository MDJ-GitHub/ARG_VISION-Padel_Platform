import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:mobile_frontend_argvision/services/storage_service.dart';

class SideBar extends StatelessWidget {
  final void Function(int index) onItemSelected;
  final VoidCallback onLogout;

  const SideBar({
    super.key,
    required this.onItemSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width * 0.6;
    final height = screenSize.height * 0.8;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(-4, 0),
              blurRadius: 10,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 40), // top padding for buttons
                    // Tappable Profile
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onItemSelected(6);
                      },

                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          onItemSelected(6); // Navigate to profile
                        },
                        child: FutureBuilder<String?>(
                          future: _getUserImageUrl(),
                          builder: (context, snapshot) {
                            final String? imageUrl = snapshot.data;
                            return CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.blue,
                              child: CircleAvatar(
                                radius: 42,
                                backgroundImage:
                                    imageUrl != null && imageUrl.isNotEmpty
                                        ? NetworkImage(
                                          imageUrl,
                                        ) // show image from Django
                                        : const AssetImage(
                                              'assets/images/placeholderpicture.webp',
                                            )
                                            as ImageProvider, // fallback
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    FutureBuilder(
                      future: _getUserName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text(
                            'User Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        } else {
                          return Text(
                            snapshot.data ?? 'User Name',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ), // spacing between profile and menu
                    // Menu items
                    _buildIconMenu(
                      icon: Icons.sports_esports,
                      label: 'My Matches',
                      onTap: () {
                        Navigator.pop(context);
                        onItemSelected(0);
                      },
                    ),
                    _buildIconMenu(
                      icon: Icons.emoji_events,
                      label: 'My Tournaments',
                      onTap: () {
                        Navigator.pop(context);
                        onItemSelected(1);
                      },
                    ),
                    _buildIconMenu(
                      icon: Icons.groups,
                      label: 'My Teams',
                      onTap: () {
                        Navigator.pop(context);
                        onItemSelected(2);
                      },
                    ),

                    const Spacer(),

                    // Footer items
                    _buildFooterItem(
                      icon: Icons.info_outline,
                      label: 'About us',
                      color: Colors.blue,
                      onTap: () {},
                    ),
                    _buildFooterItem(
                      icon: Icons.help_outline,
                      label: 'Help',
                      color: Colors.blue,
                      onTap: () {},
                    ),
                    _buildFooterItem(
                      icon: Icons.logout,
                      label: 'Logout',
                      color: Colors.pink,
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ),

            // Settings button (top right)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.blue),
                onPressed: () {
                  Navigator.pop(context);
                  onItemSelected(-1);
                },
              ),
            ),

            // Close button (top left)
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.blue),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _getUserImageUrl() async {
  try {
    final String? userDataJson = await StorageService.read('user_data');
    if (userDataJson != null) {
      final Map<String, dynamic> userData = jsonDecode(userDataJson);
      final String? imagePath = userData['image']; // the path stored from Django
      if (imagePath != null && imagePath.isNotEmpty) {
        // Assuming Django serves media at 127.0.0.1:8000/media/...
        return 'http://127.0.0.1:8000$imagePath';
      }
    }
  } catch (e) {
    // ignore errors and fallback to placeholder
  }
  return null;
}


  Future<String> _getUserName() async {
    try {
      final String? userDataJson = await StorageService.read('user_data');
      if (userDataJson != null) {
        final Map<String, dynamic> userData = jsonDecode(userDataJson);
        final String firstName = userData['first_name'] ?? '';
        final String lastName = userData['last_name'] ?? '';
        return '$firstName $lastName'.trim();
      }
      return 'User Name';
    } catch (e) {
      return 'User Name';
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Clear all the required storage items
      await StorageService.delete('access_token');
      await StorageService.delete('refresh_token');
      await StorageService.delete('rememberMe');
      await StorageService.delete('user_data');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('See you soon!'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.blue,
        ),
      );

      // Navigate to index 10
      if (context.mounted) {
        Navigator.pop(context); // Close the sidebar
        onItemSelected(10); // Navigate to index 10 (login/splash screen)
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error during logout')));
      }
    }
  }

  Widget _buildIconMenu({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 13,
        backgroundColor: Colors.blue,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
    );
  }

  Widget _buildFooterItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 13,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
    );
  }
}
