from django.shortcuts import render

# Create your views here.

from django.utils import timezone
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from accounts import models
from organizations import serializers
from accounts.models import User
from notifications.utils import send_notification
from .models import Game, Match, Message, Ranking, Team, MatchMembership, TeamMembership, User
from .serializers import GameSerializer, MatchSerializer, MessageSerializer, RankingSerializer, TeamMembershipSerializer, TeamSerializer, MatchMembershipSerializer
from django.shortcuts import get_object_or_404
from rest_framework.views import APIView
from django.db import transaction

class GameListView(generics.ListAPIView):
    queryset = Game.objects.filter(archived=False)
    serializer_class = GameSerializer
    permission_classes = [permissions.IsAuthenticated]

class GameCreateView(generics.CreateAPIView):
    queryset = Game.objects.filter(archived=False)
    serializer_class = GameSerializer
    permission_classes = [permissions.IsAdminUser]

class GameRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Game.objects.all()
    serializer_class = GameSerializer
    permission_classes = [permissions.IsAdminUser]

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    def perform_destroy(self, instance):
        # Soft delete (archive) instead of actual deletion
        instance.archived = True
        instance.save()

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        self.perform_destroy(instance)
        return Response(
            {'detail': 'Game archived successfully'},
            status=status.HTTP_204_NO_CONTENT
        )
    
class GameArchivesView(generics.ListAPIView):
     queryset = Game.objects.filter(archived=True)        
     serializer_class = GameSerializer
     permission_classes = [permissions.IsAdminUser]


class MatchCreateView(generics.ListCreateAPIView):
    serializer_class = MatchSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    def perform_create(self, serializer):
        # Get invited user IDs from request data
        invited_user_ids = self.request.data.get('invited_users', [])
        
        # First save the match instance
        match = serializer.save(created_by=self.request.user)
        
        # Create admin membership for creator
        MatchMembership.objects.create(
            user=self.request.user,
            match=match,
            status='ADMIN',
            date_joined=timezone.now()
        )
        
        # Create ranking for creator if needed
        Ranking.objects.get_or_create(
            user=self.request.user,
            game=match.game,
            team=None,
            defaults={
                'score': 0,
                'level': 1,
                'rank': 1,
                'type': 'STANDARD'
            }
        )
        
        # If users were specified in the invitation list
        if invited_user_ids and isinstance(invited_user_ids, list):
            for user_id in invited_user_ids:
                try:
                    user = User.objects.get(id=user_id)
                    
                    # Check if user is already invited or in match
                    if not MatchMembership.objects.filter(user=user, match=match).exists():
                        MatchMembership.objects.create(
                            user=user,
                            match=match,
                            status='PENDING',
                            date_invited=timezone.now()
                        )
                        
                        # Send notification
                        send_notification(
                            user=user,
                            message=f"You've been invited to match '{match.name}'",
                            match=match,
                            notification_type='match_invite'
                        )
                except User.DoesNotExist:
                    continue  # Skip invalid user IDs
        
        # For public matches, notify all users
        if match.visibility == 'public':
            users = User.objects.exclude(id=self.request.user.id)
            for user in users:
                send_notification(
                    user=user,
                    message=f"A new public match '{match.name}' has been created.",
                    match=match,
                    notification_type='match_invite'
                )
                

    
class MatchListAllView(generics.ListAPIView):
    queryset = Match.objects.filter(archived=False)
    serializer_class = MatchSerializer
    permission_classes = [permissions.IsAdminUser]


class MatchListPublicView(generics.ListAPIView):
    serializer_class = MatchSerializer
    permission_classes = [permissions.AllowAny]
    
    def get_queryset(self):
        return Match.objects.filter(
            visibility='PUBLIC',
            archived=False,
            status__in=['UPCOMING', 'IN_PROGRESS']
        ).order_by('date_start')


class MatchRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Match.objects.all()
    serializer_class = MatchSerializer
    permission_classes = [permissions.IsAuthenticated]  # Changed from IsAdminUser

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    def check_object_permissions(self, request, obj):
        super().check_object_permissions(request, obj)
        
        # Check if user is admin of the match
        if not obj.matchmembership_set.filter(
            user=request.user,
            status='admin'
        ).exists():
            self.permission_denied(
                request,
                message="Only match admins can perform this action"
            )

    def perform_update(self, serializer):
        instance = serializer.instance
        
        # Prevent changing archived from True to False
        if 'archived' in serializer.validated_data:
            if instance.archived and not serializer.validated_data['archived']:
                raise serializers.ValidationError(
                    {"archived": "Cannot unarchive a match once archived"}
                )
        
        serializer.save()

    def perform_destroy(self, instance):
        instance.archived = True
        instance.save()

class MatchCompleteView(generics.UpdateAPIView):
    queryset = Match.objects.all()
    serializer_class = MatchSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['patch']

    def patch(self, request, *args, **kwargs):
        match = self.get_object()
        
        if match.status != 'IN_PROGRESS':
            return Response(
                {"detail": "Only matches in progress can be completed"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        winner_id = request.data.get('winner_id')
        if not winner_id:
            return Response(
                {"detail": "winner_id is required to complete a match"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        match.status = 'COMPLETED'
        match.save()
        
        return Response(
            {"detail": "Match marked as completed"},
            status=status.HTTP_200_OK
        )
    
class MessageListView(generics.ListCreateAPIView):
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        match_id = self.kwargs['match_id']
        return Message.objects.filter(
            match_id=match_id,
            match__players=self.request.user
        ).order_by('timestamp')

    def perform_create(self, serializer):
        match = get_object_or_404(Match, id=self.kwargs['match_id'])
        serializer.save(sender=self.request.user, match=match)
    
class MatchArchivesView(generics.ListAPIView):
     queryset = Match.objects.filter(archived=True)        
     serializer_class = MatchSerializer
     permission_classes = [permissions.IsAdminUser]


class BaseMembershipView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = MatchMembershipSerializer
    
    def check_admin_permission(self, match, user):
        """Check if user is admin of the match through MatchMembership"""
        return MatchMembership.objects.filter(
            match=match,
            user=user,
            status='ADMIN'
        ).exists()

    def check_member_permission(self, match, user):
        """Check if user is any type of member (admin or regular)"""
        return MatchMembership.objects.filter(
            match=match,
            user=user
        ).exclude(status='PENDING').exists()

    def get_membership(self, match, user):
        """Get the membership object if it exists"""
        try:
            return MatchMembership.objects.get(match=match, user=user)
        except MatchMembership.DoesNotExist:
            return None

class InvitePlayerView(BaseMembershipView):
    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        match = get_object_or_404(Match, id=serializer.validated_data['match_id'])
        user_to_invite = get_object_or_404(User, id=serializer.validated_data['user_id'])
        
        # Admin check
        if not self.check_admin_permission(match, request.user):
            return Response(
                {'error': 'Only match admins can invite players'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Check if membership already exists
        if MatchMembership.objects.filter(user=user_to_invite, match=match).exists():
            return Response(
                {'error': 'User already has a membership status for this match'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if membership.status == 'BANNED':
                return Response(
                    {"detail": "Cannot invite banned user"},
                    status=status.HTTP_400_BAD_REQUEST
                )
        if membership.status == 'LEFT':
                return Response(
                    {"detail": "Invitation resent successfully"},
        status=status.HTTP_200_OK
                )
        if membership.status == 'DENIED':
                return Response(
                    {"detail": "The user denied the invitation, it is now renewed successfully"},
            status=status.HTTP_200_OK
                )
        if membership.status != 'INVITED':
                return Response(
                    {"detail": "User already in team"},
                    status=status.HTTP_400_BAD_REQUEST
                )    
        
        membership = MatchMembership.objects.create(
            user=user_to_invite,
            match=match,
            status='INVITED'
        )

        Ranking.objects.get_or_create(
                user=user_to_invite,
                game=match.game,
                team=None,
                defaults={
                    'score': 0,
                    'level': 1,
                    'rank': 1,
                    'type': 'STANDARD'
            }
        )


        
        return Response(
            self.serializer_class(membership).data,
            status=status.HTTP_201_CREATED
        )

class AcceptInviteView(BaseMembershipView):
    def post(self, request, *args, **kwargs):
        # Get membership_id from URL kwargs
        membership_id = kwargs.get('pk')


        
        membership = get_object_or_404(
            MatchMembership,
            id=membership_id,
            user=request.user,
            status='INVITED'
        )
        
        membership.status = 'MEMBER'
        membership.save()
        
        return Response(
            self.serializer_class(membership).data,
            status=status.HTTP_200_OK
        )

class DenyInviteView(BaseMembershipView):
    def post(self, request, *args, **kwargs):
        # Get membership_id from URL kwargs
        membership_id = kwargs.get('pk')
        membership = get_object_or_404(
            MatchMembership,
            id=membership_id,
            user=request.user,
            status='INVITED'
        )
        
        membership.status = 'DENIED'
        membership.save()
        
        return Response(
            self.serializer_class(membership).data,
            status=status.HTTP_200_OK
        )

class KickPlayerView(BaseMembershipView):
    def post(self, request, *args, **kwargs):
        # Get membership_id from URL kwargs
        membership_id = kwargs.get('pk')
        membership = get_object_or_404(
            MatchMembership,
            id=membership_id
        )
        
        # Admin check
        if not self.check_admin_permission(membership.match, request.user):
            return Response(
                {'error': 'Only match admins can kick players'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Prevent self-kick
        if membership.user == request.user:
            return Response(
                {'error': 'Use the leave endpoint instead'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        membership.status = 'KICKED'
        membership.save()
        
        return Response(
            self.serializer_class(membership).data,
            status=status.HTTP_200_OK
        )

class BanPlayerView(BaseMembershipView):
    def post(self, request, *args, **kwargs):
        # Get membership_id from URL kwargs
        membership_id = kwargs.get('pk')
        membership = get_object_or_404(
            MatchMembership,
            id=membership_id
        )
        
        # Admin check
        if not self.check_admin_permission(membership.match, request.user):
            return Response(
                {'error': 'Only match admins can ban players'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Prevent self-ban
        if membership.user == request.user:
            return Response(
                {'error': 'Cannot ban yourself'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        membership.status = 'BANNED'
        membership.save()
        
        return Response(
            self.serializer_class(membership).data,
            status=status.HTTP_200_OK
        )

class LeaveMatchView(BaseMembershipView):
    def post(self, request, membership_id):
        membership = get_object_or_404(
            MatchMembership,
            id=membership_id,
            user=request.user,
            status__in=['MEMBER', 'ADMIN']
        )
        
        membership.status = 'LEFT'
        membership.save()
        
        return Response(
            self.serializer_class(membership).data,
            status=status.HTTP_200_OK
        )
    
class TeamCreateView(generics.CreateAPIView):
    serializer_class = TeamSerializer
    permission_classes = [permissions.IsAuthenticated]

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        # Create team
        team = serializer.save(created_by=request.user)
        
        # Make creator an admin
        TeamMembership.objects.create(
            user=request.user,
            team=team,
            status='admin'
        )
        
        # Process invitations if any
        user_ids = request.data.get('invite_users', [])
        for user_id in user_ids:
            user = get_object_or_404(User, id=user_id)
            TeamMembership.objects.create(
                user=user,
                team=team,
                status='INVITED'
            )
        
        headers = self.get_success_headers(serializer.data)
        return Response(
            serializer.data,
            status=status.HTTP_201_CREATED,
            headers=headers
        )

    
class BaseTeamMembershipView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = TeamMembershipSerializer
    
    def check_admin_permission(self, team, user):
        """Check if user is admin of the match through MatchMembership"""
        return TeamMembership.objects.filter(
            team=team,
            user=user,
            status='ADMIN'
        ).exists()

    def check_member_permission(self, team, user):
        """Check if user is any type of member (admin or regular)"""
        return MatchMembership.objects.filter(
            team=team,
            user=user
        ).exclude(status='INVITED').exists()

    def get_membership(self, team, user):
        """Get the membership object if it exists"""
        try:
            return TeamMembership.objects.get(team=team, user=user)
        except TeamMembership.DoesNotExist:
            return None
        
class AcceptTeamInviteView(BaseTeamMembershipView):
    def post(self, request, *args, **kwargs):
        # Get membership_id from URL kwargs
        membership_id = kwargs.get('pk')

        membership = get_object_or_404(
            TeamMembership,
            id=membership_id,
            user_id=request.user,
            status='INVITED'
        )

        membership.status = 'MEMBER'
        membership.save()
        
        return Response(
            self.serializer_class(membership).data,
            status=status.HTTP_200_OK
        )
    
class DenyTeamInviteView(BaseTeamMembershipView):
    def post(self, request, *args, **kwargs):
        # Get membership_id from URL kwargs
        membership_id = kwargs.get('pk')
        membership = get_object_or_404(
            TeamMembership,
            id=membership_id,
            user=request.user,
            status='INVITED'
        )
        
        membership.status = 'DENIED'
        membership.save()
        
        return Response(
            self.serializer_class(membership).data,
            status=status.HTTP_200_OK
        )

class KickTeamMemberView(BaseTeamMembershipView):
    def post(self, request, *args, **kwargs):
        # Get membership_id from URL kwargs
        membership_id = kwargs.get('pk')
        membership = get_object_or_404(
            TeamMembership,
            id=membership_id
        )
        
        # Admin check
        if not self.check_admin_permission(membership.match, request.user):
            return Response(
                {'error': 'Only team admins can kick members'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Prevent self-kick
        if membership.user == request.user:
            return Response(
                {'error': 'Use the leave endpoint instead'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        membership.status = 'KICKED'
        membership.save()
        
        return Response(
            self.serializer_class(membership).data,
            status=status.HTTP_200_OK
        )

class BanTeamMemberView(BaseTeamMembershipView):
    def post(self, request, *args, **kwargs):
        # Get membership_id from URL kwargs
        membership_id = kwargs.get('pk')
        membership = get_object_or_404(
            TeamMembership,
            id=membership_id
        )
        
        # Admin check
        if not self.check_admin_permission(membership.match, request.user):
            return Response(
                {'error': 'Only team admins can ban members'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Prevent self-ban
        if membership.user == request.user:
            return Response(
                {'error': 'Cannot ban yourself'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        membership.status = 'BANNED'
        membership.save()
        
        return Response(
            self.serializer_class(membership).data,
            status=status.HTTP_200_OK
        )

class LeaveTeamView(BaseTeamMembershipView):
    def post(self, request, membership_id):
        membership = get_object_or_404(
            TeamMembership,
            id=membership_id,
            user=request.user,
            status__in=['MEMBER', 'ADMIN']
        )
        
        membership.status = 'LEFT'
        membership.save()
        
        return Response(
            self.serializer_class(membership).data,
            status=status.HTTP_200_OK
        )
    

class TeamInviteView(generics.CreateAPIView):
    serializer_class = TeamSerializer
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        team = get_object_or_404(Team, id=serializer.validated_data['team_id'])
        user = get_object_or_404(User, id=serializer.validated_data['user_id'])

        # Check if inviter is admin
        if not TeamMembership.objects.filter(
            user=request.user,
            team=team,
            status='ADMIN'
        ).exists():
            return Response(
                {"detail": "Only team admins can invite users"},
                status=status.HTTP_403_FORBIDDEN
            )

        # Check if already has membership
        membership, created = TeamMembership.objects.get_or_create(
            user=user,
            team=team,
            defaults={'status': 'INVITED'}
        )

        if not created:
            if membership.status == 'BANNED':
                return Response(
                    {"detail": "Cannot invite banned user"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            if membership.status == 'LEFT':
                return Response(
                    {"detail": "Invitation resent successfully"},
            status=status.HTTP_200_OK
                )
            if membership.status == 'DENIED':
                return Response(
                    {"detail": "The user denied the invitation, it is now renewed successfully"},
            status=status.HTTP_200_OK
                )
            if membership.status != 'INVITED':
                return Response(
                    {"detail": "User already in team"},
                    status=status.HTTP_400_BAD_REQUEST
                )

        
        return Response(
            {"detail": "Invitation sent successfully"},
            status=status.HTTP_200_OK
        )

class TeamListCreateView(generics.ListCreateAPIView):
    serializer_class = TeamSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Team.objects.filter(
            archived=False,
            teammembership__user=self.request.user
        ).distinct()

    def perform_create(self, serializer):
        team = serializer.save(created_by=self.request.user)
        TeamMembership.objects.create(
            user=self.request.user,
            team=team,
            is_admin=True
        )

class TeamDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = TeamSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Team.objects.filter(
            teammembership__user=self.request.user
        ).distinct()

    def perform_destroy(self, instance):
        instance.archived = True
        instance.save()

class TeamInviteView(generics.CreateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = TeamSerializer

    def post(self, request, *args, **kwargs):
        team = get_object_or_404(
            Team,
            id=request.data.get('team_id'),
            teammembership__user=request.user,
            teammembership__is_admin=True
        )
        
        user = get_object_or_404(User, id=request.data.get('user_id'))
        
        if user.pending_team_invites.filter(id=team.id).exists():
            return Response(
                {"detail": "User already invited"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if user.teams.filter(id=team.id).exists():
            return Response(
                {"detail": "User already in team"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        user.pending_team_invites.add(team)
        return Response(
            {"detail": "Invitation sent successfully"},
            status=status.HTTP_200_OK
        )

class TeamAcceptInviteView(generics.CreateAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = TeamSerializer

    def post(self, request, *args, **kwargs):
        team = get_object_or_404(
            Team,
            id=request.data.get('team_id'),
            invited_users=request.user
        )
        
        TeamMembership.objects.create(
            user=request.user,
            team=team,
            is_admin=False
        )
        request.user.pending_team_invites.remove(team)
        
        return Response(
            TeamSerializer(team, context={'request': request}).data,
            status=status.HTTP_200_OK
        )
    

class UserRankingListView(generics.ListAPIView):
    serializer_class = RankingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Ranking.objects.filter(user=self.request.user)

class GameRankingListView(generics.ListAPIView):
    serializer_class = RankingSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        game = self.request.query_params.get('game')
        team_id = self.request.query_params.get('team_id')
        
        queryset = Ranking.objects.all()
        
        if game:
            queryset = queryset.filter(game=game)
        if team_id:
            queryset = queryset.filter(team_id=team_id)
        
        return queryset.order_by('-score')
    

class UserRankingListView(generics.ListAPIView):
    serializer_class = RankingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Ranking.objects.filter(user=self.request.user)

class RankingDetailView(generics.RetrieveUpdateAPIView):
    serializer_class = RankingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Ranking.objects.filter(user=self.request.user)

class GameRankingListView(generics.ListAPIView):
    serializer_class = RankingSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        game = self.request.query_params.get('game')
        team_id = self.request.query_params.get('team_id')
        
        queryset = Ranking.objects.all()
        
        if game:
            queryset = queryset.filter(game=game)
        if team_id:
            queryset = queryset.filter(team_id=team_id)
        
        return queryset.order_by('-score')

class UpdateRankingAfterMatchView(generics.UpdateAPIView):
    serializer_class = RankingSerializer
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, *args, **kwargs):
        user = request.user
        match = get_object_or_404(Match, id=kwargs['match_id'])
        
        # Get or create ranking
        ranking, created = Ranking.objects.get_or_create(
            user=user,
            game=match.game,
            team=None,
            defaults={
                'score': 0,
                'level': 1,
                'rank': 1
            }
        )

        # Calculate score change based on match result
        score_change = self.calculate_score_change(user, match)
        ranking.score += score_change
        
        # Update rank and level
        ranking.rank = self.calculate_rank(ranking.score)
        ranking.level = self.calculate_level(ranking.score)
        
        ranking.save()
        
        return Response(
            RankingSerializer(ranking, context={'request': request}).data,
            status=status.HTTP_200_OK
        )

    def calculate_score_change(self, user, match):
        # Implement your scoring logic here
        base_points = match.game.base_points if hasattr(match.game, 'base_points') else 10
        
        if match.winner == user:
            return base_points * 2
        elif user in match.players.all():
            return base_points
        return 0

    def calculate_rank(self, score):
        if score >= 2000: return 6  # Diamond
        elif score >= 1500: return 5  # Platinum
        elif score >= 1000: return 4  # Gold
        elif score >= 500: return 3  # Silver
        elif score >= 200: return 2  # Bronze
        return 1  # Iron

    def calculate_level(self, score):
        if score >= 3000: return 5  # Master
        elif score >= 2000: return 4  # Expert
        elif score >= 1000: return 3  # Advanced
        elif score >= 500: return 2  # Intermediate
        return 1  # Beginner
    
class SelectSideView(generics.UpdateAPIView):
    serializer_class = MatchMembershipSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['patch']

    def get_object(self):
        match_id = self.kwargs.get('match_id')
        return get_object_or_404(
            MatchMembership,
            user=self.request.user,
            match_id=match_id
        )

    def patch(self, request, *args, **kwargs):
        membership = self.get_object()
        side = request.data.get('side')
        
        if side not in [1, 2]:
            return Response(
                {"detail": "Side must be 1 or 2"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check if side is already taken
        if MatchMembership.objects.filter(
            match=membership.match, 
            side=side
        ).exists():
            return Response(
                {"detail": "This side is already taken"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        membership.side = side
        membership.save()
        
        return Response(
            self.get_serializer(membership).data,
            status=status.HTTP_200_OK
        )
    

class BeginMatchView(generics.CreateAPIView):
    serializer_class = MatchMembershipSerializer
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        match = get_object_or_404(Match, id=serializer.validated_data['match_id'])
        
        # Check if user is match creator
        if match.created_by != request.user:
            return Response(
                {"detail": "Only match creator can start the match"},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Check if match is already started/completed
        if match.status != 'UPCOMING':
            return Response(
                {"detail": f"Match is already {match.get_status_display()}"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check participant count
        participants_count = MatchMembership.objects.filter(match=match).count()
        if participants_count != match.max_participants:
            return Response(
                {
                    "detail": f"Match requires {match.max_participants} participants",
                    "current_participants": participants_count
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Check all sides are assigned
        unassigned = MatchMembership.objects.filter(
            match=match,
            side=0  # Not assigned
        ).exists()
        
        if unassigned:
            return Response(
                {"detail": "All participants must be assigned to a side"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # All checks passed - start the match
        match.status = 'IN_PROGRESS'
        match.save()
        
        return Response(
            {
                "detail": "Match started successfully",
                "match_id": match.id,
                "status": match.status
            },
            status=status.HTTP_200_OK
        )


class CompleteMatchView(generics.UpdateAPIView):
    serializer_class = MatchSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = Match.objects.all()
    http_method_names = ['patch']

    @transaction.atomic
    def patch(self  , request, *args, **kwargs):
        match = self.get_object()
        
        # Verify requester is match creator or admin
        if match.created_by != request.user and not request.user.is_staff:
            return Response(
                {"detail": "Only match creator or admin can complete matches"},
                status=status.HTTP_403_FORBIDDEN
            )

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        winning_side = serializer.validated_data['which_side_won']
        reward = serializer.validated_data['reward']

        # Update match status and winner
        match.status = 'COMPLETED'
        match.winner_side = winning_side
        match.reward = reward
        match.save()

        # Update player scores and rankings
        winning_players = MatchMembership.objects.filter(
            match=match,
            side=winning_side
        ).select_related('user')
        
        for membership in winning_players:
            user = membership.user
            user.score += reward
            user.ranking = User.objects.filter(score__gt=user.score).count() + 1
            user.save()

        return Response(
            {
                "detail": "Match completed successfully",
                "match_id": match.id,
                "winning_side": winning_side,
                "reward_distributed": reward * winning_players.count()
            },
            status=status.HTTP_200_OK
        )
    
    