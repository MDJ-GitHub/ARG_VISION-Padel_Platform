from django.utils import timezone
from rest_framework import serializers

from accounts.models import User

from .models import Discussion, Game, Match, MatchMembership, Message, Ranking, Team, TeamMembership
from accounts.serializers import UserSerializer

class GameSerializer(serializers.ModelSerializer):
    class Meta:
        model = Game
        fields = '__all__'
        read_only_fields = ['id']
        extra_kwargs = {
            'picture': {'required': False},
            'base_points': {'min_value': 0}
        }

    def validate(self, data):
        # Add any custom validation logic here
        request = self.context.get('request')
        
        # Example: Prevent changing game type if matches exist
        if self.instance and 'game_type' in data:
            if self.instance.match_set.exists():
                raise serializers.ValidationError(
                    "Cannot change game type when matches exist"
                )
        
        return data

class MatchSerializer(serializers.ModelSerializer):
    class Meta:
        model = Match
        fields = '__all__'
        read_only_fields = ['id', 'date_created', 'date_changed']
        extra_kwargs = {
            'date_start': {'required': False},
            'duration': {'required': False}
        }

    def validate(self, data):
        request = self.context.get('request')
        instance = getattr(self, 'instance', None)
        
        # Create/Update validations
        if request and request.method in ['POST', 'PUT', 'PATCH']:
            # Date validation
            if 'date_start' in data and data['date_start'] < timezone.now():
                raise serializers.ValidationError("Match cannot be scheduled in the past")
            
            # Completed match protection
            if instance and instance.status == 'completed':
                protected_fields = ['date_start', 'duration', 'terrain']
                if any(field in data for field in protected_fields):
                    raise serializers.ValidationError("Cannot modify completed matches")
                
            # Archive validation
            if 'archived' in data and instance:
                if instance.status == 'in_progress' and data['archived']:
                    raise serializers.ValidationError("Cannot archive a match in progress")
        
        return data
    
class MatchMembershipSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    match_id = serializers.IntegerField(write_only=True, required=False)
    user_id = serializers.IntegerField(write_only=True, required=False)
    
    class Meta:
        model = MatchMembership
        fields = [
            'id', 'user', 'user_id', 'match_id', 'match', 
            'date_joined', 'date_invited', 'status', 'archived', 'side'
        ]
        read_only_fields = [
            'id', 'user', 'match', 'date_joined', 
            'date_invited', 'archived'
        ]
        extra_kwargs = {
            'status': {'required': False}
        }

    def validate(self, data):
        # Get the current instance if it exists
        instance = getattr(self, 'instance', None)
        
        # Prevent modifying archived memberships
        if instance and instance.archived:
            raise serializers.ValidationError("Cannot modify archived membership.")
        
        # Add any additional validation here
        return data
    
class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)
    
    class Meta:
        model = Message
        fields = ['id', 'sender', 'content', 'timestamp']
        read_only_fields = ['sender', 'timestamp']

# serializers.py
class TeamMembershipSerializer(serializers.ModelSerializer):
    user_id = serializers.IntegerField(source='user.id', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.CharField(source='user.email', read_only=True)
    team_id = serializers.IntegerField(source='team.id', read_only=True)
    team_name = serializers.CharField(source='team.title', read_only=True)

    class Meta:
        model = TeamMembership
        fields = [
            'id', 'user_id', 'username', 'email',
            'team_id', 'team_name', 'date_joined', 'status'
        ]
        read_only_fields = ['id', 'date_joined']

class TeamSerializer(serializers.ModelSerializer):
    members = TeamMembershipSerializer(
        source='teammembership_set',
        many=True,
        read_only=True
    )
    is_admin = serializers.SerializerMethodField()

    class Meta:
        model = Team
        fields = [
            'id', 'title', 'slogan', 'picture', 'date_creation',
            'game', 'rank', 'score', 'archived', 'created_by',
            'members', 'is_admin'
        ]
        read_only_fields = ['id', 'date_creation', 'created_by', 'members']

    def get_is_admin(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.teammembership_set.filter(
                user=request.user,
                status='admin'
            ).exists()
        return False

class RankingSerializer(serializers.ModelSerializer):
    rank_display = serializers.CharField(source='get_rank_display', read_only=True)
    level_display = serializers.CharField(source='get_level_display', read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    team_name = serializers.CharField(source='team.title', read_only=True, allow_null=True)
    game_display = serializers.SerializerMethodField()

    class Meta:
        model = Ranking
        fields = [
            'id', 'user', 'username', 'game', 'game_display', 'score',
            'level', 'level_display', 'rank', 'rank_display',
            'team', 'team_name', 'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'created_at', 'updated_at', 'rank_display',
            'level_display', 'username', 'team_name', 'game_display'
        ]

    def get_game_display(self, obj):
        return dict(Game.GAME_TYPES).get(obj.game, obj.game)

    def validate(self, data):
        # Ensure team's game matches ranking game if team is specified
        if data.get('team'):
            if data['team'].game != data.get('game', self.instance.game if self.instance else None):
                raise serializers.ValidationError(
                    "Team game must match ranking game"
                )
        return data
    

    from rest_framework import serializers

class DiscussionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Discussion
        fields = '__all__'
