from django.shortcuts import render
from rest_framework import generics, status, permissions, serializers as drf_serializers
from rest_framework import views
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.exceptions import AuthenticationFailed
from apps.auth import serializers as auth_serializers
from apps.auth.models import PasswordResetToken, User
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
from django.utils import timezone
from datetime import timedelta
from django.contrib.auth import authenticate, update_session_auth_hash
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.db import transaction


from .utils import send_password_reset_email, validate_password_strength

# Create your views here.

class EmailTokenObtainPairSerializer(TokenObtainPairSerializer):
    username = drf_serializers.CharField(required=False, allow_blank=True, write_only=True)
    email = drf_serializers.EmailField(required=False, allow_blank=True, write_only=True)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["username"].required = False
        self.fields["email"].required = False

    def validate(self, attrs):
        email = attrs.get("email") or attrs.get("username")
        password = attrs.get("password")

        if not email or not password:
            raise AuthenticationFailed("Email and password are required")

        user = User.objects.filter(email=email).first()
        if not user:
            raise AuthenticationFailed("No account found for this email")

        authenticated_user = authenticate(username=email, password=password)
        if not authenticated_user:
            raise AuthenticationFailed("No active account found with the given credentials")

        refresh = RefreshToken.for_user(authenticated_user)
        data = {
            "refresh": str(refresh),
            "access": str(refresh.access_token),
            "user": auth_serializers.UserSerializer(authenticated_user).data,
        }
        return data


class EmailTokenObtainPairView(TokenObtainPairView):
    serializer_class = EmailTokenObtainPairSerializer


