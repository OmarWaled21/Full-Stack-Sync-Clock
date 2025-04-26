from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from authentication.models import CustomUser
from .forms import AddUserForm, EditUserForm 

@login_required
def my_users(request):
    if request.user.rule != 'admin':
        return redirect('home')

    users = CustomUser.objects.filter(admin=request.user)
    return render(request, 'my_users.html', {'users': users})



@login_required
def edit_user(request, user_id):
    user = get_object_or_404(CustomUser, id=user_id, admin=request.user)
    
    if request.method == 'POST':
        form = EditUserForm(request.POST, instance=user)
        if form.is_valid():
            form.save()
            return redirect('my_users')
    else:
        form = EditUserForm(instance=user)
    
    return render(request, 'edit_user.html', {'form': form, 'user_obj': user})


@login_required
def delete_user(request, user_id):
    user = get_object_or_404(CustomUser, id=user_id, admin=request.user)
    
    if request.method == 'POST':
        user.delete()
        return redirect('my_users')
    
    return render(request, 'confirm_delete.html', {'user_obj': user})


@login_required
def add_user(request):
    if request.user.rule != 'admin':
        return redirect('home')

    if request.method == 'POST':
        form = AddUserForm(request.POST)
        if form.is_valid():
            user = form.save(commit=False)
            user.set_password(form.cleaned_data['password'])  # تأمين الباسورد
            user.admin = request.user  # ربطه بالـ admin الحالي
            user.save()
            return redirect('my_users')
    else:
        form = AddUserForm()

    return render(request, 'add_user.html', {'form': form})