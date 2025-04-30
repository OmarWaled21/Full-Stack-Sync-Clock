# home/serializers.py
from rest_framework import serializers
from home.models import DeviceLog

from home.models import ClockDevice  # import this

class DeviceLogSerializer(serializers.ModelSerializer):
    device_id = serializers.CharField(write_only=True)  # Accept device_id from POST
    device_name = serializers.CharField(source='device.name', read_only=True)

    class Meta:
        model = DeviceLog
        fields = ['device_id', 'device_name', 'timestamp', 'error_type', 'message']

    def create(self, validated_data):
        device_id = validated_data.pop('device_id')
        try:
            device = ClockDevice.objects.get(device_id=device_id)
        except ClockDevice.DoesNotExist:
            raise serializers.ValidationError("Invalid device_id")

        return DeviceLog.objects.create(device=device, **validated_data)
