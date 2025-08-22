from django.shortcuts import render

# Create your views here.

from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.views import TokenObtainPairView

from backend_argvision import permissions
from .models import User
from .serializers import BasicUserSerializer, CustomTokenObtainPairSerializer, ForgotPasswordChangeSerializer, ForgotPasswordCodeSerializer, PublicUserSerializer, RegisterSerializer, ResendVerificationCodeSerializer, UserSearchMixin, UserSerializer
from django.db.models import Q
from .serializers import SignUpSerializer, VerifyEmailSerializer
from django.core.mail import send_mail
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser

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


class SignUpView(generics.CreateAPIView):
    serializer_class = SignUpSerializer
    permission_classes = [AllowAny]
    parser_classes = (MultiPartParser, FormParser)  # ✅ this allows images

class VerifyEmailView(generics.CreateAPIView):
    serializer_class = VerifyEmailSerializer
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        user = serializer.validated_data['user']
        user.email_verified = True
        user.verification_code = None
        user.verification_code_expiry = None
        user.is_active = True
        user.save()
        
        return Response(
            {"detail": "Email verified successfully"},
            status=status.HTTP_200_OK
        )

class ResendCodeView(generics.CreateAPIView):
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        email = request.data.get('email')
        if not email:
            return Response(
                {"detail": "Email is required"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            user = User.objects.get(email=email)
            if user.email_verified:
                return Response(
                    {"detail": "Email already verified"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            code = user.generate_verification_code()
            send_mail(
                'Your New Verification Code',
                f'Your new verification code is: {code}',
                settings.DEFAULT_FROM_EMAIL,
                [user.email],
                fail_silently=False,
            )
            return Response(
                {"detail": "New verification code sent"},
                status=status.HTTP_200_OK
            )
        except User.DoesNotExist:
            return Response(
                {"detail": "User not found"},
                status=status.HTTP_404_NOT_FOUND
            )

class ImageUploadView(APIView):
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request, *args, **kwargs):
        file = request.FILES['file']
        # Save the file to a model, or FileSystemStorage
        return Response({"message": "Image uploaded successfully", "filename": file.name})
    

class ForgotPasswordCodeView(generics.CreateAPIView):
    serializer_class = ForgotPasswordCodeSerializer
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            {"detail": "Password reset code sent to email."},
            status=status.HTTP_200_OK
        )


# Reset password with code
class ForgotPasswordChangeView(generics.CreateAPIView):
    serializer_class = ForgotPasswordChangeSerializer
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(
            {"detail": "Password has been reset successfully."},
            status=status.HTTP_200_OK
        )
    

class ResendVerificationCodeView(generics.GenericAPIView):
    serializer_class = ResendVerificationCodeSerializer
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"detail": "Verification code resent successfully."}, status=status.HTTP_200_OK)
    




# Full details (without sensitive info)
class PublicUserListView(UserSearchMixin, generics.ListAPIView):
    serializer_class = PublicUserSerializer
    permission_classes = [IsAuthenticated]

# Minimal details
class BasicUserListView(UserSearchMixin, generics.ListAPIView):
    serializer_class = BasicUserSerializer
    permission_classes = [IsAuthenticated]