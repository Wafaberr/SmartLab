# accounts/utils.py
import re

from django.core.mail import send_mail, EmailMultiAlternatives
from django.template.loader import render_to_string
from django.utils.html import strip_tags
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
    Envoie un email de réinitialisation de mot de passe avec template HTML
    """
    try:
        # Construction du lien de réinitialisation
        reset_link = f"{settings.FRONTEND_URL}/reset-password/{token_obj.token}/"
        
        # Contexte pour le template
        context = {
            'user': user,
            'reset_link': reset_link,
            'token': str(token_obj.token),
            'expires_in': '1 heure',
            'site_name': 'Password Reset App',
            'support_email': settings.DEFAULT_FROM_EMAIL,
            'year': '2024',
        }
        
        # Rendu du template HTML
        html_message = render_to_string(
            'emails/reset_password_email.html',
            context
        )
        plain_message = strip_tags(html_message)
        
        # Envoi de l'email avec EmailMultiAlternatives
        subject = 'Réinitialisation de votre mot de passe'
        from_email = settings.DEFAULT_FROM_EMAIL
        to_email = user.email
        
        email = EmailMultiAlternatives(
            subject=subject,
            body=plain_message,
            from_email=from_email,
            to=[to_email],
            reply_to=[settings.DEFAULT_FROM_EMAIL],
        )
        email.attach_alternative(html_message, "text/html")
        
        # Envoyer l'email
        email.send(fail_silently=False)
        
        logger.info(f"Email de réinitialisation envoyé à {user.email}")
        return True
        
    except Exception as e:
        logger.error(f"Erreur lors de l'envoi de l'email: {str(e)}")
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