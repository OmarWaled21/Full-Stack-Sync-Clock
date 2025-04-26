from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .utils import get_master_time
from .models import ClockDevice, MasterClock
from .serializers import ClockDeviceSerializer, DeviceFormSerializer

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def api_home(request):
    try:
        # تحديد الأجهزة بناءً على صلاحيات المستخدم
        if request.user.rule == 'admin':
            devices = ClockDevice.objects.filter(admin=request.user)
        else:
            devices = ClockDevice.objects.filter(admin=request.user.admin)
        
        # تحديث جميع الحالات
        for device in devices:
            device.update_status()
            
         # الحصول على الفرق الزمني (time_difference) من الـ MasterClock
        master_clock = MasterClock.objects.first()  # الحصول على أول سجل في MasterClock
        time_difference = master_clock.time_difference if master_clock else 0  # استخدام 0 إذا لم يكن هناك سجل
        
        # إعداد البيانات للاستجابة
        data = {
            'current_time': get_master_time().strftime("%Y-%m-%d %H:%M:%S"),
            'time_difference': time_difference, 
            'total_devices': devices.count(),
            'status_counts': {
                'green': devices.filter(status='green').count(),
                'red': devices.filter(status='red').count(),
                'gray': devices.filter(status='gray').count(),
            },
            'devices': ClockDeviceSerializer(devices, many=True).data
        }
        
        return Response({
            "message": "Data retrieved successfully",
            "results": data
        })

    except Exception as e:
        return Response({
            "message": f"An error occurred: {str(e)}"
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def api_devices_partial(request):
    try:
        # تحديد الأجهزة بناءً على صلاحيات المستخدم
        if request.user.rule == 'admin':
            devices = ClockDevice.objects.filter(admin=request.user)
        else:
            devices = ClockDevice.objects.filter(admin=request.user.admin)
        
        # تحديث جميع الحالات
        for device in devices:
            device.update_status()
        
        # استخدام السيريالايزر لعرض البيانات
        serializer = ClockDeviceSerializer(devices, many=True)
        
        return Response({
            "message": "Devices retrieved successfully",
            "results": serializer.data
        })

    except Exception as e:
        return Response({
            "message": f"An error occurred: {str(e)}"
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def api_device_details(request, device_id):
    try:
        device = ClockDevice.objects.get(device_id=device_id)  # 👈 استخدم device_id بدل id
        device.update_status()

        data = {
            'name': device.name,
            'status': device.status,
            'temperature': device.temperature,
            'temperature_max_threshold': device.temperature_max_threshold,
            'temperature_min_threshold': device.temperature_min_threshold,
            'battery_level': device.battery_level,
            'wifi_strength': device.wifi_strength,
            'last_update': device.last_update.strftime("%Y-%m-%d %H:%M:%S"),
            'rtc_error': device.rtc_error,
            'sensor_error': device.sensor_error,
            'low_battery': device.low_battery,
            'firmware_version': device.firmware_version,  # إضافة firmware_version
            'firmware_url': device.firmware_url,  # إضافة firmware_url
        }

        return Response({
            "message": "Device details retrieved successfully",
            "results": data
        })

    except ClockDevice.DoesNotExist:
        return Response({
            "message": "Device not found"
        }, status=status.HTTP_404_NOT_FOUND)

    except Exception as e:
        return Response({
            "message": f"An error occurred: {str(e)}"
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        
@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def api_edit_device(request, device_id):
    try:
        # Retrieve the device using the device_id
        device = ClockDevice.objects.get(device_id=device_id)

        # Check user permissions: only the device owner or admin can edit
        if request.user.rule != 'admin' and request.user != device.admin:
            return Response({
                "message": "You do not have permission to edit this device"
            }, status=status.HTTP_403_FORBIDDEN)

        # Deserialize the incoming data
        serializer = DeviceFormSerializer(device, data=request.data, partial=True)
        if serializer.is_valid():
            # Save the updated device
            serializer.save()

            return Response({
                "message": "Device updated successfully",
                "results": serializer.data
            })
        else:
            return Response({
                "message": "Invalid data",
                "errors": serializer.errors
            }, status=status.HTTP_400_BAD_REQUEST)

    except ClockDevice.DoesNotExist:
        return Response({
            "message": "Device not found"
        }, status=status.HTTP_404_NOT_FOUND)

    except Exception as e:
        return Response({
            "message": f"An error occurred: {str(e)}"
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        
        
        
@api_view(['POST'])
def update_firmware(request, device_id):
    """API لتحديث الفيرموير لجهاز معين"""
    try:
        # البحث عن الجهاز بناءً على device_id
        device = ClockDevice.objects.get(device_id=device_id)

        # محاولة تحديث الفيرموير
        device.update_firmware()
        
        return Response({'message': 'Firmware update successful'}, status=status.HTTP_200_OK)
    
    except ClockDevice.DoesNotExist:
        return Response({'error': 'Device not found'}, status=status.HTTP_404_NOT_FOUND)
    except ValueError as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
    
    
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_master_time(request):
    try:
        # استقبل الـ time_difference كـ int من البيانات
        time_diff = request.data.get('time_difference')
        
        if time_diff is None:
            return Response({
                'message': 'time_difference is required (in seconds)'
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            time_diff = int(time_diff)
        except ValueError:
            return Response({
                'message': 'Invalid value for time_difference. It must be an integer.'
            }, status=status.HTTP_400_BAD_REQUEST)

        # افترض وجود master واحد فقط
        master = MasterClock.objects.first()
        if not master:
            master = MasterClock.objects.create(time_difference=time_diff)
        else:
            master.time_difference = time_diff
            master.save()

        return Response({
            'message': 'Master clock time difference updated successfully.',
            'time_difference': time_diff
        })

    except Exception as e:
        return Response({
            'message': f"An error occurred: {str(e)}"
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

