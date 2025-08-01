import 'package:flutter/material.dart';

class RankingsPage extends StatefulWidget {
  const RankingsPage({super.key});

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  bool isIndividualSelected = true;
  String _selectedRank = 'Iron';

  final List<List<String>> _individualList = List.generate(
    10,
    (index) => ['I${index + 1}', '10', 'Nom ${index + 1}', '${80 + index}', index % 2 == 0 ? '✔' : '✖'],
  );

  final List<List<String>> _teamList = List.generate(
    10,
    (index) => ['T${index + 1}', '5', 'Équipe ${index + 1}', '${60 + index}', index % 2 == 0 ? '✔' : '✖'],
  );

  final List<String> _ranks = ['Iron', 'Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'];

  final Map<String, Color> _rankColors = {
    'Iron': Colors.grey,
    'Bronze': Color(0xFFCD7F32),
    'Silver': Colors.blueGrey,
    'Gold': Colors.amber,
    'Platinum': Color(0xFF00BFFF),
    'Diamond': Color(0xFF00CED1),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      drawer: _buildRankDrawer(),
      body: Builder(
        builder: (ctx) => Column(
          children: [
            _buildSearchBar(context),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: _buildRankTierButton(ctx),
              ),
            ),
            const SizedBox(height: 12),
            _buildTypeButtons(),
            const SizedBox(height: 0),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: _buildStyledTable(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF03558F), Color(0xFF2D94ED)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(158, 158, 158, 0.6),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.25),
                  width: 2,
                ),
              ),
              child: Center(
                child: TextField(
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Recherche matches, tournois, coach, joueurs...',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
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
            child: const Icon(Icons.sports_soccer, color: Colors.white, size: 27),
          ),
        ],
      ),
    );
  }

  Widget _buildRankTierButton(BuildContext ctx) {
    final rankColor = _rankColors[_selectedRank] ?? Colors.white;

    return InkWell(
      onTap: () => Scaffold.of(ctx).openDrawer(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shield, color: rankColor, size: 25),
          ),
          const SizedBox(width: 6),
          Text(
            _selectedRank,
            style: TextStyle(
              color: rankColor,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildRankDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const DrawerHeader(
            child: Center(
              child: Text(
                'Choose Rank',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          ..._ranks.map((rank) {
            final color = _rankColors[rank] ?? Colors.black;
            return ListTile(
              title: Text(rank, style: TextStyle(color: color)),
              leading: Icon(Icons.shield, color: color),
              onTap: () {
                setState(() => _selectedRank = rank);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTypeButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.6),
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF03558F), Color(0xFF0095FF)],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isIndividualSelected = true),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.emoji_events, color: Colors.white, size: 32),
                      SizedBox(width: 10),
                      Text(
                        'Individuel',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(width: 1, height: 70, color: Colors.grey),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isIndividualSelected = false),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.groups, color: Colors.white, size: 32),
                      SizedBox(width: 10),
                      Text(
                        'Team',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTable() {
    final rows = isIndividualSelected ? _individualList : _teamList;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: const LinearGradient(
          colors: [Color(0xFF03558F), Color(0xFF0095FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _topHeaderCell('I', isLeft: true),
              _topHeaderCell('II'),
              _topHeaderCell('III', isRight: true),
            ],
          ),
          Table(
            border: const TableBorder(
              verticalInside: BorderSide(color: Colors.white, width: 1),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(3),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 1),
                    bottom: BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                children: [
                  _subHeaderCell('CLS'),
                  _subHeaderCell('M.P'),
                  _subHeaderCell('Nom et prénom'),
                  _subHeaderCell('M.G'),
                  _subHeaderCell('P'),
                ],
              ),
              for (var row in rows)
                TableRow(
                  children: [
                    for (var cell in row) _tableCell(cell),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topHeaderCell(String title, {bool isLeft = false, bool isRight = false}) {
    return Expanded(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: const Border(
            right: BorderSide(color: Colors.white, width: 1),
            bottom: BorderSide(color: Colors.white, width: 1),
          ),
          borderRadius: BorderRadius.only(
            topLeft: isLeft ? const Radius.circular(20) : Radius.zero,
            topRight: isRight ? const Radius.circular(20) : Radius.zero,
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Times New Roman',
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _subHeaderCell(String text) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Container(
      height: 36,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
