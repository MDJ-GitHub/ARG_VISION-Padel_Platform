from django.utils import timezone
from django.db import models

# Create your models here.

from django.db import models
from backend_argvision import settings
from zones.models import Terrain
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from accounts.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver

class Game(models.Model):
    GAME_TYPES = (
        ('SPORT', 'Sport'),
        ('ESPORT', 'Esport'),
    )
    
    archived = models.BooleanField(default=False)
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    game_type = models.CharField(max_length=10, choices=GAME_TYPES)
    picture = models.ImageField(upload_to='game_pics/', null=True, blank=True)
    base_points = models.IntegerField(
        default=1,
        validators=[MinValueValidator(0)],
        help_text="Base points awarded for participating in the game"
    )

    def __str__(self):
        return f"{self.name} ({self.get_game_type_display()})"

    class Meta:
        ordering = ['name']

class Match(models.Model):
    VISIBILITY_CHOICES = (
        ('PUBLIC', 'Public'),  # Anyone can join
        ('PRIVATE', 'Private'),  # Invite-only
        ('PUBLIC_TEAM', 'Public Team'),  # Invite-only
        ('PRIVATE_TEAM', 'Private Team'),  # Invite-only
        ('COMPETITION', 'Competition'),
        ('OTHER', 'Other'),
    )
    
    STATUS_CHOICES = (
        ('UPCOMING', 'Upcoming'),
        ('IN_PROGRESS', 'In Progress'),
        ('COMPLETED', 'Completed'),
        ('CANCELED', 'Canceled'),
    )
    RANK_CHOICES = [
        (1, 'Iron'),
        (2, 'Bronze'),
        (3, 'Silver'),
        (4, 'Gold'),
        (5, 'Platinum'),
        (6, 'Diamond'),
    ]
    archived = models.BooleanField(default=False)
    name = models.CharField(max_length=100, default='Match')
    description = models.TextField(blank=True, null=True)
    game = models.ForeignKey(Game, on_delete=models.SET_NULL, null=True, blank=False)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='upcoming')
    rank = models.PositiveSmallIntegerField(
        choices=RANK_CHOICES, default=1)
    created_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='matches_created'
    )
    date_created = models.DateTimeField(default=timezone.now)
    date_modified = models.DateTimeField(auto_now=True)
    date_start = models.DateTimeField(null=True, blank=True)
    reward = models.IntegerField(
        default=0)
    max_participants = models.IntegerField(
        default=2)
    winnerside = models.IntegerField(
        default=1,)
    duration = models.DurationField(null=True, blank=True)
    picture = models.ImageField(upload_to='match_pics/', null=True, blank=True)
    cost = models.PositiveIntegerField(
        default=0,
        validators=[MinValueValidator(0)],
        help_text="Cost of participating in the match (must be non-negative)"
    )
    
    visibility = models.CharField(
        max_length=12,
        choices=VISIBILITY_CHOICES,
        default='PUBLIC'
    )

    terrain = models.ForeignKey(
        Terrain,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    
    def __str__(self):
        return f"{self.name} ({self.get_status_display()})"

    class Meta:
        ordering = ['-date_start']
        verbose_name_plural = 'matches'

    

def team_image_path(instance, filename):
    # Generate path: team_images/team_id/filename.ext
    return f'team_images/{instance.id}/{filename}'

class Team(models.Model):

    RANK_CHOICES = [
        (1, 'Iron'),
        (2, 'Bronze'),
        (3, 'Silver'),
        (4, 'Gold'),
        (5, 'Platinum'),
        (6, 'Diamond'),
    ]
    LEVEL_CHOICES = [
        (1, 'Beginner'),
        (2, 'Intermediate'),
        (3, 'Advanced'),
        (4, 'Expert'),
        (5, 'Master'),
    ]

    archived = models.BooleanField(default=False)
    title = models.CharField(max_length=100)
    slogan = models.CharField(max_length=200, blank=True)
    picture = models.ImageField(upload_to='team_pics/', null=True, blank=True)
    date_creation = models.DateTimeField(default=timezone.now)
    date_modified = models.DateTimeField(auto_now=True)
    game = models.ForeignKey(Game, on_delete=models.SET_NULL, null=True, blank=False)
    rank = models.IntegerField(default=0)
    score = models.IntegerField(default=0)
    members = models.ManyToManyField(User, through='TeamMembership')
    created_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='created_teams')

    rank = models.PositiveSmallIntegerField(
        choices=RANK_CHOICES,
        default=1,
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    level = models.PositiveSmallIntegerField(
        choices=LEVEL_CHOICES,
        default=1
    )

    def __str__(self):
        return self.title

    class Meta:
        ordering = ['-date_creation']

class MatchMembership(models.Model):
    STATUS = (
        ('INVITED', 'Invited'),
        ('MEMBER', 'Member'),
        ('DENIED', 'Denied'),
        ('ADMIN', 'Admin'),
        ('KICKED', 'Kicked'),
        ('LEFT', 'Left'),
    )
    archived = models.BooleanField(default=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    match = models.ForeignKey(Match, on_delete=models.CASCADE)
    date_joined = models.DateTimeField(auto_now_add=True)
    date_invited = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=10, choices=STATUS, default='INVITED')
    side = models.IntegerField(default=0)

    class Meta:
        unique_together = ('user', 'match')

class TeamMembership(models.Model):
    STATUS = (
        ('INVITED', 'Invited'),
        ('MEMBER', 'Member'),
        ('DENIED', 'Denied'),
        ('ADMIN', 'Admin'),
        ('KICKED', 'Kicked'),
        ('LEFT', 'Left'),
        ('WINNER', 'Winner'),
    )
    archived = models.BooleanField(default=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    team = models.ForeignKey(Team, on_delete=models.CASCADE)
    date_invited = models.DateTimeField(auto_now_add=True)
    date_joined = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=10, choices=STATUS, default='INVITED')

    class Meta:
        unique_together = ('user', 'team')


class Ranking(models.Model):
    RANK_CHOICES = [
        (1, 'Iron'),
        (2, 'Bronze'),
        (3, 'Silver'),
        (4, 'Gold'),
        (5, 'Platinum'),
        (6, 'Diamond'),
    ]
    LEVEL_CHOICES = [
        (1, 'Beginner'),
        (2, 'Intermediate'),
        (3, 'Advanced'),
        (4, 'Expert'),
        (5, 'Master'),
    ]
    RANK_TYPES = (
        ('STANDARD', 'Standard'),
        ('TOURNAMENT', 'Tournament'),
    )

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='rankings'
    )
    rank = models.PositiveSmallIntegerField(
        choices=RANK_CHOICES,
        default=1,
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    level = models.PositiveSmallIntegerField(
        choices=LEVEL_CHOICES,
        default=1
    )
    score = models.PositiveIntegerField(
        default=0,
        validators=[MinValueValidator(0)]
    )
    type = models.CharField(
        max_length=10,
        choices=RANK_TYPES,
        default='STANDARD'
    )
    game = models.ForeignKey(Game, on_delete=models.SET_NULL, null=True, blank=False)
    team = models.ForeignKey(
        'Team',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='rankings'
    )
    last_updated = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = [['user', 'game', 'team']]  # One ranking per game type per user
        ordering = ['-score', '-level', 'rank']

    def __str__(self):
        return f"{self.user}: {self.get_game_display()} (Level {self.level})"
    
    def update_rank(self):
        """Automatically update rank based on score"""
        if self.score >= 2000:
            self.rank = 6  # Diamond
        elif self.score >= 1500:
            self.rank = 5  # Platinum
        elif self.score >= 1200:
            self.rank = 4  # Gold
        elif self.score >= 900:
            self.rank = 3  # Silver
        elif self.score >= 600:
            self.rank = 2  # Bronze
        else:
            self.rank = 1  # Iron

    def update_level(self):
        """Automatically update level based on score"""
        if self.score >= 1800:
            self.level = 5  # Master
        elif self.score >= 1400:
            self.level = 4  # Expert
        elif self.score >= 1000:
            self.level = 3  # Advanced
        elif self.score >= 500:
            self.level = 2  # Intermediate
        else:
            self.level = 1  # Beginner

    def save(self, *args, **kwargs):
        self.update_rank()
        self.update_level()
        super().save(*args, **kwargs)


class Discussion(models.Model):
    DISCUSSION_TYPES = (
        ('GROUP', 'Group'),
        ('MATCH', 'Match'),
        ('TEAM', 'Team'),
    )

    type = models.CharField(max_length=10, choices=DISCUSSION_TYPES)
    title = models.CharField(max_length=200, blank=True, null=True)
    group = models.ManyToManyField(User, related_name='discussions', blank=True)

    # Nullable references depending on type
    match = models.ForeignKey(
        Match, on_delete=models.CASCADE, null=True, blank=True, related_name="discussions"
    )
    team = models.ForeignKey(
        Team, on_delete=models.CASCADE, null=True, blank=True, related_name="discussions"
    )

    created_at = models.DateTimeField(auto_now_add=True)

    def clean(self):
        """Enforce rules based on type"""
        from django.core.exceptions import ValidationError
        if self.type == 'GROUP' and (self.match or self.team or not self.group):
            raise ValidationError("Group discussions cannot have match or team")
        if self.type == 'MATCH' and (self.team or not self.match or self.group):
            raise ValidationError("Match discussions must have a match and no team")
        if self.type == 'TEAM' and (self.match or not self.team or self.group):
            raise ValidationError("Team discussions must have a team and no match")

    def __str__(self):
        return f"{self.get_type_display()} Discussion {self.id}"



class Message(models.Model):
    MESSAGE_TYPES = (
        ('MESSAGE', 'Message'),
        ('REPLY', 'Reply'),
        ('REACT', 'React'),
    )

    discussion = models.ForeignKey(
        Discussion, on_delete=models.CASCADE, related_name='messages'
    )
    sender = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    message_type = models.CharField(max_length=10, choices=MESSAGE_TYPES, default='MESSAGE')
    replying_to = models.ForeignKey(
        'self',
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='replies'
    )

    class Meta:
        ordering = ['timestamp']

    def __str__(self):
        return f"{self.sender.username}: {self.content[:20]}..."
