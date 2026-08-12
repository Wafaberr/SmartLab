from django.urls import path

from . import views


urlpatterns = [
    path('signup/', views.SignupView.as_view(), name='signup'),
    path('login/', views.EmailTokenObtainPairView.as_view(), name='login'),
    path('forgot-password/', views.PasswordResetRequestView.as_view(), name='forgot-password'),
    path('reset-password/link/<uuid:token>/', views.PasswordResetLinkView.as_view(), name='password_reset_link'),
    path('reset-password/', views.PasswordResetConfirmView.as_view(), name='password_reset'),
    path('reset-password/validate/<uuid:token>/', views.ValidateTokenView.as_view(), name='password_reset_validate'),
    path('change-password/', views.PasswordChangeView.as_view(), name='password_change'),
    path('profile/', views.UserProfileView.as_view(), name='profile'),
]