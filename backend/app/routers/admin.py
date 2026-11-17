from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.database.connection import get_db
from app.services.insight_service import InsightService
from app.schemas.insight import BroadcastAlertRequest
from app.models.order import Order
from app.models.user import User
from app.dependencies.authentication import require_admin

router = APIRouter(prefix="/api/admin", tags=["Platform Admin Control Center"])


class ModerationResolveRequest(BaseModel):
    status: str = "Resolved"


@router.get("/dashboard", summary="Admin control center KPI metrics (active users, GMV, disputes, uptime)")
def get_admin_dashboard(
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    metrics = InsightService.get_admin_metrics(db)
    moderation = InsightService.get_moderation_reports(db)
    compliance = InsightService.get_supplier_compliance(db)
    return {
        "success": True,
        "kpis": metrics["kpis"],
        "moderation": moderation,
        "compliance": compliance,
    }


@router.get("/moderation", summary="Get user moderation and dispute reports")
def get_moderation_queue(
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    reports = InsightService.get_moderation_reports(db)
    return {"success": True, "count": len(reports), "moderation": reports}


@router.put("/moderation/{id}", summary="Resolve or dismiss user moderation report")
def resolve_moderation_report(
    id: int,
    data: ModerationResolveRequest,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return InsightService.resolve_moderation_report(db, id, data.status)


@router.get("/compliance", summary="Get supplier quality and certification compliance statuses")
def get_supplier_compliance(
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    suppliers = InsightService.get_supplier_compliance(db)
    return {"success": True, "count": len(suppliers), "compliance": suppliers}


@router.put("/compliance/{id}/renew", summary="Renew supplier certification compliance")
def renew_supplier(
    id: int,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return InsightService.renew_supplier_compliance(db, id)


@router.get("/orders", summary="Get all platform logistics orders")
def get_admin_orders(
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    orders = db.query(Order).order_by(Order.id.desc()).limit(50).all()
    return {"success": True, "count": len(orders), "orders": orders}


@router.post("/broadcast", summary="Broadcast weather warning or system advisory to all users")
def broadcast_alert(
    data: BroadcastAlertRequest,
    current_user: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    return InsightService.broadcast_alert(db, data.title, data.message)
