from rest_framework import serializers
from .models import StockAnalysis, AIInsight
from apps.inventory.models import Product


class StockAnalysisSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)
    product_reference = serializers.CharField(source='product.reference', read_only=True)

    class Meta:
        model = StockAnalysis
        fields = [
            'id',
            'product',
            'product_name',
            'product_reference',
            'analysis_type',
            'priority',
            'current_stock',
            'minimum_stock',
            'daily_consumption',
            'estimated_days_remaining',
            'days_until_expiration',
            'expiration_date',
            'recommendation',
            'recommended_quantity',
            'is_resolved',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'created_at',
            'updated_at',
            'product_name',
            'product_reference',
        ]


class AIInsightSerializer(serializers.ModelSerializer):
    affected_products_count = serializers.SerializerMethodField()

    class Meta:
        model = AIInsight
        fields = [
            'id',
            'insight_type',
            'title',
            'description',
            'affected_products_count',
            'data_json',
            'is_active',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_affected_products_count(self, obj):
        return obj.affected_products.count()
