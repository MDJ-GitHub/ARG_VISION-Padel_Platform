import 'package:flutter/material.dart';
import 'package:mobile_frontend_argvision/services/organizations_services.dart';

class HomePage extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HomePage({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedSport = 'soccer';
  IconData _selectedSportIcon = Icons.sports_soccer;
  bool _isLoading = false;

  // List of available sports
  final List<Map<String, dynamic>> sports = [
    {'name': 'Soccer', 'icon': Icons.sports_soccer, 'value': 'soccer'},
    {
      'name': 'Basketball',
      'icon': Icons.sports_basketball,
      'value': 'basketball',
    },
    {'name': 'Football', 'icon': Icons.sports_football, 'value': 'football'},
    {'name': 'Tennis', 'icon': Icons.sports_tennis, 'value': 'tennis'},
    {'name': 'Baseball', 'icon': Icons.sports_baseball, 'value': 'baseball'},
    {
      'name': 'Volleyball',
      'icon': Icons.sports_volleyball,
      'value': 'volleyball',
    },
    {'name': 'Golf', 'icon': Icons.sports_golf, 'value': 'golf'},
    {
      'name': 'Martial Arts',
      'icon': Icons.sports_martial_arts,
      'value': 'martial_arts',
    },
  ];

  // Your hardcoded matches
  final List<Map<String, dynamic>> matches = [
    {
      'image':
          'https://th.bing.com/th/id/OIP.G7cnU7VEhC2c_u5bFyoekQHaE8?rs=1&pid=ImgDetMain',
      'name': 'Summer Tournament',
      'dateCreated': '2023-06-15 18:00',
      'dateStart': '2023-06-20 18:00',
      'duration': '2 hours',
      'players': '1/2',
      'score': '1500',
      'location': 'Central Park',
      'sport': 'soccer',
      'visibility': 'PUBLIC',
      'rank': 1,
    },
    {
      'image':
          'https://th.bing.com/th/id/OIP.Ocv__uJO2g1ow_lzdecvowHaE8?rs=1&pid=ImgDetMain',
      'name': 'Winter Singles',
      'dateCreated': '2023-06-15 18:00',
      'dateStart': '2023-06-20 18:00',
      'duration': '2 hours',
      'players': '1/2',
      'score': '1200',
      'location': 'Downtown Arena',
      'sport': 'tennis',
      'visibility': 'PUBLIC',
      'rank': 2,
    },
    {
      'image':
          'https://thumbs.dreamstime.com/b/empty-soccer-stadium-fresh-green-grass-blue-sky-football-terrain-empty-soccer-stadium-fresh-green-grass-299806360.jpg',
      'name': '1v1 Quick Match',
      'dateCreated': '2023-06-15 18:00',
      'dateStart': '2023-06-20 18:00',
      'duration': '2 hours',
      'players': '1/2',
      'score': '1800',
      'location': 'City Stadium',
      'sport': 'soccer',
      'visibility': 'PUBLIC',
      'rank': 3,
    },
  ];

  final List<Map<String, dynamic>> tournaments = [
    {
      'image':
          'https://thumbs.dreamstime.com/b/empty-soccer-stadium-fresh-green-grass-blue-sky-football-terrain-empty-soccer-stadium-fresh-green-grass-299806360.jpg',
      'name': 'Annual Championship',
      'dateCreated': '2023-05-10 18:00',
      'dateStart': '2023-05-15 18:00',
      'duration': '3 days',
      'players': '32/64',
      'score': '5000',
      'location': 'National Stadium',
      'sport': 'soccer',
      'isPublic': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchApiMatches();
  }

  Future<void> _fetchApiMatches() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiMatches = await OrganizationsServices.fetchPublicMatches();

      // Transform API data to match your format
      final transformedMatches = apiMatches.map((match) {
        return {
          'image':
              match['picture'] ??
                  'assets/images/placeholderpicture.webp',
          'name': match['name'] ?? 'Unnamed Match',
          'dateCreated': match['date_created']?.split('T')[0] ?? 'Unknown',
          'dateStart': match['date_start']?.split('T')[0] ?? 'Not scheduled',
          'duration': match['duration']?.toString() ?? 'Not specified',
          'players': '0/${match['max_participants'] ?? 2}',
          'rank': match['rank'] ?? 1,
          'score': '1500', // Default or calculate from API if available
          'location': match['terrain'] ?? 'Online',
          'sport': _mapGameIdToSport(match['game']),
          'isPublic': match['is_public'] ?? true,
          'visibility': match['visibility'] ?? 'PUBLIC',
        };
      }).toList();

      setState(() {
        matches.addAll(transformedMatches);
      });
    } catch (e) {
      print('Error fetching API matches: $e');
      // Optionally show error to user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _mapGameIdToSport(int? gameId) {
    // Implement your game ID to sport name mapping
    switch (gameId) {
      case 1:
        return 'soccer';
      case 2:
        return 'basketball';
      case 3:
        return 'football';
      case 4:
        return 'tennis';
      default:
        return 'other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildSportsSidebar(),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: 0,
              toolbarHeight: 60,
              automaticallyImplyLeading: false,
              actions: [SizedBox()], // 👈 prevent default endDrawer icon
              flexibleSpace: PreferredSize(
                preferredSize: const Size.fromHeight(90),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11),
                  child: _buildSearchRow(),
                ),
              ),
            ),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Matches Section
                    _buildSectionHeader('Matches', context),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: matches.length,
                      itemBuilder: (context, index) => _buildCardItem(matches[index]),
                    ),
                    
                    // Tournaments Section
                    _buildSectionHeader('Tournaments', context),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: tournaments.length,
                      itemBuilder: (context, index) => _buildCardItem(tournaments[index]),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

