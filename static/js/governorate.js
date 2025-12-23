// كود JavaScript لواجهة المحافظة
document.addEventListener('DOMContentLoaded', function() {
    console.log('تم تحميل لوحة تحكم المحافظة');
    // وظائف التنقل للواجهة المحافظة
function setupGovernorateNavigation() {
    // عناصر القائمة الجانبية
    const navItems = document.querySelectorAll('.sidebar-nav a');
    
    navItems.forEach(item => {
        item.addEventListener('click', function(e) {
            e.preventDefault();
            const page = this.getAttribute('href').substring(1);
            
            // إزالة النشاط من جميع العناصر
            navItems.forEach(i => i.parentElement.classList.remove('active'));
            // إضافة النشاط للعنصر الحالي
            this.parentElement.classList.add('active');
            
            // عرض المحتوى المناسب
            showContent(page);
        });
    });

    // زر العودة للصفحة الرئيسية
    const logo = document.querySelector('.sidebar-header .logo');
    if (logo) {
        logo.addEventListener('click', function() {
            window.location.href = 'index.html';
        });
    }

    // زر تسجيل الخروج
    const logoutBtn = document.querySelector('.logout-btn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', function() {
            if (confirm('هل تريد تسجيل الخروج؟')) {
                window.location.href = 'index.html';
            }
        });
    }
}

// وظيفة عرض المحتوى
function showContent(page) {
    console.log('الانتقال إلى:', page);
    // إخفاء جميع الأقسام
    document.querySelectorAll('.content-section').forEach(section => {
        section.style.display = 'none';
    });
    
    // عرض القسم المطلوب
    const targetSection = document.getElementById(`${page}-section`);
    if (targetSection) {
        targetSection.style.display = 'block';
    }
}

// استدعاء وظيفة التنقل
document.addEventListener('DOMContentLoaded', function() {
    setupGovernorateNavigation();
});
    
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
            handleButtonAction(buttonType, this.closest('tr'));
        });
    });
    
    // إعداد نموذج إنشاء الطلب
    setupRequestForm();
    
    // وظيفة تسجيل الخروج
    const logoutBtn = document.querySelector('.logout-btn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', function() {
            if (confirm('هل أنت متأكد من تسجيل الخروج؟')) {
                window.location.href = 'index.html';
            }
        });
    }
    
    // إعداد وظيفة البحث
    setupSearchFunctionality();
});

// التعامل مع إجراءات الأزرار
function handleButtonAction(buttonType, row) {
    const requestId = row.querySelector('td:first-child').textContent;
    const schoolName = row.querySelector('td:nth-child(2)').textContent;
    
    switch(buttonType) {
        case 'view-btn':
            alert(`عرض تفاصيل الطلب: ${requestId} للمدرسة: ${schoolName}`);
            break;
        case 'approve-btn':
            if (confirm(`هل تريد الموافقة على الطلب ${requestId}؟`)) {
                row.querySelector('.status').textContent = 'معتمد';
                row.querySelector('.status').className = 'status status-approved';
                alert(`تمت الموافقة على الطلب ${requestId}`);
            }
            break;
        case 'reject-btn':
            if (confirm(`هل تريد رفض الطلب ${requestId}؟`)) {
                row.querySelector('.status').textContent = 'مرفوض';
                row.querySelector('.status').className = 'status status-rejected';
                alert(`تم رفض الطلب ${requestId}`);
            }
            break;
        case 'assign-btn':
            alert(`تعيين مندوب للتوصيل للطلب: ${requestId}`);
            break;
        case 'track-btn':
            alert(`تتبع عملية التوصيل للطلب: ${requestId}`);
            break;
        case 'report-btn':
            alert(`إنشاء تقرير للطلب: ${requestId}`);
            break;
    }
}

// إعداد نموذج إنشاء الطلب
function setupRequestForm() {
    const submitBtn = document.getElementById('submitRequest');
    const saveBtn = document.getElementById('saveDraft');
    
    submitBtn.addEventListener('click', function(e) {
        e.preventDefault();
        if (validateRequestForm()) {
            if (confirm('هل تريد إرسال الطلب إلى الوزارة؟')) {
                const requestData = collectFormData();
                submitRequestToMinistry(requestData);
            }
        }
    });
    
    saveBtn.addEventListener('click', function(e) {
        e.preventDefault();
        if (validateRequestForm()) {
            const requestData = collectFormData();
            saveAsDraft(requestData);
            alert('تم حفظ الطلب كمسودة');
            document.querySelector('.request-form').reset();
        }
    });
}

