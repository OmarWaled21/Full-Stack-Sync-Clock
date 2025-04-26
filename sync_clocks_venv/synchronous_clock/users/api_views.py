from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from authentication.models import CustomUser
from .serializers import UserSerializer, AddUserSerializer
from django.contrib.auth.models import User
from django.shortcuts import get_object_or_404

# الحصول على جميع المستخدمين المرتبطين بالـ admin
@api_view(['GET'])
def my_users(request):
    if request.user.rule != 'admin':
        return Response({'error': 'You do not have permission to access this resource.'}, status=status.HTTP_403_FORBIDDEN)

    users = CustomUser.objects.filter(admin=request.user)
    serializer = UserSerializer(users, many=True)
    return Response(serializer.data)

# تعديل بيانات المستخدم
@api_view(['GET', 'PUT'])
def edit_user(request, username):
    user = get_object_or_404(CustomUser, id=username, admin=request.user)

    if request.method == 'PUT':
        serializer = UserSerializer(user, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    # عرض بيانات المستخدم
    serializer = UserSerializer(user)
    return Response(serializer.data)

# حذف مستخدم
@api_view(['DELETE'])
def delete_user(request, username):
    user = get_object_or_404(CustomUser, id=username, admin=request.user)
    
    if request.method == 'DELETE':
        user.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

# إضافة مستخدم جديد
@api_view(['POST'])
def add_user(request):
    if request.user.rule != 'admin':
        return Response({'error': 'You do not have permission to add users.'}, status=status.HTTP_403_FORBIDDEN)

    if request.method == 'POST':
        serializer = AddUserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            user.set_password(request.data['password'])  # تأمين الباسورد
            user.admin = request.user  # ربطه بالـ admin الحالي
            user.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
