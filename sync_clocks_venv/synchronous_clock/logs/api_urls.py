from django.urls import path
from . import api_views

urlpatterns = [
    path('', api_views.api_logs_view, name='logs_api_view'),
    path('download/pdf/', api_views.download_logs_pdf, name='download_logs_pdf_api'),
]
