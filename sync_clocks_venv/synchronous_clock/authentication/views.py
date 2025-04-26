from django.shortcuts import render, redirect
from django.contrib import messages
from django.contrib.auth import authenticate, login, logout

from logs.models import AdminLog
from django.contrib.auth.views import  PasswordResetConfirmView, PasswordResetCompleteView
from django.contrib.auth.forms import PasswordResetForm
from django.urls import reverse_lazy

# Create your views here.
def user_login(request):
    if request.user.is_authenticated:
        return redirect('home')
    else: 
        if request.method == 'POST':
            username = request.POST.get('username')
            password = request.POST.get('password')
            remember = request.POST.get('remember')

            user = authenticate(request, username=username, password=password)

            if user is not None:
                login(request, user)
                
                if user.rule != 'admin' and user.admin:
                    AdminLog.objects.create(
                        admin=user.admin,
                        user=user,
                        action='login',
                        message='User logged in.'
                    )
                
                # لو المستخدم معلم على Remember Me
                if remember:
                    request.session.set_expiry(1209600)  # 2 weeks
                else:
                    request.session.set_expiry(0)  # الجلسة تنتهي مع غلق المتصفح
                
                messages.success(request, 'You are now logged in.. Welcome :)')
                return redirect('home')
            else:
                messages.error(request, 'Invalid username or password, Please try again...')
                return redirect('login')
        else:
            return render(request, 'login.html')

def user_logout(request):
    logout(request)
    messages.success(request, 'You are now logged out.')
    
    if request.user.is_authenticated and request.user.rule != 'admin' and request.user.admin:
        AdminLog.objects.create(
            admin=request.user.admin,
            user=request.user,
            action='logout',
            message='User logged out.'
        )    
    
    return redirect('login')

def password_reset(request):
    if request.method == 'POST':
        form = PasswordResetForm(request.POST)
        if form.is_valid():
            form.save(
                request=request,
            )
            messages.success(request, 'Password reset link has been sent to your email.')
            return redirect('password_reset_done')
    else:
        form = PasswordResetForm()
    return render(request, 'password_reset.html', {'form': form})

def password_reset_done(request):
    return render(request, 'password_reset_done.html')

def password_reset_confirm(request, uidb64, token):
    return PasswordResetConfirmView.as_view(template_name='password_reset_confirm.html')(request, uidb64=uidb64, token=token)

def password_reset_complete(request):
    return PasswordResetCompleteView.as_view(template_name='password_reset_complete.html')(request)