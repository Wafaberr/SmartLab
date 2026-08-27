from django.db import transaction
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from .models import Category, Product, StockItem, StockMovement
from .serializers import (
    CategorySerializer,
    ProductSerializer,
    StockItemSerializer,
    StockMovementSerializer,
)


class IsAdmin(permissions.BasePermission):
    message = 'Seul un administrateur peut modifier les produits.'

    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.role == 'admin'
        )


class CategoryListCreateView(generics.ListCreateAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class CategoryDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class ProductListCreateView(generics.ListCreateAPIView):
    queryset = Product.objects.select_related('category').all()
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_permissions(self):
        return [IsAdmin()] if self.request.method == 'POST' else [permissions.IsAuthenticatedOrReadOnly()]


class ProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Product.objects.select_related('category').all()
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_permissions(self):
        return [IsAdmin()] if self.request.method in ('PUT', 'PATCH', 'DELETE') else [permissions.IsAuthenticatedOrReadOnly()]


class StockListCreateView(generics.ListCreateAPIView):
    queryset = StockItem.objects.select_related('product').all()
    serializer_class = StockItemSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class StockDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = StockItem.objects.select_related('product').all()
    serializer_class = StockItemSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class ProductMovementListCreateView(generics.ListCreateAPIView):
    serializer_class = StockMovementSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return StockMovement.objects.filter(product_id=self.kwargs['product_id']).select_related('user')

    @transaction.atomic
    def create(self, request, *args, **kwargs):
        product = Product.objects.select_for_update().get(pk=kwargs['product_id'])
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        movement_type = serializer.validated_data['movement_type']
        quantity = serializer.validated_data['quantity']
        if quantity <= 0:
            return Response({'error': 'La quantité doit être positive.'}, status=status.HTTP_400_BAD_REQUEST)
        before = product.stock_quantity
        after = before + quantity if movement_type == 'entry' else before - quantity
        if movement_type == 'exit' and after < 0:
            return Response({'error': 'Stock insuffisant.'}, status=status.HTTP_400_BAD_REQUEST)
        movement = serializer.save(product=product, user=request.user, stock_before=before, stock_after=after)
        product.stock_quantity = after
        product.is_low_stock = after <= product.minimum_stock
        product.save(update_fields=('stock_quantity', 'is_low_stock', 'updated_at'))
        return Response(self.get_serializer(movement).data, status=status.HTTP_201_CREATED)

