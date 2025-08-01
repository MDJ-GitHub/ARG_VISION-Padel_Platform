import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

@override
Widget build(BuildContext context) {
  return Container(
    
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
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, -1),
        ),
      ],
    ),
    child: BottomAppBar(
      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0, top: 0),
      color: Colors.transparent,
      elevation: 0,
      shape: const CircularNotchedRectangle(),
      notchMargin: 0.0,
      height: 67,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              _buildFlexibleNavItemWithImage('assets/images/icon_home.png', 'Home', 0),
              _buildFlexibleNavItemWithImage('assets/images/icon_medal2.png', 'Rankings', 8),
              _buildFlexibleNavItemWithImage('assets/images/icon_explore.png', 'Explore', 11),
              const SizedBox(width: 50), // Floating button space
              _buildFlexibleNavItemWithImage('assets/images/icon_chat.png', 'Messaging', 9),
              _buildFlexibleNavItemWithImage('assets/images/icon_trophy2.png', 'Tournys', 1),
              _buildFlexibleNavItemWithImage('assets/images/icon_profile.png', 'Profile', 4),
            ],
          );
        },
      ),
    ),
  );
}

Widget _buildFlexibleNavItemWithImage(String icon, String label, int index) {
  bool isSelected = currentIndex == index;

  return Flexible(
    fit: FlexFit.tight,
    child: GestureDetector(
      onTap: () => onTap(index),
      child: Container(
     
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: 42,
              height: 42,
              color: isSelected ? Colors.white : const Color(0xFFD0D0D0),
            ),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFD0D0D0),
                  fontSize: 10,
                ),
                maxLines: 2,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
