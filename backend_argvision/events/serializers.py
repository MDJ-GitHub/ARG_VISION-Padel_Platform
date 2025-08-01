from rest_framework import serializers
from .models import Post

class PostSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = '__all__'
        read_only_fields = ['id', 'date_creation', 'date_change', 'poster']
    
    def validate_pictures(self, value):
        """Ensure pictures is a list of strings"""
        if not isinstance(value, list):
            raise serializers.ValidationError("Pictures must be a list")
        if not all(isinstance(item, str) for item in value):
            raise serializers.ValidationError("All picture items must be strings")
        return value