Widget _buildSectionHeader(String title, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
    child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/banner.webp'), // Make sure to add the image to your assets
          fit: BoxFit.cover, // This will cover the entire container
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.8), // Optional: adds a slight dark overlay for better text visibility
            BlendMode.lighten,
          ),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onTap(5),
                    child: const Row(
                      children: [
                        Text(
                          'View all',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                        Icon(Icons.arrow_forward, size: 18, color: Colors.blue),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _buildSportsSidebar() {
    return SizedBox(
      height: 400,
      child: Drawer(
        width: 200,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Sport',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sports.length,
                itemBuilder: (context, index) {
                  final sport = sports[index];
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _selectedSport == sport['value']
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        sport['icon'],
                        color: _selectedSport == sport['value']
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                    title: Text(
                      sport['name'],
                      style: TextStyle(
                        fontWeight: _selectedSport == sport['value']
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedSport = sport['value'];
                        _selectedSportIcon = sport['icon'];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    final currentSport = sports.firstWhere(
      (sport) => sport['value'] == _selectedSport,
      orElse: () => sports.first,
    )['name'];

    return Row(
      children: [
        // Search bar first (expanded to take available space)
        Expanded(
          child: Container(
            height: 37,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 180, 180, 180).withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: '🔎 Search matches',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.tune,
                        color: Colors.blue,
                        size: 23,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 251, 251, 251),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Sport button on the right
        Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_selectedSportIcon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      currentSport,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardItem(Map<String, dynamic> tournament) {
    IconData sportIcon;

    switch (tournament['sport']) {
      case 'football':
        sportIcon = Icons.sports_football;
        break;
      case 'tennis':
        sportIcon = Icons.sports_tennis;
        break;
      case 'basketball':
        sportIcon = Icons.sports_basketball;
        break;
      case 'soccer':
      default:
        sportIcon = Icons.sports_soccer;
    }

    // Rank definitions
    final Map<int, Map<String, dynamic>> ranks = {
      1: {'name': 'Iron', 'color': Color(0xFFA19D94)},
      2: {'name': 'Bronze', 'color': Color(0xFFCD7F32)},
      3: {'name': 'Silver', 'color': Color(0xFFC0C0C0)},
      4: {'name': 'Gold', 'color': Color(0xFFFFD700)},
      5: {'name': 'Platinum', 'color': Color(0xFFE5E4E2)},
      6: {'name': 'Diamond', 'color': Color(0xFFB9F2FF)},
    };

    final int rankValue = tournament['rank'] ?? 1;
    final rank = ranks[rankValue] ?? ranks[1]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 0, left: 16, right: 16, top: 6),
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
          height: 150,
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tournament image
                  Container(
                    width: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(tournament['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Tournament info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title with grey background
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              tournament['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Information rows with labels
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Starts: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      tournament['dateStart'],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                 Row(
                                  children: [
                                    Text(
                                      'Duration: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      tournament['duration'],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Players: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      tournament['players'],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Score: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      tournament['score'],
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Rank: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      rank['name'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: rank['color'],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Location tag
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tournament['location'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Visibility tag
              Positioned(
                right: 8,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: tournament['visibility'] == 'PUBLIC' ||
                              tournament['visibility'] == 'TEAM_PUBLIC'
                          ? Colors.green
                          : Colors.red,
                      width: 1.3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tournament['visibility'] == 'PUBLIC' ||
                            tournament['visibility'] == 'TEAM_PUBLIC'
                        ? 'Public'
                        : 'Private',
                    style: TextStyle(
                      color: tournament['visibility'] == 'PUBLIC' ||
                              tournament['visibility'] == 'TEAM_PUBLIC'
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Join type and sport icon
              Positioned(
                right: 8,
                bottom: 8,
                child: Row(
                  children: [
                    Text(
                      tournament['visibility'] == 'PUBLIC' ||
                              tournament['visibility'] == 'PRIVATE'
                          ? 'Individual Join'
                          : 'Team Join',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      sportIcon,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}