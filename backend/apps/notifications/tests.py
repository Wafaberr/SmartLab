from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework.test import APIClient

from .models import Notification


class NotificationsApiTests(TestCase):
	def setUp(self):
		user_model = get_user_model()
		self.user = user_model.objects.create_user(
			email='notifications@example.com', password='secret123'
		)
		other_user = user_model.objects.create_user(
			email='other@example.com', password='secret123'
		)
		Notification.objects.create(
			recipient=self.user, title='Stock faible', message='Tube presque vide'
		)
		Notification.objects.create(
			recipient=other_user, title='Privée', message='Autre compte'
		)
		self.client = APIClient()
		self.client.force_authenticate(user=self.user)

	def test_list_is_scoped_to_authenticated_user(self):
		response = self.client.get('/notifications/')
		self.assertEqual(response.status_code, 200)
		self.assertEqual(len(response.data), 1)
