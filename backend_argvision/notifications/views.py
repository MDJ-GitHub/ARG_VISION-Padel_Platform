from django.shortcuts import render

# Create your views here.

from rest_framework import generics
from .models import Notification
from .serializers import NotificationSerializer

class NotificationListView(generics.ListAPIView):
    serializer_class = NotificationSerializer
    
    def get_queryset(self):
        return self.request.user.notifications.all()

class NotificationMarkReadView(generics.UpdateAPIView):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    
    def perform_update(self, serializer):
        serializer.save(is_read=True)