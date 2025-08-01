import 'package:flutter/material.dart';

class RankingsTeamPage extends StatefulWidget {
  const RankingsTeamPage({super.key});

  @override
  State<RankingsTeamPage> createState() => _RankingsTeamPageState();
}

class _RankingsTeamPageState extends State<RankingsTeamPage> {
  int _selectedIndex = 0; // 0 for Standard, 1 for Tournament

  // Sample ranking data for a single user across sports
  final List<Map<String, dynamic>> standardRanks = [
    {'sport': 'soccer', 'rank': 4, 'level': 12, 'score': 2450
    ,'name': 'Farik So9or'},
    {'sport': 'basketball', 'rank': 3, 'level': 10, 'score': 2100
    ,'name': 'Kabtin majed'},
    {'sport': 'tennis', 'rank': 5, 'level': 15, 'score': 2875
    ,'name': 'Hassan Elhaj'},
        {'sport': 'soccer', 'rank': 4, 'level': 12, 'score': 2450
    ,'name': 'Farik So9or'},
  ];

  final List<Map<String, dynamic>> tournamentRanks = [
    {'sport': 'soccer', 'rank': 4, 'level': 12, 'score': 2450
    ,'name': 'Farik So9or'},
    {'sport': 'basketball', 'rank': 3, 'level': 10, 'score': 2100
    ,'name': 'Kabtin majed'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildButtonBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _selectedIndex == 0 ? standardRanks.length : tournamentRanks.length,
              itemBuilder: (context, index) => _buildRankCard(
                _selectedIndex == 0 ? standardRanks[index] : tournamentRanks[index],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonBar() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.92,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        color: const Color.fromARGB(255, 253, 253, 253),
        image: DecorationImage(
          image: AssetImage('assets/images/banner.webp'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.9),
            BlendMode.lighten,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Added header
          Padding(
            padding: const EdgeInsets.only(top: 2.0, bottom: 0.0),
            child: Text(
              'Your teams rankings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Row(
            children: [
              _buildButtonItem(0, Icons.child_friendly, 'Standard'),
              _buildButtonItem(1, Icons.emoji_events, 'Tournament'),
            ],
          ),
          SizedBox(
            height: 4,
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    color: _selectedIndex == 0 ? Colors.blue : Colors.transparent,
                  ),
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    color: _selectedIndex == 1 ? Colors.blue : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonItem(int index, IconData icon, String text) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: _selectedIndex == index ? Colors.blue : Colors.grey,
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: _selectedIndex == index ? Colors.blue : Colors.grey,
                    fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankCard(Map<String, dynamic> rank) {
    final Map<int, Map<String, dynamic>> ranks = {
      1: {'name': 'Iron', 'color': const Color(0xFFA19D94)},
      2: {'name': 'Bronze', 'color': const Color(0xFFCD7F32)},
      3: {'name': 'Silver', 'color': const Color(0xFFC0C0C0)},
      4: {'name': 'Gold', 'color': const Color(0xFFFFD700)},
      5: {'name': 'Platinum', 'color': const Color(0xFFE5E4E2)},
      6: {'name': 'Diamond', 'color': const Color(0xFFB9F2FF)},
    };

    final rankInfo = ranks[rank['rank']] ?? ranks[1]!;

    IconData sportIcon;
    switch (rank['sport']) {
      case 'basketball': sportIcon = Icons.sports_basketball; break;
      case 'football': sportIcon = Icons.sports_football; break;
      case 'tennis': sportIcon = Icons.sports_tennis; break;
      case 'volleyball': sportIcon = Icons.sports_volleyball; break;
      case 'soccer':
      default: sportIcon = Icons.sports_soccer;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 3, left: 16, right: 16, top: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.35),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: SizedBox(
          height: 95,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    sportIcon,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        rank['sport'].toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 20,
                            color: rankInfo['color'],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            rankInfo['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: rankInfo['color'],
                            ),
                          ),
                        ],
                      ),
                   
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16),
                          const SizedBox(width: 4),
                          Text('Level ${rank['level']}'),
                          const SizedBox(width: 16),
                          const Icon(Icons.score, size: 16),
                          const SizedBox(width: 4),
                          Text('${rank['score']} pts'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}