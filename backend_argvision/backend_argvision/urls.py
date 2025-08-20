"""
URL configuration for backend_argvision project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenRefreshView
from accounts.views import CustomTokenObtainPairView, PlayerSearchView, RegisterView, ResendCodeView, SignUpView, UserProfileView, VerifyEmailView
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path('admin/', admin.site.urls),

    # Authentication URLs
    path('api/auth/', include([
        path('login/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
        path('refresh/', TokenRefreshView.as_view(), name='token_refresh'),
        path('register/', RegisterView.as_view(), name='register'),
        path('signup/', SignUpView.as_view(), name='signup'),
        path('verify/', VerifyEmailView.as_view(), name='verify'),
        path('resend/', ResendCodeView.as_view(), name='resend'),
    ])),
    
    # User profile
    path('api/user/', UserProfileView.as_view(), name='user_profile'),
    path('api/players/search/', PlayerSearchView.as_view(), name='player-search'),

    # Zones app
    path('api/zones/', include('zones.urls')),

    # Organizations app
    path('api/organizations/', include('organizations.urls')),

    # Events app
    path('api/events/', include('events.urls')),

    # Spectacular API schema and docs
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
]
