import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from organizations.models import Match, Message

User = get_user_model()

class MatchChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.match_id = self.scope['url_route']['kwargs']['match_id']
        self.room_group_name = f'match_{self.match_id}'

        # Reject anonymous users
        if self.scope['user'].is_anonymous:
            await self.close()
            return

        # Verify access
        if await self.user_has_access(self.scope['user'], self.match_id):
            await self.channel_layer.group_add(
                self.room_group_name,
                self.channel_name
            )
            await self.accept()
        else:
            await self.close()

    @database_sync_to_async
    def user_has_access(self, user, match_id):
        """Check if user has access to this match"""
        return Match.objects.filter(
            id=match_id,
        ).exists()

    async def receive(self, text_data):
        try:
            data = json.loads(text_data)
            message = data['message']
            user = self.scope['user']
            
            # Save message
            saved_message = await self.save_message(user, message)
            
            # Broadcast
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'chat_message',
                    'message': message,
                    'sender': user.username,
                    'timestamp': saved_message.timestamp.isoformat()
                }
            )
        except Exception as e:
            print(f"Error processing message: {e}")

    @database_sync_to_async
    def save_message(self, user, content):
        """Save message to database"""
        return Message.objects.create(
            match_id=self.match_id,
            sender=user,
            content=content
        )

    async def chat_message(self, event):
        """Send message to WebSocket"""
        await self.send(text_data=json.dumps(event))

class NotificationConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope['user']
        if self.user.is_anonymous:
            await self.close()
            return
            
        self.room_group_name = f'notifications_{self.user.id}'
        
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, 'room_group_name'):
            await self.channel_layer.group_discard(
                self.room_group_name,
                self.channel_name
            )

    async def send_notification(self, event):
        await self.send(text_data=json.dumps(event['notification']))