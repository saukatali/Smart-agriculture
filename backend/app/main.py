import time
import os
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from sqlalchemy.exc import SQLAlchemyError

from app.core.config import settings
from app.database.connection import engine, check_db_connection, has_ssl
from app.database.seeder import seed_database_if_empty
from app.database.base import Base
import app.models  # noqa: F401 - register all SQLAlchemy models

from app.routers import (
    auth,
    users,
    farmers,
    customers,
    products,
    categories,
    cart,
    orders,
    payments,
    admin,
    insights,
)

start_time = time.time()


@asynccontextmanager
async def lifespan(app: FastAPI):
    print("====================================================")
    print("🌾 [AgriSmart] Starting Python FastAPI Backend Server")
    print(f"🌐 Host: {settings.HOST}:{settings.PORT}")
    print(f"🗄️  Database: {settings.effective_db_name} on {settings.effective_db_host}:{settings.effective_db_port}")
    print(f"🔒 TLS / SSL: {'Enabled' if has_ssl else 'Disabled'}")
    print(f"📜 Swagger Docs: http://127.0.0.1:{settings.PORT}/docs")
    print("====================================================")

    try:
        Base.metadata.create_all(bind=engine)
    except Exception as e:
        print(f"⚠️ [Database] Schema check notice: {e}")

    if check_db_connection():
        print(f"✅ [MySQL] Connected successfully to database: {settings.effective_db_name} ({settings.effective_db_host}:{settings.effective_db_port})")
        try:
            seed_database_if_empty()
        except Exception as se:
            print(f"⚠️ [Database] Seed notice: {se}")
    else:
        print(f"⚠️ [MySQL] Warning: Could not verify connection to database at {settings.effective_db_host}:{settings.effective_db_port}.")

    os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
    yield
    print("🌾 [AgriSmart] Backend Server shutting down cleanly.")


app = FastAPI(
    title="AgriSmart API",
    description="AI-powered Agricultural Marketplace & Advisory Platform REST API with MySQL 8.0 & JWT Authentication",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = exc.errors()
    first_msg = "Validation error. Please check your input."
    if errors:
        msg = errors[0].get("msg", first_msg)
        first_msg = msg.replace("Value error, ", "")
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "success": False,
            "message": first_msg,
            "detail": first_msg,
        },
    )


@app.exception_handler(SQLAlchemyError)
async def database_exception_handler(request: Request, exc: SQLAlchemyError):
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "message": "A database error occurred. Please try again later.",
            "detail": "Database operation failed.",
        },
    )


@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "message": "An unexpected server error occurred.",
            "detail": "Internal server error.",
        },
    )


if os.path.exists(settings.UPLOAD_DIR):
    app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(farmers.router)
app.include_router(customers.router)
app.include_router(products.router)
app.include_router(categories.router)
app.include_router(cart.router)
app.include_router(orders.router)
app.include_router(payments.router)
app.include_router(admin.router)
app.include_router(insights.router)


@app.get("/", tags=["Root"])
def root():
    return {
        "service": "AgriSmart API",
        "status": "online",
        "version": "1.0.0",
        "documentation": "/docs",
        "health": "/health",
    }


@app.head("/", include_in_schema=False)
def root_head():
    return JSONResponse(status_code=status.HTTP_200_OK, content={})


@app.get("/health", tags=["Health"])
@app.get("/api/health", tags=["Health"])
def health_check():
    db_connected = check_db_connection()
    uptime = int(time.time() - start_time)
    return {
        "success": db_connected,
        "status": "healthy" if db_connected else "degraded",
        "service": "AgriSmart FastAPI Backend",
        "version": "1.0.0",
        "uptime": f"{uptime}s",
        "database": {
            "type": "MySQL 8.0",
            "host": settings.effective_db_host,
            "port": settings.effective_db_port,
            "name": settings.effective_db_name,
            "connected": db_connected,
            "tls_enabled": bool(has_ssl),
        },
    }


@app.head("/health", include_in_schema=False)
@app.head("/api/health", include_in_schema=False)
def health_check_head():
    return JSONResponse(status_code=status.HTTP_200_OK, content={})


@app.post("/api/seed", tags=["Admin"])
def trigger_seed():
    seeded = seed_database_if_empty()
    return {
        "success": True,
        "seeded": seeded,
        "message": "Seed data populated successfully." if seeded else "Database already populated.",
    }

