from django.urls import path
from . import api_views

urlpatterns = [
    path('', api_views.api_home, name='clockdevice-list'),
    path('devices/partial/', api_views.api_devices_partial, name='api_devices_partial'),
    path('device/<str:device_id>/', api_views.api_device_details, name='api_device_details'),
    path('device/<str:device_id>/edit/', api_views.api_edit_device, name='api_edit_device'),
    path('update_firmware/<str:device_id>/', api_views.update_firmware, name='update_firmware'),
    path('master/update-time/', api_views.update_master_time, name='update_master_time'),
]