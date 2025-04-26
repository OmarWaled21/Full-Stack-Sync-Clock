from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('devices-partial/', views.devices_partial, name='devices_partial'),
    path('device/<int:device_id>/', views.device_details, name='device_details'),
    path('device/<int:device_id>/edit/', views.edit_device, name='edit_device'),
    path('master/update-time/', views.edit_master_clock, name='edit_master_clock'),
]
