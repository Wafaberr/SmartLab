from django.contrib import admin
from .models import Category, Product, StockItem


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'description')
    search_fields = ('name',)


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'sku', 'category', 'price', 'is_active')
    list_filter = ('is_active', 'category')
    search_fields = ('name', 'sku')


@admin.register(StockItem)
class StockItemAdmin(admin.ModelAdmin):
    list_display = ('id', 'product', 'quantity', 'location', 'last_updated')
    search_fields = ('product__name', 'product__sku')
from django.contrib import admin

# Register your models here.
