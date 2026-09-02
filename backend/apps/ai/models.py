from django.db import models
from django.conf import settings
from django.utils import timezone
from datetime import timedelta


class StockAnalysis(models.Model):
    """Analyse IA du stock et prédictions"""
    ALERT_PRIORITY = [
        ('critical', 'Critique'),
        ('high', 'Haute'),
        ('medium', 'Moyenne'),
        ('low', 'Basse'),
    ]

    RECOMMENDATION_TYPE = [
        ('low_stock', 'Stock Bas'),
        ('expiring', 'Expiration Proche'),
        ('expired', 'Expiré'),
        ('overstock', 'Surstock'),
        ('trend', 'Tendance'),
    ]

    product = models.ForeignKey('inventory.Product', on_delete=models.CASCADE, related_name='ai_analyses')
    analysis_type = models.CharField(max_length=20, choices=RECOMMENDATION_TYPE)
    priority = models.CharField(max_length=20, choices=ALERT_PRIORITY, default='medium')
    
    # Données d'analyse
    current_stock = models.FloatField()
    minimum_stock = models.FloatField()
    daily_consumption = models.FloatField(default=0, help_text='Consommation moyenne par jour')
    estimated_days_remaining = models.IntegerField(null=True, blank=True, help_text='Jours avant rupture')
    
    # Pour les expirations
    days_until_expiration = models.IntegerField(null=True, blank=True)
    expiration_date = models.DateField(null=True, blank=True)
    
    # Recommandations
    recommendation = models.TextField()
    recommended_quantity = models.FloatField(null=True, blank=True, help_text='Quantité recommandée à acheter')
    
    # Métadonnées
    is_resolved = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-priority', '-created_at']
        unique_together = ('product', 'analysis_type')

    def __str__(self):
        return f"{self.product.name} - {self.get_analysis_type_display()}"


class AIInsight(models.Model):
    """Insights et prédictions générales du système"""
    INSIGHT_TYPE = [
        ('stock_forecast', 'Prévision de Stock'),
        ('cost_optimization', 'Optimisation des Coûts'),
        ('seasonal_trend', 'Tendance Saisonnière'),
        ('supplier_performance', 'Performance Fournisseur'),
    ]

    insight_type = models.CharField(max_length=30, choices=INSIGHT_TYPE)
    title = models.CharField(max_length=255)
    description = models.TextField()
    affected_products = models.ManyToManyField('inventory.Product', blank=True)
    
    data_json = models.JSONField(default=dict, help_text='Données additionnelles en JSON')
    
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.get_insight_type_display()} - {self.title}"
