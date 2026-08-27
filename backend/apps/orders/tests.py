from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework.test import APIClient

from apps.inventory.models import Product, StockMovement
from apps.supliers.models import Supplier
from .models import Order, OrderItem


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

	def test_receive_order_increases_stock_and_creates_entry(self):
		order = Order.objects.create(
			reference='CMD-RECEIVE-001',
			supplier=self.supplier,
			created_by=self.user,
		)
		OrderItem.objects.create(
			order=order,
			product=self.product,
			quantity=10,
			unit_price='2.50',
		)

		response = self.client.post(f'/orders/{order.id}/receive/', format='json')

		self.assertEqual(response.status_code, 200)
		self.product.refresh_from_db()
		order.refresh_from_db()
		self.assertEqual(self.product.stock_quantity, 10)
		self.assertEqual(order.status, 'received')
		self.assertEqual(StockMovement.objects.count(), 1)
		self.assertEqual(StockMovement.objects.get().movement_type, 'entry')
