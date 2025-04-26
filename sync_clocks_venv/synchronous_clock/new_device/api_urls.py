# urls.py
from django.urls import path
from .api_views import add_device, delete_device,update_device

urlpatterns = [
    path('', add_device, name='add_device'),
    path('device/<str:device_id>/delete/', delete_device, name='delete_device'),
    path('device/<str:device_id>/update/', update_device, name='update_device'),
]