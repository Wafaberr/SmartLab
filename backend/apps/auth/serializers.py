from rest_framework import serializers
from .models import User
from django.contrib.auth.password_validation import validate_password
from django.core.validators import EmailValidator
from django.core.exceptions import ValidationError
import re

class UserSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = ('id', 'email', 'first_name', 'last_name', 'role')
        read_only_fields = ('id', 'email', 'role')
        
        
        
class PasswordResetRequestSerializer(serializers.Serializer):
    """
    Sérialiseur pour la demande de réinitialisation de mot de passe
    """
    email = serializers.EmailField(
        required=True,
        validators=[EmailValidator()]
    )
    
    def validate_email(self, value):
        """
        Vérifie que l'email existe dans la base de données
        """
        try:
            user = User.objects.get(email=value)
            return value
        except User.DoesNotExist:
            raise serializers.ValidationError(
                "Aucun compte n'est associé à cet email."
            )
        except User.MultipleObjectsReturned:
            raise serializers.ValidationError(
                "Plusieurs comptes sont associés à cet email. Contactez le support."
            )
    
    class Meta:
        fields = ['email']

class PasswordResetConfirmSerializer(serializers.Serializer):
    """
    Sérialiseur pour la confirmation de réinitialisation
    """
    token = serializers.UUIDField(
        required=True,
        error_messages={
            'invalid': 'Le token fourni est invalide.',
            'required': 'Le token est requis.'
        }
    )
    new_password = serializers.CharField(
        required=True,
        write_only=True,
        validators=[validate_password],
        error_messages={
            'required': 'Le nouveau mot de passe est requis.'
        }
    )
    confirm_password = serializers.CharField(
        required=True,
        write_only=True,
        error_messages={
            'required': 'La confirmation du mot de passe est requise.'
        }
    )
    
    def validate(self, data):
        """
        Vérifie que les mots de passe correspondent
        """
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError({
                "confirm_password": "Les mots de passe ne correspondent pas."
            })
        
        # Validation supplémentaire du mot de passe
        try:
            validate_password(data['new_password'])
        except ValidationError as e:
            raise serializers.ValidationError({
                "new_password": e.messages
            })
        
        return data
    
    def validate_token(self, value):
        """
        Vérifie que le token existe et est valide
        """
        from .models import PasswordResetToken
        token_obj = PasswordResetToken.get_valid_token(value)
        if not token_obj:
            raise serializers.ValidationError(
                "Ce token est invalide ou a expiré."
            )
        return value

class PasswordChangeSerializer(serializers.Serializer):
    """
    Sérialiseur pour le changement de mot de passe (utilisateur authentifié)
    """
    old_password = serializers.CharField(
        required=True,
        write_only=True,
        error_messages={
            'required': 'L\'ancien mot de passe est requis.'
        }
    )
    new_password = serializers.CharField(
        required=True,
        write_only=True,
        validators=[validate_password],
        error_messages={
            'required': 'Le nouveau mot de passe est requis.'
        }
    )
    confirm_password = serializers.CharField(
        required=True,
        write_only=True,
        error_messages={
            'required': 'La confirmation du mot de passe est requise.'
        }
    )
    
    def validate(self, data):
        """
        Vérifie que les mots de passe correspondent
        """
        if data['new_password'] != data['confirm_password']:
            raise serializers.ValidationError({
                "confirm_password": "Les mots de passe ne correspondent pas."
            })
        return data
