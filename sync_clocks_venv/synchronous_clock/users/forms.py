from django import forms
from authentication.models import CustomUser

class EditUserForm(forms.ModelForm):
    class Meta:
        model = CustomUser
        fields = ['rule']
        widgets = {
            'rule': forms.Select(attrs={'class': 'form-select'}),
        }
        
class AddUserForm(forms.ModelForm):
    password = forms.CharField(widget=forms.PasswordInput, required=True)

    class Meta:
        model = CustomUser
        fields = ['username', 'email', 'rule', 'password']
        widgets = {
            'rule': forms.Select(attrs={'class': 'form-select'}),
        }