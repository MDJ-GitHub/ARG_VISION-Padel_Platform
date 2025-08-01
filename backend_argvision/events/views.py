from django.shortcuts import render

# Create your views here.

from rest_framework import generics, permissions, status
from rest_framework.response import Response
from .models import Post
from .serializers import PostSerializer

class PostListCreateView(generics.ListCreateAPIView):
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        # Show non-archived posts by default
        return Post.objects.filter(archived=False).order_by('-date_creation')

    def perform_create(self, serializer):
        # Automatically set the poster to the current user
        serializer.save(poster=self.request.user)

class PostRetrieveUpdateDestroy(generics.RetrieveUpdateDestroyAPIView):
    queryset = Post.objects.all()
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def perform_update(self, serializer):
        serializer.save()  # date_change auto-updates via model

    def perform_destroy(self, instance):
        # Soft delete (archive) instead of actual deletion
        instance.archived = True
        instance.save()

class PortArchivesView(generics.ListAPIView):
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return Post.objects.filter(archived=True).order_by('-date_creation')

class PostRestoreView(generics.UpdateAPIView):
    queryset = Post.objects.all()
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticated]
    http_method_names = ['patch']

    def patch(self, request, *args, **kwargs):
        post = self.get_object()
        post.archived = False
        post.save()
        return Response(self.get_serializer(post).data)