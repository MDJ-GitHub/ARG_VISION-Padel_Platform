from django.urls import path
from .views import (
    PositionCreateView,
    PositionListView,
    PositionRetrieveUpdateDestroyView,
    TerrainListView,
    TerrainCreateView,
    LocationListView,
    LocationCreateView,
    TerrainRetrieveUpdateDestroyView,
    LocationRetrieveUpdateDestroyView,
    LocationArchivesView,
    TerrainArchivesView,
)

urlpatterns = [
    path('terrains/list/', TerrainListView.as_view(), name='location-list'),
    path('terrains/create/', TerrainCreateView.as_view(), name='terrain-create'),
    path('terrains/<int:pk>/', TerrainRetrieveUpdateDestroyView.as_view(), name='terrain-retrieve-update-destroy'),
    path('terrains/archives/', TerrainArchivesView.as_view(), name='terrain-archives'),

    path('locations/list/', LocationListView.as_view(), name='location-list'),
    path('locations/create/', LocationCreateView.as_view(), name='location-add'),
    path('locations/<int:pk>/', LocationRetrieveUpdateDestroyView.as_view(), name='location-control'),
    path('locations/archives/', LocationArchivesView.as_view(), name='location-archives'),

    path('positions/create/', PositionCreateView.as_view(), name='position-create'),
    path('positions/list/', PositionListView.as_view(), name='position-list'),
    path('positions/<int:pk>/', PositionRetrieveUpdateDestroyView.as_view(), name='position-detail'),
]