from django.db import transaction
from rest_framework import generics, permissions, status
from rest_framework.response import Response

from apps.inventory.models import Product, StockMovement
from .models import Order, OrderItem
from .serializers import OrderItemSerializer, OrderSerializer


class OrderListCreateView(generics.ListCreateAPIView):
	serializer_class = OrderSerializer
	permission_classes = [permissions.IsAuthenticated]

	def get_queryset(self):
		return Order.objects.select_related('supplier', 'created_by').prefetch_related('items__product')

	def perform_create(self, serializer):
		serializer.save(created_by=self.request.user)


class OrderDetailView(generics.RetrieveUpdateDestroyAPIView):
	serializer_class = OrderSerializer
	permission_classes = [permissions.IsAuthenticated]

	def get_queryset(self):
		return Order.objects.select_related('supplier', 'created_by').prefetch_related('items__product')


class OrderItemListCreateView(generics.ListCreateAPIView):
	serializer_class = OrderItemSerializer
	permission_classes = [permissions.IsAuthenticated]

	def get_queryset(self):
		return OrderItem.objects.filter(order_id=self.kwargs['order_id']).select_related('product')

	def perform_create(self, serializer):
		serializer.save(order_id=self.kwargs['order_id'])


class OrderReceiveView(generics.GenericAPIView):
	permission_classes = [permissions.IsAuthenticated]

	@transaction.atomic
	def post(self, request, *args, **kwargs):
		try:
			order = Order.objects.select_for_update().prefetch_related('items').get(pk=kwargs['pk'])
		except Order.DoesNotExist:
			return Response({'error': 'Commande introuvable.'}, status=status.HTTP_404_NOT_FOUND)

		if order.status == 'received':
			return Response({'error': 'La commande est déjà reçue.'}, status=status.HTTP_400_BAD_REQUEST)

		for item in order.items.all():
			product = Product.objects.select_for_update().get(pk=item.product_id)
			before = product.stock_quantity
			product.stock_quantity += item.quantity
			product.is_low_stock = product.stock_quantity <= product.minimum_stock
			product.save(update_fields=('stock_quantity', 'is_low_stock', 'updated_at'))
			StockMovement.objects.create(
				product=product,
				user=request.user,
				movement_type='entry',
				quantity=item.quantity,
				stock_before=before,
				stock_after=product.stock_quantity,
				reason=f'Reception commande {order.reference}',
			)

		order.status = 'received'
		order.save(update_fields=('status', 'updated_at'))
		return Response(OrderSerializer(order).data, status=status.HTTP_200_OK)
