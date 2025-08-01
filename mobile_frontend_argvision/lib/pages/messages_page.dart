import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;

  const _HeaderIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.white,
      child: Icon(icon, size: 18, color: Color(0xFF007AFF)),
    );
  }
}


class _MessagesPageState extends State<MessagesPage> {
  String _selectedType = 'All';
  final TextEditingController _searchController = TextEditingController();

  bool _isChatOpen = false;
  Map<String, String>? _activeItem;
  final TextEditingController _chatController = TextEditingController();

  // Example messages for each type/name
  final Map<String, List<_ChatMessage>> _exampleConversations = {
    'Lionel Messi': [
      _ChatMessage(text: 'Hey Lionel, great match last night!', isUser: true),
      _ChatMessage(text: 'Thanks! Appreciate your support.', isUser: false),
    ],
    'FC Barcelona': [
      _ChatMessage(text: 'How is the team preparing for the final?', isUser: true),
      _ChatMessage(text: 'Were training hard and focused.', isUser: false),
    ],
    'Champions League Final': [
      _ChatMessage(text: 'Can you share highlights of the final?', isUser: true),
      _ChatMessage(text: 'Sure, check out the goal by Dembele at 67\' minute.', isUser: false),
    ],
    'Cristiano Ronaldo': [
      _ChatMessage(text: 'Congrats on the hat-trick!', isUser: true),
      _ChatMessage(text: 'Thank you, means a lot!', isUser: false),
    ],
  };

  final List<Map<String, String>> _items = [
    {
      'type': 'Player',
      'name': 'Lionel Messi',
      'image': 'assets/images/userplaceholder.jpg',
    },
    {
      'type': 'Team',
      'name': 'FC Barcelona',
      'image': 'assets/images/userplaceholder.jpg',
    },
    {
      'type': 'Match',
      'name': 'Champions League Final',
      'image': 'assets/images/userplaceholder.jpg',
    },
    {
      'type': 'Player',
      'name': 'Cristiano Ronaldo',
      'image': 'assets/images/userplaceholder.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems =
        _selectedType == 'All'
            ? _items
            : _items.where((item) => item['type'] == _selectedType).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
if (!_isChatOpen) ...[
  const SizedBox(height: 12),
  _buildTopRow(),
  const SizedBox(height: 12),
],

            Expanded(
              child: _isChatOpen ? _buildChatArea() : _buildList(filteredItems),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, String>> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _activeItem = item;
              _isChatOpen = true;
            });
          },
          child: _buildCard(item),
        );
      },
    );
  }

  

 Widget _buildChatArea() {
  final name = _activeItem!['name']!;
  final conversation = _exampleConversations[name] ?? [];

  return Container(
    color: const Color(0xFFF1F8FC), // Light chat background
    child: Column(
      children: [
 // Chat header
Container(
  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
  decoration: const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF0095FF), Color(0xFF03558F)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
  ),
  child: Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          setState(() {
            _isChatOpen = false;
            _chatController.clear();
          });
        },
      ),
      CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 18,
          backgroundImage: AssetImage(_activeItem!['image']!),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          _activeItem!['name']!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      Row(
        children: const [
          _HeaderIcon(icon: Icons.videocam_outlined),
          SizedBox(width: 8),
          _HeaderIcon(icon: Icons.call_outlined),
          SizedBox(width: 8),
          Icon(Icons.more_vert, color: Colors.white),
        ],
      ),
    ],
  ),
),



        // Messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: conversation.length,
            itemBuilder: (context, index) {
              final msg = conversation[index];
              final isUser = msg.isUser;

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isUser)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage(_activeItem!['image']!),
                        ),
                      ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.white : const Color.fromARGB(125, 2, 112, 190),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: isUser ? Colors.black : Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    if (isUser)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage(_activeItem!['image']!),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        // Input area
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: const InputDecoration(
                            hintText: 'Write a message',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isEmpty) return;
                            setState(() {
                              _exampleConversations[_activeItem!['name']!]!
                                  .add(_ChatMessage(text: value, isUser: true));
                              _chatController.clear();
                            });
                          },
                        ),
                      ),
                      const Icon(Icons.mic_none, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Icon(Icons.attach_file, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final text = _chatController.text.trim();
                  if (text.isEmpty) return;
                  setState(() {
                    _exampleConversations[_activeItem!['name']!]!
                        .add(_ChatMessage(text: text, isUser: true));
                    _chatController.clear();
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0270BE),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  // Card builder for each item in the list
Widget _buildCard(Map<String, String> item) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        // Avatar with green online dot
        Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: AssetImage(item['image']!),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Name and last message
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['type']!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Time
        const Text(
          '21:35',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}


  Widget _buildTopRow() {
  final tabs = ['All', 'Player','Group','Team', 'Match'];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔍 Search + Add Button Row
        Row(
          children: [
            Expanded(
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: '',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.edit, size: 20),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 📁 Tabs
        Row(
          children: tabs.map((tab) {
            final isSelected = _selectedType == tab;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = tab;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey[300] : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tab,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
