from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework.test import APIClient

from apps.inventory.models import Product
from apps.supliers.models import Supplier


class OrdersApiTests(TestCase):
	def setUp(self):
		self.user = get_user_model().objects.create_user(
			email='orders@example.com', password='secret123'
		)
		self.supplier = Supplier.objects.create(name='Biolab')
		self.product = Product.objects.create(name='Tube', reference='TUBE-001')
		self.client = APIClient()
		self.client.force_authenticate(user=self.user)

	def test_create_order_and_item(self):
		order_response = self.client.post(
			'/orders/',
			{'reference': 'CMD-001', 'supplier': self.supplier.id},
			format='json',
		)
		self.assertEqual(order_response.status_code, 201)

		item_response = self.client.post(
			f"/orders/{order_response.data['id']}/items/",
			{'product': self.product.id, 'quantity': 10, 'unit_price': '2.50'},
			format='json',
		)
		self.assertEqual(item_response.status_code, 201)
