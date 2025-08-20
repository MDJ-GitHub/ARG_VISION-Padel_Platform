import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_frontend_argvision/services/storage_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  Map<String, dynamic>? _activeDiscussion;
  final TextEditingController _chatController = TextEditingController();

  final List<Map<String, dynamic>> _discussions = [
    // Static discussions with random IDs and types, filling missing attributes
    {
      'id': 1,
      'type': 'PLAYER',
      'name': 'Lionel Messi',
      'image': 'assets/images/userplaceholder.jpg',
    },
    {
      'id': 2,
      'type': 'TEAM',
      'name': 'FC Barcelona',
      'image': 'assets/images/userplaceholder.jpg',
    },
    {
      'id': 3,
      'type': 'MATCH',
      'name': 'Champions League Final',
      'image': 'assets/images/userplaceholder.jpg',
    },
    {
      'id': 4,
      'type': 'PLAYER',
      'name': 'Cristiano Ronaldo',
      'image': 'assets/images/userplaceholder.jpg',
    },
    {
      'id': 5,
      'type': 'GROUP',
      'name': 'Study Group',
      'image': 'assets/images/userplaceholder.jpg',
    },
  ];

  final Map<int, List<_ChatMessage>> _conversations = {}; // keyed by discussion id
  final Map<int, WebSocketChannel> _channels = {}; // keyed by discussion id

  @override
  void dispose() {
    _chatController.dispose();
    _searchController.dispose();
    _channels.forEach((key, channel) => channel.sink.close());
    super.dispose();
  }

void _connectToDiscussion(int discussionId) async {
  if (_channels[discussionId] != null) return;
  

  final token = await StorageService.read('access_token');
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:8000/ws/discussion/$discussionId/chat/?token=$token'),
  );

channel.stream.listen((data) async {
  final decoded = jsonDecode(data);
  if (decoded['type'] == 'chat_message') {
    final userDataJson = await StorageService.read("user_data");
    final username = jsonDecode(userDataJson!)['username'];

    if (decoded['sender'] != username) {
      setState(() {
        _conversations[discussionId] ??= [];
        _conversations[discussionId]!.add(
          _ChatMessage(text: decoded['message'], isUser: false),
        );
      });
    }
  }
});


  _channels[discussionId] = channel;
}



  void _sendMessage(String message) {
    if (_activeDiscussion == null) return;
    final discussionId = _activeDiscussion!['id'] as int;
    final channel = _channels[discussionId];
    if (channel != null && message.trim().isNotEmpty) {
      channel.sink.add(jsonEncode({'message': message}));
      setState(() {
        _conversations[discussionId] ??= [];
        _conversations[discussionId]!.add(
          _ChatMessage(text: message, isUser: true),
        );
        _chatController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDiscussions = _selectedType == 'All'
        ? _discussions
        : _discussions
            .where((d) => d['type']!.toString().toUpperCase() == _selectedType.toUpperCase())
            .toList();

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
              child: _isChatOpen
                  ? _buildChatArea()
                  : _buildList(filteredDiscussions),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _activeDiscussion = item;
              _isChatOpen = true;
              _connectToDiscussion(item['id']);
            });
          },
          child: _buildCard(item),
        );
      },
    );
  }

  Widget _buildChatArea() {
    final discussionId = _activeDiscussion!['id'] as int;
    final conversation = _conversations[discussionId] ?? [];

    return Container(
      color: const Color(0xFFF1F8FC),
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
                    backgroundImage: AssetImage(_activeDiscussion!['image']),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _activeDiscussion!['name'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
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
                            backgroundImage:
                                AssetImage(_activeDiscussion!['image']),
                          ),
                        ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.white
                                : const Color.fromARGB(125, 2, 112, 190),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                                color: isUser ? Colors.black : Colors.black,
                                fontSize: 15),
                          ),
                        ),
                      ),
                      if (isUser)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                AssetImage(_activeDiscussion!['image']),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Input
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
                            onSubmitted: _sendMessage,
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
                  onTap: () => _sendMessage(_chatController.text),
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

  Widget _buildCard(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(item['image']),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['type'],
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
    final tabs = ['All', 'Player', 'Group', 'Team', 'Match'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
