from django.conf import settings
from django.db import models

from apps.inventory.models import Product


class AnalysisType(models.Model):
	name = models.CharField(max_length=120, unique=True)
	duration_minutes = models.PositiveIntegerField(default=0)
	price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
	is_active = models.BooleanField(default=True)

	class Meta:
		ordering = ['name']

	def __str__(self):
		return self.name


class LabSession(models.Model):
	STATUS_CHOICES = [
		('draft', 'Draft'),
		('in_progress', 'In progress'),
		('completed', 'Completed'),
		('cancelled', 'Cancelled'),
	]

	analysis_type = models.ForeignKey(AnalysisType, on_delete=models.PROTECT, related_name='sessions')
	technician = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name='lab_sessions')
	sample_count = models.PositiveIntegerField(default=1)
	comment = models.TextField(blank=True)
	status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft')
	started_at = models.DateTimeField(null=True, blank=True)
	completed_at = models.DateTimeField(null=True, blank=True)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['-created_at']


class SessionConsumption(models.Model):
	session = models.ForeignKey(LabSession, on_delete=models.CASCADE, related_name='consumptions')
	product = models.ForeignKey(Product, on_delete=models.PROTECT, related_name='session_consumptions')
	planned_quantity = models.FloatField(default=0)
	actual_quantity = models.FloatField(default=0)
	unit = models.CharField(max_length=50, blank=True)

	class Meta:
		unique_together = ('session', 'product')


class SessionLoss(models.Model):
	REASON_CHOICES = [
		('broken', 'Produit cassé'),
		('expired', 'Produit expiré'),
		('handling_error', 'Erreur de manipulation'),
		('other', 'Autre'),
	]

	session = models.ForeignKey(LabSession, on_delete=models.CASCADE, related_name='losses')
	product = models.ForeignKey(Product, on_delete=models.PROTECT, related_name='session_losses')
	quantity = models.FloatField()
	reason = models.CharField(max_length=30, choices=REASON_CHOICES, default='other')
	comment = models.TextField(blank=True)
	created_at = models.DateTimeField(auto_now_add=True)
