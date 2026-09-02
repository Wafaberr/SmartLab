from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework.test import APIClient

from apps.inventory.models import Product, StockMovement
from .models import AnalysisRecipe, AnalysisType, LabSession, SessionConsumption


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

	def test_create_session_creates_planned_consumption_from_recipe(self):
		product = Product.objects.create(
			name='Tube EDTA', reference='EDTA-RECIPE-001', unit='piece'
		)
		AnalysisRecipe.objects.create(
			analysis_type=self.analysis_type,
			product=product,
			quantity_per_sample=2,
			unit='piece',
		)

		response = self.client.post(
			'/laboratory/sessions/',
			{'analysis_type': self.analysis_type.id, 'sample_count': 20},
			format='json',
		)

		self.assertEqual(response.status_code, 201)
		consumption = SessionConsumption.objects.get()
		self.assertEqual(consumption.planned_quantity, 40)
		self.assertEqual(consumption.actual_quantity, 0)

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

	def test_validate_session_returns_400_when_stock_is_insufficient(self):
		product = Product.objects.create(
			name='Tube EDTA', reference='EDTA-002', stock_quantity=2,
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
		self.assertEqual(response.status_code, 400)
		self.assertIn('Stock insuffisant', response.data.get('error', ''))
		product.refresh_from_db()
		self.assertEqual(product.stock_quantity, 2)

	def test_get_analysis_types_returns_correct_fields(self):
		response = self.client.get('/laboratory/analysis-types/')
		self.assertEqual(response.status_code, 200)
		self.assertEqual(len(response.data), 1)
		analysis_type = response.data[0]
		self.assertEqual(analysis_type['id'], self.analysis_type.id)
		self.assertEqual(analysis_type['name'], 'Glycémie')
		self.assertEqual(analysis_type['duration_minutes'], 5)
		self.assertIn('price', analysis_type)
		# recipes et is_active ne doivent pas être retournés
		self.assertNotIn('recipes', analysis_type)
		self.assertNotIn('is_active', analysis_type)
