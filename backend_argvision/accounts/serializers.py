from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth import authenticate
from django.utils.translation import gettext_lazy as _
from .models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id','username', 'email', 'phone', 'first_name', 'last_name', 'birthdate', 
                  'gender', 'picture', 'matches', 'wins', 'losses', 'score', 
                  'date_joined', 'last_login', 'role']
        read_only_fields = ['date_joined', 'last_login', 'matches', 'wins', 'losses', 'score']

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        username = attrs.get('email')  # Default is email
        password = attrs.get('password')

        # Check if username is actually a phone number
        if username and not '@' in username:
            # Try to find user by phone
            user = User.objects.filter(phone=username).first()
            if user:
                username = user.email

        # Authenticate with email (or phone converted to email)
        user = authenticate(
            request=self.context.get('request'),
            email=username,
            password=password,
        )

        if not user:
            msg = _('Unable to log in with provided credentials.')
            raise serializers.ValidationError(msg, code='authorization')

        if not user.is_active:
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
            email=validated_data.get('email'),
            phone=validated_data.get('phone'),
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name'],
            password=validated_data['password']
        )
        return user