import re
from pathlib import Path
from pydantic import AliasChoices, Field
from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy.engine import URL, make_url

BASE_DIR = Path(__file__).resolve().parent.parent.parent


class Settings(BaseSettings):
    APP_NAME: str = "AgriSmart API"
    APP_ENV: str = "development"
    PORT: int = 8000
    HOST: str = "0.0.0.0"

    # Cloud connection string (supports TiDB Cloud, Render, Railway, PlanetScale, Supabase)
    DATABASE_URL: str | None = Field(
        default=None,
        validation_alias=AliasChoices(
            "DATABASE_URL",
            "MYSQL_URL",
            "DB_URL",
            "TIDB_DATABASE_URL",
            "CLEARDB_DATABASE_URL",
        ),
    )

    # Individual database parameters (fallback or local development)
    DB_HOST: str = Field(
        default="localhost",
        validation_alias=AliasChoices("DB_HOST", "MYSQLHOST", "MYSQL_HOST", "TIDB_HOST"),
    )
    DB_PORT: int = Field(
        default=3306,
        validation_alias=AliasChoices("DB_PORT", "MYSQLPORT", "MYSQL_PORT", "TIDB_PORT"),
    )
    DB_USER: str = Field(
        default="root",
        validation_alias=AliasChoices("DB_USER", "MYSQLUSER", "MYSQL_USER", "TIDB_USER"),
    )
    DB_PASSWORD: str = Field(
        default="",
        validation_alias=AliasChoices("DB_PASSWORD", "MYSQLPASSWORD", "MYSQL_PASSWORD", "TIDB_PASSWORD"),
    )
    DB_NAME: str = Field(
        default="agrisokat",
        validation_alias=AliasChoices("DB_NAME", "MYSQLDATABASE", "MYSQL_DATABASE", "TIDB_DATABASE"),
    )

    # TLS / SSL options
    DB_SSL_CA: str | None = Field(
        default=None,
        validation_alias=AliasChoices("DB_SSL_CA", "MYSQL_SSL_CA", "SSL_CA"),
    )
    DB_SSL_MODE: bool | None = Field(
        default=None,
        validation_alias=AliasChoices("DB_SSL_MODE", "DB_SSL", "MYSQL_SSL", "TIDB_SSL"),
    )

    # Security & Auth
    SECRET_KEY: str = Field(
        default="",
        validation_alias=AliasChoices("JWT_SECRET", "SECRET_KEY"),
    )
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 43200  # 30 days

    CORS_ORIGINS: list[str] = ["*"]
    UPLOAD_DIR: str = str(BASE_DIR / "uploads")

    @property
    def _parsed_db_url(self):
        if self.DATABASE_URL and self.DATABASE_URL.strip():
            raw = self.DATABASE_URL.strip()
            # Handle quoted passwords or standard mysql schemes
            try:
                return make_url(raw)
            except Exception:
                return None
        return None

    @property
    def effective_db_host(self) -> str:
        parsed = self._parsed_db_url
        if parsed and parsed.host:
            return parsed.host
        return self.DB_HOST

    @property
    def effective_db_port(self) -> int:
        parsed = self._parsed_db_url
        if parsed and parsed.port:
            return parsed.port
        return self.DB_PORT

    @property
    def effective_db_user(self) -> str:
        parsed = self._parsed_db_url
        if parsed and parsed.username:
            return parsed.username
        return self.DB_USER

    @property
    def effective_db_name(self) -> str:
        parsed = self._parsed_db_url
        if parsed and parsed.database:
            return parsed.database
        return self.DB_NAME

    @property
    def is_remote_db(self) -> bool:
        host = (self.effective_db_host or "").lower()
        return host not in ("localhost", "127.0.0.1", "::1", "db", "mysql", "")

    @property
    def database_url(self) -> URL:
        if self._parsed_db_url:
            u = self._parsed_db_url
            if u.drivername in ("mysql", "mysql+mysqldb", ""):
                u = u.set(drivername="mysql+pymysql")
            # Strip problematic raw string parameters that PyMySQL rejects
            q = dict(u.query)
            q.pop("ssl", None)
            q.pop("ssl-mode", None)
            q.pop("sslmode", None)
            q.setdefault("charset", "utf8mb4")
            return u.set(query=q)

        return URL.create(
            drivername="mysql+pymysql",
            username=self.DB_USER,
            password=self.DB_PASSWORD,
            host=self.DB_HOST,
            port=self.DB_PORT,
            database=self.DB_NAME,
            query={"charset": "utf8mb4"},
        )

    model_config = SettingsConfigDict(
        env_file=str(BASE_DIR / ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
if not settings.SECRET_KEY:
    raise RuntimeError(
        "JWT_SECRET environment variable must be configured in environment or backend/.env"
    )
