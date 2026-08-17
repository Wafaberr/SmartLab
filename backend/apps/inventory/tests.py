from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from .models import Category, Product


class InventoryBasicTests(TestCase):
	def setUp(self):
		self.client = APIClient()
		self.category = Category.objects.create(name='Default')

	def test_create_product(self):
		url = reverse('inventory_products')
		payload = {
			'name': 'Test product',
			'sku': 'TP-001',
			'price': '12.50',
			'category_id': self.category.id,
		}
		resp = self.client.post(url, payload, format='json')
		self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
		self.assertEqual(Product.objects.count(), 1)

