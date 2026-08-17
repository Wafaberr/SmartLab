from django.db import models
from django.utils import timezone

from apps.supliers.models import Supplier


class Category(models.Model):
	name = models.CharField(max_length=120, unique=True)
	description = models.TextField(blank=True)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['name']

	def __str__(self):
		return self.name


class Product(models.Model):
	category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, related_name='products')
	supplier = models.ForeignKey(Supplier, on_delete=models.SET_NULL, null=True, blank=True, related_name='products')
	
	name = models.CharField(max_length=255)
	reference = models.CharField(max_length=64, unique=True)
	sku = models.CharField(max_length=64, blank=True)
	barcode = models.CharField(max_length=128, blank=True, unique=True, null=True)
	description = models.TextField(blank=True)
	
	# Pricing and stock info
	purchase_price = models.DecimalField(max_digits=12, decimal_places=2, default=0)
	price = models.DecimalField(max_digits=12, decimal_places=2, default=0)
	unit = models.CharField(max_length=50, default='piece')
	
	# Stock levels
	stock_quantity = models.FloatField(default=0)
	minimum_stock = models.FloatField(default=0)
	maximum_stock = models.FloatField(default=0)
	
	# Storage and expiration
	storage_temperature = models.CharField(max_length=50, blank=True)
	expiration_date = models.DateField(null=True, blank=True)
	
	# Media
	image = models.URLField(blank=True)
	
	# Metadata
	is_active = models.BooleanField(default=True)
	is_low_stock = models.BooleanField(default=False)
	
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		ordering = ['name']

	def __str__(self):
		return f"{self.name} ({self.reference})"


class StockItem(models.Model):
	product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='stock_items')
	quantity = models.IntegerField(default=0)
	location = models.CharField(max_length=255, blank=True)
	last_updated = models.DateTimeField(default=timezone.now)

	class Meta:
		ordering = ['-last_updated']

	def __str__(self):
		return f"{self.product.reference} - {self.quantity} @ {self.location or 'default'}"
