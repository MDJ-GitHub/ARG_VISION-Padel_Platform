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
                  'gender', 'picture', 'matches', 'wins', 'losses', 'score', 
                  'date_joined', 'last_login', 'role']
        read_only_fields = ['date_joined', 'last_login', 'matches', 'wins', 'losses', 'score']

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        username = attrs.get('email')
        password = attrs.get('password')

        if username:
            if '@' in username:  # Email
                pass
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


# Authenticate with email (resolved from any input)
        print(username)
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
            password=validated_data['password'],
            username=validated_data.get['username']
        )
        return user
    
class SignUpSerializer(serializers.ModelSerializer):
    password2 = serializers.CharField(write_only=True, required=True, style={'input_type': 'password2'})

    class Meta:
        model = User
        fields = ['username','email', 'phone', 'first_name', 'last_name', 'password', 'password2', 'birthdate','gender']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', '')
        )
        
        # Generate and send verification code
        code = user.generate_verification_code()
        send_mail(
            'OnlySport - SignUp code ',
            f'Thank you for singing up in OnlySport! \nTo start using the app, input the following verification code in the final step: {code}',
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            fail_silently=False,
        )
        return user

class VerifyEmailSerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(max_length=6)

    def validate(self, data):
        try:
            user = User.objects.get(email=data['email'])
        except User.DoesNotExist:
            raise serializers.ValidationError("User not found")
        
        if user.email_verified:
            raise serializers.ValidationError("Email already verified")
        
        if (user.verification_code != data['code'] or 
            user.verification_code_expiry < datetime.datetime.now(datetime.timezone.utc)):
            raise serializers.ValidationError("Invalid or expired code")
        
        data['user'] = user
        return data