// التحقق من صحة النموذج
function validateRequestForm() {
    const educationLevel = document.getElementById('educationLevel').value;
    const subject = document.getElementById('subject').value;
    const quantity = document.getElementById('quantity').value;
    
    if (!educationLevel) {
        alert('يرجى اختيار المرحلة التعليمية');
        return false;
    }
    
    if (!subject) {
        alert('يرجى اختيار المادة الدراسية');
        return false;
    }
    
    if (!quantity || quantity <= 0) {
        alert('يرجى إدخال كمية صحيحة');
        return false;
    }
    
    return true;
}

// جمع بيانات النموذج
function collectFormData() {
    return {
        educationLevel: document.getElementById('educationLevel').value,
        educationLevelText: document.getElementById('educationLevel').options[document.getElementById('educationLevel').selectedIndex].text,
        subject: document.getElementById('subject').value,
        subjectText: document.getElementById('subject').options[document.getElementById('subject').selectedIndex].text,
        quantity: document.getElementById('quantity').value,
        notes: document.getElementById('notes').value,
        timestamp: new Date().toISOString(),
        status: 'pending'
    };
}

// محاكاة إرسال الطلب للوزارة
function submitRequestToMinistry(requestData) {
    // هنا سيتم إرسال البيانات للخادم في التطبيق الحقيقي
    console.log('إرسال الطلب للوزارة:', requestData);
    
    // محاكاة الإرسال
    setTimeout(() => {
        alert(`تم إرسال الطلب للوزارة بنجاح!\n\nالمرحلة: ${requestData.educationLevelText}\nالمادة: ${requestData.subjectText}\nالكمية: ${requestData.quantity}`);
        
        // إضافة الطلب الجديد إلى الجدول
        addNewRequestToTable(requestData);
        
        // مسح النموذج
        document.querySelector('.request-form').reset();
    }, 1000);
}

// حفظ كمسودة
function saveAsDraft(requestData) {
    // هنا سيتم حفظ البيانات في localStorage أو قاعدة البيانات
    console.log('حفظ الطلب كمسودة:', requestData);
    
    // محاكاة الحفظ
    const drafts = JSON.parse(localStorage.getItem('bookRequestDrafts') || '[]');
    drafts.push(requestData);
    localStorage.setItem('bookRequestDrafts', JSON.stringify(drafts));
}

// إضافة الطلب الجديد إلى الجدول
function addNewRequestToTable(requestData) {
    const table = document.querySelector('table tbody');
    const newRow = document.createElement('tr');
    
    // إنشاء رقم طلب عشوائي
    const requestId = '#SCH' + Math.floor(1000 + Math.random() * 9000);
    
    newRow.innerHTML = `
        <td>${requestId}</td>
        <td>طلب جديد</td>
        <td>${new Date().toLocaleDateString('ar-EG')}</td>
        <td>${requestData.quantity}</td>
        <td><span class="status status-pending">قيد المراجعة</span></td>
        <td>
            <button class="action-btn view-btn"><i class="fas fa-eye"></i></button>
            <button class="action-btn approve-btn"><i class="fas fa-check"></i></button>
            <button class="action-btn reject-btn"><i class="fas fa-times"></i></button>
        </td>
    `;
    
    // إضافة الصف في بداية الجدول
    table.insertBefore(newRow, table.firstChild);
    
    // تحديث الإحصائيات
    updateStatistics();
    
    // إضافة事件المستمعين للأزرار الجديدة
    const newActionButtons = newRow.querySelectorAll('.action-btn');
    newActionButtons.forEach(button => {
        button.addEventListener('click', function() {
            const buttonType = this.classList[1];
            handleButtonAction(buttonType, this.closest('tr'));
        });
    });
}

// تحديث الإحصائيات
function updateStatistics() {
    const pendingElements = document.querySelectorAll('.status-pending');
    const statsElement = document.querySelector('.dashboard-cards .card:nth-child(3) .stats');
    
    if (statsElement && pendingElements) {
        statsElement.textContent = pendingElements.length;
    }
}

// وظيفة البحث في الجداول
function setupSearchFunctionality() {
    const searchInput = document.createElement('input');
    searchInput.type = 'text';
    searchInput.placeholder = 'ابحث في طلبات المدارس...';
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