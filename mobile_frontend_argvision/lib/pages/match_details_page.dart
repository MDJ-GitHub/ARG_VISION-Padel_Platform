import 'package:flutter/material.dart';

class MatchDetailsPage extends StatelessWidget {
  const MatchDetailsPage({super.key});

  final Map<String, dynamic> matchData = const {
    "title": "Championnat de Football Amateur",
    "subtitle": "Football • 7 vs 7  +3 Remplaçants",
    "date": "15–17 Décembre 2025",
    "location": "Borj touil, Ariana",
    "teams": "10/16 équipes",
    "price": "1500 DT",
    "points": "1500 P",
    "teamCost": "200 DT par équipe",
    "spotsLeft": "4 places restantes",
    "imagePath": "assets/images/placeholderpicture.webp"
  };

  final List<Map<String, dynamic>> players = const [
    {"id": 1, "name": "Ahmed Salah", "team": 1},
    {"id": 2, "name": "Karim Ben Ali", "team": 1},
    {"id": 3, "name": "Youssef Gharbi", "team": 0},
    {"id": 4, "name": "Walid Jabari", "team": 2},
    {"id": 5, "name": "Oussama Trabelsi", "team": 2},
    {"id": 6, "name": "Fedi Mbarek", "team": 2},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xF5F8FAFF),
        body: Column(
          children: [
            // Match Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)), // Added border property
                  boxShadow:  [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.7),
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 48,
                            height: 48,
                            color: Colors.white,
                            child: Image.asset(
                              matchData['imagePath'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              matchData['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              matchData['subtitle'],
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color.fromARGB(255, 204, 204, 204),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date & Location
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(matchData['date']),
                        const SizedBox(width: 24),
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Text(matchData['location']),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Teams, Price, Points
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 16),
                        const SizedBox(width: 8),
                        Text(matchData['teams']),
                        const SizedBox(width: 20),
                        const Icon(Icons.attach_money, size: 16),
                        const SizedBox(width: 4),
                        Text(matchData['price']),
                        const SizedBox(width: 20),
                        const Icon(Icons.emoji_events_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(matchData['points']),
                      ],
                    ),

                    const Divider(height: 24, color: Colors.grey),

                    // Bottom row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          matchData['teamCost'],
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          matchData['spotsLeft'],
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tab Bar
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
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(text: 'Info'),
                  Tab(text: 'Terrain'),
                  Tab(text: 'Players'),
                  Tab(text: 'Coaches'),
                  Tab(text: 'Results'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _emptyTabContent('Info'),
                  _emptyTabContent('Terrain'),
                  _buildPlayersTab(),
                  _emptyTabContent('Coaches'),
                  _emptyTabContent('Results'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _emptyTabContent(String title) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          'Contenu vide pour $title',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildPlayersTab() {
    final team1Players = players.where((p) => p['team'] == 1).toList();
    final team0Players = players.where((p) => p['team'] == 0).toList();
    final team2Players = players.where((p) => p['team'] == 2).toList();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team 1 (Blue)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Team 1',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...team1Players.map((player) => _buildPlayerCard(player, Colors.blue)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Team 0 (Grey)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invited',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...team0Players.map((player) => _buildPlayerCard(player, Colors.grey)),
              ],
            ),
          ),
          // Team 2 (Red)
           const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Team 2',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...team2Players.map((player) => _buildPlayerCard(player, Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildPlayerCard(Map<String, dynamic> player, Color color) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name in a row (single line)
        Row(
          children: [
            Expanded(
              child: Text(
                player['name'],
                style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Picture and ID in a row
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                player['name'][0],
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '#${player['id']}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

}
