import 'package:flutter/material.dart';
import 'package:mobile_frontend_argvision/pages/add_page.dart';
import 'package:mobile_frontend_argvision/pages/explore_page.dart';
import 'package:mobile_frontend_argvision/pages/login_page.dart';
import 'package:mobile_frontend_argvision/pages/match_details_page.dart';
import 'package:mobile_frontend_argvision/pages/matches_page.dart';
import 'package:mobile_frontend_argvision/pages/messages_page.dart';
import 'package:mobile_frontend_argvision/pages/tournaments_page.dart';
import 'package:mobile_frontend_argvision/pages/profile_page.dart';
import 'package:mobile_frontend_argvision/pages/rankings_team_page.dart';
import 'package:mobile_frontend_argvision/pages/rankings_page.dart';

import 'package:mobile_frontend_argvision/services/organizations_services.dart';
import 'package:mobile_frontend_argvision/widgets/bottom_navbar.dart';
import 'package:mobile_frontend_argvision/widgets/top_navbar.dart';
import 'package:mobile_frontend_argvision/widgets/profile_sidebar.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => OrganizationsServices()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnlySport',
      theme: ThemeData(
        fontFamily: 'SFProDisplay',
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'SFProDisplay',
        ),
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          onPrimary: Colors.white,
        ),
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MainWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => MainWrapperState();
}

class MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 10; // Start with login page (index 10)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Widget> _pages;

  void _onItemTapped(int index) {
    if (index == 4) { // If profile button is pressed
      _scaffoldKey.currentState?.openEndDrawer(); // Open the sidebar
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _handleLoginSuccess(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize pages here so they have access to the current state
    _pages = [
      HomePage(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      TournamentsPage(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      const AddPage(),
      const MatchDetailsPage(),
      const MatchesPage(), 
      const MatchesPage(), 
      const ProfilePage(),
      const RankingsTeamPage(),
      const RankingsPage(),
      const MessagesPage(), // Profile page at index 6
      LoginPage(onLoginSuccess: _handleLoginSuccess), // Login page at index 10
            const ExplorePage(),
    ];

    // Determine if we're showing the login page
    bool isLoginPage = _currentIndex == 10;

    return Scaffold(
      key: _scaffoldKey,
      appBar: isLoginPage ? null : PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(),
          child: TopAppBar(),
        ),
      ),
      endDrawer: isLoginPage ? null : SideBar(
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onLogout: () {
          setState(() {
            _currentIndex = 10; // Go back to login page
          });
          Navigator.pop(context);
        },
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: isLoginPage ? null : Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.6),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
        ),
      ),
      floatingActionButton: isLoginPage ? null : Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(1),
            width: 3,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF03558F),
                Color.fromARGB(255, 45, 148, 237),
              ],
            ),
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape: const CircleBorder(),
            onPressed: () {
              setState(() {
                _currentIndex = 2; // Add page index
              });
            },
            child: Image.asset(
              'assets/images/icon_add.png',
              width: 32,
              height: 32,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}