from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include
from rest_framework_simplejwt.views import TokenRefreshView
from accounts.views import (
    BasicUserListView,
    CustomTokenObtainPairView,
    ForgotPasswordChangeView,
    ForgotPasswordCodeView,
    ImageUploadView,
    PlayerSearchView,
    PublicUserListView,
    RegisterView,
    ResendCodeView,
    ResendVerificationCodeView,
    SignUpView,
    UserProfileView,
    VerifyEmailView
)
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView # type: ignore

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
        path('forgot/code/', ForgotPasswordCodeView.as_view(), name='forgot_password_code'),
        path('forgot/change/', ForgotPasswordChangeView.as_view(), name='forgot_password_change'),
        path('refreshVerify/', ResendVerificationCodeView.as_view(), name='resend-verification-code'),

    ])),

    path('api/user/', UserProfileView.as_view(), name='user_profile'),
    path('api/players/search/', PlayerSearchView.as_view(), name='player-search'),


    path("api/users/public/", PublicUserListView.as_view(), name="public-user-list"),
    path("api/users/basic/", BasicUserListView.as_view(), name="basic-user-list"),

    path('api/zones/', include('zones.urls')),
    path('api/organizations/', include('organizations.urls')),
    path('api/events/', include('events.urls')),

    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),

    path('upload/', ImageUploadView.as_view(), name='upload'),



]

# ✅ Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
