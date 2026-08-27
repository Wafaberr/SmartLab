from rest_framework import serializers

from .models import AnalysisRecipe, AnalysisType, LabSession, SessionConsumption, SessionLoss


class AnalysisTypeSerializer(serializers.ModelSerializer):
    recipes = serializers.PrimaryKeyRelatedField(many=True, read_only=True)

    class Meta:
        model = AnalysisType
        fields = ('id', 'name', 'duration_minutes', 'price', 'is_active', 'recipes')


class AnalysisRecipeSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)

    class Meta:
        model = AnalysisRecipe
        fields = ('id', 'analysis_type', 'product', 'product_name', 'quantity_per_sample', 'unit')


class SessionConsumptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = SessionConsumption
        fields = ('id', 'session', 'product', 'planned_quantity', 'actual_quantity', 'unit')
        read_only_fields = ('session',)


class SessionLossSerializer(serializers.ModelSerializer):
    class Meta:
        model = SessionLoss
        fields = '__all__'
        read_only_fields = ('session',)


class LabSessionSerializer(serializers.ModelSerializer):
    technician_name = serializers.CharField(source='technician.get_full_name', read_only=True)
    analysis_type_name = serializers.CharField(source='analysis_type.name', read_only=True)
    consumptions = SessionConsumptionSerializer(many=True, read_only=True)
    losses = SessionLossSerializer(many=True, read_only=True)

    class Meta:
        model = LabSession
        fields = '__all__'
        read_only_fields = ('technician',)
