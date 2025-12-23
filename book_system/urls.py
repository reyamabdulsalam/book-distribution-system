from django.contrib import admin
from django.urls import path
from django.views.generic import TemplateView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', TemplateView.as_view(template_name='index.html'), name='index'),
    path('ministry/', TemplateView.as_view(template_name='ministry.html'), name='ministry'),
    path('governorate/', TemplateView.as_view(template_name='governorate.html'), name='governorate'),
]