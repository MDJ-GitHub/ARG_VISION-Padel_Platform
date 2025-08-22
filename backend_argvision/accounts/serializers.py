import datetime
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth import authenticate
from django.core.mail import send_mail
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from .models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id','username', 'email', 'phone', 'first_name', 'last_name', 'birthdate', 
                  'gender', 'image', 'matches', 'wins', 'losses', 'score', 
                  'date_joined', 'last_login', 'role', 'bio', 'location']
        read_only_fields = ['date_joined', 'last_login', 'matches', 'wins', 'losses', 'score']

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        username = attrs.get('email')
        password = attrs.get('password')

        if username:
            if '@' in username:  # Email
                user = User.objects.filter(email=username.lower()).first()
            elif username.isdigit():  # Phone number (basic check)
                user = User.objects.filter(phone=username).first()
                if user:
                    username = user.email
                    attrs['email'] = user.email
            else:  # Username
                user = User.objects.filter(username=username).first()
                if user:
                    username = user.email
                    attrs['email'] = user.email


        if user and not user.is_active and not user.email_verified :
            if user.check_password(password):
             msg = _('Account is ready but needs verification.')
             raise serializers.ValidationError(msg, code='authorization')

        user = authenticate(
            request=self.context.get('request'),
            email=username,
            password=password,
        )

        if not user:
            msg = _('Unable to log in with provided credentials.')
            raise serializers.ValidationError(msg, code='authorization')

        if not user.is_active and user.email_verified :
            msg = _('User account is disabled.')
            raise serializers.ValidationError(msg, code='authorization')
        


        data = super().validate(attrs)
        refresh = self.get_token(user)

        data['refresh'] = str(refresh)
        data['access'] = str(refresh.access_token)
        data['user'] = UserSerializer(user).data

        return data

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})
    password2 = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'})

    class Meta:
        model = User
        fields = ['username','email', 'phone', 'first_name', 'last_name', 'password', 'password2']
        extra_kwargs = {
            'email': {'required': False},
            'phone': {'required': False},
        }

    def validate(self, attrs):
        if not attrs.get('email') and not attrs.get('phone'):
            raise serializers.ValidationError("Either email or phone must be provided.")

        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Password fields didn't match."})

        return attrs

    def create(self, validated_data):
        user = User.objects.create_user(
            email=validated_data.get('email').lower(),
            phone=validated_data.get('phone'),
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name'],
            password=validated_data['password'],
            username=validated_data.get['username']
        )
        return user
    
class SignUpSerializer(serializers.ModelSerializer):
    from phonenumber_field.serializerfields import PhoneNumberField
    password2 = serializers.CharField(write_only=True, required=True, style={'input_type': 'password2'})
    class Meta:
        model = User
        fields = ['username','email', 'phone', 'first_name', 'last_name', 'password', 'password2', 'birthdate','gender','image','location','role', 'bio']
        extra_kwargs = {'password': {'write_only': True}}

    

     
    def create(self, validated_data):
        user = User.objects.create_user(
            image = validated_data.get('image', None),
            phone=validated_data.get('phone', None),
            gender=validated_data.get('gender', None),
            bio=validated_data.get('bio', ''),
            role=validated_data.get('role', 'Player'),
            birthdate=validated_data.get('birthdate',None),
            location=validated_data.get('location', None),
            username=validated_data['username'],
            email=validated_data['email'].lower(),
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', '')
        )
        
        # Generate and send verification code
        code = user.generate_verification_code()
        send_mail(
            'OnlySport - Signup code ',
            f'Thank you for signing up in OnlySport! \nTo start using the app, input the following verification code in the final step: {code}',
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            fail_silently=False,
        )
        return user

import re
from django.core.validators import validate_email
from django.core.exceptions import ValidationError
import datetime
from rest_framework import serializers
from .models import User

