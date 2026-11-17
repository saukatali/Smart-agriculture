# AgriSmart Backend API & MySQL Database Integration (Python FastAPI)

High-performance, production-ready REST API backend for the **AgriSmart** Flutter mobile application, built with **Python 3**, **FastAPI**, **SQLAlchemy ORM**, **PyMySQL**, **Alembic**, and **MySQL 8.0**.

---

## 🛠 Technology Stack

- **Framework:** Python 3 + FastAPI
- **ASGI Server:** Uvicorn
- **Database:** MySQL 8.0+ / MySQL Workbench
- **ORM:** SQLAlchemy 2.0+ & PyMySQL
- **Data Validation & Serialization:** Pydantic v2
- **Authentication:** JWT (`pyjwt`), OAuth2 Password Bearer, and `bcrypt` password hashing
- **API Documentation:** Interactive Swagger UI (`/docs`) & ReDoc (`/redoc`)
- **CORS:** Pre-configured for Flutter Desktop/Web, Android Emulator (`10.0.2.2`), and Physical USB Debugging (`127.0.0.1` via ADB reverse)

---

## 🚀 Quick Start

### 1. Database Configuration
Ensure your local MySQL service is running on port `3306`. Configure credentials in `.env`:

```env
PORT=8000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=mysql123
DB_NAME=agrismart_db
SECRET_KEY=agrismart_fastapi_jwt_secret_key_2026_super_secure
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=43200
```

### 2. Install Python Dependencies
```bash
python -m pip install -r requirements.txt
```

### 3. Start the FastAPI Server
```bash
# From d:\agre_smart_fast\backend:
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
Once started, the backend will be available at:
- **API Base:** `http://127.0.0.1:8000/api`
- **Swagger UI:** `http://127.0.0.1:8000/docs`
- **ReDoc:** `http://127.0.0.1:8000/redoc`
- **Health Check:** `http://127.0.0.1:8000/api/health`

### 4. Run Automated Test Suite
```bash
python test_api.py
```

---

## 📱 Seed Accounts & Credentials

| Role | Name | Email | Password |
|---|---|---|---|
| **Farmer** | Rajesh Kumar | `rajesh.farmer@agrismart.com` | `Farmer@123` |
| **Customer** | Priya Sharma | `priya.customer@agrismart.com` | `Customer@123` |
| **Admin** | System Administrator | `admin@agrismart.com` | `Admin@123` |

---

## 📡 API Endpoints Overview

### Health & Docs
- `GET /api/health` - Server and MySQL database health check
- `GET /docs` - Swagger UI interactive documentation & tester
- `GET /redoc` - ReDoc API reference
- `GET /openapi.json` - OpenAPI 3.0 specification

### Authentication (`/api/auth`)
- `POST /api/auth/register` - Create new farmer or customer account (bcrypt hashed)
- `POST /api/auth/login` - Authenticate with email/mobile and return JWT token
- `POST /api/auth/token` - OAuth2 password bearer token endpoint for Swagger UI "Authorize" button
- `POST /api/auth/logout` - Invalidate user session
- `GET /api/auth/me` - Authenticated user profile

### Farmer Operations (`/api/farmer`)
- `GET /api/farmer/dashboard` - Stats (revenue, active listings, pending orders, demand)
- `GET /api/farmer/sales-history` - Weekly performance (Mon-Sun)
- `GET /api/farmer/products` - Farmer's listed crops
- `POST /api/farmer/products` - Add new product listing to marketplace
- `PUT /api/farmer/products/{id}` - Update product details
- `DELETE /api/farmer/products/{id}` - Remove listing
- `GET /api/farmer/orders` - Orders awaiting farmer action
- `PUT /api/farmer/orders/{id}/status` - Update order status (pending -> confirmed -> shipped -> delivered)

### Customer Marketplace & Cart (`/api/customer`)
- `GET /api/customer/categories` - Produce categories (Vegetables, Fruits, Grains, Spices)
- `GET /api/customer/products` - Search and category filtering
- `GET /api/customer/products/{id}` - Specific product details
- `GET /api/customer/farmers` - Nearby verified organic farmers
- `GET /api/customer/cart` - User's active cart items
- `POST /api/customer/cart` - Add item to cart
- `PUT /api/customer/cart/{id}` - Adjust quantity (+/-)
- `DELETE /api/customer/cart/{id}` - Remove item
- `POST /api/customer/checkout` - Create real order in MySQL & clear cart
- `GET /api/customer/orders` - Customer's past orders

### AI Advisory & Insights (`/api/insights`)
- `GET /api/insights/predictions?window=7+Days` - Demand predictions by forecast window (7/30/90 days)
- `GET /api/insights/recommendations` - Smart AI selling recommendations
- `POST /api/insights/apply-strategy/{id}` - Apply recommendation strategy to logistics

### Admin Control Center (`/api/admin`)
- `GET /api/admin/dashboard` - KPI metrics (GMV, active users, disputes, uptime)
- `GET /api/admin/moderation` - Moderation queue reports
- `PUT /api/admin/moderation/{id}` - Resolve moderation dispute
- `GET /api/admin/compliance` - Supplier certification tracking
- `PUT /api/admin/compliance/{id}/renew` - Renew supplier compliance
- `GET /api/admin/orders` - Platform logistics orders
- `POST /api/admin/broadcast` - Broadcast weather/system alert to all users

### Notifications (`/api/notifications`)
- `GET /api/notifications` - Notifications list
- `PUT /api/notifications/{id}/read` - Mark notification as read

---

## 🔌 Connecting Android Mobile Device (e.g., OnePlus Nord CE4)

When debugging on a physical Android device over USB:
```bash
adb reverse tcp:8000 tcp:8000
```
This maps `http://127.0.0.1:8000` on your phone directly to the FastAPI server running on your PC.

For the Android emulator, `http://10.0.2.2:8000/api` is automatically used by `ApiEndpoints`.
