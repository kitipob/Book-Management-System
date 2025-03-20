# โปรเจคฝึกฝน: ระบบจัดการหนังสือ (Book Management System)

โปรเจคนี้เป็นโจทย์สำหรับฝึกฝนการพัฒนาระบบเว็บแอปพลิเคชันแบบ Full Stack โดยใช้เทคโนโลยีที่หลากหลาย เพื่อสร้างระบบจัดการหนังสืออย่างง่าย
## เทคโนโลยีที่ใช้

### Backend
- Django 5.1.7
- Django REST Framework
- GraphQL (Graphene-Django)
- JWT Authentication
- Logging System

### Frontend
- React.js
- Bootstrap
- Axios
- GraphQL Relay

### DevOps
- Docker & Docker Compose
- VS Code DevContainer

## ฟีเจอร์หลัก

- ระบบจัดการผู้ใช้งาน (ลงทะเบียน, เข้าสู่ระบบด้วย JWT)
- การแสดงรายการหนังสือ และรายละเอียดหนังสือ
- การเพิ่ม แก้ไข ลบหนังสือ (สำหรับผู้ดูแลระบบ)
- Activity Logging

## การติดตั้งและเริ่มต้นใช้งาน

### สิ่งที่ต้องมี
- Docker และ Docker Compose
- Visual Studio Code พร้อม Extension "Remote - Containers"
- Git

### วิธีการติดตั้ง

#### การใช้งานกับ VS Code DevContainer
1. Clone โปรเจค

2. เริ่มต้นด้วย VS Code DevContainer
   - เปิด VS Code
   - กด F1 และเลือก "Remote-Containers: Open Folder in Container"
   - เลือกโฟลเดอร์ของโปรเจค
   - รอให้ VS Code สร้าง Container และติดตั้งส่วนประกอบต่างๆ

#### การใช้งานด้วย Docker Compose (ไม่ใช้ DevContainer)
```bash
docker-compose up -d
```

### การเข้าถึงระบบ
- Backend: http://localhost:8000
- Frontend: http://localhost:3000
- API Endpoints: http://localhost:8000/api/
- Admin Dashboard: http://localhost:8000/admin/ (user: admin, password: admin)
- GraphQL Playground: http://localhost:8000/graphql/

## โครงสร้างโปรเจค

```
book-management-system/
├── .devcontainer/             # การตั้งค่า DevContainer
│   └── devcontainer.json
├── backend/                   # Django Backend
│   ├── Dockerfile.dev
│   ├── requirements.txt
│   └── ...
├── frontend/                  # React Frontend
│   ├── Dockerfile.dev
│   ├── package.json
│   └── ...
├── docker-compose.yml         # การตั้งค่า Docker Compose
├── setup.sh                   # สคริปต์ตั้งค่าโครงสร้างโปรเจค
└── README.md
```

## API Documentation

### REST API Endpoints

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/api/books/` | GET | รายการหนังสือทั้งหมด | ไม่ต้องการ |
| `/api/books/:id/` | GET | รายละเอียดหนังสือ | ไม่ต้องการ |
| `/api/books/` | POST | เพิ่มหนังสือใหม่ | ต้องการ (Admin) |
| `/api/books/:id/` | PUT | อัปเดตข้อมูลหนังสือ | ต้องการ (Admin) |
| `/api/books/:id/` | DELETE | ลบหนังสือ | ต้องการ (Admin) |
| `/api/auth/token/` | POST | ขอรับ JWT Token | ไม่ต้องการ |
| `/api/auth/register/` | POST | ลงทะเบียนผู้ใช้ใหม่ | ไม่ต้องการ |

## เป้าหมายการเรียนรู้

1. เรียนรู้การพัฒนา API ด้วย Django REST Framework และ GraphQL
2. เรียนรู้การพัฒนา Frontend ด้วย React และเชื่อมต่อกับ Backend
3. ฝึกฝนการใช้ JWT Authentication
4. เรียนรู้การใช้งาน Docker และ DevContainer
5. เข้าใจการทำงานของระบบบันทึกกิจกรรม (Logging)

## ขั้นตอนการพัฒนา

### สัปดาห์ที่ 1:
- วันที่ 1-2: ศึกษาเทคโนโลยีและตั้งค่าโปรเจค
- วันที่ 3-4: พัฒนา Models, REST API และระบบ JWT Authentication
- วันที่ 5-7: พัฒนา GraphQL API พื้นฐานและหน้า Frontend เริ่มต้น

### สัปดาห์ที่ 2:
- วันที่ 1-2: พัฒนาหน้า Frontend ให้ครบทุกฟังก์ชัน
- วันที่ 3-4: เชื่อมต่อ GraphQL Relay กับ Frontend
- วันที่ 5-6: ตั้งค่า Docker และทดสอบระบบบน Container
- วันที่ 7: ทดสอบระบบและแก้ไขข้อผิดพลาด

## คำแนะนำเพิ่มเติม

- ศึกษาเอกสารของแต่ละเทคโนโลยีให้เข้าใจก่อนเริ่มการพัฒนา
- ใช้ Git เพื่อจัดการ Source Code และแบ่งการทำงานเป็น Branch
- เขียนเอกสารและความคิดเห็นในโค้ดเพื่อให้เข้าใจง่าย
- ทดสอบระบบอย่างสม่ำเสมอเพื่อให้แน่ใจว่าทุกอย่างทำงานได้ถูกต้อง

## การแก้ปัญหาเบื้องต้น (Troubleshooting)

| ปัญหา | วิธีแก้ไข |
|-------|----------|
| Container ไม่สามารถเริ่มต้นได้ | ตรวจสอบ Docker service และ log ด้วยคำสั่ง `docker-compose logs` |
| เกิด error ตอน migrations | ลบไฟล์ migrations และสร้างใหม่ด้วย `python manage.py makemigrations` |
| Frontend ไม่สามารถเชื่อมต่อกับ Backend | ตรวจสอบค่า REACT_APP_API_URL ใน environment variables |

## การอ้างอิง

- [Django Documentation](https://docs.djangoproject.com/)
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Graphene Django](https://docs.graphene-python.org/projects/django/en/latest/)
- [React Documentation](https://reactjs.org/docs/getting-started.html)
- [Docker Documentation](https://docs.docker.com/)

## License
MIT License - ดูรายละเอียดได้ที่ [LICENSE](LICENSE) file
