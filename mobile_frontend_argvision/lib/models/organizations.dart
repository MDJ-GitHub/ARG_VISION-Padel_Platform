import 'package:mobile_frontend_argvision/models/zones.dart';

class Game {
  final int id;
  final String name;
  final String description;
  final String gameType;
  final String? picture;
  final int basePoints;
  final bool archived;

  Game({
    required this.id,
    required this.name,
    required this.description,
    required this.gameType,
    this.picture,
    required this.basePoints,
    required this.archived,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      gameType: json['game_type'],
      picture: json['picture'],
      basePoints: json['base_points'] ?? 1,
      archived: json['archived'] ?? false,
    );
  }
}


class Match {
  final String id;
  final String name;
  final String description;
  final String? game;
  final String status;
  final String visibility;
  final DateTime dateCreated;
  final DateTime dateModified;
  final DateTime? dateStart;
  final int reward;
  final int maxParticipants;
  final int winnerside;
  final Duration? duration;
  final String? picture;
  final bool archived;
  final Terrain? terrain;

  Match({
    required this.id,
    required this.name,
    required this.description,
    this.game,
    required this.status,
    required this.visibility,
    required this.dateCreated,
    required this.dateModified,
    this.dateStart,
    required this.reward,
    required this.maxParticipants,
    required this.winnerside,
    this.duration,
    this.picture,
    required this.archived,
    this.terrain,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      game: json['game'],
      status: json['status'],
      visibility: json['visibility'],
      dateCreated: DateTime.parse(json['date_created']),
      dateModified: DateTime.parse(json['date_modified']),
      dateStart: json['date_start'] != null ? DateTime.parse(json['date_start']) : null,
      reward: json['reward'] ?? 0,
      maxParticipants: json['max_participants'] ?? 2,
      winnerside: json['winnerside'] ?? 1,
      duration: json['duration'] != null ? Duration(seconds: json['duration']) : null,
      picture: json['picture'],
      archived: json['archived'] ?? false,
      terrain: json['terrain'],
    );
  }
}
class Message {
  final int id;
  final int matchId;
  final int senderId;
  final String content;
  final DateTime timestamp;
  final String messageType;
  final int? replyingToId;

  Message({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.messageType,
    this.replyingToId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      matchId: json['match'],
      senderId: json['sender'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      messageType: json['message_type'],
      replyingToId: json['replying_to'],
    );
  }
}

class Team {
  final int id;
  final String title;
  final String? slogan;
  final String? picture;
  final DateTime dateCreation;
  final DateTime dateModified;
  final Game? game;
  final int rank;
  final int score;
  final int level;
  final bool archived;

  Team({
    required this.id,
    required this.title,
    this.slogan,
    this.picture,
    required this.dateCreation,
    required this.dateModified,
    this.game,
    required this.rank,
    required this.score,
    required this.level,
    required this.archived,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      title: json['title'],
      slogan: json['slogan'],
      picture: json['picture'],
      dateCreation: DateTime.parse(json['date_creation']),
      dateModified: DateTime.parse(json['date_modified']),
      game: json['game'] != null ? Game.fromJson(json['game']) : null,
      rank: json['rank'] ?? 1,
      score: json['score'] ?? 0,
      level: json['level'] ?? 1,
      archived: json['archived'] ?? false,
    );
  }
}

class MatchMembership {
  final int id;
  final int userId;
  final int matchId;
  final DateTime dateJoined;
  final DateTime dateInvited;
  final String status;
  final int side;
  final bool archived;

  MatchMembership({
    required this.id,
    required this.userId,
    required this.matchId,
    required this.dateJoined,
    required this.dateInvited,
    required this.status,
    required this.side,
    required this.archived,
  });

  factory MatchMembership.fromJson(Map<String, dynamic> json) {
    return MatchMembership(
      id: json['id'],
      userId: json['user'],
      matchId: json['match'],
      dateJoined: DateTime.parse(json['date_joined']),
      dateInvited: DateTime.parse(json['date_invited']),
      status: json['status'],
      side: json['side'] ?? 0,
      archived: json['archived'] ?? false,
    );
  }
}

class TeamMembership {
  final int id;
  final int userId;
  final int teamId;
  final DateTime dateInvited;
  final DateTime dateJoined;
  final String status;
  final bool archived;

  TeamMembership({
    required this.id,
    required this.userId,
    required this.teamId,
    required this.dateInvited,
    required this.dateJoined,
    required this.status,
    required this.archived,
  });

  factory TeamMembership.fromJson(Map<String, dynamic> json) {
    return TeamMembership(
      id: json['id'],
      userId: json['user'],
      teamId: json['team'],
      dateInvited: DateTime.parse(json['date_invited']),
      dateJoined: DateTime.parse(json['date_joined']),
      status: json['status'],
      archived: json['archived'] ?? false,
    );
  }
}

class Ranking {
  final int id;
  final int userId;
  final int rank;
  final int level;
  final int score;
  final String type;
  final int? gameId;
  final int? teamId;
  final DateTime lastUpdated;

  Ranking({
    required this.id,
    required this.userId,
    required this.rank,
    required this.level,
    required this.score,
    required this.type,
    this.gameId,
    this.teamId,
    required this.lastUpdated,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      id: json['id'],
      userId: json['user'],
      rank: json['rank'] ?? 1,
      level: json['level'] ?? 1,
      score: json['score'] ?? 0,
      type: json['type'],
      gameId: json['game'],
      teamId: json['team'],
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}