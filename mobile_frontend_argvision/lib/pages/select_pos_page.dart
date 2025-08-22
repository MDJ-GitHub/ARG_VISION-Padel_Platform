import 'package:flutter/material.dart';

class Player {
  final String name;
  final String team;
  final String position; // "GK", "DEF", "MID", "ATT"

  Player({required this.name, required this.team, required this.position});
}

class Team {
  final String name;
  final List<Player> players;
  final List<Player> substitutes;

  Team({required this.name, required this.players, required this.substitutes});
}

class SelectPosPage extends StatefulWidget {
  const SelectPosPage({super.key});

  @override
  State<SelectPosPage> createState() => _SelectPosPageState();
}

class _SelectPosPageState extends State<SelectPosPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final teams = [
    Team(
      name: "Team 1",
      players: [
        Player(name: "GK1", team: "MONX", position: "GK"),
        Player(name: "DEF1", team: "MONX", position: "DEF"),
        Player(name: "DEF2", team: "MONX", position: "DEF"),
        Player(name: "DEF3", team: "MONX", position: "DEF"),
        Player(name: "DEF4", team: "MONX", position: "DEF"),
        Player(name: "MID1", team: "MONX", position: "MID"),
        Player(name: "MID2", team: "MONX", position: "MID"),
        Player(name: "MID3", team: "MONX", position: "MID"),
        Player(name: "ATT1", team: "MONX", position: "ATT"),
        Player(name: "ATT2", team: "MONX", position: "ATT"),
        Player(name: "ATT3", team: "MONX", position: "ATT"),
      ],
      substitutes: [
        Player(name: "Sub1", team: "MONX", position: "SUB"),
        Player(name: "Sub2", team: "MONX", position: "SUB"),
        Player(name: "Sub3", team: "MONX", position: "SUB"),
        Player(name: "Sub4", team: "MONX", position: "SUB"),
      ],
    ),
    Team(
      name: "Team 2",
      players: [
        Player(name: "GK2", team: "ABC", position: "GK"),
        Player(name: "DEF1", team: "ABC", position: "DEF"),
        Player(name: "DEF2", team: "ABC", position: "DEF"),
        Player(name: "MID1", team: "ABC", position: "MID"),
        Player(name: "MID2", team: "ABC", position: "MID"),
        Player(name: "ATT1", team: "ABC", position: "ATT"),
        Player(name: "ATT2", team: "ABC", position: "ATT"),
      ],
      substitutes: [
        Player(name: "Sub1", team: "ABC", position: "SUB"),
        Player(name: "Sub2", team: "ABC", position: "SUB"),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: teams.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildPlayerSlot({Widget? child}) {
    return Container(
      width: 60,
      height: 80,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Center(
        child: child ??
            const Icon(Icons.add, color: Colors.black54, size: 28),
      ),
    );
  }

  Widget _buildPlayerCard(Player player) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_soccer, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            player.name,
            style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            player.team,
            style: const TextStyle(color: Colors.white, fontSize: 9),
          )
        ],
      ),
    );
  }

  Widget _buildRow(List<Player> players, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        count,
        (i) => i < players.length
            ? _buildPlayerCard(players[i])
            : _buildPlayerSlot(),
      ),
    );
  }

  Widget _buildField(Team team) {
    final gk = team.players.where((p) => p.position == "GK").toList();
    final def = team.players.where((p) => p.position == "DEF").toList();
    final mid = team.players.where((p) => p.position == "MID").toList();
    final att = team.players.where((p) => p.position == "ATT").toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Stack(
        children: [
          // Scrollable field with background
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/selectterrain.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(team.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Text(team.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                      ),


                      // GK
                      if (gk.isNotEmpty) Center(child: _buildPlayerCard(gk[0])),

                      const SizedBox(height: 20),
                      // Defense
                      _buildRow(def, 4),
                      const SizedBox(height: 20),
                      // Midfield
                      _buildRow(mid, 4),
                      const SizedBox(height: 20),
                      // Attack
                      _buildRow(att, 4),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Substitutes (fixed bar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[900]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Inviter des remplaçants",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: team.substitutes.isNotEmpty
                        ? team.substitutes
                            .map((p) => _buildPlayerCard(p))
                            .toList()
                        : List.generate(4, (_) => _buildPlayerSlot()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  toolbarHeight: 0, // hides default appbar height
  flexibleSpace: Container(
    decoration: BoxDecoration(
      color: Colors.blue[800] ,
    
    ),
  ),
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(80),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
  colors: [Color(0xFF0095FF), Color(0xFF03558F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(15),
            boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.4), // shadow color
        spreadRadius: 4, // how wide
        blurRadius: 12, // how soft
        offset: const Offset(0, 6), // position (x, y)
      ),
    ],
      ),
      child: TabBar(
  controller: _tabController,
  indicator: BoxDecoration(
    gradient: const LinearGradient(
  colors: [Color(0xFF0095FF), Color(0xFF03558F)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    borderRadius: BorderRadius.circular(15),

  ),
  labelColor: Colors.white,
  unselectedLabelColor: Colors.white70,
  tabs: teams.map((t) => Tab(text: t.name)).toList(),
),
    ),
  ),
),

      body: TabBarView(
        controller: _tabController,
        children: teams.map((t) => _buildField(t)).toList(),
      ),
    );
  }
}
