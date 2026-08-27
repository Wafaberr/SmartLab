from django.urls import path

from . import views

urlpatterns = [
    path('analysis-types/', views.AnalysisTypeListCreateView.as_view(), name='laboratory_analysis_types'),
    path('analysis-types/<int:pk>/', views.AnalysisTypeDetailView.as_view(), name='laboratory_analysis_type_detail'),
    path('analysis-types/<int:analysis_type_id>/recipes/', views.AnalysisRecipeListCreateView.as_view(), name='laboratory_analysis_recipes'),
    path('sessions/', views.LabSessionListCreateView.as_view(), name='laboratory_sessions'),
    path('sessions/<int:pk>/', views.LabSessionDetailView.as_view(), name='laboratory_session_detail'),
    path('sessions/<int:session_id>/consumptions/', views.SessionConsumptionListCreateView.as_view(), name='laboratory_consumptions'),
    path('sessions/<int:pk>/start/', views.LabSessionStartView.as_view(), name='laboratory_session_start'),
    path('sessions/<int:pk>/complete/', views.LabSessionCompleteView.as_view(), name='laboratory_session_complete'),
    path('sessions/<int:pk>/validate/', views.LabSessionValidateView.as_view(), name='laboratory_session_validate'),
]
