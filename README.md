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
<img src="screenshots/auth_screen.png" width="100%"/>

</td>
<td width="50%">

**Admin Dashboard**
<img src="screenshots/admin_dashboard.png" width="100%"/>

</td>
</tr>
<tr>
<td width="50%">

**Create User**
<img src="screenshots/create_user.png" width="100%"/>

</td>
<td width="50%">

**Doctors**
<img src="screenshots/doctors.png" width="100%"/>

</td>
</tr>
<tr>
<td width="50%">

**Add Doctor**
<img src="screenshots/add_doctor.png" width="100%"/>

</td>
<td width="50%">

**Doctor Dashboard**
<img src="screenshots/doctor_dashboard.png" width="100%"/>

</td>
</tr>
<tr>
<td width="50%">

**Patients**
<img src="screenshots/patients.png" width="100%"/>

</td>
<td width="50%">

**Add Patient**
<img src="screenshots/add_patient.png" width="100%"/>

</td>
</tr>
<tr>
<td width="50%">

**Appointments**
<img src="screenshots/appointments.png" width="100%"/>

</td>
<td width="50%">

**Add Appointment**
<img src="screenshots/add_appointment.png" width="100%"/>

</td>
</tr>
<tr>
<td width="50%">

**Add Availability**
<img src="screenshots/add_availability.png" width="100%"/>

</td>
<td width="50%">

**Visit Detail**
<img src="screenshots/visit_detail.png" width="100%"/>

</td>
</tr>
<tr>
<td width="50%">

**Write Prescription**
<img src="screenshots/write_prescription.png" width="100%"/>

</td>
<td width="50%">

**Pharmacy Home**
<img src="screenshots/pharmacy_home.png" width="100%"/>

</td>
</tr>
<tr>
<td width="50%">

**Add Medicine**
<img src="screenshots/add_medicine.png" width="100%"/>

</td>
<td width="50%">

**Add Stock**
<img src="screenshots/add_stock.png" width="100%"/>

</td>
</tr>
<tr>
<td width="50%">

**Dispense Medicine**
<img src="screenshots/dispense_medicine.png" width="100%"/>

</td>
<td width="50%">

**Dispense Prescription**
<img src="screenshots/dispense_prescription.png" width="100%"/>

</td>
</tr>
<tr>
<td width="50%">

**Lab Tests**
<img src="screenshots/lab_tests.png" width="100%"/>

</td>
<td width="50%">

**Lab Technician**
<img src="screenshots/lab_technician.png" width="100%"/>

</td>
</tr>
<tr>
<td width="50%">

**Lab Reports**
<img src="screenshots/lab_reports.png" width="100%"/>

</td>
<td width="50%">

**Add Lab Result**
<img src="screenshots/add_lab_result.png" width="100%"/>

</td>
</tr>
<tr>
<td width="50%">

**Billing Overview**
<img src="screenshots/billing_overview.png" width="100%"/>

</td>
<td width="50%">

**Billing**
<img src="screenshots/billing.png" width="100%"/>

</td>
</tr>
<tr>
<td width="50%">

**Create Invoice**
<img src="screenshots/create_invoice.png" width="100%"/>

</td>
<td width="50%">

**Invoice Details**
<img src="screenshots/invoice_details.png" width="100%"/>

</td>
</tr>
<tr>
<td width="50%">

**Payment**
<img src="screenshots/payment.png" width="100%"/>

</td>
<td width="50%">

**Receptionist Dashboard**
<img src="screenshots/receptionist_dashboard.png" width="100%"/>

</td>
</tr>
</table>

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
