from django.db import models
from .utils import get_master_time
from datetime import timedelta
from django.conf import settings
from logs.models import DeviceLog 
import requests 
from django.utils import timezone

class MasterClock(models.Model):
    time_difference = models.IntegerField(default=0)  # الفرق بالثواني بين الوقت الفعلي والوقت الذي اختاره المستخدم

    def set_time(self, new_time):
        """يحسب الفرق بين الوقت الجديد و timezone.now()"""
        time_diff = int((new_time - timezone.now()).total_seconds())
        self.time_difference = time_diff
        self.save()

    def get_adjusted_time(self):
        """يرجع الوقت المعدل بناءً على الفرق المخزن"""
        return timezone.now() + timedelta(seconds=self.time_difference)

class ClockDevice(models.Model):
    STATUS_CHOICES = [
        ('green', 'Green (OK)'),
        ('red', 'Red (Error)'),
        ('gray', 'Gray (Disconnected)'),
    ]
    admin = models.ForeignKey(
        settings.AUTH_USER_MODEL,      # يربط بموديل CustomUser
        on_delete=models.CASCADE,      # لو الأدمن اتحذف، تمسح أجهزته
        related_name='clock_devices',   # تقدر تستخدم user.clock_devices.all()
    )
    device_id = models.CharField(max_length=100, unique=True)
    name = models.CharField(max_length=100, blank=True, null=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='gray')
    temperature = models.FloatField(null=True, blank=True)
    wifi_strength = models.IntegerField(null=True, blank=True)  # قوة الواي فاي (dBm)
    battery_level = models.IntegerField(null=True, blank=True)  # نسبة البطارية (0-100)
    rtc_error = models.BooleanField(default=False)
    sensor_error = models.BooleanField(default=False)
    low_battery = models.BooleanField(default=False)
    last_update = models.DateTimeField(auto_now=True)
    temperature_max_threshold = models.FloatField(default=40.0)
    temperature_min_threshold = models.FloatField(default=-20.0)  
    firmware_version = models.CharField(max_length=20, default='1.0.0')
    firmware_url = models.URLField(blank=True, null=True)
    last_calibrated = models.DateTimeField(default=timezone.now)
    is_deleted = models.BooleanField(default=False)
    

    def __str__(self):
        return self.name or self.device_id
    
    def needs_calibration(self):
        reference_date = self.last_calibrated or self.created_at
        return (timezone.now() - reference_date).days >= 180  # 6 شهور

    def check_connection(self):
        """التحقق من اتصال الجهاز (إذا كان متصلاً خلال آخر 5 دقائق)"""
        return get_master_time() - self.last_update < timedelta(minutes=5)

    def check_wifi_strength(self):
        """التحقق من قوة إشارة الواي فاي"""
        return self.wifi_strength is None or self.wifi_strength >= -80

    def check_battery(self):
        """التحقق من حالة البطارية"""
        self.low_battery = self.battery_level is not None and self.battery_level < 20
        return not self.low_battery

    def check_sensors(self):
        """التحقق من حالة المستشعرات"""
        temp_error = False
        
        if self.temperature is None:
            temp_error = True
        else:
            if self.temperature == -127:
                temp_error = True
            elif self.temperature == 80:
                temp_error = True
            elif self.temperature > self.temperature_max_threshold or self.temperature < self.temperature_min_threshold:
                temp_error = True
        
        # تحديث حالة sensor_error بناءً على قراءة الحرارة
        self.sensor_error = temp_error or self.rtc_error
        
        return not self.sensor_error

    def update_status(self):
        """تحديث حالة الجهاز تلقائياً بناءً على جميع الشروط"""
        # حفظ الحالة الحالية قبل التحديث
        old_status = self.status
        old_rtc_error = self.rtc_error
        old_sensor_error = self.sensor_error
        old_low_battery = self.low_battery
        
        # التحقق من جميع الشروط
        is_connected = self.check_connection()
        good_wifi = self.check_wifi_strength()
        good_battery = self.check_battery()
        good_sensors = self.check_sensors()
        
        # تحديث الحالة بناءً على الشروط
        if not is_connected or not good_wifi:
            new_status = 'gray'
        elif not good_battery or not good_sensors:
            new_status = 'red'
        else:
            new_status = 'green'
        
        # تحديث الحالة فقط إذا تغيرت
        if new_status != old_status:
            self.status = new_status
            self.save()
        
        # تسجيل الأخطاء فقط إذا كانت جديدة أو تغيرت
        if self.rtc_error and (self.rtc_error != old_rtc_error):
            message = 'Real-Time Clock synchronization issue.'
            last_log = DeviceLog.objects.filter(
                device=self,
                error_type='RTC Error',
                message=message
            ).order_by('-timestamp').first()

            # إذا لم يكن هناك سجل سابق أو مر أكثر من دقيقة على السجل الأخير
            if not last_log or (timezone.now() - last_log.timestamp).seconds >= 60:
                DeviceLog.objects.create(
                    device=self,
                    error_type='RTC Error',
                    message=message
                )

        if self.sensor_error:
            temp_display = f" (Temp: {self.temperature}°C)" if self.temperature is not None else " (Temp: null)"
            message = f'Temperature sensor malfunction{temp_display}'
            
            last_log = DeviceLog.objects.filter(
                device=self,
                error_type='Sensor Error',
                message=message
            ).order_by('-timestamp').first()

            # إذا لم يكن هناك سجل سابق أو مر أكثر من دقيقة على السجل الأخير
            if not last_log or (timezone.now() - last_log.timestamp).seconds >= 60:
                DeviceLog.objects.create(
                    device=self,
                    error_type='Sensor Error',
                    message=message
                )
            
        if self.low_battery and (self.low_battery != old_low_battery):
            message = f'Battery level is {self.battery_level}%.'
            
            last_log = DeviceLog.objects.filter(
                device=self,
                error_type='Low Battery',
                message=message
            ).order_by('-timestamp').first()

            # إذا لم يكن هناك سجل سابق أو مر أكثر من دقيقة على السجل الأخير
            if not last_log or (timezone.now() - last_log.timestamp).seconds >= 60:
                DeviceLog.objects.create(
                    device=self,
                    error_type='Low Battery',
                    message=message
                )
        
        return self.status
    
    def update_firmware(self):
        """تحديث الفيرموير بناءً على الـ firmware_url"""
        if not self.firmware_url:
            raise ValueError("No firmware URL provided.")
        
        try:
            # استدعاء الرابط لتنزيل الفيرموير (فقط كمثال)
            response = requests.get(self.firmware_url)
            if response.status_code == 200:
                # عملية التحديث الفعلي هنا (مثلاً تحميل الفيرموير إلى الجهاز)
                # تحتاج إلى تخصيص هذه العملية حسب كيفية تحديث الفيرموير في جهازك
                self.firmware_version = 'Updated Version'  # تحديث النسخة الجديدة
                self.save()  # حفظ التحديث في قاعدة البيانات
                return True
            else:
                raise ValueError(f"Failed to download firmware. Status code: {response.status_code}")
        except Exception as e:
            raise ValueError(f"Error updating firmware: {str(e)}")
    
    def clear_firmware_url_if_updated(self, new_version):
        if new_version == self.firmware_version:
            self.firmware_url = None
            self.save()

