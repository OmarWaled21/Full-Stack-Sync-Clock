from django.contrib import admin
from .models import ClockDevice
from authentication.models import CustomUser

class ClockDeviceAdmin(admin.ModelAdmin):
    list_display = ('name', 'device_id', 'admin', 'status')

    def formfield_for_foreignkey(self, db_field, request, **kwargs):
        if db_field.name == "admin":
            kwargs["queryset"] = CustomUser.objects.filter(rule='admin')
        return super().formfield_for_foreignkey(db_field, request, **kwargs)

admin.site.register(ClockDevice, ClockDeviceAdmin)
