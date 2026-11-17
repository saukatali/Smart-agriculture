import os
import logging
from typing import Generator

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session

from app.core.config import settings

logger = logging.getLogger("uvicorn.error")

# Determine default system / bundle CA path
DEFAULT_CA_PATH = None
try:
    import certifi
    DEFAULT_CA_PATH = certifi.where()
except ImportError:
    pass

if not DEFAULT_CA_PATH or not os.path.exists(DEFAULT_CA_PATH):
    linux_ca = "/etc/ssl/certs/ca-certificates.crt"
    if os.path.exists(linux_ca):
        DEFAULT_CA_PATH = linux_ca


def build_ssl_args() -> dict:
    """
    Build SSL arguments for PyMySQL / SQLAlchemy.
    Automatically enables TLS for cloud providers (TiDB Cloud, AWS, Aiven, etc.)
    using standard certifi/system CA roots without requiring manual secret file uploads.
    """
    # Explicitly disabled
    if settings.DB_SSL_MODE is False:
        return {}

    # Check for custom certificate file
    if settings.DB_SSL_CA and settings.DB_SSL_CA.strip():
        ca_candidate = settings.DB_SSL_CA.strip()
        ca_path = os.path.abspath(ca_candidate) if not os.path.isabs(ca_candidate) else ca_candidate
        if os.path.exists(ca_path):
            return {
                "ssl_ca": ca_path,
                "ssl_verify_cert": True,
                "ssl_verify_identity": True,
            }
        logger.warning(
            f"⚠️ [Database] Configured DB_SSL_CA certificate file '{ca_candidate}' was not found. "
            f"Falling back to system/certifi CA bundle."
        )

    # Remote database (e.g. TiDB Cloud *.tidbcloud.com, AWS RDS, Render, etc.) or explicitly requested
    is_tidb = "tidbcloud.com" in (settings.effective_db_host or "").lower()
    if settings.DB_SSL_MODE is True or settings.is_remote_db or is_tidb:
        if DEFAULT_CA_PATH and os.path.exists(DEFAULT_CA_PATH):
            return {
                "ssl_ca": DEFAULT_CA_PATH,
                "ssl_verify_cert": True,
                "ssl_verify_identity": True,
            }
        return {
            "ssl": True,
        }

    return {}


ssl_args = build_ssl_args()
has_ssl = bool(ssl_args)

engine = create_engine(
    settings.database_url,
    connect_args=ssl_args,
    pool_pre_ping=True,
    pool_recycle=1800,
    pool_size=3,
    max_overflow=5,
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
        print(f"⚠️ [Database] Connection check failed to {settings.effective_db_host}:{settings.effective_db_port}: {e}")
        return False
