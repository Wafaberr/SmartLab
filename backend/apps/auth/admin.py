from django.contrib import admin
from django.utils import timezone
from django.utils.html import format_html

from .models import PasswordResetToken


@admin.register(PasswordResetToken)
class PasswordResetTokenAdmin(admin.ModelAdmin):
    list_display = [
        'user',
        'user_email',
        'token_preview',
        'created_at',
        'expires_at',
        'is_used',
        'status_display',
    ]
    list_filter = ['is_used', 'created_at', 'expires_at']
    search_fields = ['user__email', 'user__username', 'token']
    readonly_fields = ['token', 'created_at']
    ordering = ['-created_at']

    def user_email(self, obj):
        return obj.user.email

    user_email.short_description = 'Email'

    def token_preview(self, obj):
        return str(obj.token)[:8] + '...'

    token_preview.short_description = 'Token'

    def status_display(self, obj):
        if obj.is_used:
            return format_html('<span style="color: red;">✗ Utilisé</span>')
        if obj.expires_at and obj.expires_at < timezone.now():
            return format_html('<span style="color: orange;">⚠ Expiré</span>')
        return format_html('<span style="color: green;">✓ Valide</span>')

    status_display.short_description = 'Statut'

    actions = ['clean_expired_tokens']

    def clean_expired_tokens(self, request, queryset):
        """Action admin pour nettoyer les tokens expirés."""
        count = queryset.filter(is_used=False, expires_at__lt=timezone.now()).delete()[0]
        self.message_user(request, f'{count} tokens expirés supprimés.')

    clean_expired_tokens.short_description = 'Nettoyer les tokens expirés'