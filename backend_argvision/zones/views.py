from django.shortcuts import render

# Create your views here.

from rest_framework import generics, permissions
from backend_argvision.permissions import IsAdmin, IsOwner
from .models import Location, Position, Terrain
from .serializers import LocationSerializer, PositionSerializer, TerrainSerializer

class TerrainListView(generics.ListAPIView):
    queryset = Terrain.objects.filter(archived=False)
    serializer_class = TerrainSerializer
    permission_classes = [permissions.IsAuthenticated]

class TerrainCreateView(generics.CreateAPIView):
    serializer_class = TerrainSerializer
    permission_classes = [IsOwner]

class TerrainRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Terrain.objects.all()
    serializer_class = TerrainSerializer
    permission_classes = [IsOwner]

    def perform_destroy(self, instance):
        # Soft delete instead of actual deletion
        instance.is_active = False
        instance.save()

class TerrainArchivesView(generics.ListAPIView):
    queryset = Terrain.objects.filter(archived=True)
    serializer_class = TerrainSerializer
    permission_classes = [IsAdmin]

class LocationListView(generics.ListAPIView):
    queryset = Location.objects.all()
    serializer_class = LocationSerializer
    permission_classes = [permissions.IsAuthenticated]

class LocationCreateView(generics.CreateAPIView): 
    queryset = Location.objects.all()
    serializer_class = LocationSerializer
    permission_classes = [IsAdmin, IsOwner]

class LocationRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Location.objects.all()
    serializer_class = LocationSerializer
    permission_classes = [IsAdmin, IsOwner]

    def perform_destroy(self, instance):
        # Soft delete instead of actual deletion
        instance.is_active = False
        instance.save()

class LocationArchivesView(generics.ListAPIView):
    queryset = Location.objects.filter(archived=True)
    serializer_class = LocationSerializer
    permission_classes = [permissions.IsAdminUser]


class PositionCreateView(generics.CreateAPIView):
    serializer_class = PositionSerializer
    permission_classes = [IsOwner]

    def get_queryset(self):
        queryset = Position.objects.filter(archived=False)
        
        # Optional filtering
        terrain_id = self.request.query_params.get('terrain_id')
        side = self.request.query_params.get('side')
        
        if terrain_id:
            queryset = queryset.filter(terrain_id=terrain_id)
        if side:
            queryset = queryset.filter(side=side)
            
        return queryset.order_by('terrain', 'side', 'x', 'y')
    
class PositionListView(generics.ListAPIView):
    serializer_class = PositionSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        queryset = Position.objects.filter(archived=False)
        
        # Optional filtering
        terrain_id = self.request.query_params.get('terrain_id')
        side = self.request.query_params.get('side')
        
        if terrain_id:
            queryset = queryset.filter(terrain_id=terrain_id)
        if side:
            queryset = queryset.filter(side=side)
            
        return queryset.order_by('terrain', 'side', 'x', 'y')

class PositionRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = PositionSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    
    def get_queryset(self):
        return Position.objects.all()
    
    def perform_destroy(self, instance):
        # Soft delete (archive) instead of actual deletion
        instance.archived = True
        instance.save()

