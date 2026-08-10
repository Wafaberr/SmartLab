# accounts/utils.py
import re

from django.core.mail import EmailMessage
from django.conf import settings
from rest_framework.views import exception_handler
import logging

logger = logging.getLogger(__name__)

def custom_exception_handler(exc, context):
    """
    Gestionnaire d'exceptions personnalisé pour l'API
    """
    response = exception_handler(exc, context)
    
    if response is not None:
        # Formater la réponse d'erreur
        if isinstance(response.data, dict):
            if 'detail' in response.data:
                response.data = {
                    'success': False,
                    'error': response.data['detail']
                }
            elif 'non_field_errors' in response.data:
                response.data = {
                    'success': False,
                    'error': response.data['non_field_errors'][0]
                }
            else:
                # Garder les erreurs de validation
                response.data = {
                    'success': False,
                    'errors': response.data
                }
        else:
            response.data = {
                'success': False,
                'error': str(response.data)
            }
    
    return response

def send_password_reset_email(user, token_obj, request=None):
    """
    Envoie un email texte de réinitialisation de mot de passe via SMTP.
    """
    try:
        if not settings.EMAIL_HOST_USER or not settings.EMAIL_HOST_PASSWORD:
            raise RuntimeError(
                'EMAIL_HOST_USER et EMAIL_HOST_PASSWORD doivent être configurés.'
            )

        # Construction du lien de réinitialisation
        reset_link = f"{settings.FRONTEND_URL}/reset-password/{token_obj.token}/"
        
        subject = 'Réinitialisation de votre mot de passe'
        to_email = user.email
        message = (
            f"Bonjour {user.get_short_name() or user.email},\n\n"
            "Vous avez demandé la réinitialisation de votre mot de passe SmartLab.\n\n"
            f"Ouvrez ce lien pour continuer : {reset_link}\n\n"
            "Ce lien est valable pendant 1 heure.\n"
            "Si vous n'êtes pas à l'origine de cette demande, ignorez cet email.\n"
        )

        email = EmailMessage(
            subject=subject,
            body=message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            to=[to_email],
            reply_to=[settings.DEFAULT_FROM_EMAIL],
        )

        sent = email.send(fail_silently=False)
        if sent != 1:
            logger.error("Le backend email n'a envoyé aucun message à %s", to_email)
            return False
        
        logger.info(f"Email de réinitialisation envoyé à {user.email}")
        return True
        
    except Exception as e:
        logger.exception("Erreur lors de l'envoi de l'email: %s", e)
        return False

def validate_password_strength(password):
    """
    Valide la force du mot de passe
    """
    errors = []
    
    if len(password) < 8:
        errors.append("Le mot de passe doit contenir au moins 8 caractères.")
    
    if not re.search(r'[A-Z]', password):
        errors.append("Le mot de passe doit contenir au moins une majuscule.")
    
    if not re.search(r'[a-z]', password):
        errors.append("Le mot de passe doit contenir au moins une minuscule.")
    
    if not re.search(r'[0-9]', password):
        errors.append("Le mot de passe doit contenir au moins un chiffre.")
    
    if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        errors.append("Le mot de passe doit contenir au moins un caractère spécial.")
    
    return errors