// كود JavaScript لواجهة الوزارة
document.addEventListener('DOMContentLoaded', function() {
    console.log('تم تحميل لوحة تحكم الوزارة');
    
    // تهيئة الرسوم البيانية
    initializeCharts();
    
    // تفعيل العناصر النشطة في القائمة الجانبية
    const navItems = document.querySelectorAll('.sidebar-nav li');
    navItems.forEach(item => {
        item.addEventListener('click', function() {
            navItems.forEach(i => i.classList.remove('active'));
            this.classList.add('active');
        });
    });
    
    // تأثيرات تفاعلية للبطاقات
    const cards = document.querySelectorAll('.card');
    cards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-5px)';
            this.style.boxShadow = '0 8px 16px rgba(0,0,0,0.1)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
            this.style.boxShadow = '0 2px 10px rgba(0,0,0,0.1)';
        });
    });
    
    // تأثيرات تفاعلية لأزرار الإجراءات
    const actionButtons = document.querySelectorAll('.action-btn');
    actionButtons.forEach(button => {
        button.addEventListener('mouseenter', function() {
            this.style.transform = 'scale(1.1)';
        });
        
        button.addEventListener('mouseleave', function() {
            this.style.transform = 'scale(1)';
        });
        
        // إضافة أحداث النقر للأزرار
        button.addEventListener('click', function() {
            const buttonType = this.classList[1];
            const row = this.closest('tr');
            handleButtonAction(buttonType, row);
        });
    });
    
    // تفعيل زر تسجيل الخروج
    setupLogoutButton();
    
    // إدارة نموذج الشحنة الجديدة
    setupShipmentForm();
    
    // مراقبة تغيير الفلتر
    const reportPeriod = document.getElementById('reportPeriod');
    if (reportPeriod) {
        reportPeriod.addEventListener('change', function() {
            updateCharts(this.value);
        });
    }
    
    // إعداد وظيفة البحث
    setupSearchFunctionality();
});

// تفعيل زر تسجيل الخروج
function setupLogoutButton() {
    const logoutBtn = document.querySelector('.logout-btn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', function(e) {
            e.preventDefault();
            
            // عرض تأكيد تسجيل الخروج
            Swal.fire({
                title: 'تسجيل الخروج',
                text: 'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'نعم، سجل خروج',
                cancelButtonText: 'إلغاء',
                reverseButtons: true
            }).then((result) => {
                if (result.isConfirmed) {
                    // محاكاة عملية تسجيل الخروج
                    simulateLogout();
                }
            });
        });
        
        // إضافة تأثيرات عند التمرير
        logoutBtn.addEventListener('mouseenter', function() {
            this.style.backgroundColor = '#c0392b';
            this.style.transform = 'scale(1.05)';
        });
        
        logoutBtn.addEventListener('mouseleave', function() {
            this.style.backgroundColor = '';
            this.style.transform = '';
        });
    }
}

// محاكاة عملية تسجيل الخروج
function simulateLogout() {
    // إظهار رسالة تحميل
    Swal.fire({
        title: 'جاري تسجيل الخروج...',
        text: 'Please wait while we securely log you out',
        icon: 'info',
        showConfirmButton: false,
        allowOutsideClick: false,
        didOpen: () => {
            Swal.showLoading()
        }
    });
    
    // محاكاة الانتظار لمدة 2 ثانية ثم التوجيه إلى الصفحة الرئيسية
    setTimeout(() => {
        Swal.fire({
            title: 'تم تسجيل الخروج بنجاح!',
            text: 'لقد تم تسجيل خروجك من النظام بأمان',
            icon: 'success',
            confirmButtonColor: '#3085d6',
            confirmButtonText: 'موافق',
            reverseButtons: true
        }).then((result) => {
            if (result.isConfirmed) {
                // التوجيه إلى الصفحة الرئيسية
                window.location.href = '/';
            }
        });
    }, 2000);
}

