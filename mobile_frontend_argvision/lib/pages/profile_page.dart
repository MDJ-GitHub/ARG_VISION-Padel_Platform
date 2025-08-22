import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_frontend_argvision/services/storage_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final String? userDataJson = await StorageService.read('user_data');
    if (userDataJson != null) {
      final decoded = json.decode(userDataJson) as Map<String, dynamic>;
      print(decoded);
      setState(() {
        userData = decoded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      // Show loading spinner while fetching user data
      return const Center(child: CircularProgressIndicator());
    }

    // Extract data safely with fallback values
    final String fullName = "${userData?['first_name'] ?? ''} ${userData?['last_name'] ?? ''}";
    final String email = userData?['email'] ?? 'N/A';
    final String phone = userData?['phone'] ?? 'N/A';
    final String profession = userData?['role'] ?? 'N/A';
    final String location = userData?['location'] ?? 'Unknown';
    final String bio = userData?['bio'] ?? 'N/A';
    final double rating = (userData?['rating'] ?? 0).toDouble();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 250, child: _buildProfileSection(fullName, rating, location)),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 1,
                    offset: const Offset(0, -1),
                  ),
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const TabBar(
                labelColor: Color(0xFF0074E1),
                unselectedLabelColor: Colors.black87,
                indicatorColor: Color(0xFF0074E1),
                tabs: [
                  Tab(text: 'Profil'),
                  Tab(text: 'Sports'),
                  Tab(text: 'Avis'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  _ProfilTab(email: email, phone: phone, profession: profession, bio: bio),
                  const _SportsTab(),
                  const _AvisTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String fullName, double rating, String location) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 177,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF03558F), Color.fromARGB(255, 45, 148, 237)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Profile',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white24,
                          child: const Icon(Icons.person,
                              size: 40, color: Colors.white),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 18),
                            const SizedBox(width: 4),
                            Text(rating.toString(),
                                style: const TextStyle(color: Colors.white)),
                            const SizedBox(width: 12),
                            const Icon(Icons.location_on_outlined,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 4),
                            Text(location,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w100)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // The stats box can also be dynamic if needed
        Positioned(
          bottom: 26,
          left: 16,
          right: 16,
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _StatItem(
                    number: '47', label: 'Matches \n Played', color: Colors.blue),
                _StatItem(
                    number: '23',
                    label: 'Matches \n Created',
                    color: Colors.purple),
                _StatItem(
                    number: '29',
                    label: 'Matches \n Won',
                    color: Colors.green),
                _StatItem(
                    number: '2',
                    label: 'Tournois \n Won',
                    color: Colors.orange),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Modify _ProfilTab to accept dynamic data
class _ProfilTab extends StatelessWidget {
  final String email;
  final String phone;
  final String profession;
  final String bio;

  const _ProfilTab({
    required this.email,
    required this.phone,
    required this.profession,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: 'Informations personnelles',
          children: [
            _InfoRow(label: 'Email', value: email),
            _InfoRow(label: 'Phone', value: phone),
            _InfoRow(label: 'Profession', value: profession),
          ],
        ),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'About me',
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
              bio,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class _SportsTab extends StatelessWidget {
  const _SportsTab();

  final List<Map<String, dynamic>> sportsList = const [
    {
      'icon': Icons.sports_soccer,
      'name': 'Football',
      'level': 'Gold',
      'rating': 4.8,
    },
    {
      'icon': Icons.sports_tennis,
      'name': 'Tennis',
      'level': 'Silver',
      'rating': 4.2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sportsList.length,
      itemBuilder: (context, index) {
        final sport = sportsList[index];
        return _SportCard(
          icon: sport['icon'],
          title: sport['name'],
          level: sport['level'],
          rating: sport['rating'],
        );
      },
    );
  }
}

class _AvisTab extends StatelessWidget {
  const _AvisTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Aucun avis pour le moment."),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;
  final Color color;

  const _StatItem({
    required this.number,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String level;
  final double rating;

  const _SportCard({
    required this.icon,
    required this.title,
    required this.level,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Niveau: $level',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(rating.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
