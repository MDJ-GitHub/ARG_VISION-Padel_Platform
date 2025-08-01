import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF03558F),
              
               // Darker blue at the top
              Color.fromARGB(255, 45, 148, 237), // Lighter blue at the bottom
            ],
          ),
        ),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 4),
        child: Text(
          'OnlySport',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0, top: 0),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications, size: 20, color: Colors.white),
              onPressed: () {
                // Notification logic here
              },
              padding: EdgeInsets.zero,
              splashRadius: 20,
            ),
          ),
        ),
      ],
    );
  }
}
