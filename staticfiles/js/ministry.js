// كود JavaScript لواجهة الوزارة
document.addEventListener('DOMContentLoaded', function() {
    console.log('تم تحميل لوحة تحكم الوزارة');
    
    // تفعيل القائمة الجانبية
    const navItems = document.querySelectorAll('.sidebar-nav li');
    navItems.forEach(item => {
        item.addEventListener('click', function() {
            navItems.forEach(i => i.classList.remove('active'));
            this.classList.add('active');
        });
    });
});