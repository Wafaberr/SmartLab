from datetime import timedelta

from django.test import TestCase
from django.utils import timezone

from apps.ai.services import StockAIAnalyzer
from apps.auth.models import User
from apps.inventory.models import Category, Product
from apps.notifications.models import Notification
from apps.supliers.models import Supplier


class StockAIAnalyzerTests(TestCase):
    def setUp(self):
        self.admin = User.objects.create_user(
            email='admin@smartlab.test',
            password='StrongPass123!',
            role='admin',
        )
        self.supplier = Supplier.objects.create(
            name='Supplier Test',
            email='supplier@test.com',
        )
        self.category = Category.objects.create(name='Medical')

    def test_low_stock_creates_analysis_and_notification(self):
        product = Product.objects.create(
            category=self.category,
            supplier=self.supplier,
            name='Vitamin C',
            reference='VIT-001',
            stock_quantity=5,
            minimum_stock=10,
            maximum_stock=40,
            unit='bottle',
            expiration_date=timezone.now().date() + timedelta(days=20),
        )

        StockAIAnalyzer.analyze_product(product)

        self.assertTrue(
            product.ai_analyses.filter(analysis_type='low_stock').exists(),
        )
        self.assertTrue(
            Notification.objects.filter(
                recipient=self.admin,
                title__icontains='Stock bas',
            ).exists(),
        )

    def test_expiring_product_creates_alert_and_notification(self):
        product = Product.objects.create(
            category=self.category,
            supplier=self.supplier,
            name='Antibiotic',
            reference='ANT-002',
            stock_quantity=25,
            minimum_stock=5,
            maximum_stock=50,
            unit='box',
            expiration_date=timezone.now().date() + timedelta(days=3),
        )

        StockAIAnalyzer.analyze_product(product)

        self.assertTrue(
            product.ai_analyses.filter(analysis_type='expiring').exists(),
        )
        self.assertTrue(
            Notification.objects.filter(
                recipient=self.admin,
                title__icontains='Expiration proche',
            ).exists(),
        )