class VerifyEmailSerializer(serializers.Serializer):
    email = serializers.CharField()  # Accept email, username, or phone
    code = serializers.CharField(max_length=6)

    def validate(self, data):
        input_value = data['email'].strip().lower()  # Normalize input

        user = None

        # Check if input is a valid email
        try:
            validate_email(input_value)
            user = User.objects.filter(email=input_value).first()
        except ValidationError:
            # If not an email, check if it's a phone number
            if re.fullmatch(r'\+?\d{7,15}', input_value):
                user = User.objects.filter(phone=input_value).first()
            else:
                # Otherwise, treat it as username
                user = User.objects.filter(username=input_value).first()

        if not user:
            raise serializers.ValidationError("User not found")

        if user.email_verified:
            raise serializers.ValidationError("Email already verified")

        # Check verification code and expiry
        if (user.verification_code != data['code'] or
            user.verification_code_expiry < datetime.datetime.now(datetime.timezone.utc)):
            raise serializers.ValidationError("Invalid or expired code")

        data['user'] = user
        return data


class ForgotPasswordCodeSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate(self, data):
        try:
            user = User.objects.get(email=data['email'])
        except User.DoesNotExist:
            raise serializers.ValidationError("User not found")
        data['user'] = user
        return data

    def save(self, **kwargs):
        user = self.validated_data['user']
        code = user.generate_verification_code()  # you already use this for signup
        send_mail(
            'OnlySport - Password Reset Code',
            f'You requested a password reset. Use this code to reset your password: {code}',
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            fail_silently=False,
        )
        return user


class ForgotPasswordChangeSerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(max_length=6)
    password = serializers.CharField(write_only=True, style={'input_type': 'password'})
    password2 = serializers.CharField(write_only=True, style={'input_type': 'password'})

    def validate(self, data):
        try:
            user = User.objects.get(email=data['email'])
        except User.DoesNotExist:
            raise serializers.ValidationError("User not found")

        # Validate code
        if (user.verification_code != data['code'] or 
            user.verification_code_expiry < datetime.datetime.now(datetime.timezone.utc)):
            raise serializers.ValidationError("Invalid or expired code")

        # Validate passwords
        if data['password'] != data['password2']:
            raise serializers.ValidationError({"password": "Passwords do not match."})

        data['user'] = user
        return data

    def save(self, **kwargs):
        user = self.validated_data['user']
        user.set_password(self.validated_data['password'])
        user.verification_code = None  # clear code
        user.verification_code_expiry = None
        user.save()
        return user


import re
from django.core.validators import validate_email
from django.core.exceptions import ValidationError

class ResendVerificationCodeSerializer(serializers.Serializer):
    email = serializers.CharField()  # Keep it generic, could be email, username, or phone

    def validate(self, data):
        input_value = data['email'].strip().lower()  # Normalize input

        user = None

        # Check if input is a valid email
        try:
            validate_email(input_value)
            user = User.objects.filter(email=input_value).first()
        except ValidationError:
            # If not an email, check if it's a phone number
            if re.fullmatch(r'\+?\d{7,15}', input_value):
                user = User.objects.filter(phone=input_value).first()
            else:
                # Otherwise, treat it as username
                user = User.objects.filter(username=input_value).first()

        if not user:
            raise serializers.ValidationError("User not found")

        if user.email_verified:
            raise serializers.ValidationError("Email is already verified")

        data['user'] = user
        return data

    def save(self, **kwargs):
        user = self.validated_data['user']
        code = user.generate_verification_code()
        send_mail(
            'OnlySport - Resend Verification Code',
            f'To complete your registration, use this verification code: {code}',
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            fail_silently=False,
        )
        return user

from rest_framework import serializers
from .models import User

# Serializer that hides sensitive fields
class PublicUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        exclude = (
            "password", 
            "is_active", 
            "email_verified", 
            "verification_code", 
            "verification_code_expiry",
            "is_staff", 
            "is_superuser",
        )

# Serializer with only basic fields
class BasicUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("username", "email", "first_name", "last_name")



from django.db.models import Q

class UserSearchMixin:
    def get_queryset(self):
        search_term = self.request.query_params.get("q", "").strip()
        if not search_term:
            return User.objects.none()

        query = (
            Q(username__icontains=search_term) |
            Q(email__icontains=search_term) |
            Q(phone__icontains=search_term)
        )

        return User.objects.filter(query).distinct()
