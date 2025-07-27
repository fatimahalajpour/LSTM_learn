# طراحی دیتابیس سیستم مدیریت کلینیک مشاوره

## 🗄️ نوع دیتابیس
**PostgreSQL** - انتخاب شده به دلیل:
- پشتیبانی قوی از JSON
- مقیاس‌پذیری بالا
- امنیت و قابلیت اطمینان
- پشتیبانی از تراکنش‌های پیچیده

## 📊 نمودار ERD (Entity Relationship Diagram)

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Users     │    │   Patients   │    │Appointments │
├─────────────┤    ├──────────────┤    ├─────────────┤
│ id (PK)     │    │ id (PK)      │    │ id (PK)     │
│ username    │    │ first_name   │    │ patient_id  │◄─┐
│ email       │    │ last_name    │    │ doctor_id   │  │
│ password    │    │ phone        │    │ date_time   │  │
│ role        │    │ email        │    │ status      │  │
│ created_at  │    │ birth_date   │    │ notes       │  │
│ updated_at  │    │ gender       │    │ created_at  │  │
└─────────────┘    │ address      │    │ updated_at  │  │
                   │ medical_hist │    └─────────────┘  │
                   │ created_at   │                     │
                   │ updated_at   │                     │
                   │ is_active    │                     │
                   └──────────────┘◄────────────────────┘
                           │
                           ▼
                   ┌──────────────┐
                   │   Payments   │
                   ├──────────────┤
                   │ id (PK)      │
                   │ patient_id   │
                   │ amount       │
                   │ method       │
                   │ status       │
                   │ created_at   │
                   └──────────────┘
```

## 🔑 جداول دیتابیس

### 1. جدول Users (کاربران سیستم)
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'staff',
    phone VARCHAR(15),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT users_role_check CHECK (role IN ('admin', 'doctor', 'staff', 'receptionist'))
);
```

### 2. جدول Patients (بیماران)
```sql
CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_code VARCHAR(20) UNIQUE NOT NULL, -- کد بیمار یکتا
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(255),
    birth_date DATE,
    gender VARCHAR(10) NOT NULL,
    national_id VARCHAR(10) UNIQUE, -- کد ملی
    address TEXT,
    emergency_contact_name VARCHAR(200),
    emergency_contact_phone VARCHAR(15),
    medical_history TEXT,
    allergies TEXT,
    current_medications TEXT,
    insurance_info JSONB, -- اطلاعات بیمه
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT patients_gender_check CHECK (gender IN ('male', 'female', 'other'))
);
```

### 3. جدول Appointments (قرارهای ملاقات)
```sql
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_number VARCHAR(20) UNIQUE NOT NULL,
    patient_id UUID NOT NULL REFERENCES patients(id),
    doctor_id UUID NOT NULL REFERENCES users(id),
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    duration_minutes INTEGER DEFAULT 30,
    appointment_type VARCHAR(50) DEFAULT 'consultation',
    status VARCHAR(20) DEFAULT 'scheduled',
    chief_complaint TEXT, -- شکایت اصلی
    diagnosis TEXT,
    treatment_plan TEXT,
    notes TEXT,
    fee DECIMAL(10,2),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT appointments_status_check CHECK (
        status IN ('scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show')
    ),
    CONSTRAINT appointments_type_check CHECK (
        appointment_type IN ('consultation', 'follow_up', 'therapy', 'assessment', 'emergency')
    )
);
```

### 4. جدول Payments (پرداخت‌ها)
```sql
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_number VARCHAR(20) UNIQUE NOT NULL,
    patient_id UUID NOT NULL REFERENCES patients(id),
    appointment_id UUID REFERENCES appointments(id),
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'pending',
    transaction_id VARCHAR(100), -- شناسه تراکنش بانکی
    payment_date TIMESTAMP WITH TIME ZONE,
    description TEXT,
    discount DECIMAL(10,2) DEFAULT 0,
    final_amount DECIMAL(10,2) NOT NULL,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT payments_method_check CHECK (
        payment_method IN ('cash', 'card', 'bank_transfer', 'online', 'insurance')
    ),
    CONSTRAINT payments_status_check CHECK (
        payment_status IN ('pending', 'completed', 'failed', 'refunded', 'cancelled')
    )
);
```

