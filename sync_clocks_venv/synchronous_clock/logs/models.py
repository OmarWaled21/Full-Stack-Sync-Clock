from django.conf import settings
from django.db import models
from home.utils import get_master_time

# Create your models here.
class DeviceLog(models.Model):
    device = models.ForeignKey('home.ClockDevice', on_delete=models.CASCADE)
    timestamp = models.DateTimeField(default=get_master_time)
    error_type = models.CharField(max_length=100)
    message = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.device.name or self.device.device_id} - {self.error_type} - {self.timestamp.strftime('%Y-%m-%d %H:%M:%S')}"
    
    def get_log_info(self):
        return {
            'source': self.device.name or self.device.device_id,
            'timestamp': self.timestamp,
            'type': self.error_type,
            'message': self.message,
        }
        
    
class AdminLog(models.Model):
    admin = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='admin_logs',
        limit_choices_to={'rule': 'admin'}
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='user_logs'
    )
    timestamp = models.DateTimeField(default=get_master_time)
    action = models.CharField(max_length=50)  # مثل: login, logout
    message = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.user.username} - {self.action} - {self.timestamp.strftime('%Y-%m-%d %H:%M:%S')}"
    
    def get_log_info(self):
        return {
            'source': f"{self.user.username} (User)",
            'timestamp': self.timestamp,
            'type': self.action,
            'message': self.message,
        }