// وظائف التنقل بين الصفحات
function setupNavigation() {
    // الانتقال إلى واجهة المحافظة
    const governorateBtn = document.querySelector('.btn-primary[data-navigate="governorate"]');
    if (governorateBtn) {
        governorateBtn.addEventListener('click', function() {
            window.location.href = '/governorate/';
        });
    }

    // الانتقال إلى واجهة الوزارة
    const ministryBtn = document.querySelector('.btn-secondary[data-navigate="ministry"]');
    if (ministryBtn) {
        ministryBtn.addEventListener('click', function() {
            window.location.href = '/ministry/';
        });
    }

    // إضافة event listener لأي زر يحتوي على data-navigate
    document.querySelectorAll('[data-navigate]').forEach(button => {
        button.addEventListener('click', function() {
            const page = this.getAttribute('data-navigate');
            window.location.href = '/' + page + '/';
        });
    });
}

// استدعاء وظيفة التنقل عند تحميل الصفحة
document.addEventListener('DOMContentLoaded', function() {
    setupNavigation();
    console.log('تم تهيئة نظام التنقل بين الصفحات');
});