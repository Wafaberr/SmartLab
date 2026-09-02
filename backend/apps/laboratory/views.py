from django.db import transaction
from apps.inventory.models import Product, StockMovement
from django.utils import timezone
from rest_framework import generics, permissions, serializers, status
from rest_framework.response import Response

from .models import AnalysisRecipe, AnalysisType, LabSession, SessionConsumption, SessionLoss
from .serializers import AnalysisRecipeSerializer, AnalysisTypeSerializer, LabSessionSerializer, SessionConsumptionSerializer


class AnalysisTypeListCreateView(generics.ListCreateAPIView):
	queryset = AnalysisType.objects.all()
	serializer_class = AnalysisTypeSerializer
	permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class AnalysisTypeDetailView(generics.RetrieveUpdateDestroyAPIView):
	queryset = AnalysisType.objects.all()
	serializer_class = AnalysisTypeSerializer
	permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class AnalysisRecipeListCreateView(generics.ListCreateAPIView):
	serializer_class = AnalysisRecipeSerializer
	permission_classes = [permissions.IsAuthenticated]

	def get_queryset(self):
		return AnalysisRecipe.objects.filter(
			analysis_type_id=self.kwargs['analysis_type_id']
		).select_related('product')

	def perform_create(self, serializer):
		serializer.save(analysis_type_id=self.kwargs['analysis_type_id'])


class LabSessionListCreateView(generics.ListCreateAPIView):
	serializer_class = LabSessionSerializer
	permission_classes = [permissions.IsAuthenticated]

	def get_queryset(self):
		return LabSession.objects.select_related('analysis_type', 'technician').prefetch_related('consumptions')

	def perform_create(self, serializer):
		session = serializer.save(technician=self.request.user)
		recipes = session.analysis_type.recipes.select_related('product')
		SessionConsumption.objects.bulk_create([
			SessionConsumption(
				session=session,
				product=recipe.product,
				planned_quantity=recipe.quantity_per_sample * session.sample_count,
				unit=recipe.unit or recipe.product.unit,
			)
			for recipe in recipes
		])


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
		try:
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
		except serializers.ValidationError as exc:
			message = self._validation_error_to_message(exc)
			return Response({'error': message}, status=status.HTTP_400_BAD_REQUEST)
		session.status = 'completed'
		session.completed_at = timezone.now()
		session.save(update_fields=('status', 'completed_at', 'updated_at'))
		return Response(self.get_serializer(session).data, status=status.HTTP_200_OK)

	def _validation_error_to_message(self, exc):
		detail = exc.detail
		if isinstance(detail, dict):
			for value in detail.values():
				if isinstance(value, list) and value:
					return str(value[0])
				if isinstance(value, str) and value:
					return value
		if isinstance(detail, list) and detail:
			return str(detail[0])
		return str(detail)

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
