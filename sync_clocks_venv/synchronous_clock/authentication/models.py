from django.contrib.auth.models import AbstractUser
from django.db import models
from django.conf import settings

class CustomUser(AbstractUser):
    RULE_CHOICES = (
        ('admin', 'Admin'),
        ('supervisor', 'Supervisor'),
        ('user', 'User'),
    )
    
    rule = models.CharField(max_length=50, choices=RULE_CHOICES, default='user')
    
    admin = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        limit_choices_to={'rule': 'admin'},
        related_name='sub_users'
    )

    def __str__(self):
        return self.username
