# 🏥 Hospital Management System

A full-stack Hospital Management System built with **Spring Boot** (backend) and **Flutter** (frontend), designed to streamline core hospital operations including patient management, appointments, billing, pharmacy, lab, and more.

---

## 📁 Project Structure

```
hospital-management-system/
├── backend/       # Spring Boot REST API
├── frontend/      # Flutter cross-platform app
└── README.md
```

---

## ⚙️ Tech Stack

### Backend
| Technology | Purpose |
|---|---|
| Java 17 | Core language |
| Spring Boot 3.2.4 | Application framework |
| Spring Security + JWT | Authentication & authorization |
| PostgreSQL | Relational database |
| Redis | JWT blacklisting / token cache |
| Spring Data JPA + Hibernate | ORM |
| Spring Mail (Gmail SMTP) | Email notifications |
| iText7 | PDF generation (invoices, lab reports) |
| Springdoc OpenAPI (Swagger) | API documentation |
| Lombok | Boilerplate reduction |

### Frontend
| Technology | Purpose |
|---|---|
| Flutter (Dart SDK ^3.9.2) | Cross-platform UI |
| Dio | HTTP client with JWT interceptor |
| Provider | State management |
| Flutter Secure Storage | Secure token storage |
| Shared Preferences | Local persistence |
| iText / open_file | PDF viewing |

---

## 🚀 Features

### 👤 Auth
- Role-based login (Admin, Doctor, Receptionist, Pharmacist, Lab Technician)
- JWT access + refresh token flow
- Token blacklisting via Redis on logout
- **No public registration** — only Admin can create other users

### 🧑‍⚕️ Patient Management
- Register, update, view patients

### 👨‍⚕️ Doctor Management
- Add doctors with specialization
- Manage weekly availability slots

### 📅 Appointments
- Book appointments based on doctor availability
- Status management (scheduled, completed, cancelled)

### 🏥 Visit
- Track patient visits linked to appointments

### 💊 Pharmacy
- Medicine catalog management
- Stock tracking with add/dispense transactions
- Prescription-based dispensing

### 🧪 Lab
- Order lab tests per visit
- Lab technician fills result parameters
- PDF lab report generation

### 💳 Billing
- Create invoices per visit
- Add line items, track payment status
- PDF invoice generation & email delivery

### 📋 Prescription
- Doctors write prescriptions per visit
- Linked to pharmacy dispensing flow

### 📧 Notifications
- Email notifications for appointments and billing via Gmail SMTP

---

## 📸 Screenshots

<table>
<tr>
<td width="50%">

**Auth**
<img width="100%" alt="Auth screen" src="https://github.com/user-attachments/assets/b4a9cc0b-097c-4e27-9767-942038e4405d" />

</td>
<td width="50%">

**Admin Dashboard**
<img width="100%" alt="Admin dashboard" src="https://github.com/user-attachments/assets/1e600b17-6523-4cea-9150-ed8e60a95513" />

</td>
</tr>
<tr>
<td width="50%">

**Create User**
<img width="100%" alt="Create user" src="https://github.com/user-attachments/assets/792198c4-7109-45ab-991b-e7af5692d1e5" />

</td>
<td width="50%">

**Doctors**
<img width="100%" alt="Doctors list" src="https://github.com/user-attachments/assets/a80f8990-009a-4689-93b2-954f1a75b2af" />

</td>
</tr>
<tr>
<td width="50%">

**Add Doctor**
<img width="100%" alt="Add doctor" src="https://github.com/user-attachments/assets/9a8eeae7-54cb-4c87-aa61-23e9ee989b3f" />

</td>
<td width="50%">

**Doctor Dashboard**
<img width="100%" alt="Doctor dashboard" src="https://github.com/user-attachments/assets/ac518e33-c66e-4f9c-856b-0723d8b936ad" />

</td>
</tr>
<tr>
<td width="50%">

**Patients**
<img width="100%" alt="Patients list" src="https://github.com/user-attachments/assets/ac2dba17-a05d-4cb6-baea-cea8fc282fc9" />

</td>
<td width="50%">

**Add Patient**
<img width="100%" alt="Add patient" src="https://github.com/user-attachments/assets/f230d184-26f0-4ddc-a15c-bb4bde9abbe5" />

</td>
</tr>
<tr>
<td width="50%">

**Appointments**
<img width="100%" alt="Appointments list" src="https://github.com/user-attachments/assets/b92bc3df-3bc1-41d0-8c1c-f30f62af83dc" />

</td>
<td width="50%">

**Book Appointment**
<img width="100%" alt="Book appointment" src="https://github.com/user-attachments/assets/0d29a688-7c5e-4e1b-bfa7-76d08b467287" />

</td>
</tr>
<tr>
<td width="50%">

**Add Availability**
<img width="100%" alt="Add availability" src="https://github.com/user-attachments/assets/7dce33d4-9a6d-4684-83ae-4ba9fa402ec0" />

</td>
<td width="50%">

