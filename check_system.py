#!/usr/bin/env python
"""
🔍 فحص سريع لجاهزية النظام
Quick System Readiness Check
"""

import os
import sys
import json
import subprocess

def print_step(step, msg):
    """طباعة خطوة فحص"""
    symbols = {
        'check': '✅',
        'warn': '⚠️ ',
        'error': '❌',
        'info': 'ℹ️ '
    }
    print(f"{symbols.get(step, '➡️')} {msg}")

def check_python_version():
    """تحقق من إصدار Python"""
    print("\n📦 Python Version Check")
    print("-" * 50)
    
    version = sys.version_info
    required = (3, 8)
    
    current_version = f"{version.major}.{version.minor}.{version.micro}"
    print_step('info', f"Current: Python {current_version}")
    
    if version[:2] >= required:
        print_step('check', f"Required: Python {required[0]}.{required[1]}+ ✓")
        return True
    else:
        print_step('error', f"Required: Python {required[0]}.{required[1]}+")
        return False

def check_django_packages():
    """تحقق من مكتبات Django"""
    print("\n📚 Django Packages Check")
    print("-" * 50)
    
    packages = {
        'django': 'Django',
        'rest_framework': 'Django REST Framework',
        'rest_framework_simplejwt': 'JWT Auth',
        'mysql': 'MySQL Connector',
        'mysqlclient': 'MySQL Client',
    }
    
    all_ok = True
    for package, name in packages.items():
        try:
            __import__(package)
            print_step('check', f"{name} installed ✓")
        except ImportError:
            print_step('error', f"{name} NOT installed")
            all_ok = False
    
    return all_ok

def check_files():
    """تحقق من الملفات الأساسية"""
    print("\n📁 Essential Files Check")
    print("-" * 50)
    
    files = [
        'manage.py',
        'requirements.txt',
        'book_system/settings.py',
        'book_system/urls.py',
        'distribution/views.py',
        'distribution/urls.py',
        'distribution/models.py',
        'distribution/serializers.py',
    ]
    
    all_ok = True
    for file_path in files:
        if os.path.exists(file_path):
            print_step('check', f"{file_path} ✓")
        else:
            print_step('error', f"{file_path} NOT FOUND")
            all_ok = False
    
    return all_ok

def check_database_config():
    """تحقق من إعدادات قاعدة البيانات"""
    print("\n🗄️  Database Configuration Check")
    print("-" * 50)
    
    try:
        # استيراد إعدادات Django
        os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'book_system.settings')
        
        import django
        from django.conf import settings
        
        db_config = settings.DATABASES.get('default', {})
        
        print_step('info', f"Database Engine: {db_config.get('ENGINE', 'N/A')}")
        print_step('info', f"Database Name: {db_config.get('NAME', 'N/A')}")
        print_step('info', f"Database Host: {db_config.get('HOST', 'localhost')}")
        print_step('info', f"Database Port: {db_config.get('PORT', '3306')}")
        
        # تحقق من REST Framework
        if 'rest_framework' in settings.INSTALLED_APPS:
            print_step('check', "REST Framework configured ✓")
        else:
            print_step('error', "REST Framework NOT configured")
        
        # تحقق من JWT
        if 'rest_framework_simplejwt' in settings.INSTALLED_APPS:
            print_step('check', "JWT configured ✓")
        else:
            print_step('error', "JWT NOT configured")
        
        return True
    except Exception as e:
        print_step('error', f"Error reading config: {str(e)}")
        return False

def check_api_endpoints():
    """تحقق من نقاط الاتصال API"""
    print("\n🔗 API Endpoints Check")
    print("-" * 50)
    
    try:
        os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'book_system.settings')
        
        import django
        django.setup()
        
        from django.urls import get_resolver
        from django.urls.exceptions import Resolver404
        
        resolver = get_resolver()
        
        endpoints = [
            'distribution:api_login',
            'distribution:api_users_login',
            'distribution:api_refresh',
            'distribution:api_profile',
        ]
        
        all_ok = True
        for endpoint in endpoints:
            try:
                url = resolver.reverse(endpoint)
                print_step('check', f"{endpoint} → {url} ✓")
            except Resolver404:
                print_step('error', f"{endpoint} NOT FOUND")
                all_ok = False
        
        return all_ok
    except Exception as e:
        print_step('error', f"Error checking endpoints: {str(e)}")
        return False

def check_migrations():
    """تحقق من حالة الهجرات"""
    print("\n🔄 Database Migrations Check")
    print("-" * 50)
    
    try:
        os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'book_system.settings')
        
        import django
        django.setup()
        
        from django.db import connection
        from django.contrib.auth.models import User
        
        # جرّب الاتصال
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        
        print_step('check', "Database connection successful ✓")
        
        # تحقق من جداول الحسابات
        try:
            users_count = User.objects.count()
            print_step('check', f"User table exists ({users_count} users) ✓")
        except Exception as e:
            print_step('error', f"User table issue: {str(e)}")
        
        return True
    except Exception as e:
        print_step('warn', f"Database connection issue: {str(e)}")
        print_step('info', "Run: python manage.py migrate")
        return False

def main():
    """الدالة الرئيسية"""
    print("\n" + "="*60)
    print("  🔍 نظام توزيع الكتب - فحص الجاهزية")
    print("  Book Distribution System - Readiness Check")
    print("="*60)
    
    checks = [
        ("Python Version", check_python_version),
        ("Django Packages", check_django_packages),
        ("Essential Files", check_files),
        ("Database Config", check_database_config),
        ("API Endpoints", check_api_endpoints),
        ("Database Migrations", check_migrations),
    ]
    
    results = []
    for name, check_func in checks:
        try:
            result = check_func()
            results.append((name, result))
        except Exception as e:
            print_step('error', f"Error in {name}: {str(e)}")
            results.append((name, False))
    
    # ملخص النتائج
    print("\n" + "="*60)
    print("  📊 ملخص الفحص")
    print("="*60)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for name, result in results:
        symbol = '✅' if result else '❌'
        print(f"{symbol} {name}")
    
    print("-" * 60)
    print(f"النتيجة: {passed}/{total} فحوصات نجحت\n")
    
    if passed == total:
        print("🎉 كل شيء جاهز! يمكنك البدء الآن")
        print("\n📖 الخطوات التالية:")
        print("  1. python manage.py create_test_users")
        print("  2. python manage.py runserver 0.0.0.0:8000")
        print("  3. python test_database_login.py")
    else:
        print("⚠️  هناك بعض المشاكل التي يجب حلها")
        print("\n📖 الخطوات الموصى بها:")
        print("  1. اقرأ الأخطاء أعلاه")
        print("  2. تحقق من requirements.txt")
        print("  3. قم بتشغيل: pip install -r requirements.txt")
        print("  4. قم بتشغيل: python manage.py migrate")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  تم الإيقاف من قبل المستخدم")
    except Exception as e:
        print(f"\n❌ خطأ غير متوقع: {str(e)}")
        sys.exit(1)
