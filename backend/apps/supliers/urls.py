from django.urls import path
from . import views

urlpatterns = [
    path('suppliers/', views.SupplierListCreateView.as_view(), name='suppliers_list'),
    path('suppliers/<int:pk>/', views.SupplierDetailView.as_view(), name='suppliers_detail'),
]
