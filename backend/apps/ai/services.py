from datetime import timedelta, datetime
from django.utils import timezone
from apps.inventory.models import Product, StockMovement
from apps.notifications.models import Notification
from apps.ai.models import StockAnalysis
from django.db.models import Q, Avg


class StockAIAnalyzer:
    """Service d'analyse IA du stock"""

    @staticmethod
    def analyze_all_products(days_lookback=30):
        """Analyse tous les produits et génère des recommandations"""
        products = Product.objects.filter(is_active=True)
        
        for product in products:
            StockAIAnalyzer.analyze_product(product, days_lookback)

    @staticmethod
    def analyze_product(product, days_lookback=30):
        """Analyse un produit spécifique"""
        
        # Analyser le stock bas
        if product.stock_quantity <= product.minimum_stock:
            StockAIAnalyzer._create_low_stock_analysis(product, days_lookback)
        
        # Analyser l'expiration
        if product.expiration_date:
            StockAIAnalyzer._create_expiration_analysis(product)
        
        # Analyser le surstock
        if product.stock_quantity >= product.maximum_stock and product.maximum_stock > 0:
            StockAIAnalyzer._create_overstock_analysis(product)

    @staticmethod
    def _create_low_stock_analysis(product, days_lookback=30):
        """Crée une analyse pour stock bas"""
        
        # Calculer la consommation moyenne
        lookback_date = timezone.now() - timedelta(days=days_lookback)
        movements = StockMovement.objects.filter(
            product=product,
            movement_type='exit',
            created_at__gte=lookback_date
        )
        
        total_consumption = sum(m.quantity for m in movements)
        daily_consumption = total_consumption / days_lookback if days_lookback > 0 else 0
        
        # Estimer les jours restants
        if daily_consumption > 0:
            days_remaining = int(product.stock_quantity / daily_consumption)
        else:
            days_remaining = None
        
        # Déterminer la priorité
        if product.stock_quantity == 0:
            priority = 'critical'
        elif days_remaining and days_remaining < 7:
            priority = 'high'
        elif product.stock_quantity <= product.minimum_stock:
            priority = 'medium'
        else:
            priority = 'low'
        
        # Calculer la quantité recommandée
        recommended_qty = max(
            product.maximum_stock - product.stock_quantity,
            product.minimum_stock * 1.5
        )
        
        recommendation = f"Le stock de {product.name} est bas. "
        recommendation += f"Stock actuel: {product.stock_quantity} {product.unit}. "
        recommendation += f"Consommation moyenne: {daily_consumption:.2f} {product.unit}/jour. "
        
        if days_remaining is not None:
            recommendation += f"Jours restants estimés: {days_remaining}. "
        
        recommendation += f"Recommandation: Acheter {recommended_qty:.0f} {product.unit} auprès de {product.supplier.name if product.supplier else 'un fournisseur'}."
        
        # Créer ou mettre à jour l'analyse
        StockAnalysis.objects.update_or_create(
            product=product,
            analysis_type='low_stock',
            defaults={
                'priority': priority,
                'current_stock': product.stock_quantity,
                'minimum_stock': product.minimum_stock,
                'daily_consumption': daily_consumption,
                'estimated_days_remaining': days_remaining,
                'recommendation': recommendation,
                'recommended_quantity': recommended_qty,
                'is_resolved': False,
            }
        )
        
        # Créer une notification
        StockAIAnalyzer._create_notification(
            product=product,
            title=f"⚠️ Stock bas: {product.name}",
            message=recommendation,
            kind='warning'
        )

    @staticmethod
    def _create_expiration_analysis(product):
        """Crée une analyse pour expiration proche"""
        
        today = timezone.now().date()
        days_until = (product.expiration_date - today).days
        
        if days_until < 0:
            # Expiré
            priority = 'critical'
            analysis_type = 'expired'
            recommendation = f"{product.name} a expiré le {product.expiration_date.strftime('%d/%m/%Y')}. "
            recommendation += f"Quantité affectée: {product.stock_quantity} {product.unit}. "
            recommendation += "Action recommandée: Éliminer ou retourner au fournisseur."
            kind = 'error'
            title = f"🔴 Produit expiré: {product.name}"
        elif days_until <= 7:
            # Expiration proche
            priority = 'high'
            analysis_type = 'expiring'
            recommendation = f"{product.name} expire dans {days_until} jour(s) ({product.expiration_date.strftime('%d/%m/%Y')}). "
            recommendation += f"Stock: {product.stock_quantity} {product.unit}. "
            recommendation += "Recommandation: Utiliser en priorité ou réduire les nouveaux achats."
            kind = 'warning'
            title = f"⏰ Expiration proche: {product.name}"
        else:
            # Pas d'action immédiate
            return
        
        StockAnalysis.objects.update_or_create(
            product=product,
            analysis_type=analysis_type,
            defaults={
                'priority': priority,
                'current_stock': product.stock_quantity,
                'minimum_stock': product.minimum_stock,
                'days_until_expiration': days_until,
                'expiration_date': product.expiration_date,
                'recommendation': recommendation,
                'is_resolved': False,
            }
        )
        
        # Créer une notification
        StockAIAnalyzer._create_notification(
            product=product,
            title=title,
            message=recommendation,
            kind=kind
        )

    @staticmethod
    def _create_overstock_analysis(product):
        """Crée une analyse pour surstock"""
        
        priority = 'medium'
        recommendation = f"{product.name} est en surstock. "
        recommendation += f"Stock actuel: {product.stock_quantity} {product.unit}. "
        recommendation += f"Maximum recommandé: {product.maximum_stock} {product.unit}. "
        recommendation += "Recommandation: Réduire les achats ou augmenter la consommation."
        
        StockAnalysis.objects.update_or_create(
            product=product,
            analysis_type='overstock',
            defaults={
                'priority': priority,
                'current_stock': product.stock_quantity,
                'minimum_stock': product.minimum_stock,
                'recommendation': recommendation,
                'is_resolved': False,
            }
        )
        
        StockAIAnalyzer._create_notification(
            product=product,
            title=f"📦 Surstock: {product.name}",
            message=recommendation,
            kind='info'
        )

    @staticmethod
    def _create_notification(product, title, message, kind='info'):
        """Crée une notification pour tous les admins"""
        from apps.auth.models import User
        
        admins = User.objects.filter(role='admin')
        
        for admin in admins:
            # Vérifier si une notification similaire existe récemment
            recent = Notification.objects.filter(
                recipient=admin,
                title=title,
                created_at__gte=timezone.now() - timedelta(hours=24)
            ).exists()
            
            if not recent:
                Notification.objects.create(
                    recipient=admin,
                    title=title,
                    message=message,
                    kind=kind,
                    is_read=False
                )

    @staticmethod
    def get_critical_alerts():
        """Retourne tous les alertes critiques"""
        return StockAnalysis.objects.filter(
            priority='critical',
            is_resolved=False
        ).select_related('product')

    @staticmethod
    def get_alerts_for_user(user):
        """Retourne les alertes pertinentes pour un utilisateur"""
        return StockAnalysis.objects.filter(
            is_resolved=False
        ).select_related('product').order_by('-priority', '-created_at')
