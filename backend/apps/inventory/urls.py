from django.urls import path
from . import views

urlpatterns = [
    path('categories/', views.CategoryListCreateView.as_view(), name='inventory_categories'),
    path('categories/<int:pk>/', views.CategoryDetailView.as_view(), name='inventory_category_detail'),

    path('products/', views.ProductListCreateView.as_view(), name='inventory_products'),
    path('products/<int:pk>/', views.ProductDetailView.as_view(), name='inventory_product_detail'),

    path('stock/', views.StockListCreateView.as_view(), name='inventory_stock'),
    path('stock/<int:pk>/', views.StockDetailView.as_view(), name='inventory_stock_detail'),
    path('products/<int:product_id>/movements/', views.ProductMovementListCreateView.as_view(), name='inventory_product_movements'),
]
