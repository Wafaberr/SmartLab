from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    dependencies = [
        ('inventory', '0002_alter_product_image'),
        ('laboratory', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='AnalysisRecipe',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('quantity_per_sample', models.FloatField()),
                ('unit', models.CharField(blank=True, max_length=50)),
                ('analysis_type', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='recipes', to='laboratory.analysistype')),
                ('product', models.ForeignKey(on_delete=django.db.models.deletion.PROTECT, related_name='analysis_recipes', to='inventory.product')),
            ],
            options={
                'unique_together': {('analysis_type', 'product')},
            },
        ),
    ]
