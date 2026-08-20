from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from . import views


urlpatterns = [
    path('signup/', views.SignupView.as_view(), name='signup'),
    path('login/', views.EmailTokenObtainPairView.as_view(), name='login'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('forgot-password/', views.PasswordResetRequestView.as_view(), name='forgot-password'),
    path('reset-password/link/<uuid:token>/', views.PasswordResetLinkView.as_view(), name='password_reset_link'),
    path('reset-password/', views.PasswordResetConfirmView.as_view(), name='password_reset'),
    path('reset-password/validate/<uuid:token>/', views.ValidateTokenView.as_view(), name='password_reset_validate'),
    path('change-password/', views.PasswordChangeView.as_view(), name='password_change'),
    path('profile/', views.UserProfileView.as_view(), name='profile'),
]