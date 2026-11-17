"""
AgriSmart FastAPI Test Suite
Validates all REST endpoints against MySQL agrismart_db.
"""

import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_suite():
    print("==================================================")
    print("  RUNNING AGRISMART FASTAPI AUTOMATED TEST SUITE  ")
    print("==================================================")

    # 1. Health & Docs
    print("\n[1/7] Testing Health & Documentation Endpoints...")
    r = client.get("/")
    assert r.status_code == 200, f"Root endpoint failed: {r.text}"
    print(" -> GET /: OK (Service online)")

    r = client.get("/health")
    assert r.status_code == 200, f"Health check failed: {r.text}"
    print(" -> GET /health: OK (Database connected)")

    r = client.get("/api/health")
    assert r.status_code == 200, f"API Health check failed: {r.text}"
    print(" -> GET /api/health: OK (Database connected)")

    r = client.get("/openapi.json")
    assert r.status_code == 200, f"OpenAPI failed: {r.text}"
    print(" -> GET /openapi.json: OK")

    r = client.get("/docs")
    assert r.status_code == 200, f"Swagger Docs failed: {r.text}"
    print(" -> GET /docs: OK (Swagger UI)")

    r = client.get("/redoc")
    assert r.status_code == 200, f"ReDoc failed: {r.text}"
    print(" -> GET /redoc: OK (ReDoc UI)")

    # 2. Authentication
    print("\n[2/7] Testing Authentication Endpoints...")
    # Farmer login
    r = client.post("/api/auth/login", json={
        "email": "rajesh.farmer@agrismart.com",
        "password": "Farmer@123"
    })
    assert r.status_code == 200, f"Farmer login failed: {r.text}"
    farmer_data = r.json()
    farmer_token = farmer_data.get("token") or farmer_data.get("access_token")
    farmer_headers = {"Authorization": f"Bearer {farmer_token}"}
    print(f" -> POST /api/auth/login (Farmer): OK (User: {farmer_data['user']['name']})")

    # Admin login
    r = client.post("/api/auth/login", json={
        "email": "admin@agrismart.com",
        "password": "Admin@123"
    })
    assert r.status_code == 200, f"Admin login failed: {r.text}"
    admin_data = r.json()
    admin_token = admin_data.get("token") or admin_data.get("access_token")
    admin_headers = {"Authorization": f"Bearer {admin_token}"}
    print(f" -> POST /api/auth/login (Admin): OK (User: {admin_data['user']['name']})")

    # Customer login
    r = client.post("/api/auth/login", json={
        "email": "priya.customer@agrismart.com",
        "password": "Customer@123"
    })
    assert r.status_code == 200, f"Customer login failed: {r.text}"
    customer_data = r.json()
    customer_token = customer_data.get("token") or customer_data.get("access_token")
    customer_headers = {"Authorization": f"Bearer {customer_token}"}
    print(f" -> POST /api/auth/login (Customer): OK (User: {customer_data['user']['name']})")

    # OAuth2 Token endpoint (for Swagger Authorize button)
    r = client.post("/api/auth/token", data={
        "username": "rajesh.farmer@agrismart.com",
        "password": "Farmer@123"
    })
    assert r.status_code == 200, f"OAuth2 token failed: {r.text}"
    print(" -> POST /api/auth/token (OAuth2 Swagger): OK")

    # Current user
    r = client.get("/api/auth/me", headers=farmer_headers)
    assert r.status_code == 200, f"Auth me failed: {r.text}"
    print(" -> GET /api/auth/me: OK")

    # 3. Farmer Endpoints
    print("\n[3/7] Testing Farmer Endpoints...")
    r = client.get("/api/farmer/dashboard", headers=farmer_headers)
    assert r.status_code == 200, f"Farmer dashboard failed: {r.text}"
    dash = r.json()
    print(f" -> GET /api/farmer/dashboard: OK (Stats: {dash.get('stats', {}).get('totalRevenue')})")

    r = client.get("/api/farmer/sales-history", headers=farmer_headers)
    assert r.status_code == 200, f"Sales history failed: {r.text}"
    print(f" -> GET /api/farmer/sales-history: OK ({len(r.json().get('history', []))} records)")

    r = client.get("/api/farmer/products", headers=farmer_headers)
    assert r.status_code == 200, f"Farmer products failed: {r.text}"
    print(f" -> GET /api/farmer/products: OK ({len(r.json().get('products', []))} products)")

    r = client.get("/api/farmer/orders", headers=farmer_headers)
    assert r.status_code == 200, f"Farmer orders failed: {r.text}"
    print(f" -> GET /api/farmer/orders: OK ({len(r.json().get('orders', []))} orders)")

    # 4. Customer Endpoints
    print("\n[4/7] Testing Customer Marketplace & Shopping Endpoints...")
    r = client.get("/api/customer/categories")
    assert r.status_code == 200, f"Categories failed: {r.text}"
    categories = r.json().get("categories", [])
    print(f" -> GET /api/customer/categories: OK ({len(categories)} categories)")

    r = client.get("/api/customer/products")
    assert r.status_code == 200, f"Customer products failed: {r.text}"
    products = r.json().get("products", [])
    print(f" -> GET /api/customer/products: OK ({len(products)} products listed)")

    r = client.get("/api/customer/farmers")
    assert r.status_code == 200, f"Customer farmers failed: {r.text}"
    farmers = r.json().get("farmers", [])
    print(f" -> GET /api/customer/farmers: OK ({len(farmers)} verified farmers)")

    # Test Cart functionality
    if products:
        prod_id = products[0]["id"]
        # Add to cart
        r = client.post("/api/customer/cart", headers=customer_headers, json={
            "productId": prod_id,
            "quantity": 2.0
        })
        assert r.status_code == 200, f"Add to cart failed: {r.text}"
        print(f" -> POST /api/customer/cart: OK (Added product {prod_id})")

    r = client.get("/api/customer/cart", headers=customer_headers)
    assert r.status_code == 200, f"Get cart failed: {r.text}"
    cart_items = r.json().get("items", [])
    print(f" -> GET /api/customer/cart: OK ({len(cart_items)} items in cart)")

    # Checkout
    r = client.post("/api/customer/checkout", headers=customer_headers, json={
        "deliveryAddress": "402 Nilkanth Greens, Ahmedabad",
        "paymentMethod": "UPI"
    })
    assert r.status_code == 201, f"Checkout failed: {r.text}"
    created_order = r.json().get("order", {})
    print(f" -> POST /api/customer/checkout: OK (Order placed: #{created_order.get('orderNumber')})")

    r = client.get("/api/customer/orders", headers=customer_headers)
    assert r.status_code == 200, f"Customer orders failed: {r.text}"
    print(f" -> GET /api/customer/orders: OK ({len(r.json().get('orders', []))} past orders)")

    # 5. Admin Endpoints
    print("\n[5/7] Testing Admin Control Center Endpoints...")
    r = client.get("/api/admin/dashboard", headers=admin_headers)
    assert r.status_code == 200, f"Admin dashboard failed: {r.text}"
    admin_dash = r.json()
    print(f" -> GET /api/admin/dashboard: OK (KPIs loaded: {len(admin_dash.get('kpis', []))})")

    r = client.get("/api/admin/moderation", headers=admin_headers)
    assert r.status_code == 200, f"Admin moderation failed: {r.text}"
    print(f" -> GET /api/admin/moderation: OK ({len(r.json().get('moderation', []))} moderation reports)")

    r = client.get("/api/admin/compliance", headers=admin_headers)
    assert r.status_code == 200, f"Admin compliance failed: {r.text}"
    print(f" -> GET /api/admin/compliance: OK ({len(r.json().get('compliance', []))} supplier compliance records)")

    r = client.get("/api/admin/orders", headers=admin_headers)
    assert r.status_code == 200, f"Admin orders failed: {r.text}"
    print(f" -> GET /api/admin/orders: OK ({len(r.json().get('orders', []))} all platform orders)")

    r = client.post("/api/admin/broadcast", headers=admin_headers, json={
        "title": "System Update Notice",
        "message": "AgriSmart FastAPI backend is now running smoothly on MySQL.",
        "targetRole": "all"
    })
    assert r.status_code == 200, f"Admin broadcast failed: {r.text}"
    print(" -> POST /api/admin/broadcast: OK")

    # 6. Insights & AI Endpoints
    print("\n[6/7] Testing AI Insights & Recommendations Endpoints...")
    r = client.get("/api/insights/predictions?window=30d")
    assert r.status_code == 200, f"Insights predictions failed: {r.text}"
    predictions = r.json().get("predictions", [])
    print(f" -> GET /api/insights/predictions: OK ({len(predictions)} demand predictions)")

    r = client.get("/api/insights/recommendations")
    assert r.status_code == 200, f"Insights recommendations failed: {r.text}"
    recommendations = r.json().get("recommendations", [])
    print(f" -> GET /api/insights/recommendations: OK ({len(recommendations)} recommendations)")

    if recommendations:
        rec_id = recommendations[0]["id"]
        r = client.post(f"/api/insights/apply-strategy/{rec_id}", headers=farmer_headers)
        assert r.status_code == 200, f"Apply strategy failed: {r.text}"
        print(f" -> POST /api/insights/apply-strategy/{rec_id}: OK")

    # 7. Notifications
    print("\n[7/7] Testing Notifications Endpoints...")
    r = client.get("/api/notifications", headers=farmer_headers)
    assert r.status_code == 200, f"Notifications failed: {r.text}"
    print(f" -> GET /api/notifications: OK ({len(r.json().get('notifications', []))} notifications loaded)")

    print("\n==================================================")
    print("  ALL FASTAPI BACKEND API TESTS PASSED 100%!       ")
    print("==================================================")

if __name__ == "__main__":
    test_suite()
