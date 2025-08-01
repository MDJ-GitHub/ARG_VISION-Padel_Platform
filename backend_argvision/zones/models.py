from django.db import models

# Create your models here.

from django.core.validators import MinValueValidator

class Location(models.Model):
    archived = models.BooleanField(default=False)
    country = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    city = models.CharField(max_length=100)
    street = models.CharField(max_length=255)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, blank=True, null=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, blank=True, null=True)

    def __str__(self):
        return f"{self.street}, {self.city}, {self.state}, {self.country}"

class Terrain(models.Model):
    SIZE_CHOICES = (
        ('S', 'Small'),
        ('M', 'Medium'),
        ('L', 'Large'),
    )

    archived = models.BooleanField(default=False)
    name = models.CharField(max_length=100)
    size = models.CharField(max_length=1, choices=SIZE_CHOICES, default='M')
    area = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0.01)])
    max_players = models.PositiveIntegerField(
        validators=[MinValueValidator(2)],
        default=4,
        help_text="Maximum number of players that can play on this terrain"
    )
    location = models.ForeignKey(Location, on_delete=models.CASCADE, related_name='terrains')
    description = models.TextField(blank=True, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    starttime = models.TimeField
    endtime = models.TimeField
    unavailable_days = models.CharField(max_length=255, blank=True, null=True, help_text="Comma-separated list of unavailable days (e.g., 'Monday, Wednesday')")
    picture = models.ImageField(upload_to='terrain_pics/', null=True, blank=True)

    def __str__(self):
        return f"{self.name} ({self.get_size_display()})"

class Position(models.Model):
    SIDE_CHOICES = (
        ('A', 'Side A'),
        ('B', 'Side B'),
    )
    
    archived = models.BooleanField(default=False)
    x = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0)])
    y = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0)])
    terrain = models.ForeignKey(Terrain, on_delete=models.CASCADE, related_name='positions')
    side = models.CharField(max_length=1, choices=SIDE_CHOICES, help_text="Which side (A or B) this position belongs to")

    def __str__(self):
        return f"Position ({self.x}, {self.y}) - {self.get_side_display()} for {self.terrain.name}"

    class Meta:
        ordering = ['terrain', 'side', 'x', 'y']