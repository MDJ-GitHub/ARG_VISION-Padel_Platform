# organization/urls.py
from django.urls import path

from .views import (
    BeginMatchView, CompleteMatchView, GameCreateView, GameListView, GameRetrieveUpdateDestroyView,
    MatchCreateView, MatchListAllView, MatchRetrieveUpdateDestroyView,
    MatchCompleteView,
    MatchListPublicView,
    MatchArchivesView, GameArchivesView, MessageListView,
    InvitePlayerView, AcceptInviteView,
    KickPlayerView, BanPlayerView, DenyInviteView, LeaveMatchView,
    TeamCreateView, AcceptTeamInviteView, SelectSideView
    )


urlpatterns = [
    # Game URLs
    path('games/create/', GameCreateView.as_view(), name='game-list-create'),
    path('games/list/', GameListView.as_view(), name='game-list'),
    path('games/<int:pk>/', GameRetrieveUpdateDestroyView.as_view(), name='game-retrieve-update-destroy'),
    path('games/archives/', GameArchivesView.as_view(), name='game-archives'),
    
    # Match URLs
    path('matches/list/all/', MatchListAllView.as_view(), name='match-list-all'),
    path('matches/list/public/', MatchListPublicView.as_view(), name='match-list-public'),

    path('matches/create/', MatchCreateView.as_view(), name='match-create'),

    path('matches/invite/', InvitePlayerView.as_view(), name='match-invite'),
    path('matches/accept/<int:pk>/', AcceptInviteView.as_view(), name='match-accept'),
    path('matches/deny/<int:pk>/', DenyInviteView.as_view(), name='match-deny'),
    path('matches/kick/<int:pk>/', KickPlayerView.as_view(), name='match-kick'),
    path('matches/ban/<int:pk>/', BanPlayerView.as_view(), name='match-ban'),
    path('matches/leave/<int:pk>/', LeaveMatchView.as_view(), name='match-leave'),

    path('matches/<int:pk>/', MatchRetrieveUpdateDestroyView.as_view(), name='match-retrieve-update-destroy'),
    path('matches/<int:match_id>/messages/', MessageListView.as_view(), name='match-messages'),
    path('matches/archives/', MatchArchivesView.as_view(), name='match-archives'),
    path('matches/<int:match_id>/side/', SelectSideView.as_view(), name='select-side'),
    
    path('matches/begin/', BeginMatchView.as_view(), name='begin-match'),
    path('matches/complete/<int:pk>/', CompleteMatchView.as_view(), name='complete-match'),

    # Team URLs
    path('teams/create/', TeamCreateView.as_view(), name='team-create'),
    path('teams/accept/<int:pk>/', AcceptTeamInviteView.as_view(), name='team-accept'),


   # Ranking URLs

  
]