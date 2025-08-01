import 'package:flutter/material.dart';
import 'package:mobile_frontend_argvision/services/organizations_services.dart';

class TournamentsPage extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const TournamentsPage({super.key, required this.currentIndex, required this.onTap});

  @override
  State<TournamentsPage> createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedSport = 'soccer';
  IconData _selectedSportIcon = Icons.sports_soccer;
  bool _isLoading = false;
  String statusFilter = 'AVAILABLE';

  final List<Map<String, dynamic>> sports = [
    {'name': 'Soccer', 'icon': Icons.sports_soccer, 'value': 'soccer'},
    {'name': 'Basketball', 'icon': Icons.sports_basketball, 'value': 'basketball'},
    {'name': 'Football', 'icon': Icons.sports_football, 'value': 'football'},
    {'name': 'Tennis', 'icon': Icons.sports_tennis, 'value': 'tennis'},
    {'name': 'Baseball', 'icon': Icons.sports_baseball, 'value': 'baseball'},
    {'name': 'Volleyball', 'icon': Icons.sports_volleyball, 'value': 'volleyball'},
    {'name': 'Golf', 'icon': Icons.sports_golf, 'value': 'golf'},
    {'name': 'Martial Arts', 'icon': Icons.sports_martial_arts, 'value': 'martial_arts'},
  ];

  final List<Map<String, dynamic>> tournaments = [
    {
      'image': 'https://thumbs.dreamstime.com/b/empty-soccer-stadium-fresh-green-grass-blue-sky-football-terrain-empty-soccer-stadium-fresh-green-grass-299806360.jpg',
      'name': 'Annual Championship',
      'dateCreated': '2023-05-10 18:00',
      'dateStart': '2023-05-15 18:00',
      'duration': '3 days',
      'players': '32/64',
      'score': '5000',
      'location': 'National Stadium',
      'sport': 'soccer',
      'visibility': 'TEAM_PUBLIC',
      'status': 'AVAILABLE',
    },
    {
      'image': 'https://example.com/ongoing.jpg',
      'name': 'Spring Cup',
      'dateCreated': '2023-07-01 18:00',
      'dateStart': '2023-07-05 18:00',
      'duration': '5 days',
      'players': '10/16',
      'score': '3200',
      'location': 'Arena Field',
      'sport': 'football',
      'visibility': 'TEAM_PUBLIC',
      'status': 'RUNNING',
    },
    {
      'image': 'https://example.com/finished.jpg',
      'name': 'Fall Showdown',
      'dateCreated': '2022-09-10 18:00',
      'dateStart': '2022-09-15 18:00',
      'duration': '3 days',
      'players': '16/16',
      'score': '4500',
      'location': 'Old Stadium',
      'sport': 'tennis',
      'visibility': 'PUBLIC',
      'status': 'FINISHED',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchApiMatches();
  }

  Future<void> _fetchApiMatches() async {
    setState(() => _isLoading = true);
    try {
      final apiMatches = await OrganizationsServices.fetchPublicMatches();
      final transformed = apiMatches.map((match) {
        return {
          'image': match['picture'] ?? 'assets/images/placeholderpicture.webp',
          'name': match['name'] ?? 'Unnamed Match',
          'dateCreated': match['date_created']?.split('T')[0] ?? 'Unknown',
          'dateStart': match['date_start']?.split('T')[0] ?? 'Not scheduled',
          'duration': match['duration']?.toString() ?? 'Not specified',
          'players': '0/${match['max_participants'] ?? 2}',
          'score': '1500',
          'location': match['terrain'] ?? 'Online',
          'sport': _mapGameIdToSport(match['game']),
          'visibility': match['visibility'] ?? 'PUBLIC',
          'rank': match['rank'] ?? 0,
          'cost': match['cost']?.toString() ?? '0',
          'status': 'disponible', // You can adjust logic if needed
        };
      }).toList();
      setState(() => tournaments.addAll(transformed));
    } catch (e) {
      print('Error fetching matches: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _mapGameIdToSport(int? gameId) {
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
    final filteredTournaments = tournaments
        .where((t) => t['status'] == statusFilter)
        .toList();

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildSportsSidebar(),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 0,
            toolbarHeight: 55,
            automaticallyImplyLeading: false,
            actions: [const SizedBox()],
            flexibleSpace: PreferredSize(
              preferredSize: const Size.fromHeight(55),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: _buildSearchRow(),
              ),
            ),
          ),
        ],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                          _buildSectionHeader('Our Tournaments', context),
                
                    const SizedBox(height: 20),
                  _buildStatusFilterBar(),
                     const SizedBox(height: 12),
                    GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredTournaments.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.5,
                      ),
                      itemBuilder: (ctx, i) => _buildCardItem(filteredTournaments[i]),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusFilterBar() {
  final labelMap = {
    'AVAILABLE': 'Available',
    'RUNNING': 'Running',
    'FINISHED': 'Finished',
  };

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12.0),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        gradient: const LinearGradient(
          colors: [Color(0xFF03558F), Color(0xFF2D94ED)],
        ),
      ),
      child: Row(
        children: ['AVAILABLE', 'RUNNING', 'FINISHED'].map((status) {
          final count = tournaments.where((t) => t['status'] == status).length;
          final isSelected = status == statusFilter;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  statusFilter = status;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                    
                      Text(
                        labelMap[status]!,
                        style: TextStyle(
                          color: isSelected ? Colors.black87 : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                        const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF036FBD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}





  Widget _buildCardItem(Map<String, dynamic> match) {
    final now = DateTime.now();
    // Parse the date and format as "samedi 21 nov 2025"
    final sstartDate = DateTime.parse(match['dateStart']);
    final List<String> frenchWeekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final List<String> frenchMonths = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    String matchDate =
        '${frenchWeekdays[sstartDate.weekday % 7]} '
        '${sstartDate.day.toString().padLeft(2, '0')} '
        '${frenchMonths[sstartDate.month - 1]} '
        '${sstartDate.year}';
    final daysDiff = sstartDate.difference(now).inDays;

    final matchTime =
        match['dateStart'] != null && match['dateStart'].contains(' ')
            ? match['dateStart'].split(' ')[1].substring(0, 5)
            : '21:00';

    final joinText =
        (match['visibility'] ?? '').contains('TEAM')
            ? 'Join \n with Teams'
            : 'Join \n Individually';

    final maxPlayers = int.parse(match['players'].split('/')[1]);
    final joined = int.parse(match['players'].split('/')[0]);
    final teamCount = (maxPlayers / 2).floor();
    final teamFormat = '$teamCount vs $teamCount';

    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Background
            Image.network(
              match['image'],
              width: double.infinity,
              height: MediaQuery.of(context).size.width * 0.6,
              fit: BoxFit.cover,
            ),

            // Gradient
            Container(
              height: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF646464).withOpacity(0.4),
                    Color(0xFF2A2A2A).withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Top Left: Time & Date
            Positioned(
              top: 12,
              left: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        matchTime,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    matchDate,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),

            // Top Right: "7 vs 7"
            Positioned(
              top: 12,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  teamFormat,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Max remplaçants
            Positioned(
              top: 85,
              right: 12,
              child: const Text(
                'Max 3 remplacement',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),

            // Public
            Positioned(
              top: 110,
              left: 12,
              child: Row(
                children: const [
                  Icon(Icons.circle, color: Colors.green, size: 12),
                  SizedBox(width: 6),
                  Text(
                    'Public',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

           // Bottom White Section
Positioned(
  bottom: 0,
  child: Container(
    width: MediaQueryData.fromView(
      WidgetsBinding.instance.window,
    ).size.width - 32,
    padding: const EdgeInsets.symmetric(
      vertical: 10,
      horizontal: 12,
    ),
    color: Colors.white,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3, // more space for this column
              child: _infoBlock(
                'assets/images/icon_calendar.png',
                'In $daysDiff Days',
              ),
            ),
            Expanded(
              flex: 2,
              child: _infoBlock(
                'assets/images/icon_trophy.png',
                (match['cost'] != null && match['cost'].toString() != '0')
                    ? 'Pay'
                    : 'Free',
              ),
            ),
            Expanded(
              flex: 2,
              child: _infoBlock(
                'assets/images/icon_medal.png',
                match['score']?.toString() ?? 'Rank',
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
Expanded(
  flex: 3,
  child: _infoBlock(
    'assets/images/icon_shield.png',
    '$joined/$maxPlayers players',
    highlight: true,
  ),
),

            Expanded(
              flex: 2,
              child: _infoBlock(
                'assets/images/icon_cash.png',
                '${match['cost'] ?? '---'}DT',
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    joinText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
      ),
    );
  }

Widget _infoBlock(String icon, String text, {bool highlight = false}) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(icon, width: 32, height: 32),
        const SizedBox(width: 6),
        Flexible(
          child: highlight
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: text.contains('/') && text.split('/')[0] != text.split('/')[1]
                        ? const Color.fromARGB(64, 35, 234, 0)
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ],
    ),
  );
}



  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      child: Container(
        color: Colors.transparent, // Transparent background
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20, // Bigger font
                fontWeight: FontWeight.bold,
                color: Colors.black, // Black text
              ),
            ),
            GestureDetector(
              onTap: () => widget.onTap(5),
              child: const Row(
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 14, // Smaller font
                      color: Colors.blue, // Blue text
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 18, color: Colors.blue),
                ],
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
                    leading: CircleAvatar(
                      backgroundColor:
                          _selectedSport == sport['value']
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                      child: Icon(
                        sport['icon'],
                        color:
                            _selectedSport == sport['value']
                                ? Colors.blue
                                : Colors.grey,
                      ),
                    ),
                    title: Text(sport['name']),
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
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(
              158,
              158,
              158,
              0.6,
            ), // Colors.grey.withOpacity(0.6)
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(
                    0.25,
                  ), // Light gray border for inset feel
                  width: 2,
                ),
              ),
              child: Center(
                child: TextField(
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14), // Reduced font size
                  decoration: InputDecoration(
                    hintText: 'Seatch matches, tournys, coachs, players...',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ), // Reduced hint font size
                    border: InputBorder.none,
                           contentPadding: const EdgeInsets.symmetric(vertical: 14),
             
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
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
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
                child: Center(
                  child: Icon(
                    _selectedSportIcon,
                    color: Colors.white,
                    size: 27,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
