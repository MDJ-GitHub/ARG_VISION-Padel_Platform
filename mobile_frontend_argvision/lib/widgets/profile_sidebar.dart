import 'package:flutter/material.dart';

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
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.blue,
                        child: const CircleAvatar(
                          radius: 42,
                          backgroundImage: AssetImage('assets/images/placeholderpicture.webp'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text(
                      'Noamen Ben makhlouf',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30), // spacing between profile and menu

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
                      onTap: () {
                        Navigator.pop(context);
                        onLogout();
                      },
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
      title: Text(
        label,
        style: const TextStyle(fontSize: 15),
      ),
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
      title: Text(
        label,
        style: const TextStyle(fontSize: 15),
      ),
      onTap: onTap,
    );
  }
}
