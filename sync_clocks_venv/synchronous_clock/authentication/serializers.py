from .models import CustomUser
from rest_framework import serializers

# Serializer for Login (Optional if you want to handle login through API)
class LoginSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=255)
    password = serializers.CharField(write_only=True)

# Serializer for Password Reset
class PasswordResetSerializer(serializers.Serializer):
    email = serializers.EmailField()