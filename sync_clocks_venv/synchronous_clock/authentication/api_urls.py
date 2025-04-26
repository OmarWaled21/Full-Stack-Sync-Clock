from django.urls import path
from rest_framework.authtoken.views import obtain_auth_token
from . import api_views

urlpatterns = [
    path('login/', api_views.UserLoginView.as_view(), name='api_login'),
    path('logout/', api_views.UserLogoutView.as_view(), name='api_logout'),
    path('password_reset/', api_views.PasswordResetView.as_view(), name='api_password_reset'),
    path('password_reset_confirm/<uidb64>/<token>/', api_views.PasswordResetConfirmView.as_view(), name='api_password_reset_confirm'),
    
    path('token/', obtain_auth_token, name='api_token_auth'),
]