from rest_framework import serializers

from .models import AnalysisType, LabSession, SessionConsumption
from .models import AnalysisType, LabSession, SessionConsumption, SessionLoss


class AnalysisTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = AnalysisType
        fields = '__all__'


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
