from rest_framework import serializers
from django.contrib.auth.models import User
from .models import School, Courier, SchoolUser, BookRequest


class UserSerializer(serializers.ModelSerializer):
    """Serializer لبيانات المستخدم"""
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']


class CourierSerializer(serializers.ModelSerializer):
    """Serializer لبيانات المندوب"""
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = Courier
        fields = ['id', 'user', 'name', 'phone', 'governorate', 'is_active']


class SchoolUserSerializer(serializers.ModelSerializer):
    """Serializer لبيانات مستخدم المدرسة"""
    user = UserSerializer(read_only=True)
    school_name = serializers.CharField(source='school.name', read_only=True)
    school_id = serializers.IntegerField(source='school.id', read_only=True)
    
    class Meta:
        model = SchoolUser
        fields = ['id', 'user', 'school_id', 'school_name', 'is_active']


class LoginSerializer(serializers.Serializer):
    """Serializer لتسجيل الدخول"""
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
