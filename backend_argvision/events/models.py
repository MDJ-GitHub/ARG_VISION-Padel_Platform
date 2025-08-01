from django.db import models

# Create your models here.

# models.py
from django.db import models
from django.utils import timezone
from accounts.models import User

class Post(models.Model):
    title = models.CharField(max_length=200)
    content = models.TextField()
    pictures = models.JSONField(default=list)  # Stores list of image URLs/paths
    date_creation = models.DateTimeField(default=timezone.now)
    date_change = models.DateTimeField(auto_now=True)
    poster = models.ForeignKey(User, on_delete=models.CASCADE, related_name='posts')
    archived = models.BooleanField(default=False)

    def __str__(self):
        return self.title

    class Meta:
        ordering = ['-date_creation']
