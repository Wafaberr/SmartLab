from django.contrib.auth import get_user_model
from django.core import mail
from django.test import TestCase, override_settings
from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APITestCase
from datetime import timedelta

from apps.auth.models import PasswordResetToken
from apps.auth.utils import send_password_reset_email


class UserModelTests(TestCase):
    def test_create_user_with_email(self):
        User = get_user_model()
        user = User.objects.create_user(
            email='test@example.com',
            password='secret123',
            first_name='Test',
            last_name='User',
        )

        self.assertEqual(user.email, 'test@example.com')
        self.assertTrue(user.check_password('secret123'))

    def test_password_reset_token_lifecycle(self):
        User = get_user_model()
        user = User.objects.create_user(
            email='reset@example.com',
            password='secret123',
        )
        token = PasswordResetToken.objects.create(
            user=user,
            expires_at=timezone.now() + timedelta(hours=1),
        )

        self.assertEqual(PasswordResetToken.get_valid_token(token.token), token)

        token.mark_as_used()

        self.assertIsNone(PasswordResetToken.get_valid_token(token.token))

    def test_clean_expired_tokens_removes_expired_tokens(self):
        User = get_user_model()
        user = User.objects.create_user(
            email='expired@example.com',
            password='secret123',
        )
        PasswordResetToken.objects.create(
            user=user,
            expires_at=timezone.now() - timedelta(minutes=1),
        )

        self.assertEqual(PasswordResetToken.clean_expired_tokens(), 1)
        self.assertFalse(PasswordResetToken.objects.exists())

    @override_settings(
        EMAIL_HOST_USER='test@example.com',
        EMAIL_HOST_PASSWORD='test-password',
    )
    def test_password_reset_email_is_rendered_and_sent(self):
        User = get_user_model()
        user = User.objects.create_user(
            email='email@example.com',
            password='secret123',
        )
        token = PasswordResetToken.objects.create(
            user=user,
            expires_at=timezone.now() + timedelta(hours=1),
        )

        self.assertTrue(send_password_reset_email(user, token))
        self.assertEqual(len(mail.outbox), 1)
        self.assertIn(str(token.token), mail.outbox[0].body)


class AuthApiTests(APITestCase):
    def test_signup_creates_user(self):
        response = self.client.post(
            reverse('signup'),
            {
                'username': 'testuser',
                'email': 'signup@example.com',
                'password': 'secret123',
            },
            format='json',
        )

        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.json()['user']['email'], 'signup@example.com')
