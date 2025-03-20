# โปรเจคฝึกฝน: ระบบจัดการหนังสือด้วย Django

โปรเจคนี้เป็นโจทย์สำหรับฝึกฝนการพัฒนาระบบจัดการหนังสืออย่างง่ายด้วย Django และเทคโนโลยีที่เกี่ยวข้อง

## เทคโนโลยีที่ใช้

- Django 5.1.7
- Django REST Framework
- GraphQL (Graphene-Django)
- JWT Authentication
- PostgreSQL
- Docker & DevContainer

## ฟีเจอร์หลัก

- ระบบผู้ใช้งาน (ลงทะเบียน, เข้าสู่ระบบด้วย JWT)
- การแสดงรายการหนังสือ และรายละเอียดหนังสือ
- การเพิ่ม แก้ไข ลบหนังสือ (สำหรับผู้ดูแลระบบ)
- ระบบ Logging

## การติดตั้งและเริ่มต้นใช้งาน

### สิ่งที่ต้องมี
- Docker และ Docker Compose
- Visual Studio Code พร้อม Extension "Remote - Containers"
- Git

### วิธีเริ่มต้น

1. Clone โปรเจคนี้
2. รันสคริปต์ตั้งค่าโปรเจค (หากต้องการตั้งค่าโครงสร้างใหม่)
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. เริ่มต้นด้วย VS Code DevContainer
   - เปิด VS Code
   - กด F1 และเลือก "Remote-Containers: Open Folder in Container"
   - เลือกโฟลเดอร์ของโปรเจค
   - รอให้ VS Code สร้าง Container และติดตั้งส่วนประกอบต่างๆ

4. เข้าถึงแอปพลิเคชัน
   - Django: http://localhost:8000

## โครงสร้างโปรเจค

```
book-management-system/
├── .devcontainer/             # การตั้งค่า DevContainer
│   └── devcontainer.json
├── books/                     # Django app จัดการหนังสือ
├── bookmanagement/            # Django project หลัก
├── Dockerfile.dev             # Dockerfile สำหรับการพัฒนา
├── docker-compose.yml         # การตั้งค่า Docker Compose
├── requirements.txt           # Python dependencies
├── setup.sh                   # สคริปต์ตั้งค่าโครงสร้างโปรเจค
├── .gitignore
└── README.md
```

## ข้อกำหนดของโปรเจค

### Models

1. **หนังสือ (Book)**
   - ชื่อหนังสือ
   - ผู้แต่ง
   - ปีที่พิมพ์
   - หมวดหมู่ (FK)
   - คำอธิบายสั้นๆ
   - รูปปก (URL)
   - วันที่สร้าง/แก้ไข

2. **หมวดหมู่ (Category)**
   - ชื่อหมวดหมู่

### API Endpoints

1. **การจัดการผู้ใช้**
   - `/api/auth/register/` - ลงทะเบียนผู้ใช้ใหม่
   - `/api/auth/token/` - รับ token (JWT)
   - `/api/auth/token/refresh/` - รีเฟรช token

2. **การจัดการหนังสือ**
   - `/api/books/` - แสดงรายการหนังสือทั้งหมด (GET) / เพิ่มหนังสือใหม่ (POST)
   - `/api/books/<id>/` - ดูรายละเอียดหนังสือ (GET) / แก้ไขหนังสือ (PUT) / ลบหนังสือ (DELETE)
   - `/api/categories/` - แสดงรายการหมวดหมู่ทั้งหมด

3. **GraphQL API**
   - `/graphql/` - เข้าถึง GraphQL API

## ขั้นตอนการพัฒนา

### สัปดาห์ที่ 1:
- วันที่ 1-2: ศึกษาเทคโนโลยีและตั้งค่าโปรเจค Django
- วันที่ 3-4: พัฒนา Models, REST API และระบบ JWT Authentication
- วันที่ 5-7: พัฒนา GraphQL API พื้นฐาน

### สัปดาห์ที่ 2:
- วันที่ 1-3: พัฒนา API ให้ครบถ้วนตามความต้องการ
- วันที่ 4-5: พัฒนาระบบ Logging และการตรวจสอบสิทธิ์
- วันที่ 6-7: ทดสอบระบบและแก้ไขข้อผิดพลาด

## การเริ่มต้นพัฒนา Django Project

1. สร้าง Django project
   ```bash
   django-admin startproject bookmanagement .
   ```

2. สร้าง app สำหรับจัดการหนังสือ
   ```bash
   python manage.py startapp books
   ```

3. ตั้งค่าฐานข้อมูล PostgreSQL ใน settings.py
   ```python
   DATABASES = {
       'default': {
           'ENGINE': 'django.db.backends.postgresql',
           'NAME': 'bookmanagement',
           'USER': 'postgres',
           'PASSWORD': 'postgres',
           'HOST': 'db',
           'PORT': '5432',
       }
   }
   ```

4. ตั้งค่า REST Framework และ JWT ใน settings.py
   ```python
   INSTALLED_APPS = [
       # ...
       'rest_framework',
       'corsheaders',
       'graphene_django',
       'books',
   ]

   REST_FRAMEWORK = {
       'DEFAULT_AUTHENTICATION_CLASSES': (
           'rest_framework_simplejwt.authentication.JWTAuthentication',
       ),
   }
   ```

## การอ้างอิง

- [Django Documentation](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Graphene Django](https://docs.graphene-python.org/projects/django/en/latest/)
- [Simple JWT](https://django-rest-framework-simplejwt.readthedocs.io/)
- [Docker Documentation](https://docs.docker.com/)
