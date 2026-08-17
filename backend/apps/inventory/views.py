from rest_framework import generics, permissions
from .models import Category, Product, StockItem
from .serializers import (
    CategorySerializer,
    ProductSerializer,
    StockItemSerializer,
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


class ProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Product.objects.select_related('category').all()
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class StockListCreateView(generics.ListCreateAPIView):
    queryset = StockItem.objects.select_related('product').all()
    serializer_class = StockItemSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class StockDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = StockItem.objects.select_related('product').all()
    serializer_class = StockItemSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

