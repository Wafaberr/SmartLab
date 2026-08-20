from rest_framework import generics, permissions

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
