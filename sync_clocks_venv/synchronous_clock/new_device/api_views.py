from rest_framework.decorators import api_view, authentication_classes, permission_classes
from rest_framework.authentication import TokenAuthentication
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from home.models import ClockDevice
from home.serializers import ClockDeviceSerializer
from django.contrib.auth import get_user_model
from rest_framework.exceptions import AuthenticationFailed

User = get_user_model()

@api_view(['POST'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def add_device(request):
    device_id = request.data.get('device_id')
    temperature = request.data.get('temperature')
    wifi_strength = request.data.get('wifi_strength')
    battery_level = request.data.get('battery_level')
    name = request.data.get('name')
    firmware_url = request.data.get('firmware_url')
    last_update = request.data.get('last_update')
    

    if not device_id:
        return Response({'error': 'device_id is required'}, status=status.HTTP_400_BAD_REQUEST)

    user = request.user
    device = ClockDevice.objects.filter(device_id=device_id).first()

    if device:
        # إذا كان الجهاز موجود بالفعل، نعرض رسالة تفيد بذلك بدلاً من تحديثه
        return Response({'error': 'Device already exists'}, status=status.HTTP_400_BAD_REQUEST)

    # إذا لم يكن الجهاز موجودًا، نقوم بإضافته
    device = ClockDevice.objects.create(
        device_id=device_id,
        admin=user,
        temperature=temperature,
        wifi_strength=wifi_strength,
        battery_level=battery_level,
        name=name,
        firmware_url=firmware_url,
        last_update=last_update
    )

    serializer = ClockDeviceSerializer(device)
    return Response(serializer.data, status=status.HTTP_201_CREATED)



@api_view(['PUT'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def update_device(request, device_id):
    temperature = request.data.get('temperature')
    wifi_strength = request.data.get('wifi_strength')
    battery_level = request.data.get('battery_level')
    name = request.data.get('name')
    firmware_url = request.data.get('firmware_url')
    rtc_error = request.data.get('rtc_error')
    sensor_error = request.data.get('sensor_error')
    low_battery = request.data.get('low_battery')
    last_update = request.data.get('last_update')

    try:
        # نحاول جلب الجهاز بناءً على الـ device_id
        device = ClockDevice.objects.get(device_id=device_id)

        # تأكد من أن المستخدم هو الذي يمتلك الجهاز أو أنه أدمن
        if device.admin != request.user and request.user.rule != 'admin':
            raise AuthenticationFailed('You do not have permission to update this device.')

        # تحديث البيانات فقط إذا كانت موجودة في الطلب
        if temperature is not None:
            device.temperature = temperature
        if wifi_strength is not None:
            device.wifi_strength = wifi_strength
        if battery_level is not None:
            device.battery_level = battery_level
        if name is not None:
            device.name = name
        if firmware_url is not None:
            device.firmware_url = firmware_url
        if rtc_error is not None:
            device.rtc_error = rtc_error
        if sensor_error is not None:
            device.sensor_error = sensor_error
        if low_battery is not None:
            device.low_battery = low_battery
        if last_update is not None:
            device.last_update = last_update

        # حفظ التحديثات
        device.save()

        # إرجاع البيانات المحدثة
        serializer = ClockDeviceSerializer(device)
        return Response(serializer.data, status=status.HTTP_200_OK)

    except ClockDevice.DoesNotExist:
        return Response({"error": "Device not found."}, status=status.HTTP_404_NOT_FOUND)



@api_view(['DELETE'])
@authentication_classes([TokenAuthentication])
@permission_classes([IsAuthenticated])
def delete_device(request, device_id):
    try:
        # نحاول جلب الجهاز بناءً على الـ device_id
        device = ClockDevice.objects.get(device_id=device_id)

        # تأكد من أن المستخدم هو الذي يمتلك الجهاز أو أنه أدمن
        if device.admin != request.user and request.user.rule != 'admin':
            raise AuthenticationFailed('You do not have permission to delete this device.')

        # حذف الجهاز من قاعدة البيانات
        device.delete()

        # إرجاع استجابة بنجاح
        return Response({"message": "Device deleted successfully."}, status=status.HTTP_204_NO_CONTENT)

    except ClockDevice.DoesNotExist:
        return Response({"error": "Device not found."}, status=status.HTTP_404_NOT_FOUND)
    