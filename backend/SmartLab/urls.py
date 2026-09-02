"""
URL configuration for SmartLab project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.contrib import admin
from django.urls import path, include
from rest_framework.schemas import get_schema_view
from django.views.generic import TemplateView
from django.conf.urls.static import static
from SmartLab import settings

urlpatterns = [
    path('admin/', admin.site.urls),
    path('auth/', include('apps.auth.urls')),
    path('inventory/', include('apps.inventory.urls')),
    path('laboratory/', include('apps.laboratory.urls')),
    path('orders/', include('apps.orders.urls')),
    path('notifications/', include('apps.notifications.urls')),
    path('ai/', include('apps.ai.urls')),
    path(
        'openapi/',
        get_schema_view(
            title='SmartLab API',
            description='API documentation for SmartLab authentication and management endpoints',
            version='1.0.0',
            public=True,
        ),
        name='openapi-schema',
    ),
    path(
        'docs/',
        TemplateView.as_view(template_name='swagger-ui.html', extra_context={'schema_url': 'openapi-schema'}),
        name='swagger-ui',
    ),
]
if settings.DEBUG:
    urlpatterns += static(
        settings.MEDIA_URL,
        document_root=settings.MEDIA_ROOT)