**Visit Detail**
<img width="100%" alt="Visit detail" src="https://github.com/user-attachments/assets/828bccc8-8063-4304-a042-5cda58f40f65" />

</td>
</tr>
<tr>
<td width="50%">

**Write Prescription**
<img width="100%" alt="Write prescription" src="https://github.com/user-attachments/assets/5581693e-3730-4d09-9bf2-b9a7ca8600b6" />

</td>
<td width="50%">

**Pharmacy Home**
<img width="100%" alt="Pharmacy home" src="https://github.com/user-attachments/assets/03cf0b35-4853-4cb2-ba61-9bf249eef9ef" />

</td>
</tr>
<tr>
<td width="50%">

**Add Medicine**
<img width="100%" alt="Add medicine" src="https://github.com/user-attachments/assets/b09b5d11-4170-4213-8e2a-0951c83fdae4" />

</td>
<td width="50%">

**Add Stock**
<img width="100%" alt="Add stock" src="https://github.com/user-attachments/assets/aa2daa2f-79ff-4f64-aecb-dd54a47063a3" />

</td>
</tr>
<tr>
<td width="50%">

**Expiring Stock**
<img width="100%" alt="Expiring stock" src="https://github.com/user-attachments/assets/9bfa6ee4-f4bf-4d39-8153-64b4bbeb0677" />

</td>
<td width="50%">

**Available Stock**
<img width="100%" alt="Available stock" src="https://github.com/user-attachments/assets/1ef63880-2655-43a1-9599-5f9ff6500a96" />

</td>
</tr>
<tr>
<td width="50%">

**Dispense Prescription**
<img width="100%" alt="Dispense prescription" src="https://github.com/user-attachments/assets/366ce9c7-86c3-4edb-9953-a6333889c843" />

</td>
<td width="50%">

**Lab Tests**
<img width="100%" alt="Lab tests" src="https://github.com/user-attachments/assets/480252d3-4fe2-4fee-bdb9-e313d18bc69e" />

</td>
</tr>
<tr>
<td width="50%">

**Lab Technician**
<img width="100%" alt="Lab technician" src="https://github.com/user-attachments/assets/95bc99be-2c41-4194-b4dc-1ac5a63aa85f" />

</td>
<td width="50%">

**Billing**
<img width="100%" alt="Billing" src="https://github.com/user-attachments/assets/87989418-e1f7-474b-b863-aa1b51cc104a" />

</td>
</tr>
<tr>
<td width="50%">

**Receptionist Dashboard**
<img width="100%" alt="Receptionist dashboard" src="https://github.com/user-attachments/assets/1f62cf73-36c2-4d6d-b50a-94bfe0299337" />

</td>
<td width="50%">

<!-- Add a screenshot here (e.g. Lab Reports, Add Lab Result, Billing Overview, or Invoice Details) -->

</td>
</tr>
</table>

> Note: "Lab Reports", "Add Lab Result", "Billing Overview", "Create Invoice", "Invoice Details", and "Payment" screenshots were referenced via local `screenshots/` paths but no image was actually uploaded for them yet. Upload these to GitHub (drag-and-drop into a comment/PR/issue, or directly into the README editor on GitHub.com) to get a permanent `user-attachments` URL, then drop them into the empty cell above or add new rows.

---

## 🔐 User Role Flow

> **There is no public registration in this system.** Access is controlled entirely by the Admin.

```
Admin (manually created via Postman)
  └── Creates → Doctor
  └── Creates → Receptionist
  └── Creates → Pharmacist
  └── Creates → Lab Technician
```

### Step 1 — Create the first Admin user via Postman

Send a `POST` request to:

```
POST http://localhost:8080/api/auth/register
```

Request body:
```json
{
  "username": "admin",
  "password": "admin123",
  "role": "ADMIN"
}
```

> ⚠️ **Important:** This endpoint is only intended for initial Admin setup. In a production environment, this endpoint should be disabled or secured (e.g. IP-restricted) after the first Admin is created.

### Step 2 — Log in as Admin

```
POST http://localhost:8080/api/auth/login
```

Use the JWT token returned to authenticate all further requests.

### Step 3 — Admin creates other users from within the app or via API

Once logged in, the Admin can create Doctors, Receptionists, Pharmacists, and Lab Technicians through the Flutter frontend or directly via the API.

---

## 🛠️ Getting Started

### Prerequisites
- Java 17+
- Maven 3.8+
- PostgreSQL 14+
- Redis 7+
- Flutter SDK (Dart ^3.9.2)

---

### 1. PostgreSQL Setup

Create the database:
```sql
CREATE DATABASE hospital_db;
```

---

### 2. Redis Setup

#### macOS (Homebrew)
```bash
brew install redis
brew services start redis
```