### 5. جدول Patient_Files (فایل‌های بیمار)
```sql
CREATE TABLE patient_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients(id),
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100),
    category VARCHAR(50) DEFAULT 'general',
    description TEXT,
    uploaded_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT files_category_check CHECK (
        category IN ('general', 'lab_result', 'xray', 'prescription', 'report', 'image')
    )
);
```

### 6. جدول Clinic_Settings (تنظیمات کلینیک)
```sql
CREATE TABLE clinic_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clinic_name VARCHAR(200) NOT NULL,
    clinic_address TEXT,
    clinic_phone VARCHAR(15),
    clinic_email VARCHAR(255),
    working_hours JSONB, -- ساعات کاری
    appointment_duration INTEGER DEFAULT 30, -- مدت زمان پیش‌فرض ویزیت
    advance_booking_days INTEGER DEFAULT 30, -- تا چند روز آینده قابل رزرو
    currency VARCHAR(3) DEFAULT 'IRR',
    timezone VARCHAR(50) DEFAULT 'Asia/Tehran',
    notification_settings JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### 7. جدول Notifications (اعلانات)
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_type VARCHAR(20) NOT NULL, -- 'user' یا 'patient'
    recipient_id UUID NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    data JSONB, -- داده‌های اضافی
    is_read BOOLEAN DEFAULT false,
    sent_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT notifications_type_check CHECK (
        notification_type IN ('appointment_reminder', 'payment_due', 'system_update', 'general')
    ),
    CONSTRAINT notifications_recipient_check CHECK (
        recipient_type IN ('user', 'patient')
    )
);
```

### 8. جدول Audit_Logs (لاگ‌های سیستم)
```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT audit_action_check CHECK (
        action IN ('INSERT', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT')
    )
);
```

## 📇 ایندکس‌ها (Indexes)

```sql
-- ایندکس‌های عملکردی
CREATE INDEX idx_patients_phone ON patients(phone);
CREATE INDEX idx_patients_national_id ON patients(national_id);
CREATE INDEX idx_patients_created_at ON patients(created_at);
CREATE INDEX idx_patients_active ON patients(is_active);

CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_patient ON appointments(patient_id);
CREATE INDEX idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX idx_appointments_status ON appointments(status);

CREATE INDEX idx_payments_patient ON payments(patient_id);
CREATE INDEX idx_payments_date ON payments(payment_date);
CREATE INDEX idx_payments_status ON payments(payment_status);

CREATE INDEX idx_notifications_recipient ON notifications(recipient_type, recipient_id);
CREATE INDEX idx_notifications_unread ON notifications(is_read) WHERE is_read = false;

-- ایندکس متنی برای جستجو
CREATE INDEX idx_patients_search ON patients USING gin(
    to_tsvector('english', first_name || ' ' || last_name || ' ' || COALESCE(phone, ''))
);
```

## 🔒 دسترسی‌ها و امنیت (Security)

### ایجاد نقش‌های کاربری
```sql
-- نقش‌های مختلف دیتابیس
CREATE ROLE clinic_admin;
CREATE ROLE clinic_doctor;
CREATE ROLE clinic_staff;
CREATE ROLE clinic_readonly;

-- تخصیص دسترسی‌ها
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO clinic_admin;
GRANT SELECT, INSERT, UPDATE ON patients, appointments, payments TO clinic_doctor;
GRANT SELECT, INSERT, UPDATE ON patients, appointments TO clinic_staff;
GRANT SELECT ON patients, appointments, payments TO clinic_readonly;
```

### Row Level Security (RLS)
```sql
-- فعال‌سازی امنیت سطح سطر
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

-- کاربران فقط داده‌های مربوط به خودشان را ببینند
CREATE POLICY patient_access_policy ON patients
    FOR ALL TO clinic_staff
    USING (created_by = current_user_id());
```

## 🔄 Views (نماها)

