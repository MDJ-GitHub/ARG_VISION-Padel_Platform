from django.shortcuts import render

# Create your views here.

from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.views import TokenObtainPairView

from backend_argvision import permissions
from .models import User
from .serializers import CustomTokenObtainPairSerializer, RegisterSerializer, UserSerializer
from django.db.models import Q

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Here you would typically send a confirmation email/SMS
        # For now, we'll just return the user data
        headers = self.get_success_headers(serializer.data)
        return Response(
            {
                'user': UserSerializer(user, context=self.get_serializer_context()).data,
                'message': 'User created successfully. Please confirm your email/phone.',
            },
            status=status.HTTP_201_CREATED,
            headers=headers
        )

class UserProfileView(generics.RetrieveUpdateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = (IsAuthenticated,)

    def get_object(self):
        return self.request.user
    
class PlayerSearchView(generics.ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        search_term = self.request.query_params.get('q', '').strip()
        
        if not search_term:
            return User.objects.none()
        
        # Create a lenient search across multiple fields
        query = Q()
        for term in search_term.split():
            query &= (
                Q(first_name__icontains=term) |
                Q(last_name__icontains=term) |
                Q(username__icontains=term) |
                Q(email__icontains=term) |
                Q(phone__icontains=term)
            )
        
        return User.objects.filter(query).distinct()


