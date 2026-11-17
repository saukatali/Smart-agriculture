from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.user import User
from app.services.insight_service import InsightService
from app.dependencies.authentication import get_current_user

router = APIRouter(tags=["AI Insights & Notifications"])


@router.get("/api/insights/predictions", summary="Get AI crop demand predictions by forecast window (7/30/90 days)")
def get_predictions(window: str = "7 Days", db: Session = Depends(get_db)):
    predictions = InsightService.get_demand_predictions(db, window)
    return {
        "success": True,
        "window": window,
        "count": len(predictions),
        "predictions": predictions,
    }


@router.get("/api/insights/recommendations", summary="Get smart AI selling and inventory holding recommendations")
def get_recommendations(db: Session = Depends(get_db)):
    recommendations = InsightService.get_smart_recommendations(db)
    return {
        "success": True,
        "count": len(recommendations),
        "recommendations": recommendations,
    }


@router.post("/api/insights/apply-strategy/{id}", summary="Apply recommended strategy (hold stock or dispatch route)")
def apply_strategy(
    id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return InsightService.apply_strategy(db, id)


@router.get("/api/notifications", summary="Get notifications for current user")
def get_notifications(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    notifications = InsightService.get_notifications(db, current_user.id)
    return {"success": True, "count": len(notifications), "notifications": notifications}


@router.put("/api/notifications/{id}/read", summary="Mark notification as read")
def mark_notification_read(
    id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    InsightService.mark_notification_read(db, id, current_user.id)
    return {"success": True, "message": "Notification marked as read."}