class SignupView(APIView):
    def post(self, request):
        username = request.data.get("username")
        email = request.data.get("email")
        password = request.data.get("password")

        if not username or not email or not password:
            return Response({"error": "username, email and password are required"}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(email=email).exists():
            return Response({"error": "EMAIL_ALREADY_EXISTS"}, status=status.HTTP_409_CONFLICT)

        user = User.objects.create_user(email=email, password=password, username=username)
        refresh = RefreshToken.for_user(user)

        return Response({"user": auth_serializers.UserSerializer(user).data, "access": str(refresh.access_token), "refresh": str(refresh)}, status=status.HTTP_201_CREATED)

# accounts/views.py


class PasswordResetRequestView(views.APIView):
    """
    Vue pour demander la réinitialisation du mot de passe
    POST: /auth/forgot-password/
    Body: {"email": "user@example.com"}
    """
    permission_classes = [AllowAny]
    serializer_class = auth_serializers.PasswordResetRequestSerializer
    
    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        
        if serializer.is_valid():
            email = serializer.validated_data['email']
            
            try:
                user = User.objects.get(email=email)
                
                with transaction.atomic():
                    # Nettoyer les anciens tokens
                    PasswordResetToken.clean_expired_tokens()
                    
                    # Supprimer les tokens non utilisés de plus de 24h
                    threshold = timezone.now() - timedelta(hours=24)
                    PasswordResetToken.objects.filter(
                        user=user,
                        is_used=False,
                        created_at__lt=threshold
                    ).delete()
                    
                    # Créer un nouveau token
                    token = PasswordResetToken.objects.create(
                        user=user,
                        expires_at=timezone.now() + timedelta(hours=1),
                        ip_address=self.get_client_ip(request),
                        user_agent=request.META.get('HTTP_USER_AGENT', '')
                    )
                    
                    # Envoyer l'email
                    email_sent = send_password_reset_email(user, token, request)
                    
                    if email_sent:
                        return Response({
                            "success": True,
                            "message": "Un email de réinitialisation a été envoyé à votre adresse.",
                            "data": {
                                "email": email,
                                "token_sent": True
                            }
                        }, status=status.HTTP_200_OK)
                    else:
                        return Response({
                            "success": False,
                            "error": "Erreur lors de l'envoi de l'email. Veuillez réessayer."
                        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
                        
            except User.DoesNotExist:
                # Pour des raisons de sécurité, on renvoie le même message
                return Response({
                    "success": True,
                    "message": "Un email de réinitialisation a été envoyé à votre adresse."
                }, status=status.HTTP_200_OK)
            
            except Exception as e:
                return Response({
                    "success": False,
                    "error": f"Une erreur est survenue: {str(e)}"
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({
            "success": False,
            "errors": serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
    
    def get_client_ip(self, request):
        """Récupère l'IP du client"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip

class PasswordResetConfirmView(views.APIView):
    """
    Vue pour confirmer la réinitialisation du mot de passe
    POST: /auth/reset-password/
    Body: {
        "token": "uuid-token",
        "new_password": "newpass123",
        "confirm_password": "newpass123"
    }
    """
    permission_classes = [AllowAny]
    serializer_class = auth_serializers.PasswordResetConfirmSerializer
    
    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        
        if serializer.is_valid():
            token_uuid = serializer.validated_data['token']
            new_password = serializer.validated_data['new_password']
            
            try:
                # Récupérer le token
                token = PasswordResetToken.get_valid_token(token_uuid)
                
                if not token:
                    return Response({
                        "success": False,
                        "error": "Token invalide ou expiré."
                    }, status=status.HTTP_400_BAD_REQUEST)
                
                with transaction.atomic():
                    # Mettre à jour le mot de passe
                    user = token.user
                    user.set_password(new_password)
                    user.save()
                    
                    # Marquer le token comme utilisé
                    token.mark_as_used()
                    
                    # Supprimer tous les autres tokens pour cet utilisateur
                    PasswordResetToken.objects.filter(
                        user=user,
                        is_used=False
                    ).delete()
                    
                    # Générer un nouveau token JWT pour l'utilisateur
                    refresh = RefreshToken.for_user(user)
                    
                    return Response({
                        "success": True,
                        "message": "Votre mot de passe a été réinitialisé avec succès.",
                        "data": {
                            "access_token": str(refresh.access_token),
                            "refresh_token": str(refresh),
                            "user": {
                                "id": user.id,
                                "email": user.email,
                                "username": user.username
                            }
                        }
                    }, status=status.HTTP_200_OK)
                    
            except Exception as e:
                return Response({
                    "success": False,
                    "error": f"Une erreur est survenue: {str(e)}"
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({
            "success": False,
            "errors": serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

class ValidateTokenView(views.APIView):
    """
    Vue pour valider un token de réinitialisation
    GET: /auth/reset-password/validate/<uuid:token>/
    """
    permission_classes = [AllowAny]
    
    def get(self, request, token):
        try:
            token_obj = PasswordResetToken.get_valid_token(token)
            
            if token_obj:
                return Response({
                    "success": True,
                    "message": "Token valide.",
                    "data": {
                        "valid": True,
                        "user_email": token_obj.user.email,
                        "user_id": token_obj.user.id,
                        "expires_at": token_obj.expires_at.isoformat()
                    }
                }, status=status.HTTP_200_OK)
            else:
                return Response({
                    "success": False,
                    "error": "Token invalide ou expiré."
                }, status=status.HTTP_400_BAD_REQUEST)
                
        except Exception as e:
            return Response({
                "success": False,
                "error": f"Une erreur est survenue: {str(e)}"
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class PasswordChangeView(views.APIView):
    """
    Vue pour changer le mot de passe (utilisateur authentifié)
    POST: /auth/change-password/
    Headers: Authorization: Bearer <token>
    Body: {
        "old_password": "oldpass",
        "new_password": "newpass123",
        "confirm_password": "newpass123"
    }
    """
    permission_classes = [IsAuthenticated]
    serializer_class = auth_serializers.PasswordChangeSerializer
    
    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        
        if serializer.is_valid():
            old_password = serializer.validated_data['old_password']
            new_password = serializer.validated_data['new_password']
            
            user = request.user
            
            # Vérifier l'ancien mot de passe
            if not user.check_password(old_password):
                return Response({
                    "success": False,
                    "error": "L'ancien mot de passe est incorrect."
                }, status=status.HTTP_400_BAD_REQUEST)
            
            try:
                # Valider le nouveau mot de passe
                validate_password(new_password, user)
                
                with transaction.atomic():
                    # Changer le mot de passe
                    user.set_password(new_password)
                    user.save()
                    
                    # Garder la session active
                    update_session_auth_hash(request, user)
                    
                    return Response({
                        "success": True,
                        "message": "Votre mot de passe a été modifié avec succès."
                    }, status=status.HTTP_200_OK)
                    
            except ValidationError as e:
                return Response({
                    "success": False,
                    "errors": {
                        "new_password": e.messages
                    }
                }, status=status.HTTP_400_BAD_REQUEST)
            
            except Exception as e:
                return Response({
                    "success": False,
                    "error": f"Une erreur est survenue: {str(e)}"
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response({
            "success": False,
            "errors": serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)

class UserProfileView(generics.RetrieveUpdateAPIView):
    """
    Vue pour récupérer et mettre à jour le profil utilisateur
    GET: /auth/profile/
    PUT/PATCH: /auth/profile/
    """
    permission_classes = [IsAuthenticated]
    serializer_class = auth_serializers.UserSerializer
    
    def get_object(self):
        return self.request.user