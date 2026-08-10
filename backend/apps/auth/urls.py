from django.urls import path

from . import views


urlpatterns = [
    path('signup/', views.SignupView.as_view(), name='signup'),
    path('login/', views.EmailTokenObtainPairView.as_view(), name='login'),
    path('password-reset/request/', views.PasswordResetRequestView.as_view(), name='password_reset_request'),
    path('password-reset/confirm/', views.PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('password-reset/validate/<uuid:token>/', views.ValidateTokenView.as_view(), name='password_reset_validate'),
    path('password-change/', views.PasswordChangeView.as_view(), name='password_change'),
]