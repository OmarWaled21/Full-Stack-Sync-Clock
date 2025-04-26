# home/serializers.py
from rest_framework import serializers
from home.models import DeviceLog

class DeviceLogSerializer(serializers.ModelSerializer):
    device_name = serializers.CharField(source='device.name', read_only=True)
    device_id = serializers.CharField(source='device.device_id', read_only=True)

    class Meta:
        model = DeviceLog
        fields = ['id', 'device_id', 'device_name', 'timestamp', 'error_type', 'message']
