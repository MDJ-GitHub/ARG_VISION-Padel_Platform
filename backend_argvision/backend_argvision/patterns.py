from django.urls import re_path
from backend_argvision import consumers

websocket_urlpatterns = [
    re_path(r'ws/discussion/(?P<discussion_id>\d+)/chat/$', consumers.DiscussionChatConsumer.as_asgi()),
    re_path(r'ws/notifications/$', consumers.NotificationConsumer.as_asgi()),
]