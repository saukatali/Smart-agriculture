from typing import Generator

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session

from app.core.config import settings

ssl_args = {}

if settings.DB_SSL_CA:
    ssl_args = {
        "ssl_ca": settings.DB_SSL_CA,
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
        print(f"MySQL connection check failed: {e}")
        return False