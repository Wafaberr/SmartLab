from rest_framework import serializers
from .models import Category, Product, StockItem


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ('id', 'name', 'description', 'created_at', 'updated_at')


class SupplierSerializer(serializers.ModelSerializer):
    class Meta:
        from apps.supliers.models import Supplier
        model = Supplier
        fields = ('id', 'name', 'email', 'phone', 'address', 'city', 'postal_code', 'country', 'website', 'is_active')


class ProductSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(), source='category', write_only=True, required=False
    )
    supplier = SupplierSerializer(read_only=True)
    supplier_id = serializers.PrimaryKeyRelatedField(
        queryset=__import__('apps.supliers.models', fromlist=['Supplier']).Supplier.objects.all(),
        source='supplier', write_only=True, required=False
    )

    class Meta:
        model = Product
        fields = (
            'id', 'name', 'reference', 'sku', 'barcode', 'description',
            'purchase_price', 'price', 'unit',
            'stock_quantity', 'minimum_stock', 'maximum_stock',
            'storage_temperature', 'expiration_date', 'image',
            'is_active', 'is_low_stock',
            'category', 'category_id', 'supplier', 'supplier_id',
            'created_at', 'updated_at'
        )


class StockItemSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    product_id = serializers.PrimaryKeyRelatedField(
        queryset=Product.objects.all(), source='product', write_only=True
    )

    class Meta:
        model = StockItem
        fields = ('id', 'product', 'product_id', 'quantity', 'location', 'last_updated')
