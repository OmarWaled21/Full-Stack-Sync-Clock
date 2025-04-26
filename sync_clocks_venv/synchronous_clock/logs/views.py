from django.shortcuts import render, redirect
from django.http import JsonResponse
from logs.models import  DeviceLog, AdminLog
from django.http import HttpResponse
from weasyprint import HTML
from PIL import Image
import io
from django.template.loader import render_to_string
import base64
from datetime import timedelta
from home.utils import get_master_time
from datetime import datetime


def logs_view(request):
    device_id = request.GET.get('device_id')
    filter_date = request.GET.get('filter_date')

    # الحصول على السجلات الأساسية حسب صلاحية المستخدم
    if request.user.rule == 'admin':
        device_logs = DeviceLog.objects.filter(device__admin=request.user).select_related('device')
        user_logs = AdminLog.objects.filter(admin=request.user)
    else:
        device_logs = DeviceLog.objects.filter(device__admin=request.user.admin).select_related('device')
        user_logs = AdminLog.objects.filter(admin=request.user.admin, user=request.user)

    # فلترة حسب الجهاز إذا تم تحديده
    if device_id:
        device_logs = device_logs.filter(device__id=device_id)

    # فلترة حسب التاريخ مع معالجة أفضل للتاريخ
    if filter_date:
        try:
            # تحويل التاريخ إلى بداية اليوم بالتوقيت الموحد
            base_master_time = get_master_time()
            naive_start_date = datetime.strptime(filter_date, "%Y-%m-%d")
            start_date = base_master_time.replace(
                year=naive_start_date.year,
                month=naive_start_date.month,
                day=naive_start_date.day,
                hour=0,
                minute=0,
                second=0,
                microsecond=0
            )
            end_date = start_date + timedelta(days=1)

            # فلترة باستخدام توقيت الماستر
            device_logs = device_logs.filter(timestamp__gte=start_date, timestamp__lt=end_date)
            user_logs = user_logs.filter(timestamp__gte=start_date, timestamp__lt=end_date)
        except ValueError as e:
            print(f"خطأ في تحويل التاريخ: {e}")
            
            # تطبيق الفلترة على النطاق الزمني
            device_logs = device_logs.filter(timestamp__gte=start_date, timestamp__lt=end_date)
            user_logs = user_logs.filter(timestamp__gte=start_date, timestamp__lt=end_date)
        except ValueError as e:
            print(f"خطأ في تحويل التاريخ: {e}")

    # جمع السجلات وترتيبها
    all_logs = list(device_logs) + list(user_logs)
    if not all_logs:
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
            return JsonResponse({'html': '<tr><td colspan="4" class="text-center py-4">No logs found for selected date</td></tr>'})
        return render(request, 'logs.html', {'logs': []})

    all_logs = [log.get_log_info() for log in all_logs]
    all_logs.sort(key=lambda log: log['timestamp'], reverse=True)

    if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
        html = render_to_string('logs_rows.html', {'logs': all_logs})
        return JsonResponse({'html': html})

    return render(request, 'logs.html', {'logs': all_logs})


def download_logs_pdf(request):
    if not request.user.is_authenticated:
        return redirect('login')
    
    device_id = request.GET.get('device_id')
    filter_date = request.GET.get('filter_date')

    # Get logs based on user role
    if request.user.rule == 'admin':
        device_logs = DeviceLog.objects.filter(device__admin=request.user)
        user_logs = AdminLog.objects.filter(admin=request.user)
    else:
        device_logs = DeviceLog.objects.filter(device__admin=request.user.admin)
        user_logs = AdminLog.objects.filter(admin=request.user.admin, user=request.user)

    if device_id:
        device_logs = device_logs.filter(device__id=device_id)

    if filter_date:
        try:
            filter_date_obj = datetime.strptime(filter_date, "%Y-%m-%d")
            device_logs = device_logs.filter(timestamp__date=filter_date_obj.date())
            user_logs = user_logs.filter(timestamp__date=filter_date_obj.date())
        except ValueError:
            pass

    # دمج الـ logs في قائمة واحدة (لو عايز تعرضهم مع بعض)
    all_logs = list(device_logs) + list(user_logs)
    all_logs = [log.get_log_info() for log in all_logs]  # ← دي أهم خطوة
    all_logs.sort(key=lambda log: log['timestamp'], reverse=True)

    # Resize logo before base64 conversion
    logo_path = 'media/tomatiki_logo.png'
    with Image.open(logo_path) as img:
        # Resize to maximum width of 150px (adjust as needed)
        img.thumbnail((150, 150))
        
        # Convert to bytes
        img_bytes = io.BytesIO()
        img.save(img_bytes, format='PNG')
        logo_base64 = base64.b64encode(img_bytes.getvalue()).decode('utf-8')

    context = {
        'logs': all_logs,
        'now': get_master_time(),
        'logo_base64': logo_base64,  # اللوجو كـ base64
    }

    # Render HTML template
    html_string = render_to_string('logs_pdf.html', context)
    
    # Create PDF
    html = HTML(string=html_string)
    result = html.write_pdf()

    # Create HTTP response with PDF
    response = HttpResponse(result, content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="device_logs.pdf"'
    
    return response
