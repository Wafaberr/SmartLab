from rest_framework import serializers
from .models import Supplier


class SupplierSerializer(serializers.ModelSerializer):
    class Meta:
        model = Supplier
        fields = (
            'id', 'name', 'email', 'phone', 'address', 'city', 'postal_code',
            'country', 'website', 'is_active', 'created_at', 'updated_at'
        )
