from rest_framework import serializers
from .models import ClockDevice

class ClockDeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = ClockDevice
        fields = '__all__'
        
        
class DeviceFormSerializer(serializers.ModelSerializer):
    class Meta:
        model = ClockDevice
        fields = ['name', 'status', 'temperature', 'battery_level', 'wifi_strength', 'rtc_error', 'sensor_error', 'low_battery']  # Add more fields as needed