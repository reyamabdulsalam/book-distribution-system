from django.urls import path
from . import views

app_name = 'distribution'

urlpatterns = [
    # عرض الصفحات
    path('', views.index, name='index'),
    path('ministry/', views.ministry_dashboard, name='ministry'),
    path('governorate/', views.governorate_dashboard, name='governorate'),
    
    # API - المصادقة
    path('api/auth/login/', views.login_view, name='api_login'),
    path('api/users/login/', views.login_view, name='api_users_login'),
    path('api/auth/token/', views.login_view, name='api_token'),
    path('api/token/', views.login_view, name='api_token_alt'),
    path('api/auth/refresh/', views.refresh_token_view, name='api_refresh'),
    path('api/users/me/', views.user_profile_view, name='api_profile'),
]
