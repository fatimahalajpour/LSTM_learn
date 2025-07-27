# طراحی API سیستم مدیریت کلینیک مشاوره

## 🔌 معماری API

### نوع API: RESTful API
- **Protocol**: HTTPS
- **Format**: JSON
- **Authentication**: JWT (JSON Web Token)
- **Versioning**: URL versioning (`/api/v1/`)

### Base URL
```
Production: https://api.clinic-management.com/v1
Development: http://localhost:3000/api/v1
```

## 🔐 Authentication & Authorization

### JWT Token Structure
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "user_id": "uuid",
    "email": "user@example.com",
    "role": "doctor",
    "clinic_id": "uuid",
    "exp": 1234567890,
    "iat": 1234567890
  }
}
```

### Authentication Endpoints

#### POST `/auth/login`
```json
// Request
{
  "email": "doctor@clinic.com",
  "password": "password123"
}

// Response (200)
{
  "status": "success",
  "data": {
    "user": {
      "id": "uuid",
      "email": "doctor@clinic.com",
      "first_name": "احمد",
      "last_name": "احمدی",
      "role": "doctor"
    },
    "token": "jwt_token_here",
    "expires_in": 3600
  }
}

// Error Response (401)
{
  "status": "error",
  "message": "نام کاربری یا رمز عبور اشتباه است",
  "error_code": "INVALID_CREDENTIALS"
}
```

#### POST `/auth/logout`
```json
// Headers
Authorization: Bearer <jwt_token>

// Response (200)
{
  "status": "success",
  "message": "با موفقیت خارج شدید"
}
```

#### POST `/auth/refresh`
```json
// Request
{
  "refresh_token": "refresh_token_here"
}

// Response (200)
{
  "status": "success",
  "data": {
    "token": "new_jwt_token",
    "expires_in": 3600
  }
}
```

## 👥 Users Management API

### GET `/users/profile`
```json
// Headers
Authorization: Bearer <jwt_token>

