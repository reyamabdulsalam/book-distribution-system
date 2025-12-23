from django.db import models
from django.contrib.auth.models import User

class Governorate(models.Model):
    name = models.CharField(max_length=100, verbose_name="اسم المحافظة")
    code = models.CharField(max_length=10, unique=True, verbose_name="الكود")
    is_active = models.BooleanField(default=True, verbose_name="نشط")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = "محافظة"
        verbose_name_plural = "المحافظات"

    def __str__(self):
        return self.name

class School(models.Model):
    name = models.CharField(max_length=200, verbose_name="اسم المدرسة")
    governorate = models.ForeignKey(Governorate, on_delete=models.CASCADE, verbose_name="المحافظة")
    address = models.TextField(verbose_name="العنوان")
    phone = models.CharField(max_length=20, blank=True, verbose_name="الهاتف")
    is_active = models.BooleanField(default=True, verbose_name="نشط")

    class Meta:
        verbose_name = "مدرسة"
        verbose_name_plural = "المدارس"

    def __str__(self):
        return self.name

class BookRequest(models.Model):
    STATUS_CHOICES = [
        ('pending', 'قيد المراجعة'),
        ('approved', 'معتمد'),
        ('rejected', 'مرفوض'),
        ('delivered', 'تم التسليم'),
    ]

    school = models.ForeignKey(School, on_delete=models.CASCADE, verbose_name="المدرسة")
    governorate = models.ForeignKey(Governorate, on_delete=models.CASCADE, verbose_name="المحافظة")
    book_type = models.CharField(max_length=100, verbose_name="نوع الكتاب")
    quantity = models.IntegerField(verbose_name="الكمية")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending', verbose_name="الحالة")
    request_date = models.DateTimeField(auto_now_add=True, verbose_name="تاريخ الطلب")
    notes = models.TextField(blank=True, verbose_name="ملاحظات")

    class Meta:
        verbose_name = "طلب كتب"
        verbose_name_plural = "طلبات الكتب"

    def __str__(self):
        return f"طلب {self.book_type} - {self.school.name}"


class Courier(models.Model):
    """موديل المندوب"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='courier_profile', verbose_name="حساب المستخدم")
    name = models.CharField(max_length=200, verbose_name="اسم المندوب")
    phone = models.CharField(max_length=20, verbose_name="الهاتف")
    governorate = models.ForeignKey(Governorate, on_delete=models.SET_NULL, null=True, blank=True, verbose_name="المحافظة")
    is_active = models.BooleanField(default=True, verbose_name="نشط")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="تاريخ الإنشاء")

    class Meta:
        verbose_name = "مندوب"
        verbose_name_plural = "المندوبين"

    def __str__(self):
        return self.name


class SchoolUser(models.Model):
    """موديل مستخدم المدرسة"""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='school_profile', verbose_name="حساب المستخدم")
    school = models.OneToOneField(School, on_delete=models.CASCADE, related_name='user_profile', verbose_name="المدرسة")
    is_active = models.BooleanField(default=True, verbose_name="نشط")
    created_at = models.DateTimeField(auto_now_add=True, verbose_name="تاريخ الإنشاء")

    class Meta:
        verbose_name = "مستخدم مدرسة"
        verbose_name_plural = "مستخدمي المدارس"

    def __str__(self):
        return f"{self.user.username} - {self.school.name}"
