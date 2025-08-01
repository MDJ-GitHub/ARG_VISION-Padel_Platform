from channels.db import database_sync_to_async
from django.contrib.auth.models import AnonymousUser
from rest_framework_simplejwt.tokens import AccessToken
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError
from django.contrib.auth import get_user_model

User = get_user_model()

class TokenAuthMiddleware:
    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        # Get token from query string
        token = None
        for param in scope.get('query_string', b'').decode().split('&'):
            if param.startswith('token='):
                token = param.split('=')[1]
                break

        if token:
            try:
                access_token = AccessToken(token)
                scope['user'] = await self.get_user(access_token['user_id'])
            except (InvalidToken, TokenError, User.DoesNotExist):
                scope['user'] = AnonymousUser()
        else:
            scope['user'] = AnonymousUser()

        return await self.app(scope, receive, send)

    @database_sync_to_async
    def get_user(self, user_id):
        return User.objects.get(id=user_id)