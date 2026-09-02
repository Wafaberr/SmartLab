from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'analyses', views.StockAnalysisViewSet, basename='stock-analysis')
router.register(r'insights', views.AIInsightViewSet, basename='ai-insight')

urlpatterns = [
    path('', include(router.urls)),
]
