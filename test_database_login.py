#!/usr/bin/env python
"""
🔐 Quick Test Script for Database Login
اختبر تسجيل الدخول من قاعدة البيانات

Usage:
    python test_database_login.py
"""

import os
import django
import json
import requests

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'book_system.settings')
django.setup()

from django.contrib.auth.models import User
from distribution.models import SchoolUser, Courier

def print_header(title):
    """طباعة رأس جميل"""
    print("\n" + "="*60)
    print(f"  {title}")
    print("="*60 + "\n")

def print_success(msg):
    """طباعة رسالة النجاح"""
    print(f"✅ {msg}")

def print_error(msg):
    """طباعة رسالة الخطأ"""
    print(f"❌ {msg}")

def test_database_users():
    """اختبر وجود المستخدمين في قاعدة البيانات"""
    print_header("📊 Database Users Check")
    
    users = User.objects.all()
    print(f"Total Users in Database: {users.count()}\n")
    
    for user in users:
        print(f"👤 {user.username}")
        print(f"   Email: {user.email}")
        print(f"   Active: {user.is_active}")
        
        # Check if Courier
        try:
            courier = Courier.objects.get(user=user)
            print(f"   Role: 🚗 Driver - {courier.name}")
        except Courier.DoesNotExist:
            pass
        
        # Check if School Staff
        try:
            school_user = SchoolUser.objects.get(user=user)
            print(f"   Role: 🏫 School Staff - {school_user.school.name}")
        except SchoolUser.DoesNotExist:
            pass
        
        print()

def test_api_login(username, password):
    """اختبر API login endpoint"""
    print_header(f"🔐 Testing Login: {username}")
    
    url = "http://localhost:8000/api/auth/login/"
    
    print(f"Endpoint: POST {url}")
    print(f"Username: {username}")
    print(f"Password: {'*' * len(password)}\n")
    
    try:
        response = requests.post(
            url,
            json={"username": username, "password": password},
            timeout=5
        )
        
        print(f"Status Code: {response.status_code}\n")
        
        data = response.json()
        print(json.dumps(data, indent=2, ensure_ascii=False))
        
        if response.status_code in [200, 201]:
            print_success(f"Login successful for {username}!")
            return True
        else:
            print_error(f"Login failed: {data.get('error', 'Unknown error')}")
            return False
            
    except requests.exceptions.ConnectionError:
        print_error("Cannot connect to Backend!")
        print("   Make sure Django is running:")
        print("   python manage.py runserver")
        return False
    except Exception as e:
        print_error(f"Error: {str(e)}")
        return False

def main():
    """Main test function"""
    print("\n")
    print("╔════════════════════════════════════════════════════════════╗")
    print("║         🔐 Database Login Integration Test                ║")
    print("╚════════════════════════════════════════════════════════════╝")
    
    # Test 1: Check Database Users
    test_database_users()
    
    # Test 2: Test API Logins
    test_cases = [
        ("sf1", "sf1password"),
        ("driver1", "driver123"),
        ("invalid_user", "wrong_password"),
    ]
    
    print_header("🔐 API Login Tests")
    
    passed = 0
    failed = 0
    
    for username, password in test_cases:
        if test_api_login(username, password):
            passed += 1
        else:
            failed += 1
    
    # Summary
    print_header("📊 Summary")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print()
    
    if passed > 0 and failed == 1:  # Expecting 1 failure (invalid login)
        print_success("All tests passed! Database login is working correctly.")
    else:
        print_error("Some tests failed. Check the output above.")

if __name__ == "__main__":
    main()
