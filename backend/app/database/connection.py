import os
import logging
from typing import Generator

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session

from app.core.config import settings

logger = logging.getLogger("uvicorn.error")

ssl_args = {}

if settings.DB_SSL_CA:
    ca_path = os.path.abspath(settings.DB_SSL_CA) if not os.path.isabs(settings.DB_SSL_CA) else settings.DB_SSL_CA
    if not os.path.exists(ca_path):
        raise FileNotFoundError(
            f"Configured DB_SSL_CA certificate file was not found at: {ca_path}. "
            "Please ensure the CA certificate is uploaded (e.g., as a Render Secret File)."
        )
    ssl_args = {
        "ssl_ca": ca_path,
        "ssl_verify_cert": True,
        "ssl_verify_identity": True,
    }

engine = create_engine(
    settings.database_url,
    connect_args=ssl_args,
    pool_pre_ping=True,
    pool_recycle=1800,
    pool_size=2,
    max_overflow=3,
    echo=False,
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)


def get_db() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def check_db_connection() -> bool:
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        return True
    except Exception as e:
        print(f"⚠️ [Database] Connection check failed: {e}")
        return False
