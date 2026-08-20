from django.db import transaction
from apps.inventory.models import Product, StockMovement
from django.utils import timezone
from rest_framework import generics, permissions, serializers, status
from rest_framework.response import Response

from .models import AnalysisType, LabSession, SessionConsumption, SessionLoss
from .serializers import AnalysisTypeSerializer, LabSessionSerializer, SessionConsumptionSerializer


class AnalysisTypeListCreateView(generics.ListCreateAPIView):
	queryset = AnalysisType.objects.all()
	serializer_class = AnalysisTypeSerializer
	permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class AnalysisTypeDetailView(generics.RetrieveUpdateDestroyAPIView):
	queryset = AnalysisType.objects.all()
	serializer_class = AnalysisTypeSerializer
	permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class LabSessionListCreateView(generics.ListCreateAPIView):
	serializer_class = LabSessionSerializer
	permission_classes = [permissions.IsAuthenticated]

	def get_queryset(self):
		return LabSession.objects.select_related('analysis_type', 'technician').prefetch_related('consumptions')

	def perform_create(self, serializer):
		serializer.save(technician=self.request.user)


class LabSessionDetailView(generics.RetrieveUpdateDestroyAPIView):
	serializer_class = LabSessionSerializer
	permission_classes = [permissions.IsAuthenticated]

	def get_queryset(self):
		return LabSession.objects.select_related('analysis_type', 'technician').prefetch_related('consumptions')


class SessionConsumptionListCreateView(generics.ListCreateAPIView):
	serializer_class = SessionConsumptionSerializer
	permission_classes = [permissions.IsAuthenticated]

	def get_queryset(self):
		return SessionConsumption.objects.filter(session_id=self.kwargs['session_id']).select_related('product')

	def perform_create(self, serializer):
		serializer.save(session_id=self.kwargs['session_id'])


class LabSessionStartView(generics.UpdateAPIView):
	queryset = LabSession.objects.all()
	serializer_class = LabSessionSerializer
	permission_classes = [permissions.IsAuthenticated]
	http_method_names = ['patch']

	def patch(self, request, *args, **kwargs):
		session = self.get_object()
		session.status = 'in_progress'
		session.started_at = timezone.now()
		session.save(update_fields=('status', 'started_at', 'updated_at'))
		return Response(self.get_serializer(session).data, status=status.HTTP_200_OK)


class LabSessionCompleteView(generics.UpdateAPIView):
	queryset = LabSession.objects.all()
	serializer_class = LabSessionSerializer
	permission_classes = [permissions.IsAuthenticated]
	http_method_names = ['patch']

	def patch(self, request, *args, **kwargs):
		session = self.get_object()
		session.status = 'completed'
		session.completed_at = timezone.now()
		session.save(update_fields=('status', 'completed_at', 'updated_at'))
		return Response(self.get_serializer(session).data, status=status.HTTP_200_OK)


class LabSessionValidateView(generics.UpdateAPIView):
	queryset = LabSession.objects.all()
	serializer_class = LabSessionSerializer
	permission_classes = [permissions.IsAuthenticated]
	http_method_names = ['post']

	@transaction.atomic
	def post(self, request, *args, **kwargs):
		session = self.get_object()
		if session.status == 'completed':
			return Response({'error': 'La session est déjà validée.'}, status=status.HTTP_400_BAD_REQUEST)
		consumptions = request.data.get('consumptions', [])
		losses = request.data.get('losses', [])
		for item in consumptions:
			self._apply_movement(session, item, 'Consommation de session')
		for item in losses:
			quantity = float(item.get('quantity', 0))
			if quantity <= 0:
				continue
			loss = SessionLoss.objects.create(
				session=session,
				product_id=item['product_id'],
				quantity=quantity,
				reason=item.get('reason', 'other'),
				comment=item.get('comment', ''),
			)
			self._apply_movement(session, item, 'Perte: ' + loss.get_reason_display())
		session.status = 'completed'
		session.completed_at = timezone.now()
		session.save(update_fields=('status', 'completed_at', 'updated_at'))
		return Response(self.get_serializer(session).data, status=status.HTTP_200_OK)

	def _apply_movement(self, session, item, reason):
		product = Product.objects.select_for_update().get(pk=item['product_id'])
		quantity = float(item.get('actual_quantity', item.get('quantity', 0)))
		if quantity <= 0 or product.stock_quantity < quantity:
			raise serializers.ValidationError('Stock insuffisant pour cette session.')
		before = product.stock_quantity
		product.stock_quantity -= quantity
		product.is_low_stock = product.stock_quantity <= product.minimum_stock
		product.save(update_fields=('stock_quantity', 'is_low_stock', 'updated_at'))
		StockMovement.objects.create(
			product=product,
			user=session.technician,
			movement_type='exit',
			quantity=quantity,
			stock_before=before,
			stock_after=product.stock_quantity,
			reason=reason,
		)

# Create your views here.
