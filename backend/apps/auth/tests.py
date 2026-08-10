from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APITestCase


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