### View برای آمار داشبورد
```sql
CREATE VIEW dashboard_stats AS
SELECT 
    (SELECT COUNT(*) FROM patients WHERE is_active = true) as total_patients,
    (SELECT COUNT(*) FROM appointments WHERE appointment_date = CURRENT_DATE) as today_appointments,
    (SELECT COUNT(*) FROM appointments WHERE appointment_date = CURRENT_DATE + 1) as tomorrow_appointments,
    (SELECT SUM(final_amount) FROM payments WHERE DATE(created_at) = CURRENT_DATE) as today_revenue,
    (SELECT SUM(final_amount) FROM payments WHERE EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM CURRENT_DATE)) as monthly_revenue;
```

### View برای گزارش تفصیلی قرارها
```sql
CREATE VIEW appointments_detailed AS
SELECT 
    a.id,
    a.appointment_number,
    a.appointment_date,
    a.appointment_time,
    a.status,
    a.appointment_type,
    p.first_name || ' ' || p.last_name as patient_name,
    p.phone as patient_phone,
    u.first_name || ' ' || u.last_name as doctor_name,
    a.fee,
    CASE 
        WHEN pay.payment_status = 'completed' THEN 'paid'
        ELSE 'unpaid'
    END as payment_status
FROM appointments a
JOIN patients p ON a.patient_id = p.id
JOIN users u ON a.doctor_id = u.id
LEFT JOIN payments pay ON a.id = pay.appointment_id;
```

## 🚀 Functions و Triggers

### تابع برای تولید کد یکتا
```sql
CREATE OR REPLACE FUNCTION generate_patient_code()
RETURNS TRIGGER AS $$
BEGIN
    NEW.patient_code := 'P' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || 
                        LPAD(NEXTVAL('patient_sequence')::text, 4, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger برای تولید خودکار کد بیمار
CREATE TRIGGER trigger_generate_patient_code
    BEFORE INSERT ON patients
    FOR EACH ROW
    EXECUTE FUNCTION generate_patient_code();
```

### تابع برای بروزرسانی updated_at
```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- اعمال به تمام جداول
CREATE TRIGGER trigger_update_patients_updated_at
    BEFORE UPDATE ON patients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_update_appointments_updated_at
    BEFORE UPDATE ON appointments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
```

## 📱 Schema برای NoSQL (اختیاری - MongoDB)

برای قسمت‌هایی که نیاز به مقیاس‌پذیری بالا دارند:

### مجموعه Patient Analytics
```javascript
{
  "_id": ObjectId,
  "patient_id": "uuid",
  "visit_history": [
    {
      "date": ISODate,
      "diagnosis": "string",
      "medications": ["string"],
      "next_visit": ISODate
    }
  ],
  "statistics": {
    "total_visits": Number,
    "last_visit": ISODate,
    "avg_visit_interval": Number
  },
  "created_at": ISODate,
  "updated_at": ISODate
}
```

## 📊 Sample Data (نمونه داده)

### دیتای اولیه برای تست
```sql
-- ایجاد کاربر ادمین
INSERT INTO users (username, email, password_hash, first_name, last_name, role) VALUES
('admin', 'admin@clinic.com', '$2a$10$hashed_password', 'مدیر', 'سیستم', 'admin'),
('dr_ahmadi', 'ahmadi@clinic.com', '$2a$10$hashed_password', 'احمد', 'احمدی', 'doctor');

-- نمونه تنظیمات کلینیک
INSERT INTO clinic_settings (clinic_name, working_hours) VALUES 
('کلینیک مشاوره دکتر احمدی', 
 '{"saturday": {"start": "08:00", "end": "18:00"}, 
   "sunday": {"start": "08:00", "end": "18:00"},
   "monday": {"start": "08:00", "end": "18:00"},
   "tuesday": {"start": "08:00", "end": "18:00"},
   "wednesday": {"start": "08:00", "end": "18:00"},
   "thursday": {"start": "08:00", "end": "14:00"},
   "friday": "closed"}');
```

---

## ✅ چک‌لیست طراحی دیتابیس

- [x] طراحی ERD
- [x] تعریف جداول اصلی
- [x] تعریف روابط
- [x] طراحی ایندکس‌ها
- [x] تنظیمات امنیتی
- [x] نماها و توابع
- [x] نمونه داده‌ها

**مرحله بعدی: API Design** 🔌