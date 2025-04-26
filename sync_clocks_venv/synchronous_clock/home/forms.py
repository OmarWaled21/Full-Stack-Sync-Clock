from django import forms
from .models import ClockDevice, MasterClock
from django.utils import timezone

BOOLEAN_CHOICES = [(True, 'True'), (False, 'False')]

class DeviceForm(forms.ModelForm):
    class Meta:
        model = ClockDevice
        fields = ['name', 'rtc_error', 'sensor_error', 'temperature_max_threshold', 'temperature_min_threshold']
        widgets = {
            'name': forms.TextInput(attrs={'class': 'form-control text-primary border-primary', 'style': 'font-weight: bold;'}),
            'rtc_error': forms.Select(choices=BOOLEAN_CHOICES, attrs={'class': 'form-control text-primary border-primary', 'style': 'font-weight: bold;'}),
            'sensor_error': forms.Select(choices=BOOLEAN_CHOICES, attrs={'class': 'form-control text-primary border-primary', 'style': 'font-weight: bold;'}),
            'temperature_max_threshold': forms.NumberInput(attrs={'class': 'form-control text-primary border-primary', 'style': 'width: 100px; font-weight: bold;'}),
            'temperature_min_threshold': forms.NumberInput(attrs={'class': 'form-control text-primary border-primary', 'style': 'width: 100px; font-weight: bold;'}),
        }

    def __init__(self, *args, **kwargs):
        super(DeviceForm, self).__init__(*args, **kwargs)
        self.fields['name'].required = True
        self.fields['temperature_max_threshold'].label = "Max Temperature"
        self.fields['temperature_min_threshold'].label = "Min Temperature"

    def clean(self):
        cleaned_data = super().clean()
        min_temp = cleaned_data.get("temperature_min_threshold")
        max_temp = cleaned_data.get("temperature_max_threshold")

        if min_temp is not None and max_temp is not None and max_temp <= min_temp:
            raise forms.ValidationError("Max temperature must be greater than min temperature.")


class MasterClockForm(forms.ModelForm):
    current_time = forms.DateTimeField(
        label="Current Time",
        initial=timezone.now,
        widget=forms.DateTimeInput(attrs={
            'type': 'datetime-local',
            'class': 'form-control',
            'step': '1' 
        })
    )

    class Meta:
        model = MasterClock
        fields = []

    def save(self, commit=True):
        instance = self.instance
        new_time = self.cleaned_data['current_time']
        instance.set_time(new_time)
        return instance