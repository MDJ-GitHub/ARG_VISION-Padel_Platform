import json
from channels.generic.websocket import AsyncWebsocketConsumer # type: ignore
from channels.db import database_sync_to_async # type: ignore
from django.contrib.auth import get_user_model
from organizations.models import Discussion, Match, Message, Team

User = get_user_model()

class DiscussionChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.discussion_id = self.scope['url_route']['kwargs'].get('discussion_id')
        self.room_group_name = f'discussion_{self.discussion_id}'

        print(f"[DEBUG] Connect attempt to discussion {self.discussion_id}")
        print(f"[DEBUG] User from scope: {self.scope.get('user')}")

        # Reject anonymous users
        if self.scope['user'].is_anonymous:
            print("[DEBUG] Connection rejected: anonymous user")
            await self.close()
            return

        # Verify access
        has_access = await self.user_has_access(self.scope['user'], self.discussion_id)
        print(f"[DEBUG] User access check: {has_access}")

        if has_access:
            await self.channel_layer.group_add(self.room_group_name, self.channel_name)
            print("[DEBUG] User added to channel group")
            await self.accept()
        else:
            print("[DEBUG] Connection rejected: user has no access")
            await self.close()

    @database_sync_to_async
    def user_has_access(self, user, discussion_id):
        """Check if user has access to this discussion"""
        from organizations.models import Discussion
        try:
            discussion = Discussion.objects.get(id=discussion_id)
            if discussion.type == 'GROUP':
                return discussion.group.filter(id=user.id).exists()
            elif discussion.type == 'MATCH':
                return Match.objects.filter(id=discussion.match_id).exists()
            elif discussion.type == 'TEAM':
                return Team.objects.filter(id=discussion.team_id).exists()
            return False
        except Discussion.DoesNotExist:
            return False

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
        """Make sure to save with a Discussion object, not just the ID"""
        discussion = Discussion.objects.get(id=self.discussion_id)
        return Message.objects.create(
            discussion=discussion,   # ✅ fixed
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