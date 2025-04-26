from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('home.urls')),
    path('api/', include('home.api_urls')),
    path('auth/', include('authentication.urls')),
    path('api/auth/', include('authentication.api_urls')),
    path('users/', include('users.urls')),
    path('api/users/', include('users.api_urls')),
    path('logs/', include('logs.urls')),
    path('api/logs/', include('logs.api_urls')),
    path('api/new_device/', include('new_device.api_urls')),
    
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
