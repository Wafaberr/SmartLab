import base64

from rest_framework import serializers
from .models import Category, Product, StockItem, StockMovement


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
    image = serializers.ImageField(write_only=True, required=False, allow_null=True)
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

    def to_representation(self, instance):
        data = super().to_representation(instance)
        if instance.image_data:
            encoded = base64.b64encode(bytes(instance.image_data)).decode('ascii')
            data['image'] = f'data:{instance.image_content_type};base64,{encoded}'
        else:
            data['image'] = ''
        return data

    def create(self, validated_data):
        image = validated_data.pop('image', None)
        product = Product.objects.create(**validated_data)
        self._store_image(product, image)
        return product

    def update(self, instance, validated_data):
        image = validated_data.pop('image', serializers.empty)
        product = super().update(instance, validated_data)
        if image is not serializers.empty:
            self._store_image(product, image)
        return product

    @staticmethod
    def _store_image(product, image):
        if image is None:
            product.image_data = None
            product.image_content_type = ''
            product.image_name = ''
        else:
            product.image_data = image.read()
            product.image_content_type = image.content_type or 'application/octet-stream'
            product.image_name = image.name
        product.save(update_fields=('image_data', 'image_content_type', 'image_name'))


class StockItemSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    product_id = serializers.PrimaryKeyRelatedField(
        queryset=Product.objects.all(), source='product', write_only=True
    )

    class Meta:
        model = StockItem
        fields = ('id', 'product', 'product_id', 'quantity', 'location', 'last_updated')


class StockMovementSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.get_full_name', read_only=True)

    class Meta:
        model = StockMovement
        fields = '__all__'
        read_only_fields = ('product', 'user', 'stock_before', 'stock_after')
