// كود JavaScript للصفحة الرئيسية
document.addEventListener('DOMContentLoaded', function() {
    console.log('تم تحميل الصفحة الرئيسية لنظام توزيع الكتب المدرسية');
    
    // تأثيرات تفاعلية للأزرار
    const buttons = document.querySelectorAll('button, .btn-primary, .btn-secondary');
    buttons.forEach(button => {
        button.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-2px)';
        });
        
        button.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
        });
    });
});