#### Ubuntu / Debian
```bash
sudo apt update
sudo apt install redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

#### Windows
Download and install from the official Redis for Windows release:
https://github.com/tporadowski/redis/releases

Then start the server:
```bash
redis-server
```

Verify Redis is running:
```bash
redis-cli ping
# Expected output: PONG
```

---

### 3. Backend Setup

Navigate to the backend directory:
```bash
cd backend
```

Set the required environment variables:
```bash
DB_USERNAME=postgres
DB_PASSWORD=your_db_password
JWT_SECRET=your_long_random_secret_key
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_gmail_app_password
```

> **JWT Secret:** Use a long, random string (32+ characters recommended) — this signs and verifies your JWT tokens. You can generate one quickly with `openssl rand -base64 32`.

> **Gmail:** Use an [App Password](https://support.google.com/accounts/answer/185833), not your login password.

Run the application:
```bash
./mvnw spring-boot:run
```

Backend runs at `http://localhost:8080`

---

### 4. Frontend Setup

Navigate to the frontend directory:
```bash
cd frontend
```

Install dependencies:
```bash
flutter pub get
```

Update the base URL in `lib/core/network/api_client.dart` if needed:
```dart
baseUrl: "http://localhost:8080/api"
```

Run the app:
```bash
flutter run
```

---

## 📖 API Documentation

Once the backend is running, visit:

```
http://localhost:8080/swagger-ui.html
```

All endpoints are documented with request/response schemas.

---

## 🔐 Environment Variables

| Variable | Description |
|---|---|
| `DB_USERNAME` | PostgreSQL username |
| `DB_PASSWORD` | PostgreSQL password |
| `JWT_SECRET` | Secret key used to sign and verify JWT tokens |
| `MAIL_USERNAME` | Gmail address for notifications |
| `MAIL_PASSWORD` | Gmail app password (not your login password) |

> **Note:** Never commit real credentials. Use environment variables in your IDE or system, or a `.env` file that is listed in `.gitignore`.

---

## 🗄️ Database Schema

The system uses **18 tables** in PostgreSQL. The `visits` table is the central hub — prescription, invoice, lab orders, and stock transactions all link to it.

### Entity Relationships

```
users ──────────────── refresh_token
  │
  └──── doctors ──────── doctor_availability
            │
            └──── appointments ◄──── patients
                        │
                        └──── visits (central hub)
                                  ├──── prescription ──── prescription_item ──── medicine
                                  │                                                  └──── medicine_stock
                                  ├──── invoice ──── invoice_item              stock_transaction
                                  ├──── lab_test_orders ──── lab_result_parameters
                                  └──── stock_transaction
                                  
lab_tests ──── lab_test_parameters
    └────────── lab_test_orders
```

### Key Design Decisions

- **Patients are not system users** — `patients` has no FK to `users`. Patients are records managed by staff, not app users.
- **Doctors are linked to users** — each doctor profile maps to one user account (`doctors.user_id → users.id`).
- **Visit is the source of truth** — billing, prescriptions, lab orders, and pharmacy dispensing all reference `visit_id`.
- **Stock dispensing is visit-level** — `stock_transaction.visit_id` tracks pharmacy dispenses per visit, not per prescription item.
- **Lab orders carry redundant FKs** — `lab_test_orders` holds both `visit_id` and `appointment_id`. Since visits are always linked to appointments, `appointment_id` here is supplementary for quick lookups.
- **JWT blacklisting** — `refresh_token` table works alongside Redis for token invalidation on logout.

### Table Summary

| Module | Tables |
|---|---|
| Auth | `users`, `refresh_token` |
| Doctor | `doctors`, `doctor_availability` |
| Patient | `patients` |
| Appointment | `appointments` |
| Visit | `visits` |
| Prescription | `prescription`, `prescription_item` |
| Pharmacy | `medicine`, `medicine_stock`, `stock_transaction` |
| Lab | `lab_tests`, `lab_test_parameters`, `lab_test_orders`, `lab_result_parameters` |
| Billing | `invoice`, `invoice_item` |

---

## 🧩 Module Overview

```
backend/src/main/java/com/hospital/management/
├── auth/           # Login, register, JWT, refresh token
├── user/           # User entity & roles
├── patient/        # Patient CRUD
├── doctor/         # Doctor CRUD + availability
├── appointment/    # Appointment booking & status
├── visit/          # Patient visits
├── prescription/   # Doctor prescriptions
├── pharmacy/       # Medicine stock & dispensing
├── lab/            # Lab tests, orders & results
├── billing/        # Invoices & payments
├── notification/   # Email & PDF notifications
├── security/       # JWT filter, blacklist, config
└── exception/      # Global error handling
```

```
frontend/lib/
├── core/           # API client, secure storage, utils
├── modules/        # Feature modules (auth, patient, doctor...)
├── theme/          # App theme
├── routes/         # Navigation
└── widgets/        # Shared widgets
```

---

## 👨‍💻 Author

Vinayak Subhash Kharade
TY CSE, Dnyanshree Institute of Engineering and Technology

Built as a student project demonstrating enterprise-level backend architecture with a cross-platform mobile frontend.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
