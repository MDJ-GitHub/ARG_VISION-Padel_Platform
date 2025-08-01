import 'package:flutter/material.dart';

class Player {
  final String name;
  final int age;
  final List<String> interests;
  final String imageUrl;

  Player({
    required this.name,
    required this.age,
    required this.interests,
    required this.imageUrl,
  });
}

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {
  final List<Player> _players = [
    Player(
      name: 'Noamen Ben Makhlouf',
      age: 30,
      interests: ['FootBall', 'Padel', 'VolleyBall'],
      imageUrl: 'assets/images/placeholderpicture.webp',
    ),
    Player(
      name: 'Amina Selmi',
      age: 27,
      interests: ['Tennis', 'Yoga', 'Running'],
      imageUrl: 'assets/images/placeholderpicture.webp',
    ),
    Player(
      name: 'Karim Haddad',
      age: 25,
      interests: ['Basketball', 'Gaming', 'Cycling'],
      imageUrl: 'assets/images/placeholderpicture.webp',
    ),
  ];

  // keeps history for undo
  final List<Player> _removed = [];

  // for current drag
  Offset _cardOffset = Offset.zero;
  double _cardRotation = 0.0;

  Player? get _topPlayer => _players.isNotEmpty ? _players.last : null;

  void _onPanStart(DragStartDetails d) {
    setState(() {
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _cardOffset += d.delta;
      _cardRotation = _cardOffset.dx / 300; // subtle rotation
    });
  }

  void _onPanEnd(DragEndDetails d) {
    setState(() {
    });

    const threshold = 100;
    if (_cardOffset.dx > threshold) {
      _swipeRight();
    } else if (_cardOffset.dx < -threshold) {
      _swipeLeft();
    } else {
      setState(() {
        _cardOffset = Offset.zero;
        _cardRotation = 0;
      });
    }
  }

  void _swipeRight() {
    if (_topPlayer == null) return;
    setState(() {
      _removed.add(_topPlayer!);
      _players.removeLast();
      _cardOffset = Offset.zero;
      _cardRotation = 0;
    });
    // like logic
  }

  void _swipeLeft() {
    if (_topPlayer == null) return;
    setState(() {
      _removed.add(_topPlayer!);
      _players.removeLast();
      _cardOffset = Offset.zero;
      _cardRotation = 0;
    });
    // reject logic
  }

  void _undo() {
    if (_removed.isEmpty) return;
    setState(() {
      _players.add(_removed.removeLast());
    });
  }

  Widget _buildSquareIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 24, color: Colors.black54),
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, Color bg, VoidCallback onTap, {double size = 50}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.55),
      ),
    );
  }

  Widget _buildCard(Player player, {bool isTop = false}) {
    final offset = isTop ? _cardOffset : Offset.zero;
    final rotation = isTop ? _cardRotation : 0.0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: Transform.translate(
        offset: offset,
        child: Transform.rotate(
          angle: rotation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(player.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // bottom overlay with gradient, text, then four action buttons
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(150, 0, 149, 255),
                          Color(0xFF03558F),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // name and age
                        Text(
                          '${player.name}, ${player.age}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Vous avez les mêmes intérêts:\n${player.interests.join(', ')} ...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // four action buttons under text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCircleAction(Icons.rotate_left, const Color(0xFFFFD369), _undo, size: 44),
                            _buildCircleAction(Icons.close, const Color(0xFFFE6B6B), _swipeLeft, size: 44),
                            _buildCircleAction(Icons.favorite, const Color(0xFF57D9A3), _swipeRight, size: 44),
                            _buildCircleAction(Icons.star, const Color(0xFF8AA7FF), () {
                              // super like or special action
                            }, size: 44),
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
      ),
    );
  }

  Widget _buildStackWithExternalButtons() {
    if (_players.isEmpty) {
      return const Center(
        child: Text(
          'Plus de joueurs',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      );
    }

    List<Widget> cards = [];
    for (int i = 0; i < _players.length; i++) {
      final isTop = i == _players.length - 1;
      Widget cardWidget = isTop
          ? GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: _buildCard(_players[i], isTop: true),
            )
          : _buildCard(_players[i]);

      cards.add(Positioned.fill(child: cardWidget));
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ...cards,
        // exterior rounded square buttons above the card area
        Positioned(
          top: -4,
          left: 16,
          child: _buildSquareIconButton(Icons.person_outline, onTap: () {
            // profile action
          }),
        ),
        Positioned(
          top: -4,
          right: 16,
          child: _buildSquareIconButton(Icons.chat_bubble_outline, onTap: () {
            // chat action
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F7),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: _buildStackWithExternalButtons(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // external action row removed; actions live in card
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
