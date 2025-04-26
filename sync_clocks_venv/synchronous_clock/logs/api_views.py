# home/api_views.py
from datetime import datetime
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from logs.models import DeviceLog, AdminLog
from django.http import HttpResponse
from weasyprint import HTML
from PIL import Image
import io
from django.template.loader import render_to_string
from home.utils import get_master_time
import base64

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def api_logs_view(request):
    user = request.user
    device_id = request.GET.get('device_id')
    filter_date = request.GET.get('filter_date')

    # Logs حسب نوع المستخدم
    if user.rule == 'admin':
        device_logs = DeviceLog.objects.filter(device__admin=user)
        user_logs = AdminLog.objects.filter(admin=user)
    else:
        device_logs = DeviceLog.objects.filter(device__admin=user.admin)
        user_logs = AdminLog.objects.filter(admin=user.admin, user=user)

    # فلترة بالـ device_id لو موجود
    if device_id:
        device_logs = device_logs.filter(device__id=device_id)

    # فلترة بالتاريخ لو موجود
    if filter_date:
        try:
            date_obj = datetime.strptime(filter_date, "%Y-%m-%d")
            device_logs = device_logs.filter(timestamp__date=date_obj.date())
            user_logs = user_logs.filter(timestamp__date=date_obj.date())
        except ValueError:
            pass

    # دمج وتنسيق الـ logs
    all_logs = list(device_logs) + list(user_logs)
    all_logs = [log.get_log_info() for log in all_logs]  # دي أهم خطوة
    all_logs.sort(key=lambda log: log['timestamp'], reverse=True)

    return Response(all_logs)



@api_view(['GET'])
@permission_classes([IsAuthenticated])
def download_logs_pdf(request):
    user = request.user

    if user.rule == 'admin':
        device_logs = DeviceLog.objects.filter(device__admin=user)
        user_logs = AdminLog.objects.filter(admin=user)
    else:
        device_logs = DeviceLog.objects.filter(device__admin=user.admin)
        user_logs = AdminLog.objects.filter(admin=user.admin, user=user)

    all_logs = list(device_logs) + list(user_logs)
    all_logs = [log.get_log_info() for log in all_logs]
    all_logs.sort(key=lambda log: log['timestamp'], reverse=True)

    # Resize logo
    logo_path = 'media/tomatiki_logo.png'
    with Image.open(logo_path) as img:
        img.thumbnail((150, 150))
        img_bytes = io.BytesIO()
        img.save(img_bytes, format='PNG')
        logo_base64 = base64.b64encode(img_bytes.getvalue()).decode('utf-8')

    context = {
        'logs': all_logs,
        'now': get_master_time(),
        'logo_base64': logo_base64,
    }

    html_string = render_to_string('logs_pdf.html', context)
    html = HTML(string=html_string)
    result = html.write_pdf()

    response = HttpResponse(result, content_type='application/pdf')
    response['Content-Disposition'] = 'attachment; filename="device_logs.pdf"'
    return response

