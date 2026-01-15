"""
Django Management Command to Create Test Users for Database Login

Usage:
    python manage.py create_test_users
"""

from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from distribution.models import School, Governorate, Courier, SchoolUser

class Command(BaseCommand):
    help = 'Create test users for database login testing'

    def handle(self, *args, **options):
        self.stdout.write(self.style.SUCCESS('Creating test users...'))
        
        # ============================================
        # 1. Create Governorates
        # ============================================
        riyadh, created = Governorate.objects.get_or_create(
            code='riy',
            defaults={'name': 'الرياض', 'is_active': True}
        )
        if created:
            self.stdout.write(f'✅ Created Governorate: الرياض')
        
        jeddah, created = Governorate.objects.get_or_create(
            code='jed',
            defaults={'name': 'جدة', 'is_active': True}
        )
        if created:
            self.stdout.write(f'✅ Created Governorate: جدة')
        
        # ============================================
        # 2. Create Schools
        # ============================================
        school1, created = School.objects.get_or_create(
            name='مدرسة النهضة',
            governorate=riyadh,
            defaults={
                'address': 'شارع الملك فهد، الرياض',
                'phone': '0112235555',
                'is_active': True
            }
        )
        if created:
            self.stdout.write(f'✅ Created School: مدرسة النهضة')
        
        school2, created = School.objects.get_or_create(
            name='مدرسة التوحيد',
            governorate=jeddah,
            defaults={
                'address': 'شارع الأمير محمد بن عبدالعزيز، جدة',
                'phone': '0122223333',
                'is_active': True
            }
        )
        if created:
            self.stdout.write(f'✅ Created School: مدرسة التوحيد')
        
        # ============================================
        # 3. Create Driver/Courier User
        # ============================================
        driver_user, created = User.objects.get_or_create(
            username='driver1',
            defaults={
                'first_name': 'محمد',
                'last_name': 'أحمد',
                'email': 'driver1@example.com',
                'is_active': True,
            }
        )
        if created:
            driver_user.set_password('driver123')
            driver_user.save()
            self.stdout.write(f'✅ Created Driver User: driver1 (password: driver123)')
        
        # Create Courier profile for driver
        courier1, created = Courier.objects.get_or_create(
            user=driver_user,
            defaults={
                'name': 'محمد أحمد',
                'phone': '0505555555',
                'governorate': riyadh,
                'is_active': True
            }
        )
        if created:
            self.stdout.write(f'✅ Created Courier: محمد أحمد (مندوب الوزارة)')
        
        # ============================================
        # 4. Create School Staff User (sf1)
        # ============================================
        school_user1, created = User.objects.get_or_create(
            username='sf1',
            defaults={
                'first_name': 'علي',
                'last_name': 'محمد',
                'email': 'sf1@school1.edu.sa',
                'is_active': True,
            }
        )
        if created:
            school_user1.set_password('sf1password')
            school_user1.save()
            self.stdout.write(f'✅ Created School Staff User: sf1 (password: sf1password)')
        
        # Create SchoolUser profile for sf1
        school_staff1, created = SchoolUser.objects.get_or_create(
            user=school_user1,
            school=school1,
            defaults={'is_active': True}
        )
        if created:
            self.stdout.write(f'✅ Created SchoolUser: sf1 -> مدرسة النهضة')
        
        # ============================================
        # 5. Create Another School Staff User
        # ============================================
        school_user2, created = User.objects.get_or_create(
            username='sf2',
            defaults={
                'first_name': 'فاطمة',
                'last_name': 'علي',
                'email': 'sf2@school2.edu.sa',
                'is_active': True,
            }
        )
        if created:
            school_user2.set_password('sf2password')
            school_user2.save()
            self.stdout.write(f'✅ Created School Staff User: sf2 (password: sf2password)')
        
        school_staff2, created = SchoolUser.objects.get_or_create(
            user=school_user2,
            school=school2,
            defaults={'is_active': True}
        )
        if created:
            self.stdout.write(f'✅ Created SchoolUser: sf2 -> مدرسة التوحيد')
        
        # ============================================
        # 6. Create Another Driver
        # ============================================
        driver_user2, created = User.objects.get_or_create(
            username='driver2',
            defaults={
                'first_name': 'سالم',
                'last_name': 'عبدالله',
                'email': 'driver2@example.com',
                'is_active': True,
            }
        )
        if created:
            driver_user2.set_password('driver456')
            driver_user2.save()
            self.stdout.write(f'✅ Created Driver User: driver2 (password: driver456)')
        
        courier2, created = Courier.objects.get_or_create(
            user=driver_user2,
            defaults={
                'name': 'سالم عبدالله',
                'phone': '0506666666',
                'governorate': jeddah,
                'is_active': True
            }
        )
        if created:
            self.stdout.write(f'✅ Created Courier: سالم عبدالله (مندوب المحافظة)')
        
        # ============================================
        # Summary
        # ============================================
        self.stdout.write(self.style.SUCCESS('\n' + '='*60))
        self.stdout.write(self.style.SUCCESS('✅ Test Users Created Successfully!'))
        self.stdout.write(self.style.SUCCESS('='*60))
        self.stdout.write(self.style.WARNING('\n📝 Available Test Credentials:\n'))
        
        self.stdout.write(self.style.SUCCESS('🚗 DRIVERS:'))
        self.stdout.write('  • Username: driver1 | Password: driver123')
        self.stdout.write('  • Username: driver2 | Password: driver456')
        
        self.stdout.write(self.style.SUCCESS('\n🏫 SCHOOL STAFF:'))
        self.stdout.write('  • Username: sf1 | Password: sf1password | School: مدرسة النهضة')
        self.stdout.write('  • Username: sf2 | Password: sf2password | School: مدرسة التوحيد')
        
        self.stdout.write(self.style.WARNING('\n🔗 Test Login:\n'))
        self.stdout.write('  POST /api/auth/login/')
        self.stdout.write('  {')
        self.stdout.write('    "username": "sf1",')
        self.stdout.write('    "password": "sf1password"')
        self.stdout.write('  }')
        self.stdout.write('\n' + '='*60)
