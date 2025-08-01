from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from .models import Notification

def send_notification(user, notification_type, message, match=None):
    # Create database notification
    notification = Notification.objects.create(
        user=user,
        notification_type=notification_type,
        message=message,
    )
    
    # Send real-time notification
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        f'notifications_{user.id}',
        {
            'type': 'send_notification',
            'notification': {
                'id': notification.id,
                'type': notification_type,
                'message': message,
                'created_at': notification.created_at.isoformat(),
                'is_read': False
            }
        }
    )