// Response (200)
{
  "status": "success",
  "data": {
    "id": "uuid",
    "username": "dr_ahmadi",
    "email": "ahmadi@clinic.com",
    "first_name": "احمد",
    "last_name": "احمدی",
    "role": "doctor",
    "phone": "09123456789",
    "is_active": true,
    "last_login": "2024-01-15T10:30:00Z",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

### PUT `/users/profile`
```json
// Request
{
  "first_name": "احمد",
  "last_name": "احمدی",
  "phone": "09123456789"
}

// Response (200)
{
  "status": "success",
  "message": "پروفایل با موفقیت بروزرسانی شد",
  "data": {
    "id": "uuid",
    "first_name": "احمد",
    "last_name": "احمدی",
    "phone": "09123456789",
    "updated_at": "2024-01-15T10:30:00Z"
  }
}
```

## 🏥 Patients API

### GET `/patients`
```json
// Query Parameters
?page=1&limit=20&search=احمد&status=active&sort=created_at&order=desc

// Response (200)
{
  "status": "success",
  "data": {
    "patients": [
      {
        "id": "uuid",
        "patient_code": "P20240115001",
        "first_name": "علی",
        "last_name": "احمدی",
        "phone": "09123456789",
        "email": "ali@example.com",
        "birth_date": "1985-05-15",
        "gender": "male",
        "age": 39,
        "is_active": true,
        "created_at": "2024-01-15T10:30:00Z",
        "last_visit": "2024-01-10T14:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 156,
      "total_pages": 8,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

### GET `/patients/:id`
```json
// Response (200)
{
  "status": "success",
  "data": {
    "id": "uuid",
    "patient_code": "P20240115001",
    "first_name": "علی",
    "last_name": "احمدی",
    "phone": "09123456789",
    "email": "ali@example.com",
    "birth_date": "1985-05-15",
    "gender": "male",
    "national_id": "1234567890",
    "address": "تهران، خیابان ولیعصر",
    "emergency_contact_name": "فاطمه احمدی",
    "emergency_contact_phone": "09187654321",
    "medical_history": "فشار خون بالا",
    "allergies": "پنی‌سیلین",
    "current_medications": "لوزارتان 50mg",
    "insurance_info": {
      "provider": "تامین اجتماعی",
      "policy_number": "123456789"
    },
    "notes": "بیمار منظم و همکار",
    "is_active": true,
    "created_by": "uuid",
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z",
    "statistics": {
      "total_visits": 5,
      "last_visit": "2024-01-10T14:00:00Z",
      "total_payments": "2500000",
      "pending_payments": "0"
    }
  }
}

// Error Response (404)
{
  "status": "error",
  "message": "بیمار یافت نشد",
  "error_code": "PATIENT_NOT_FOUND"
}
```

### POST `/patients`
```json
// Request
{
  "first_name": "علی",
  "last_name": "احمدی",
  "phone": "09123456789",
  "email": "ali@example.com",
  "birth_date": "1985-05-15",
  "gender": "male",
  "national_id": "1234567890",
  "address": "تهران، خیابان ولیعصر",
  "emergency_contact_name": "فاطمه احمدی",
  "emergency_contact_phone": "09187654321",
  "medical_history": "فشار خون بالا",
  "allergies": "پنی‌سیلین"
}

// Response (201)
{
  "status": "success",
  "message": "بیمار با موفقیت ثبت شد",
  "data": {
    "id": "uuid",
    "patient_code": "P20240115001",
    "first_name": "علی",
    "last_name": "احمدی",
    "phone": "09123456789",
    "created_at": "2024-01-15T10:30:00Z"
  }
}

// Error Response (400)
{
  "status": "error",
  "message": "داده‌های ورودی نامعتبر",
  "errors": {
    "phone": ["شماره تلفن الزامی است"],
    "email": ["فرمت ایمیل نامعتبر است"]
  }
}
```

### PUT `/patients/:id`
```json
// Request
{
  "first_name": "علی",
  "last_name": "احمدی (ویرایش شده)",
  "phone": "09123456789",
  "address": "تهران، خیابان آزادی"
}

// Response (200)
{
  "status": "success",
  "message": "اطلاعات بیمار با موفقیت بروزرسانی شد",
  "data": {
    "id": "uuid",
    "first_name": "علی",
    "last_name": "احمدی (ویرایش شده)",
    "updated_at": "2024-01-15T11:00:00Z"
  }
}
```

### DELETE `/patients/:id`
```json
// Response (200)
{
  "status": "success",
  "message": "بیمار با موفقیت حذف شد"
}
```

## 📅 Appointments API

### GET `/appointments`
```json
// Query Parameters
?date=2024-01-15&doctor_id=uuid&status=scheduled&page=1&limit=20

// Response (200)
{
  "status": "success",
  "data": {
    "appointments": [
      {
        "id": "uuid",
        "appointment_number": "A20240115001",
        "patient": {
          "id": "uuid",
          "name": "علی احمدی",
          "phone": "09123456789"
        },
        "doctor": {
          "id": "uuid",
          "name": "دکتر احمد احمدی"
        },
        "appointment_date": "2024-01-15",
        "appointment_time": "10:30:00",
        "duration_minutes": 30,
        "appointment_type": "consultation",
        "status": "scheduled",
        "fee": "500000",
        "created_at": "2024-01-14T15:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 45,
      "total_pages": 3
    }
  }
}
```

### GET `/appointments/:id`
```json
// Response (200)
{
  "status": "success",
  "data": {
    "id": "uuid",
    "appointment_number": "A20240115001",
    "patient": {
      "id": "uuid",
      "name": "علی احمدی",
      "phone": "09123456789",
      "age": 39,
      "medical_history": "فشار خون بالا"
    },
    "doctor": {
      "id": "uuid",
      "name": "دکتر احمد احمدی"
    },
    "appointment_date": "2024-01-15",
    "appointment_time": "10:30:00",
    "duration_minutes": 30,
    "appointment_type": "consultation",
    "status": "scheduled",
    "chief_complaint": "سردرد مداوم",
    "diagnosis": "",
    "treatment_plan": "",
    "notes": "",
    "fee": "500000",
    "payment_status": "unpaid",
    "created_by": "uuid",
    "created_at": "2024-01-14T15:00:00Z",
    "updated_at": "2024-01-14T15:00:00Z"
  }
}
```

### POST `/appointments`
```json
// Request
{
  "patient_id": "uuid",
  "doctor_id": "uuid",
  "appointment_date": "2024-01-15",
  "appointment_time": "10:30:00",
  "duration_minutes": 30,
  "appointment_type": "consultation",
  "chief_complaint": "سردرد مداوم",
  "fee": "500000",
  "notes": "بیمار برای اولین بار مراجعه می‌کند"
}

// Response (201)
{
  "status": "success",
  "message": "قرار ملاقات با موفقیت ثبت شد",
  "data": {
    "id": "uuid",
    "appointment_number": "A20240115001",
    "appointment_date": "2024-01-15",
    "appointment_time": "10:30:00",
    "status": "scheduled",
    "created_at": "2024-01-14T15:00:00Z"
  }
}

// Error Response (409)
{
  "status": "error",
  "message": "در این زمان قرار دیگری وجود دارد",
  "error_code": "TIME_CONFLICT"
}
```

### PUT `/appointments/:id`
```json
// Request
{
  "appointment_date": "2024-01-16",
  "appointment_time": "14:00:00",
  "status": "confirmed",
  "notes": "زمان تغییر یافت"
}

// Response (200)
{
  "status": "success",
  "message": "قرار ملاقات با موفقیت بروزرسانی شد",
  "data": {
    "id": "uuid",
    "appointment_date": "2024-01-16",
    "appointment_time": "14:00:00",
    "status": "confirmed",
    "updated_at": "2024-01-15T11:00:00Z"
  }
}
```

### PUT `/appointments/:id/complete`
```json
// Request
{
  "diagnosis": "میگرن",
  "treatment_plan": "استراحت و مصرف مسکن",
  "notes": "بیمار بهبود یافته",
  "next_visit_date": "2024-02-15"
}

// Response (200)
{
  "status": "success",
  "message": "ویزیت با موفقیت تکمیل شد",
  "data": {
    "id": "uuid",
    "status": "completed",
    "diagnosis": "میگرن",
    "treatment_plan": "استراحت و مصرف مسکن",
    "completed_at": "2024-01-15T11:00:00Z"
  }
}
```

## 💰 Payments API

### GET `/payments`
```json
// Query Parameters
?patient_id=uuid&status=completed&from_date=2024-01-01&to_date=2024-01-31

// Response (200)
{
  "status": "success",
  "data": {
    "payments": [
      {
        "id": "uuid",
        "payment_number": "PAY20240115001",
        "patient": {
          "id": "uuid",
          "name": "علی احمدی"
        },
        "appointment": {
          "id": "uuid",
          "date": "2024-01-15",
          "type": "consultation"
        },
        "amount": "500000",
        "discount": "50000",
        "final_amount": "450000",
        "payment_method": "cash",
        "payment_status": "completed",
        "payment_date": "2024-01-15T11:30:00Z",
        "created_at": "2024-01-15T11:30:00Z"
      }
    ],
    "summary": {
      "total_amount": "45000000",
      "completed_payments": 89,
      "pending_payments": 5
    }
  }
}
```

### POST `/payments`
```json
// Request
{
  "patient_id": "uuid",
  "appointment_id": "uuid",
  "amount": "500000",
  "payment_method": "cash",
  "discount": "50000",
  "description": "پرداخت ویزیت"
}

// Response (201)
{
  "status": "success",
  "message": "پرداخت با موفقیت ثبت شد",
  "data": {
    "id": "uuid",
    "payment_number": "PAY20240115001",
    "amount": "500000",
    "discount": "50000",
    "final_amount": "450000",
    "payment_status": "completed",
    "created_at": "2024-01-15T11:30:00Z"
  }
}
```

## 📊 Reports & Analytics API

### GET `/dashboard/stats`
```json
// Response (200)
{
  "status": "success",
  "data": {
    "today": {
      "appointments": 12,
      "completed_appointments": 8,
      "revenue": "4500000",
      "new_patients": 3
    },
    "this_month": {
      "appointments": 245,
      "revenue": "122500000",
      "new_patients": 48,
      "patient_growth": 15.2
    },
    "upcoming": {
      "tomorrow_appointments": 15,
      "this_week_appointments": 87
    },
    "totals": {
      "active_patients": 1247,
      "total_revenue": "1250000000"
    }
  }
}
```

### GET `/reports/appointments`
```json
// Query Parameters
?from_date=2024-01-01&to_date=2024-01-31&doctor_id=uuid&format=json

// Response (200)
{
  "status": "success",
  "data": {
    "summary": {
      "total_appointments": 245,
      "completed": 220,
      "cancelled": 15,
      "no_show": 10,
      "completion_rate": 89.8
    },
    "by_type": {
      "consultation": 180,
      "follow_up": 45,
      "therapy": 20
    },
    "by_month": [
      {
        "month": "2024-01",
        "appointments": 245,
        "revenue": "122500000"
      }
    ]
  }
}
```

### GET `/reports/revenue`
```json
// Query Parameters
?from_date=2024-01-01&to_date=2024-01-31&group_by=month

// Response (200)
{
  "status": "success",
  "data": {
    "summary": {
      "total_revenue": "122500000",
      "total_payments": 220,
      "average_payment": "556818",
      "growth_rate": 12.5
    },
    "by_method": {
      "cash": "75000000",
      "card": "35000000",
      "bank_transfer": "12500000"
    },
    "timeline": [
      {
        "period": "2024-01",
        "revenue": "122500000",
        "payments": 220
      }
    ]
  }
}
```

## 📁 File Management API

### POST `/patients/:id/files`
```json
// Form Data
file: [binary data]
category: "lab_result"
description: "نتایج آزمایش خون"

// Response (201)
{
  "status": "success",
  "message": "فایل با موفقیت آپلود شد",
  "data": {
    "id": "uuid",
    "file_name": "blood_test_results.pdf",
    "file_size": 245760,
    "category": "lab_result",
    "description": "نتایج آزمایش خون",
    "uploaded_at": "2024-01-15T12:00:00Z",
    "download_url": "/api/v1/files/uuid/download"
  }
}
```

### GET `/patients/:id/files`
```json
// Response (200)
{
  "status": "success",
  "data": {
    "files": [
      {
        "id": "uuid",
        "file_name": "blood_test_results.pdf",
        "file_size": 245760,
        "category": "lab_result",
        "description": "نتایج آزمایش خون",
        "uploaded_by": "دکتر احمدی",
        "uploaded_at": "2024-01-15T12:00:00Z",
        "download_url": "/api/v1/files/uuid/download"
      }
    ]
  }
}
```

## 🔔 Notifications API

### GET `/notifications`
```json
// Query Parameters
?unread_only=true&limit=20

// Response (200)
{
  "status": "success",
  "data": {
    "notifications": [
      {
        "id": "uuid",
        "type": "appointment_reminder",
        "title": "یادآوری قرار ملاقات",
        "message": "قرار ملاقات شما با علی احمدی فردا ساعت 10:30 است",
        "data": {
          "appointment_id": "uuid",
          "patient_name": "علی احمدی"
        },
        "is_read": false,
        "created_at": "2024-01-14T18:00:00Z"
      }
    ],
    "unread_count": 5
  }
}
```

### PUT `/notifications/:id/read`
```json
// Response (200)
{
  "status": "success",
  "message": "اعلان به عنوان خوانده شده علامت‌گذاری شد"
}
```

## ⚙️ Settings API

### GET `/settings/clinic`
```json
// Response (200)
{
  "status": "success",
  "data": {
    "clinic_name": "کلینیک مشاوره دکتر احمدی",
    "clinic_address": "تهران، خیابان ولیعصر",
    "clinic_phone": "02122334455",
    "clinic_email": "info@clinic.com",
    "working_hours": {
      "saturday": {"start": "08:00", "end": "18:00"},
      "sunday": {"start": "08:00", "end": "18:00"},
      "friday": "closed"
    },
    "appointment_duration": 30,
    "advance_booking_days": 30,
    "timezone": "Asia/Tehran"
  }
}
```

## 🚫 Error Handling

### Standard Error Response Format
```json
{
  "status": "error",
  "message": "پیام خطا برای کاربر",
  "error_code": "ERROR_CODE",
  "details": "جزئیات بیشتر برای توسعه‌دهنده",
  "timestamp": "2024-01-15T12:00:00Z",
  "path": "/api/v1/patients"
}
```

### HTTP Status Codes
- `200` - OK
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `422` - Unprocessable Entity
- `500` - Internal Server Error

## 📝 API Documentation

### Swagger/OpenAPI Integration
```yaml
openapi: 3.0.0
info:
  title: Clinic Management API
  version: 1.0.0
  description: API سیستم مدیریت کلینیک مشاوره
servers:
  - url: https://api.clinic-management.com/v1
    description: Production server
  - url: http://localhost:3000/api/v1
    description: Development server
```

## 🔄 Rate Limiting

### Rate Limit Headers
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1234567890
```

### Rate Limits by Endpoint
- Authentication: 5 requests/minute
- General API: 1000 requests/hour
- File Upload: 10 requests/minute

---

## ✅ چک‌لیست طراحی API

- [x] Authentication & Authorization
- [x] CRUD Operations for all entities
- [x] Error Handling
- [x] Pagination
- [x] Search & Filtering
- [x] File Management
- [x] Reports & Analytics
- [x] Rate Limiting
- [x] API Documentation

**مرحله بعدی: UI/UX Design & Wireframes** 🎨