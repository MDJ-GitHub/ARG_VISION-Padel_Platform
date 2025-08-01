from rest_framework import serializers
from .models import Location, Position, Terrain


class LocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Location
        fields = '__all__'

class TerrainSerializer(serializers.ModelSerializer):
    location = LocationSerializer()
    
    class Meta:
        model = Terrain
        fields = '__all__'
        read_only_fields = ['created_at', 'updated_at']

    def create(self, validated_data):
        location_data = validated_data.pop('location')
        location = Location.objects.create(**location_data)
        terrain = Terrain.objects.create(location=location, **validated_data)
        return terrain

    def update(self, instance, validated_data):
        location_data = validated_data.pop('location', None)
        
        # Update terrain fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        
        # Update location if provided
        if location_data:
            location = instance.location
            for attr, value in location_data.items():
                setattr(location, attr, value)
            location.save()
        
        instance.save()
        return instance

class PositionSerializer(serializers.ModelSerializer):
    side_display = serializers.CharField(source='get_side_display', read_only=True)
    terrain_name = serializers.CharField(source='terrain.name', read_only=True)

    class Meta:
        model = Position
        fields = [
            'id', 'x', 'y', 'terrain', 'terrain_name', 
            'side', 'side_display', 'archived'
        ]
        read_only_fields = ['id', 'side_display', 'terrain_name']
        extra_kwargs = {
            'x': {'required': True},
            'y': {'required': True},
            'terrain': {'required': True},
            'side': {'required': True}
        }

    def validate(self, data):
        # Ensure position is unique for terrain and side
        terrain = data.get('terrain')
        side = data.get('side')
        x = data.get('x')
        y = data.get('y')

        if terrain and side and x and y:
            qs = Position.objects.filter(
                terrain=terrain,
                side=side,
                x=x,
                y=y
            )
            if self.instance:  # For updates
                qs = qs.exclude(id=self.instance.id)
            if qs.exists():
                raise serializers.ValidationError(
                    "Position with these coordinates already exists for this terrain and side"
                )
        
        return data
