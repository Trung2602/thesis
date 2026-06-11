# 🏋️ Smart Gym Management System

> Hệ thống quản lý phòng gym thông minh tích hợp tư vấn chế độ tập luyện và dinh dưỡng dựa trên AI

![Java](https://img.shields.io/badge/Java-Spring%20Boot-6DB33F?style=flat&logo=springboot&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-Dart-02569B?style=flat&logo=flutter&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat&logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-ECS%20%7C%20RDS%20%7C%20VPC-FF9900?style=flat&logo=amazonaws&logoColor=white)
![Gemini](https://img.shields.io/badge/Gemini%20API-AI-8E75B2?style=flat&logo=google&logoColor=white)

---

## 📖 Giới thiệu

Hệ thống giải quyết bài toán chuyển đổi số trong lĩnh vực thể hình, thay thế các phương pháp quản lý thủ công bằng nền tảng số hóa toàn diện. Hệ thống tự động hóa các nghiệp vụ cốt lõi như quản lý thành viên, chấm công, tính lương, thống kê tài chính, đồng thời ứng dụng AI để cá nhân hóa lộ trình tập luyện và dinh dưỡng cho từng khách hàng.

---

## ✨ Tính năng chính

### 👑 Admin – Quản trị viên
- Quản lý toàn bộ dữ liệu hệ thống (thêm, sửa, xóa danh mục)
- Tạo tài khoản, phê duyệt lịch làm việc và đơn nghỉ phép cho nhân viên
- **Tính lương tự động** theo lương cơ bản, chức vụ và ngày nghỉ (tự động cuối tháng hoặc bán thủ công)
- Xem báo cáo doanh thu, chi phí, lợi nhuận theo tháng/quý/năm với biểu đồ trực quan

### 👷 Staff – Nhân viên
- Đăng ký lịch làm việc, theo dõi danh sách khách hàng đặt lịch
- Ghi chú tiến độ tập luyện và cập nhật chỉ số cơ thể khách hàng (cân nặng, chiều cao, tỷ lệ mỡ, …)
- Xem bảng lương chi tiết hàng tháng, gửi đơn xin nghỉ phép trực tuyến
- Hỗ trợ khách hàng qua hệ thống chat

### 🏃 Customer – Khách hàng
- Đăng ký tài khoản với xác thực OTP qua email
- Thanh toán gói tập trực tuyến qua **cổng VNPAY**, nhận email xác nhận tự động
- Đặt lịch hẹn với huấn luyện viên, theo dõi lịch trình tập luyện cá nhân
- Lưu trữ và theo dõi chỉ số cơ thể theo thời gian (BMI, cân nặng, tỷ lệ mỡ, …)
- Tương tác với **Chatbot AI 24/7** để nhận tư vấn dinh dưỡng và kế hoạch bài tập cá nhân hóa
- Chat trực tiếp với nhân viên hỗ trợ

---

## 🏗️ Kiến trúc hệ thống

Hệ thống được xây dựng theo kiến trúc **Microservices**, áp dụng mô hình **Database per Service**:

```
Mobile App (Flutter)
        │
        ▼
  ALB (Public Subnet)
        │
  ┌─────┼─────────────┐
  ▼     ▼             ▼
user- gym-          ai-
server server       server
  │     │             │
userdb gymdb         aidb
     (PostgreSQL – Private Subnet)
```

### 3 Microservices chính

| Service | Công nghệ | Chức năng |
|---|---|---|
| **user-server** | Spring Boot + JWT | Xác thực, phân quyền, quản lý tài khoản |
| **gym-server** | Spring Boot + VNPay | Nghiệp vụ phòng gym, ca làm việc, lương, thanh toán |
| **ai-server** | Spring Boot + Gemini API + RAG | Tư vấn cá nhân hóa dinh dưỡng và tập luyện |

---

## 🤖 Tính năng AI

- Sử dụng kỹ thuật **RAG (Retrieval-Augmented Generation)** kết hợp **Gemini API**
- Dữ liệu dinh dưỡng được chuẩn hóa từ **Viện Dinh dưỡng Quốc gia Việt Nam**
- Chuyển đổi câu hỏi sang vector embedding, tìm kiếm ngữ nghĩa trên cơ sở dữ liệu thực phẩm và bài tập
- Phản hồi được cá nhân hóa dựa trên chỉ số cơ thể và mục tiêu của từng khách hàng
- Giao tiếp thời gian thực qua **WebSocket**

---

## 🛠️ Công nghệ sử dụng

| Nhóm | Công nghệ |
|---|---|
| **Backend** | Java Spring Boot (Microservices), OpenFeign, JWT, WebSocket |
| **Frontend** | Flutter (Dart) – iOS & Android |
| **Database** | PostgreSQL (pgvector cho AI embeddings 768-dim), Firebase Realtime Database |
| **AI** | Google Gemini API, RAG, Semantic Search |
| **Thanh toán** | VNPay |
| **DevOps** | Docker, Amazon ECR, Amazon ECS (Fargate) |
| **Cloud** | AWS (VPC, ALB, RDS, NAT Gateway, CloudWatch, CloudFormation) |

---

## ☁️ Hạ tầng triển khai (AWS)

```
Internet
    │
   IGW
    │
Public Subnet
  ├── ALB  (tiếp nhận traffic)
  ├── NAT Gateway  (cho Private Subnet ra internet)
  └── EC2  (bastion host – SSH đến RDS)
    │
Private Subnet
  ├── ECS (user-container, gym-container, ai-container)
  └── RDS (userdb, gymdb, aidb)
```

- **Bảo mật đa lớp**: toàn bộ container và database nằm trong Private Subnet, chỉ expose qua ALB
- **Auto Scaling**: ECS + ALB tự động điều chỉnh tài nguyên theo tải thực tế
- **Giám sát**: CloudWatch Logs tập trung hóa nhật ký hệ thống
- **IaC**: CloudFormation quản lý toàn bộ hạ tầng dưới dạng code

---

## 🚀 Hướng dẫn cài đặt

### Yêu cầu
- Java 17+
- Flutter SDK 3.x
- Docker & Docker Compose
- PostgreSQL 15+

### Chạy với Docker Compose

```bash
# Clone repository
git clone https://github.com/<your-username>/<repo-name>.git
cd <repo-name>

# Khởi động tất cả services
docker-compose up -d

# Kiểm tra logs
docker-compose logs -f
```

### Biến môi trường

Tạo file `.env` từ mẫu:

```bash
cp .env.example .env
```

Các biến cần cấu hình:

```env
# Database
USERDB_URL=jdbc:postgresql://localhost:5432/userdb
GYMDB_URL=jdbc:postgresql://localhost:5432/gymdb
AIDB_URL=jdbc:postgresql://localhost:5432/aidb

# JWT
JWT_SECRET=your_jwt_secret_key

# Gemini AI
GEMINI_API_KEY=your_gemini_api_key

# VNPay
VNPAY_TMN_CODE=your_vnpay_tmn_code
VNPAY_HASH_SECRET=your_vnpay_hash_secret

# Firebase
FIREBASE_CONFIG=path/to/firebase-config.json
```

### Chạy Flutter App

```bash
cd mobile
flutter pub get
flutter run
```

---

## 📁 Cấu trúc thư mục

```
├── user-server/          # Service xác thực & quản lý tài khoản
│   └── src/
├── gym-server/           # Service nghiệp vụ phòng gym
│   └── src/
├── ai-server/            # Service AI tư vấn
│   └── src/
├── mobile/               # Flutter application
│   └── lib/
├── docker-compose.yml
└── README.md
```

---

## 🔮 Hướng phát triển

- **Nâng cấp AI**: phân tích hình ảnh/video để chỉnh sửa kỹ thuật động tác; tính calories từ ảnh bữa ăn
- **Đa dạng thanh toán**: mở rộng thêm các cổng thanh toán ngoài VNPay
- **Kết nối thiết bị thông minh**: đồng bộ dữ liệu từ smartwatch, vòng tay fitness (nhịp tim, calorie tiêu thụ)
- **Multi-AZ**: triển khai nhiều Availability Zone để tăng tính sẵn sàng cao

---

## 👨‍💻 Tác giả

| | |
|---|---|
| **Sinh viên** | Lư Hiếu Trung |
| **MSSV** | 2251012145 |
| **Ngành** | Khoa học Máy tính |
| **Trường** | Đại học Mở Thành phố Hồ Chí Minh |
| **GVHD** | TS. Trương Hoàng Vinh |
| **Năm** | 2026 |

---

## 📚 Tài liệu tham khảo

- S. Newman, *Building Microservices*, 2nd ed. O'Reilly Media, 2021
- C. Richardson, *Microservices Patterns*. Manning Publications, 2018
- P. Lewis et al., "Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks," *NeurIPS*, 2020
- Viện Dinh dưỡng Quốc gia, *Bảng thành phần thực phẩm Việt Nam*. NXB Y học, 2007

---

<p align="center">Made with ❤️ by Lư Hiếu Trung · OU HCMC 2026</p>
