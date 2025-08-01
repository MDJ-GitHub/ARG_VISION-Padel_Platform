from django.urls import path
from .views import (
    PostListCreateView,
    PortArchivesView,
    PostRestoreView,
    PostRetrieveUpdateDestroy
)

urlpatterns = [
    path('posts/', PostListCreateView.as_view(), name='post-list-create'),
    path('posts/<int:pk>/', PostRetrieveUpdateDestroy.as_view(), name='post-retrieve-update-destroy'),
    path('posts/archives/', PortArchivesView.as_view(), name='post-archives'),
    path('posts/<int:pk>/restore/', PostRestoreView.as_view(), name='post-restore'),
]