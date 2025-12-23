#!/bin/bash

echo "🧪 اختبار سريع لتكامل Flutter مع Backend"
echo "=============================================="
echo ""

# الألوان
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. فحص Backend
echo "📡 1. فحص Backend..."
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" 2>&1)

if [ "$BACKEND_STATUS" = "400" ] || [ "$BACKEND_STATUS" = "200" ] || [ "$BACKEND_STATUS" = "401" ]; then
    echo -e "${GREEN}   ✅ Backend يعمل${NC}"
else
    echo -e "${RED}   ❌ Backend لا يعمل (Status: $BACKEND_STATUS)${NC}"
    echo "   شغّل Backend أولاً:"
    echo "   cd /home/reyam/ketabi && docker-compose up -d"
    exit 1
fi

# 2. فحص الـ endpoints
echo ""
echo "🔍 2. فحص Endpoints..."

# Test login endpoint
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"ministry_admin","password":"ministrypass"}' \
  -w "%{http_code}")

HTTP_CODE="${LOGIN_RESPONSE: -3}"
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}   ✅ Login endpoint يعمل${NC}"
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access":"[^"]*' | cut -d'"' -f4)
else
    echo -e "${YELLOW}   ⚠️  Login endpoint يرجع: $HTTP_CODE${NC}"
fi

# Test school-requests endpoint
if [ -n "$TOKEN" ]; then
    REQUESTS_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
      http://localhost:8000/api/school-requests/ \
      -H "Authorization: Bearer $TOKEN")
    
    if [ "$REQUESTS_CODE" = "200" ]; then
        echo -e "${GREEN}   ✅ School Requests endpoint يعمل${NC}"
    else
        echo -e "${YELLOW}   ⚠️  School Requests يرجع: $REQUESTS_CODE${NC}"
    fi
fi

# Test books endpoint
BOOKS_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  http://localhost:8000/api/books/)

if [ "$BOOKS_CODE" = "200" ]; then
    echo -e "${GREEN}   ✅ Books endpoint يعمل${NC}"
else
    echo -e "${YELLOW}   ⚠️  Books endpoint يرجع: $BOOKS_CODE${NC}"
fi

# 3. فحص الملفات
echo ""
echo "📁 3. فحص ملفات Flutter..."

FILES=(
    "lib/services/api_client.dart"
    "lib/services/auth_service.dart"
    "lib/services/order_service.dart"
    "lib/models/school_request_model.dart"
    "lib/models/shipment_model.dart"
    "lib/utils/constants.dart"
)

ALL_FILES_EXIST=true
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}   ✅ $file${NC}"
    else
        echo -e "${RED}   ❌ $file غير موجود${NC}"
        ALL_FILES_EXIST=false
    fi
done

# 4. فحص pubspec.yaml
echo ""
echo "📦 4. فحص التبعيات..."
if grep -q "provider:" pubspec.yaml && grep -q "http:" pubspec.yaml; then
    echo -e "${GREEN}   ✅ التبعيات موجودة${NC}"
else
    echo -e "${RED}   ❌ بعض التبعيات مفقودة${NC}"
fi

# 5. الخلاصة
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 النتيجة النهائية:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$HTTP_CODE" = "200" ] && [ "$ALL_FILES_EXIST" = true ]; then
    echo -e "${GREEN}✅ التكامل جاهز!${NC}"
    echo ""
    echo "🚀 لتشغيل التطبيق:"
    echo "   flutter run"
    echo ""
    echo "📚 راجع الوثائق:"
    echo "   - INTEGRATION_GUIDE.md"
    echo "   - EXAMPLES.md"
    echo "   - README_AR.md"
else
    echo -e "${YELLOW}⚠️  بعض المشاكل موجودة - راجع الرسائل أعلاه${NC}"
fi

echo ""
