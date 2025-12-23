from django.shortcuts import render
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from .models import Courier, SchoolUser
from .serializers import CourierSerializer, SchoolUserSerializer, LoginSerializer


def index(request):
    """الصفحة الرئيسية"""
    return render(request, 'index.html')


def ministry_dashboard(request):
    """لوحة تحكم الوزارة"""
    context = {
        'page_title': 'لوحة تحكم الوزارة'
    }
    return render(request, 'ministry.html', context)


def governorate_dashboard(request):
    """لوحة تحكم المحافظة"""
    context = {
        'page_title': 'لوحة تحكم المحافظة'
    }
    return render(request, 'governorate.html', context)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    """
    تسجيل دخول للمندوب أو المدرسة
    """
    serializer = LoginSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    username = serializer.validated_data['username']
    password = serializer.validated_data['password']
    
    # التحقق من بيانات الاعتماد
    user = authenticate(username=username, password=password)
    
    if user is None:
        return Response({
            'error': 'اسم المستخدم أو كلمة المرور غير صحيحة'
        }, status=status.HTTP_401_UNAUTHORIZED)
    
    if not user.is_active:
        return Response({
            'error': 'الحساب غير نشط'
        }, status=status.HTTP_403_FORBIDDEN)
    
    # إنشاء JWT tokens
    refresh = RefreshToken.for_user(user)
    
    # تحديد نوع المستخدم والبيانات الإضافية
    user_data = {
        'id': user.id,
        'username': user.username,
        'name': user.get_full_name() or user.username,
        'role': None,
    }
    
    # التحقق إذا كان مندوب
    try:
        courier = Courier.objects.get(user=user)
        user_data['role'] = 'courier'
        user_data['courier_id'] = courier.id
        user_data['name'] = courier.name
        user_data['phone'] = courier.phone
        if courier.governorate:
            user_data['governorate_id'] = courier.governorate.id
            user_data['governorate_name'] = courier.governorate.name
    except Courier.DoesNotExist:
        pass
    
    # التحقق إذا كان مستخدم مدرسة
    try:
        school_user = SchoolUser.objects.get(user=user)
        user_data['role'] = 'school'
        user_data['school_id'] = school_user.school.id
        user_data['school_name'] = school_user.school.name
    except SchoolUser.DoesNotExist:
        pass
    
    # إذا لم يكن له دور محدد، قد يكون admin
    if user_data['role'] is None:
        if user.is_superuser or user.is_staff:
            user_data['role'] = 'admin'
        else:
            return Response({
                'error': 'المستخدم ليس له دور محدد في النظام'
            }, status=status.HTTP_403_FORBIDDEN)
    
    return Response({
        'access': str(refresh.access_token),
        'refresh': str(refresh),
        'user': user_data
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([AllowAny])
def refresh_token_view(request):
    """
    تحديث access token باستخدام refresh token
    """
    refresh_token = request.data.get('refresh')
    
    if not refresh_token:
        return Response({
            'error': 'Refresh token is required'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        refresh = RefreshToken(refresh_token)
        return Response({
            'access': str(refresh.access_token)
        }, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({
            'error': 'Invalid or expired refresh token'
        }, status=status.HTTP_401_UNAUTHORIZED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_profile_view(request):
    """
    جلب معلومات المستخدم الحالي
    """
    user = request.user
    
    user_data = {
        'id': user.id,
        'username': user.username,
        'name': user.get_full_name() or user.username,
        'role': None,
    }
    
    # التحقق إذا كان مندوب
    try:
        courier = Courier.objects.get(user=user)
        user_data['role'] = 'courier'
        user_data['courier_id'] = courier.id
        user_data['name'] = courier.name
    except Courier.DoesNotExist:
        pass
    
    # التحقق إذا كان مستخدم مدرسة
    try:
        school_user = SchoolUser.objects.get(user=user)
        user_data['role'] = 'school'
        user_data['school_id'] = school_user.school.id
        user_data['school_name'] = school_user.school.name
    except SchoolUser.DoesNotExist:
        pass
    
    return Response(user_data, status=status.HTTP_200_OK)
