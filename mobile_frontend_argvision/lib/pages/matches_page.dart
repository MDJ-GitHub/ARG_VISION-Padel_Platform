import 'package:flutter/material.dart';
import 'package:mobile_frontend_argvision/services/organizations_services.dart';


class MatchesPage extends StatefulWidget {

  
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0; // 0 for Single Matches, 1 for Team Matches
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
  final List<Map<String, dynamic>> hardcodedSingleMatches = [
    {
      'image':
          'https://th.bing.com/th/id/OIP.G7cnU7VEhC2c_u5bFyoekQHaE8?rs=1&pid=ImgDetMain',
      'name': 'Summer Tournament',
      'dateCreated': '2023-06-15',
      'dateStart': '2023-06-20',
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
      'dateCreated': '2023-06-15',
      'dateStart': '2023-06-20',
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
      'dateCreated': '2023-06-15',
      'dateStart': '2023-06-20',
      'duration': '2 hours',
      'players': '1/2',
      'score': '1800',
      'location': 'City Stadium',
      'sport': 'soccer',
      'visibility': 'PUBLIC',
      'rank': 3,
    },
  ];

  final List<Map<String, dynamic>> hardcodedTeamMatches = [
    {
      'image':
          'https://thumbs.dreamstime.com/b/empty-soccer-stadium-fresh-green-grass-blue-sky-football-terrain-empty-soccer-stadium-fresh-green-grass-299806360.jpg',
      'name': 'Team Spring League',
      'dateCreated': '2023-05-10',
      'dateStart': '2023-05-15',
      'duration': '3 hours',
      'players': '9/12',
      'score': '3200',
      'location': 'City Stadium',
      'sport': 'soccer',
      'isPublic': true,
    },
    {
      'image':
          'https://th.bing.com/th/id/OIP.G7cnU7VEhC2c_u5bFyoekQHaE8?rs=1&pid=ImgDetMain',
      'name': '5v5 Championship',
      'dateCreated': '2023-04-22',
      'dateStart': '2023-04-30',
      'duration': '4 hours',
      'players': '8/10',
      'score': '2500',
      'location': 'Riverside Field',
      'sport': 'football',
      'isPublic': false,
    },
    {
      'image':
          'https://th.bing.com/th/id/OIP.Ocv__uJO2g1ow_lzdecvowHaE8?rs=1&pid=ImgDetMain',
      'name': '3v3 Tournament',
      'dateCreated': '2023-06-01',
      'dateStart': '2023-06-10',
      'duration': '2.5 hours',
      'players': '5/6',
      'score': '1900',
      'location': 'Community Center',
      'sport': 'basketball',
      'isPublic': true,
    },
  ];

  // Combined lists that will contain both hardcoded and API matches
  List<Map<String, dynamic>> singleMatches = [];
  List<Map<String, dynamic>> teamMatches = [];

  @override
  void initState() {
    super.initState();
    singleMatches = List.from(hardcodedSingleMatches);
    teamMatches = List.from(hardcodedTeamMatches);
    _fetchApiMatches();
  }

  Future<void> _fetchApiMatches() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiMatches = await OrganizationsServices.fetchPublicMatches();

      // Transform API data to match your format
      final transformedMatches =
          apiMatches.map((match) {
            return {
              'image':
                  match['picture'] ??
                  'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
              'name': match['name'] ?? 'Unnamed Match',
              'dateCreated': match['date_created']?.split('T')[0] ?? 'Unknown',
              'dateStart':
                  match['date_start']?.split('T')[0] ?? 'Not scheduled',
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
        singleMatches.addAll(transformedMatches);
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
  toolbarHeight: 125,
  automaticallyImplyLeading: false,
  actions: [SizedBox()], // 👈 prevent default endDrawer icon
  flexibleSpace: PreferredSize(
    preferredSize: const Size.fromHeight(125),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11),
          child: _buildSearchRow(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildButtonBar(),
        ),
      ],
    ),
  ),
),

          ];
        },
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                  padding: const EdgeInsets.only(top: 3.0),
                  itemCount:
                      _selectedIndex == 0
                          ? singleMatches.length
                          : teamMatches.length,
                  itemBuilder:
                      (context, index) => _buildCardItem(
                        _selectedIndex == 0
                            ? singleMatches[index]
                            : teamMatches[index],
                      ),
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
                        color:
                            _selectedSport == sport['value']
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        sport['icon'],
                        color:
                            _selectedSport == sport['value']
                                ? Colors.blue
                                : Colors.grey,
                      ),
                    ),
                    title: Text(
                      sport['name'],
                      style: TextStyle(
                        fontWeight:
                            _selectedSport == sport['value']
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
          Row(
            children: [
              _buildButtonItem(0, Icons.person, 'Single Matches'),
              _buildButtonItem(1, Icons.people, 'Team Matches'),
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
                    color:
                        _selectedIndex == 0 ? Colors.blue : Colors.transparent,
                  ),
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4,
                    color:
                        _selectedIndex == 1 ? Colors.blue : Colors.transparent,
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
                size: 25,
                color: _selectedIndex == index ? Colors.blue : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _selectedIndex == index ? Colors.blue : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    final currentSport =
        sports.firstWhere(
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
                  color: const Color.fromARGB(
                    255,
                    180,
                    180,
                    180,
                  ).withOpacity(0.3),
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
                setState(() {
                });
                _scaffoldKey.currentState?.openEndDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16, top: 6),
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
                              vertical: 6,
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Date information
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Padding(padding: EdgeInsets.only(left: 6)),
                              const Icon(Icons.event, size: 14),
                              const SizedBox(width: 4),
                              Text('${tournament['dateStart']}'),
                            ],
                          ),
                          const SizedBox(height: 2),
                          // Players and score
                          Row(
                            children: [
                              const Padding(padding: EdgeInsets.only(left: 6)),
                              const Icon(Icons.people, size: 14),
                              const SizedBox(width: 4),
                              Text(tournament['players']),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Padding(padding: EdgeInsets.only(left: 6)),
                              const Icon(Icons.star, size: 14),
                              const SizedBox(width: 4),
                              Text(tournament['score']),
                            ],
                          ),
                          const SizedBox(height: 2),
                          // Rank display
                          Row(
                            children: [
                              const Padding(padding: EdgeInsets.only(left: 6)),
                              Icon(
                                Icons.emoji_events,
                                size: 14,
                                color: rank['color'],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rank['name'],
                                style: TextStyle(
                                  color: rank['color'],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ).withOpacity(0.5),
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
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color:
                          tournament['visibility'] == 'PUBLIC' ||
                                  tournament['visibility'] == 'TEAM_PUBLIC'
                              ? Colors.green
                              : Colors.red,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tournament['visibility'] == 'PUBLIC' ||
                            tournament['visibility'] == 'TEAM_PUBLIC'
                        ? 'Public'
                        : 'Private',
                    style: TextStyle(
                      color:
                          tournament['visibility'] == 'PUBLIC' ||
                                  tournament['visibility'] == 'TEAM_PUBLIC'
                              ? Colors.green
                              : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Sport icon
              Positioned(
                right: 8,
                bottom: 14,
                child: Icon(
                  sportIcon,
                  size: 30,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              // Player count icon
              Positioned(
                right: 8,
                bottom: 45,
                child: Icon(
                  tournament['visibility'] == 'PUBLIC' ||
                          tournament['visibility'] == 'PRIVATE'
                      ? Icons.person
                      : Icons.people,
                  size: 30,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