// تهيئة الرسوم البيانية
function initializeCharts() {
    // رسم بياني للمحافظات
    const govCtx = document.getElementById('governorateChart');
    if (govCtx) {
        new Chart(govCtx.getContext('2d'), {
            type: 'bar',
            data: {
                labels: ['صنعاء', 'عدن', 'تعز', 'حضرموت', 'الحديدة', 'إب'],
                datasets: [{
                    label: 'عدد الطلبات',
                    data: [12000, 8500, 7800, 6200, 5800, 4500],
                    backgroundColor: [
                        'rgba(52, 152, 219, 0.7)',
                        'rgba(46, 204, 113, 0.7)',
                        'rgba(155, 89, 182, 0.7)',
                        'rgba(241, 196, 15, 0.7)',
                        'rgba(230, 126, 34, 0.7)',
                        'rgba(231, 76, 60, 0.7)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }
    
    // رسم بياني لحالة الطلبات
    const statusCtx = document.getElementById('statusChart');
    if (statusCtx) {
        new Chart(statusCtx.getContext('2d'), {
            type: 'doughnut',
            data: {
                labels: ['مكتملة', 'قيد المعالجة', 'مرفوضة', 'قيد المراجعة'],
                datasets: [{
                    data: [65, 15, 8, 12],
                    backgroundColor: [
                        'rgba(46, 204, 113, 0.7)',
                        'rgba(52, 152, 219, 0.7)',
                        'rgba(231, 76, 60, 0.7)',
                        'rgba(241, 196, 15, 0.7)'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });
    }
    
    // رسم بياني للكتب الأكثر طلباً
    const booksCtx = document.getElementById('booksChart');
    if (booksCtx) {
        new Chart(booksCtx.getContext('2d'), {
            type: 'bar',
            data: {
                labels: ['الرياضيات', 'اللغة العربية', 'العلوم', 'اللغة الإنجليزية', 'التربية الإسلامية'],
                datasets: [{
                    label: 'عدد النسخ',
                    data: [45000, 38000, 32000, 28000, 25000],
                    backgroundColor: 'rgba(52, 152, 219, 0.7)',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                indexAxis: 'y',
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });
    }
    
    // رسم بياني لمعدل إنجاز الشحنات
    const shipmentCtx = document.getElementById('shipmentChart');
    if (shipmentCtx) {
        new Chart(shipmentCtx.getContext('2d'), {
            type: 'line',
            data: {
                labels: ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو'],
                datasets: [{
                    label: 'نسبة الإنجاز',
                    data: [75, 82, 78, 90, 85, 88],
                    fill: false,
                    borderColor: 'rgba(46, 204, 113, 0.7)',
                    tension: 0.1
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        min: 50,
                        max: 100
                    }
                }
            }
        });
    }
}

// تحديث الرسوم البيانية حسب الفلتر
function updateCharts(period) {
    console.log('تحديث الرسوم البيانية للفترة:', period);
    // هنا سيتم تحديث البيانات حسب الفترة المحددة
}

// التعامل مع إجراءات الأزرار
function handleButtonAction(buttonType, row) {
    const requestId = row.querySelector('td:first-child').textContent;
    const governorate = row.querySelector('td:nth-child(2)').textContent;
    
    switch(buttonType) {
        case 'view-btn':
            alert(`عرض تفاصيل: ${requestId} - ${governorate}`);
            break;
        case 'approve-btn':
            if (confirm(`هل تريد الموافقة على الطلب ${requestId} من ${governorate}؟`)) {
                row.querySelector('.status').textContent = 'معتمدة';
                row.querySelector('.status').className = 'status status-approved';
                alert(`تمت الموافقة على الطلب ${requestId}`);
                // إظهار زر إنشاء شحنة
                const shipBtn = document.createElement('button');
                shipBtn.className = 'action-btn ship-btn';
                shipBtn.innerHTML = '<i class="fas fa-truck"></i>';
                shipBtn.addEventListener('click', function() {
                    createShipmentForRequest(requestId, governorate);
                });
                row.querySelector('td:last-child').appendChild(shipBtn);
            }
            break;
        case 'reject-btn':
            if (confirm(`هل تريد رفض الطلب ${requestId} من ${governorate}؟`)) {
                row.querySelector('.status').textContent = 'مرفوض';
                row.querySelector('.status').className = 'status status-rejected';
                alert(`تم رفض الطلب ${requestId}`);
            }
            break;
        case 'ship-btn':
            createShipmentForRequest(requestId, governorate);
            break;
        case 'track-btn':
            alert(`تتبع الشحنة المرتبطة بالطلب: ${requestId}`);
            break;
        case 'complete-btn':
            if (confirm(`هل تريد标记الشحنة كمكتملة؟`)) {
                row.querySelector('.status').textContent = 'تم التسليم';
                row.querySelector('.status').className = 'status status-delivered';
                alert(`تم تحديث حالة الشحنة`);
            }
            break;
    }
}

// إنشاء شحنة للطلب
function createShipmentForRequest(requestId, governorate) {
    alert(`إنشاء شحنة جديدة للطلب ${requestId} إلى ${governorate}`);
    document.getElementById('newShipmentForm').style.display = 'block';
    document.getElementById('shipmentGovernorate').value = governorate.toLowerCase();
}

// إعداد نموذج الشحنة
function setupShipmentForm() {
    const newShipmentBtn = document.querySelector('.content-section .btn-primary');
    const closeFormBtn = document.getElementById('closeForm');
    
    if (newShipmentBtn && newShipmentBtn.textContent.includes('شحنة جديدة')) {
        newShipmentBtn.addEventListener('click', function() {
            document.getElementById('newShipmentForm').style.display = 'block';
        });
    }
    
    if (closeFormBtn) {
        closeFormBtn.addEventListener('click', function() {
            document.getElementById('newShipmentForm').style.display = 'none';
        });
    }
    
    // حساب الكمية الإجمالية عند اختيار الطلبات
    const approvedRequests = document.getElementById('approvedRequests');
    if (approvedRequests) {
        approvedRequests.addEventListener('change', calculateTotalQuantity);
    }
}

// حساب الكمية الإجمالية
function calculateTotalQuantity() {
    const selectedOptions = this.selectedOptions;
    let total = 0;
    
    Array.from(selectedOptions).forEach(option => {
        // استخراج الرقم من النص (مثال: "9,320")
        const match = option.text.match(/\(([\d,]+)\)/);
        if (match) {
            const quantity = parseInt(match[1].replace(/,/g, ''));
            total += quantity;
        }
    });
    
    document.getElementById('totalQuantity').value = total.toLocaleString();
}

// وظيفة البحث في الجداول
function setupSearchFunctionality() {
    const searchInput = document.createElement('input');
    searchInput.type = 'text';
    searchInput.placeholder = 'ابحث في الطلبات...';
    searchInput.style.padding = '0.5rem';
    searchInput.style.marginBottom = '1rem';
    searchInput.style.border = '1px solid #ddd';
    searchInput.style.borderRadius = '5px';
    searchInput.style.width = '250px';
    
    const tableSections = document.querySelectorAll('.content-section');
    tableSections.forEach(section => {
        const table = section.querySelector('table');
        if (table) {
            const sectionHeader = section.querySelector('.section-header');
            const searchContainer = document.createElement('div');
            searchContainer.style.marginLeft = 'auto';
            
            searchContainer.appendChild(searchInput.cloneNode(true));
            sectionHeader.appendChild(searchContainer);
            
            const searchInputField = searchContainer.querySelector('input');
            searchInputField.addEventListener('input', function() {
                const searchTerm = this.value.toLowerCase();
                const rows = table.querySelectorAll('tbody tr');
                
                rows.forEach(row => {
                    const text = row.textContent.toLowerCase();
                    if (text.includes(searchTerm)) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            });
        }
    });
}