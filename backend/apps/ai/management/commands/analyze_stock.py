from django.core.management.base import BaseCommand
from apps.ai.services import StockAIAnalyzer


class Command(BaseCommand):
    help = 'Lance l\'analyse IA complète du stock et génère les recommandations'

    def add_arguments(self, parser):
        parser.add_argument(
            '--days',
            type=int,
            default=30,
            help='Nombre de jours à analyser pour la consommation (défaut: 30)'
        )

    def handle(self, *args, **options):
        days_lookback = options['days']
        self.stdout.write(f'Lancement de l\'analyse pour les {days_lookback} derniers jours...')
        
        try:
            StockAIAnalyzer.analyze_all_products(days_lookback=days_lookback)
            self.stdout.write(self.style.SUCCESS('✓ Analyse complétée avec succès'))
        except Exception as e:
            self.stdout.write(self.style.ERROR(f'✗ Erreur: {str(e)}'))
