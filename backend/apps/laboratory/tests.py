from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework.test import APIClient

from apps.inventory.models import Product, StockMovement
from .models import AnalysisType, LabSession


class LaboratoryApiTests(TestCase):
	def setUp(self):
		self.user = get_user_model().objects.create_user(
			email='lab@example.com', password='secret123'
		)
		self.analysis_type = AnalysisType.objects.create(
			name='Glycémie', duration_minutes=5, price='35.00'
		)
		self.client = APIClient()
		self.client.force_authenticate(user=self.user)

	def test_create_session_assigns_authenticated_technician(self):
		response = self.client.post(
			'/laboratory/sessions/',
			{'analysis_type': self.analysis_type.id, 'sample_count': 20},
			format='json',
		)

		self.assertEqual(response.status_code, 201)
		self.assertEqual(LabSession.objects.get().technician, self.user)

	def test_validate_session_consumes_stock(self):
		product = Product.objects.create(
			name='Tube EDTA', reference='EDTA-001', stock_quantity=20,
		)
		session = LabSession.objects.create(
			analysis_type=self.analysis_type,
			technician=self.user,
			sample_count=2,
		)
		response = self.client.post(
			f'/laboratory/sessions/{session.id}/validate/',
			{'consumptions': [{'product_id': product.id, 'actual_quantity': 3}], 'losses': []},
			format='json',
		)
		self.assertEqual(response.status_code, 200)
		product.refresh_from_db()
		self.assertEqual(product.stock_quantity, 17)
		self.assertEqual(StockMovement.objects.count(), 1)
