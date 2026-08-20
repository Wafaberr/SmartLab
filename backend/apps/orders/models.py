from django.conf import settings
from django.db import models

from apps.inventory.models import Product
from apps.supliers.models import Supplier


class Order(models.Model):
	STATUS_CHOICES = [
		('draft', 'Draft'),
		('pending', 'Pending'),
		('approved', 'Approved'),
		('received', 'Received'),
		('cancelled', 'Cancelled'),
	]

	reference = models.CharField(max_length=64, unique=True)
	supplier = models.ForeignKey(Supplier, on_delete=models.PROTECT, related_name='orders')
	created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name='created_orders')
	status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft')
	expected_date = models.DateField(null=True, blank=True)
	comment = models.TextField(blank=True)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['-created_at']

	@property
	def total(self):
		return sum(item.total for item in self.items.all())


class OrderItem(models.Model):
	order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
	product = models.ForeignKey(Product, on_delete=models.PROTECT, related_name='order_items')
	quantity = models.PositiveIntegerField()
	unit_price = models.DecimalField(max_digits=12, decimal_places=2)

	class Meta:
		unique_together = ('order', 'product')

	@property
	def total(self):
		return self.quantity * self.unit_price
