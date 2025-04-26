from django.urls import path
from . import api_views

urlpatterns = [
    path('', api_views.my_users, name='my_users_api'),
    path('<int:username>/edit/', api_views.edit_user, name='edit_user_api'),
    path('<int:username>/delete/', api_views.delete_user, name='delete_user_api'),
    path('add/', api_views.add_user, name='add_user_api'),
]
