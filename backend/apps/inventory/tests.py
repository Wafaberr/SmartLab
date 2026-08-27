from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from django.contrib.auth import get_user_model
from .models import Category, Product, StockMovement


class InventoryBasicTests(TestCase):
	def setUp(self):
		self.client = APIClient()
		self.category = Category.objects.create(name='Default')
		self.user = get_user_model().objects.create_user(
			email='inventory@example.com',
			password='secret123',
		)
		self.client.force_authenticate(user=self.user)

	def test_create_product(self):
		url = reverse('inventory_products')
		payload = {
			'name': 'Test product',
			'reference': 'TP-001',
			'sku': 'TP-001',
			'price': '12.50',
			'category_id': self.category.id,
		}
		resp = self.client.post(url, payload, format='json')
		self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
		self.assertEqual(Product.objects.count(), 1)

	def test_stock_movement_updates_product_and_history(self):
		product = Product.objects.create(
			name='Tube', reference='TUBE-001', stock_quantity=10,
		)
		response = self.client.post(
			f'/inventory/products/{product.id}/movements/',
			{'movement_type': 'entry', 'quantity': 5, 'reason': 'Réception'},
			format='json',
		)
		self.assertEqual(response.status_code, status.HTTP_201_CREATED)
		product.refresh_from_db()
		self.assertEqual(product.stock_quantity, 15)
		self.assertEqual(StockMovement.objects.count(), 1)

	def test_manual_stock_exit_decreases_quantity_and_records_reason(self):
		product = Product.objects.create(
			name='Réactif Glucose', reference='GLU-001', stock_quantity=20,
		)
		response = self.client.post(
			f'/inventory/products/{product.id}/movements/',
			{
				'movement_type': 'exit',
				'quantity': 5,
				'reason': 'Consommation manuelle',
				'comment': 'Sortie pour contrôle de routine',
			},
			format='json',
		)
		self.assertEqual(response.status_code, status.HTTP_201_CREATED)
		self.assertEqual(response.data['movement_type'], 'exit')
		self.assertEqual(response.data['reason'], 'Consommation manuelle')
		self.assertEqual(response.data['comment'], 'Sortie pour contrôle de routine')
		product.refresh_from_db()
		self.assertEqual(product.stock_quantity, 15)
		self.assertEqual(StockMovement.objects.count(), 1)

