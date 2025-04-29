# home/api_views.py
from datetime import datetime
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from logs.models import AdminGroupInfo, DeviceLog, AdminLog
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


@api_view(['GET'])
def get_unsent_logs(request):
    device_logs = DeviceLog.objects.filter(sent=False)
    admin_logs = AdminLog.objects.filter(sent=False)

    all_logs = list(device_logs) + list(admin_logs)
    all_logs = [log.get_log_info() for log in all_logs]

    # ترتيب حسب التاريخ
    all_logs.sort(key=lambda log: log['timestamp'])

    return Response(all_logs)


@api_view(['POST'])
def mark_logs_as_sent(request):
    ids = request.data.get('ids', [])
    DeviceLog.objects.filter(id__in=ids).update(sent=True)
    AdminLog.objects.filter(id__in=ids).update(sent=True)
    return Response({'status': 'ok'})



@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_group_info(request):
    token = request.data.get('token')
    whatsapp_is_active = request.data.get('whatsapp_is_active')  # 🛠️ الجديد: ناخد حالة السويتش
    gmail_is_active = request.data.get('gmail_is_active')
    sms_is_active = request.data.get('sms_is_active')
    group_url = request.data.get('group_url')
    email = request.data.get('email')
    phone_number = request.data.get('phone_number')
    
    if not token:
        return Response({'error': 'Token are required'}, status=400)
    
    user = request.user

    if user.rule != 'admin':
        return Response({'error': 'Only admins can update group info'}, status=403)

    group_info, created = AdminGroupInfo.objects.get_or_create(admin=user)
    group_info.token = token
    group_info.group_id = group_url
    group_info.phone_number = phone_number
    group_info.email = email

    if whatsapp_is_active is not None:
        group_info.whatsapp_is_active = whatsapp_is_active  # 🛠️ الجديد: نحفظ حالة السويتش
    group_info.save()
    
    if gmail_is_active is not None:
        group_info.gmail_is_active = gmail_is_active
    group_info.save()
    
    if sms_is_active is not None:
        group_info.sms_is_active = sms_is_active
    group_info.save()

    return Response({
        'message': 'Token, Group URL, and Active State updated successfully',
        'token': token,
        'group_url': group_url,
        'whatsapp_is_active': group_info.whatsapp_is_active,
        'gmail_is_active': group_info.gmail_is_active,
        'sms_is_active': group_info.sms_is_active,
        'phone_number': group_info.phone_number,
        'email': group_info.email
    })


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_group_info(request):
    user = request.user

    if user.rule != 'admin':
        return Response({'error': 'Only admins can access group info'}, status=403)

    try:
        group_info = AdminGroupInfo.objects.get(admin=user)
        return Response({
            'token': group_info.token,
            'group_url': group_info.group_id,
            'whatsapp_is_active': group_info.whatsapp_is_active,  # 🛠️ الجديد: ترجع حالة السويتش
            'gmail_is_active': group_info.gmail_is_active,  # 🛠️ الجديد: ترجع حالة السويتش
            'sms_is_active': group_info.sms_is_active,  # 🛠️ الجديد: ترجع حالة السويتش
            'phone_number': group_info.phone_number,
            'updated_at': group_info.updated_at,
            'email': group_info.email
        })
    except AdminGroupInfo.DoesNotExist:
        return Response({'error': 'Group info not set yet.'}, status=400)
