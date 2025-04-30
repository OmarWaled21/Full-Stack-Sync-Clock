from django.urls import path
from . import api_views

urlpatterns = [
    path('', api_views.api_logs_view, name='logs_api_view'),
    path('add_device_log/', api_views.create_device_log, name='add_device_log_api'),
    path('download/pdf/', api_views.download_logs_pdf, name='download_logs_pdf_api'),
    path('unsent-logs/', api_views.get_unsent_logs, name='get_unsent_logs'),
    path('mark-logs-sent/', api_views.mark_logs_as_sent, name='mark_logs_as_sent'),
    path('update-group-info/', api_views.update_group_info, name='update_group_info'),
    path('group-info/', api_views.get_group_info, name='get_group_info'),
]
