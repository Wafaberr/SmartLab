from django.urls import path

from . import views


urlPatterns=[
    path('login',views.render)
]