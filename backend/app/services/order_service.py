import json
import time
from typing import Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status

from app.models.order import Order, OrderItem
from app.models.cart import CartItem
from app.models.product import Product
from app.models.user import User
from app.models.notification import Notification
from app.schemas.order import OrderCreate

class OrderService:
    @staticmethod
    def get_cart(db: Session, user_id: int) -> dict:
        items = db.query(CartItem).filter(CartItem.userId == user_id).order_by(CartItem.id.desc()).all()
        formatted_items = []
        total = 0.0

        for ci in items:
            prod = db.query(Product).filter(Product.id == ci.productId).first()
            farmer_user = db.query(User).filter(User.id == prod.farmerId).first() if prod else None
            price = prod.pricePerKg if prod else ci.price
            sub = price * ci.quantity
            total += sub

            formatted_items.append({
                "id": ci.id,
                "userId": ci.userId,
                "productId": ci.productId,
                "quantity": ci.quantity,
                "price": price,
                "productName": prod.name if prod else "Produce",
                "unit": prod.unit if prod else "kg",
                "primaryImage": prod.primaryImage if prod else "grain",
                "location": prod.location if prod else "Ahmedabad",
                "farmerId": prod.farmerId if prod else 1,
                "farmerName": farmer_user.name if farmer_user else "Local Farmer",
                "createdAt": str(ci.createdAt) if ci.createdAt else None,
            })

        return {
            "success": True,
            "count": len(formatted_items),
            "items": formatted_items,
            "totalAmount": round(total, 2),
        }

    @staticmethod
    def add_to_cart(db: Session, user_id: int, product_id: int, quantity: float = 1.0) -> dict:
        prod = db.query(Product).filter(Product.id == product_id).first()
        if not prod:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Product not found")

        existing = db.query(CartItem).filter(
            CartItem.userId == user_id,
            CartItem.productId == product_id
        ).first()

        if existing:
            existing.quantity += quantity
            existing.price = prod.pricePerKg
            db.commit()
            db.refresh(existing)
        else:
            new_item = CartItem(
                userId=user_id,
                productId=product_id,
                quantity=quantity,
                price=prod.pricePerKg,
            )
            db.add(new_item)
            db.commit()

        return OrderService.get_cart(db, user_id)

    @staticmethod
    def update_cart_item(db: Session, user_id: int, item_id: int, quantity: float) -> dict:
        item = db.query(CartItem).filter(CartItem.id == item_id, CartItem.userId == user_id).first()
        if not item:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Cart item not found")

        if quantity <= 0:
            db.delete(item)
        else:
            item.quantity = quantity
        db.commit()

        return OrderService.get_cart(db, user_id)

    @staticmethod
    def remove_from_cart(db: Session, user_id: int, item_id: int) -> dict:
        item = db.query(CartItem).filter(CartItem.id == item_id, CartItem.userId == user_id).first()
        if item:
            db.delete(item)
            db.commit()
        return OrderService.get_cart(db, user_id)

    @staticmethod
    def clear_cart(db: Session, user_id: int) -> bool:
        db.query(CartItem).filter(CartItem.userId == user_id).delete()
        db.commit()
        return True

    @staticmethod
    def create_order(db: Session, customer_id: int, data: OrderCreate) -> dict:
        order_number = f"ORD-{int(time.time()) % 1000000:06d}-{int(time.time() * 1000) % 900 + 100}"
        farmer_id = 1
        items_payload = []
        total_amount = 0.0

        if data.directItem:
            items_payload = [data.directItem]
            unit_price = float(data.directItem.get("price") or data.directItem.get("unitPrice") or 0)
            qty = float(data.directItem.get("quantity") or 1)
            total_amount = unit_price * qty
            farmer_id = int(data.directItem.get("farmerId") or 1)
        else:
            cart = OrderService.get_cart(db, customer_id)
            if not cart["items"]:
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Your cart is empty.")
            items_payload = cart["items"]
            total_amount = cart["totalAmount"]
            farmer_id = int(items_payload[0].get("farmerId") or 1)

        new_order = Order(
            orderNumber=order_number,
            customerId=customer_id,
            farmerId=farmer_id,
            totalAmount=total_amount,
            status="pending",
            deliveryAddress=data.deliveryAddress,
            paymentMethod=data.paymentMethod,
            paymentStatus="pending" if data.paymentMethod == "COD" else "paid",
            itemsJson=json.dumps(items_payload, default=str),
            customerName=data.customerName,
            customerMobile=data.customerMobile,
        )
        db.add(new_order)
        db.commit()
        db.refresh(new_order)

        # Create order items
        for itm in items_payload:
            prod_id = itm.get("productId")
            prod_name = itm.get("productName") or itm.get("name") or "Produce"
            qty = float(itm.get("quantity") or 1)
            unit_price = float(itm.get("price") or itm.get("unitPrice") or 0)
            sub = qty * unit_price

            order_item = OrderItem(
                orderId=new_order.id,
                productId=prod_id,
                productName=prod_name,
                quantity=qty,
                unitPrice=unit_price,
                subtotal=sub,
            )
            db.add(order_item)

        # Notify farmer
        notif = Notification(
            userId=farmer_id,
            title="New Order Received!",
            message=f"Order {order_number} for ₹{total_amount:.0f} is awaiting your confirmation.",
            type="order",
            isRead=False,
        )
        db.add(notif)
        db.commit()

        # Clear cart if checked out from cart
        if not data.directItem:
            OrderService.clear_cart(db, customer_id)

        return {
            "success": True,
            "message": "Order placed successfully into MySQL!",
            "order": {
                "id": new_order.id,
                "orderNumber": new_order.orderNumber,
                "customerId": new_order.customerId,
                "farmerId": new_order.farmerId,
                "totalAmount": new_order.totalAmount,
                "status": new_order.status,
                "deliveryAddress": new_order.deliveryAddress,
                "paymentMethod": new_order.paymentMethod,
                "createdAt": new_order.createdAt,
            }
        }

    @staticmethod
    def get_farmer_orders(db: Session, farmer_id: int) -> list[dict]:
        orders = db.query(Order).filter(Order.farmerId == farmer_id).order_by(Order.id.desc()).all()
        return [
            {
                "id": o.id,
                "orderNumber": o.orderNumber,
                "customerName": o.customerName or "Customer",
                "customerMobile": o.customerMobile,
                "totalAmount": o.totalAmount,
                "status": o.status,
                "deliveryAddress": o.deliveryAddress,
                "paymentMethod": o.paymentMethod,
                "createdAt": o.createdAt,
            }
            for o in orders
        ]

    @staticmethod
    def get_customer_orders(db: Session, customer_id: int) -> list[dict]:
        orders = db.query(Order).filter(Order.customerId == customer_id).order_by(Order.id.desc()).all()
        return [
            {
                "id": o.id,
                "orderNumber": o.orderNumber,
                "totalAmount": o.totalAmount,
                "status": o.status,
                "deliveryAddress": o.deliveryAddress,
                "paymentMethod": o.paymentMethod,
                "createdAt": o.createdAt,
            }
            for o in orders
        ]

    @staticmethod
    def update_order_status(db: Session, order_id: int, new_status: str) -> dict:
        order = db.query(Order).filter(Order.id == order_id).first()
        if not order:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found")

        order.status = new_status.lower()
        db.commit()
        db.refresh(order)

        # Notify customer
        notif = Notification(
            userId=order.customerId,
            title=f"Order {order.orderNumber} {new_status.upper()}",
            message=f"Your order status has been updated to {new_status}. Track in your app.",
            type="order",
            isRead=False,
        )
        db.add(notif)
        db.commit()

        return {
            "success": True,
            "message": f"Order status updated to {new_status}",
            "order": {
                "id": order.id,
                "orderNumber": order.orderNumber,
                "status": order.status,
            }
        }
