from rest_framework import generics, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from django.utils import timezone
from .models import StockAnalysis, AIInsight
from .serializers import StockAnalysisSerializer, AIInsightSerializer
from .services import StockAIAnalyzer


class IsAdmin(permissions.BasePermission):
    message = 'Seul un administrateur peut accéder à cette ressource.'

    def has_permission(self, request, view):
        return bool(
            request.user
            and request.user.is_authenticated
            and request.user.role == 'admin'
        )


class StockAnalysisViewSet(ModelViewSet):
    serializer_class = StockAnalysisSerializer
    permission_classes = [permissions.IsAuthenticated]
    filterset_fields = ['priority', 'analysis_type', 'is_resolved', 'product']
    ordering_fields = ['priority', 'created_at', 'estimated_days_remaining']
    ordering = ['-priority', '-created_at']

    def get_queryset(self):
        """Les utilisateurs voient toutes les analyses, admins peuvent éditer"""
        return StockAnalysis.objects.select_related('product').all()

    def get_permissions(self):
        if self.request.method in ['PUT', 'PATCH', 'DELETE']:
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]

    @action(detail=False, methods=['post'])
    def run_analysis(self, request):
        """Lance l'analyse IA complète du stock"""
        if not request.user.role == 'admin':
            return Response(
                {'error': 'Seuls les admins peuvent lancer une analyse.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        try:
            days_lookback = request.data.get('days_lookback', 30)
            StockAIAnalyzer.analyze_all_products(days_lookback=int(days_lookback))
            
            critical = StockAnalysis.objects.filter(priority='critical').count()
            high = StockAnalysis.objects.filter(priority='high').count()
            
            return Response({
                'success': True,
                'message': 'Analyse complétée',
                'summary': {
                    'critical_alerts': critical,
                    'high_alerts': high,
                    'timestamp': timezone.now(),
                }
            })
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=False, methods=['get'])
    def critical_only(self, request):
        """Retourne uniquement les alertes critiques"""
        queryset = StockAnalysis.objects.filter(
            priority='critical',
            is_resolved=False
        ).select_related('product')
        
        serializer = self.get_serializer(queryset, many=True)
        return Response({
            'count': len(serializer.data),
            'results': serializer.data
        })

    @action(detail=True, methods=['post'])
    def mark_resolved(self, request, pk=None):
        """Marque une analyse comme résolue"""
        analysis = self.get_object()
        analysis.is_resolved = True
        analysis.save()
        
        return Response({
            'success': True,
            'message': 'Alerte marquée comme résolue',
            'analysis': self.get_serializer(analysis).data
        })

    @action(detail=False, methods=['post'])
    def resolve_all(self, request):
        """Marque toutes les analyses d'un type comme résolues"""
        if not request.user.role == 'admin':
            return Response(
                {'error': 'Seuls les admins peuvent faire ça.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        analysis_type = request.data.get('analysis_type')
        if not analysis_type:
            return Response(
                {'error': 'analysis_type est requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        updated = StockAnalysis.objects.filter(
            analysis_type=analysis_type,
            is_resolved=False
        ).update(is_resolved=True)
        
        return Response({
            'success': True,
            'message': f'{updated} analyses marquées comme résolues'
        })


class AIInsightViewSet(ModelViewSet):
    serializer_class = AIInsightSerializer
    permission_classes = [permissions.IsAuthenticated]
    filterset_fields = ['insight_type', 'is_active']
    ordering_fields = ['created_at', 'insight_type']
    ordering = ['-created_at']

    def get_queryset(self):
        return AIInsight.objects.filter(is_active=True)

    def get_permissions(self):
        if self.request.method in ['POST', 'PUT', 'PATCH', 'DELETE']:
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]
