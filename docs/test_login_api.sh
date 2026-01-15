#!/bin/bash

# 🔐 Database Login API Test Script
# يتحقق من اتصال Flutter App بـ Backend عبر API

API_URL="http://localhost:8000"
API_LOGIN_ENDPOINT="/api/auth/login/"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║         🔐 Database Login API Test                         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# التحقق من أن Backend يعمل
echo "🔍 Checking if Backend is running..."
if ! curl -s "$API_URL" > /dev/null 2>&1; then
    echo "❌ Backend is not running!"
    echo "   Start it with: python manage.py runserver"
    exit 1
fi
echo "✅ Backend is running"
echo ""

# ============================================
# Test 1: School User Login
# ============================================
echo "📝 Test 1: School User Login (sf1)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
curl -X POST "$API_URL$API_LOGIN_ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "sf1",
    "password": "sf1password"
  }' -s | python -m json.tool

echo ""
echo ""

# ============================================
# Test 2: Driver User Login
# ============================================
echo "📝 Test 2: Driver User Login (driver1)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
curl -X POST "$API_URL$API_LOGIN_ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "driver1",
    "password": "driver123"
  }' -s | python -m json.tool

echo ""
echo ""

# ============================================
# Test 3: Invalid Credentials
# ============================================
echo "📝 Test 3: Invalid Credentials"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
curl -X POST "$API_URL$API_LOGIN_ENDPOINT" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "wronguser",
    "password": "wrongpass"
  }' -s | python -m json.tool

echo ""
echo ""

# ============================================
# Summary
# ============================================
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                   ✅ Tests Complete                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Available Test Accounts:"
echo ""
echo "🚗 DRIVERS:"
echo "   • driver1 / driver123 (Ministry Driver)"
echo "   • driver2 / driver456 (Province Driver)"
echo ""
echo "🏫 SCHOOL STAFF:"
echo "   • sf1 / sf1password (مدرسة النهضة)"
echo "   • sf2 / sf2password (مدرسة التوحيد)"
echo ""
