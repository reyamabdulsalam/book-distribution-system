#!/bin/bash
# 🚀 اختبار سريع لتسجيل الدخول
# Quick Login Test

echo "╔════════════════════════════════════════════════════════════╗"
echo "║         🔐 اختبار تسجيل الدخول من قاعدة البيانات         ║"
echo "║            Quick Login Test - Database Auth                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# تلوين النص
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# الخادم
SERVER="http://localhost:8000"
API_ENDPOINT="$SERVER/api/auth/login/"

echo -e "${BLUE}ℹ️  الخادم: $SERVER${NC}"
echo ""

# 1. فحص الاتصال بالخادم
echo -e "${YELLOW}1️⃣  اختبار الاتصال بالخادم...${NC}"
if ! curl -s "$SERVER" > /dev/null 2>&1; then
    echo -e "${RED}❌ لا يمكن الوصول للخادم!${NC}"
    echo -e "${YELLOW}💡 تأكد من تشغيل:${NC}"
    echo "   python manage.py runserver 0.0.0.0:8000"
    exit 1
fi
echo -e "${GREEN}✅ الخادم يعمل${NC}"
echo ""

# 2. اختبار تسجيل الدخول برقم 1: موظف مدرسة
echo -e "${YELLOW}2️⃣  اختبار موظف مدرسة (sf1)...${NC}"
RESPONSE=$(curl -s -X POST "$API_ENDPOINT" \
    -H "Content-Type: application/json" \
    -d '{"username": "sf1", "password": "sf1password"}')

if echo "$RESPONSE" | grep -q "access"; then
    echo -e "${GREEN}✅ تسجيل دخول موظف المدرسة ناجح!${NC}"
    echo -e "${BLUE}📊 البيانات المرجعة:${NC}"
    echo "$RESPONSE" | python -m json.tool 2>/dev/null || echo "$RESPONSE"
else
    echo -e "${RED}❌ فشل تسجيل الدخول${NC}"
    echo -e "${BLUE}الرد:${NC} $RESPONSE"
fi
echo ""

# 3. اختبار تسجيل الدخول برقم 2: مندوب
echo -e "${YELLOW}3️⃣  اختبار مندوب التوزيع (driver1)...${NC}"
RESPONSE=$(curl -s -X POST "$API_ENDPOINT" \
    -H "Content-Type: application/json" \
    -d '{"username": "driver1", "password": "driver123"}')

if echo "$RESPONSE" | grep -q "access"; then
    echo -e "${GREEN}✅ تسجيل دخول المندوب ناجح!${NC}"
    echo -e "${BLUE}📊 البيانات المرجعة:${NC}"
    echo "$RESPONSE" | python -m json.tool 2>/dev/null || echo "$RESPONSE"
else
    echo -e "${RED}❌ فشل تسجيل الدخول${NC}"
    echo -e "${BLUE}الرد:${NC} $RESPONSE"
fi
echo ""

# 4. اختبار بيانات خاطئة
echo -e "${YELLOW}4️⃣  اختبار بيانات خاطئة (يجب أن يفشل)...${NC}"
RESPONSE=$(curl -s -X POST "$API_ENDPOINT" \
    -H "Content-Type: application/json" \
    -d '{"username": "invalid", "password": "wrong"}')

if echo "$RESPONSE" | grep -q "error"; then
    echo -e "${GREEN}✅ تم الرد برسالة خطأ كما هو متوقع${NC}"
else
    echo -e "${YELLOW}⚠️  لم يتم الرد برسالة خطأ واضحة${NC}"
fi
echo ""

# ملخص
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                     ✨ اختبار مكتمل ✨                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${GREEN}حسابات الاختبار:${NC}"
echo "  🚗 driver1 / driver123"
echo "  🏫 sf1 / sf1password"
echo ""

echo -e "${BLUE}ℹ️  للمزيد من التفاصيل، شغّل:${NC}"
echo "  python test_database_login.py"
echo ""
