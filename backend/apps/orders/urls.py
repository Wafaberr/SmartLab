from django.urls import path

from . import views

urlpatterns = [
    path('', views.OrderListCreateView.as_view(), name='orders'),
    path('<int:pk>/', views.OrderDetailView.as_view(), name='order_detail'),
    path('<int:order_id>/items/', views.OrderItemListCreateView.as_view(), name='order_items'),
    path('<int:pk>/receive/', views.OrderReceiveView.as_view(), name='order_receive'),
]
