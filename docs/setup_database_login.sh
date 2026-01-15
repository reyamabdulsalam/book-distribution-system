#!/bin/bash

# ⚙️ Setup Database Login Integration

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     🔐 Setting Up Database Login Integration              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Install Python Dependencies
echo "📦 Step 1: Installing Python dependencies..."
pip install -r requirements.txt
echo "✅ Dependencies installed"
echo ""

# Step 2: Run Migrations
echo "🗄️  Step 2: Running database migrations..."
python manage.py migrate
echo "✅ Migrations completed"
echo ""

# Step 3: Create Test Users
echo "👥 Step 3: Creating test users..."
python manage.py create_test_users
echo "✅ Test users created"
echo ""

# Step 4: Summary
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              ✅ Setup Complete!                           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📝 Next Steps:"
echo ""
echo "1. Start Django Server:"
echo "   python manage.py runserver 0.0.0.0:8000"
echo ""
echo "2. Test API (in another terminal):"
echo "   bash docs/test_login_api.sh"
echo ""
echo "3. Or test manually with curl:"
echo "   curl -X POST http://localhost:8000/api/auth/login/ \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"username\":\"sf1\",\"password\":\"sf1password\"}'"
echo ""
echo "4. Run Flutter app:"
echo "   flutter run"
echo ""
echo "📚 Available Credentials:"
echo ""
echo "   🚗 Driver: driver1 / driver123"
echo "   🏫 School: sf1 / sf1password"
echo ""
