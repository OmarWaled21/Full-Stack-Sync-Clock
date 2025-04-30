from django.shortcuts import render, redirect
from django.http import JsonResponse
from .utils import get_master_time
from .forms import DeviceForm, MasterClockForm
from .models import ClockDevice, MasterClock
from rest_framework.authtoken.models import Token
from django.db.models import Case, When, Value, IntegerField

def home(request):
    if not request.user.is_authenticated:
        return redirect('login')

    if request.user.rule == 'admin':
        device_qs  = ClockDevice.objects.filter(admin=request.user)
    else:
        device_qs  = ClockDevice.objects.filter(admin=request.user.admin)
    
     # ترتيب حسب الحالة: green -> red -> gray
    status_order = Case(
        When(status='green', then=Value(0)),
        When(status='red', then=Value(1)),
        When(status='gray', then=Value(2)),
        default=Value(3),
        output_field=IntegerField()
    )

    devices = device_qs.annotate(status_order=status_order).order_by('status_order', 'name')
    
    # تحديث جميع الحالات قبل عرض الصفحة
    for device in devices:
        device.update_status()
    
    # تحديث الوقت
    master_time = get_master_time()

     # 👇 هنا أضف التوكين للكونتكست
    token = Token.objects.get(user=request.user).key

    if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
        data = {
            'current_time': master_time.strftime("%Y-%m-%d %H:%M:%S"),
            'total_devices': devices.count(),
            'status_counts': {
                'green': devices.filter(status='green').count(),
                'red': devices.filter(status='red').count(),
                'gray': devices.filter(status='gray').count(),
            },
            'devices': list(devices.values(
                'id', 'name', 'device_id', 'status', 
                'last_update', 'temperature', 
                'battery_level', 'wifi_strength',
                'rtc_error', 'sensor_error', 'low_battery'
            ))
        }
        return JsonResponse(data)

    context = {
        'token': token,
        'current_time': master_time,  # اعرض الوقت المحدث هنا
        'devices': devices,
        'total_devices': devices.count(),
        'status_counts': {
            'green': devices.filter(status='green').count(),
            'red': devices.filter(status='red').count(),
            'gray': devices.filter(status='gray').count(),
        },
    }
    return render(request, 'home.html', context)

def devices_partial(request):
    if request.user.rule == 'admin':
        device_qs  = ClockDevice.objects.filter(admin=request.user)
    else:
        device_qs  = ClockDevice.objects.filter(admin=request.user.admin)
        
     # ترتيب حسب الحالة: green -> red -> gray
    status_order = Case(
        When(status='green', then=Value(0)),
        When(status='red', then=Value(1)),
        When(status='gray', then=Value(2)),
        default=Value(3),
        output_field=IntegerField()
    )

    devices = device_qs.annotate(status_order=status_order).order_by('status_order', 'name')    
    
    # تحديث جميع الحالات قبل عرض الجزئية
    for device in devices:
        device.update_status()
    
    # تحديث الوقت
    master_time = get_master_time()
    
    return render(request, 'devices_partial.html', {
        'devices': devices, 
        'current_time': master_time,  # اعرض الوقت المحدث هنا أيضًا
    })

def device_details(request, device_id):
    try:
        device = ClockDevice.objects.get(id=device_id)
        device.update_status()  # مهم يحدث حالته قبل ما نرجع البيانات

        # تحديث الوقت
        master_time = get_master_time()

        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
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
                'current_time': master_time.strftime("%Y-%m-%d %H:%M:%S")  # إضافة الوقت المحدث للـ response
            }
            return JsonResponse(data)

        context = {
            'device': device,
            'current_time': master_time,  # اعرض الوقت المحدث هنا
        }
        return render(request, 'device_details.html', context)
    except ClockDevice.DoesNotExist:
        return redirect('home')

def edit_device(request, device_id):
    device = ClockDevice.objects.get(id=device_id)

    # صلاحية الوصول: فقط الأدمن أو صاحب الجهاز
    if request.user.rule != 'admin' and request.user != device.admin:
        return redirect('home')

    if request.method == 'POST':
        form = DeviceForm(request.POST, instance=device)
        if form.is_valid():
            form.save()
            return redirect('device_details', device_id=device.id)
    else:
        form = DeviceForm(instance=device)

    return render(request, 'edit_device.html', {'form': form, 'device': device})

def edit_master_clock(request):
    try:
        master_clock = MasterClock.objects.first()

        if request.user.rule != 'admin':
            return redirect('home')

        if request.method == 'POST':
            form = MasterClockForm(request.POST, instance=master_clock)
            if form.is_valid():
                form.save()
                return redirect('home')
        else:
            form = MasterClockForm(
                instance=master_clock,
                initial={'current_time': master_clock.get_adjusted_time()}
            )

        return render(request, 'edit_master_clock.html', {'form': form, 'master_clock': master_clock})

    except MasterClock.DoesNotExist:
        return redirect('home')

