import logging
from sqlalchemy import text
from app.database.connection import SessionLocal
from app.models.user import User

logger = logging.getLogger("uvicorn.error")


def seed_database_if_empty() -> bool:
    """
    Checks if the database is newly initialized (empty users table).
    If empty, automatically populates standard initial data so the app
    is fully functional upon initial cloud deployment.
    """
    db = SessionLocal()
    try:
        user_count = db.query(User).count()
        if user_count > 0:
            return False

        print("🌱 [Database] Empty database detected. Populating initial seed data...")

        # 1. Categories
        db.execute(text("""
            INSERT IGNORE INTO `categories` (`id`, `name`, `slug`, `icon`, `description`) VALUES
            (1, 'Vegetables', 'vegetables', 'eco', 'Farm-fresh green and organic vegetables'),
            (2, 'Fruits', 'fruits', 'apple', 'Naturally ripened seasonal fresh fruits'),
            (3, 'Grains', 'grains', 'grain', 'Premium harvest wheat, rice, corn, and pulses'),
            (4, 'Spices', 'spices', 'soup_kitchen', 'Aromatic Indian spices, turmeric, and herbs')
        """))

        # 2. Users (Pass: Farmer@123, Customer@123, Admin@123)
        from sqlalchemy import inspect
        ins = inspect(db.bind)
        cols = [c['name'] for c in ins.get_columns('users')]
        name_col = 'full_name' if 'full_name' in cols else 'name'
        pass_col = 'password_hash' if 'password_hash' in cols else 'password'

        db.execute(text(f"""
            INSERT IGNORE INTO `users` (`id`, `{name_col}`, `email`, `{pass_col}`, `role`, `phone`, `location`, `status`) VALUES
            (1, 'Rajesh Kumar', 'rajesh.farmer@agrismart.com', '$2b$10$hD4KjbcXMBB84ZP4JHpFFeHXauJBwpTTj0PxSmcYhKSSjdYsRQnIW', 'farmer', '+91 98765 43210', 'Ahmedabad, Gujarat', 'active'),
            (2, 'Suresh Patel', 'suresh.patel@agrismart.com', '$2b$10$hD4KjbcXMBB84ZP4JHpFFeHXauJBwpTTj0PxSmcYhKSSjdYsRQnIW', 'farmer', '+91 98765 43211', 'Surat, Gujarat', 'active'),
            (3, 'Priya Sharma', 'priya.customer@agrismart.com', '$2b$10$A1KBpKZ47XFOiA1H/QKXyOPuJuygRLAmg0p2Wu5R45fhwjy7VsnKu', 'customer', '+91 98765 43212', 'Ahmedabad, Gujarat', 'active'),
            (4, 'System Administrator', 'admin@agrismart.com', '$2b$10$WCWo.vu208zFPHC7970Wn.9QbemVc7InH5S8ZrUi11h/0vKPPBBYW', 'admin', '+91 98765 43213', 'National Control Hub', 'active')
        """))

        # 3. Farmer Profiles
        db.execute(text("""
            INSERT IGNORE INTO `farmer_profiles` (`id`, `userId`, `farmName`, `farmLocation`, `availableProducts`, `farmingExperience`, `verificationStatus`, `rating`, `reviewCount`, `totalSalesKg`) VALUES
            (1, 1, 'Ramesh Patel Farms', 'Ahmedabad, Gujarat (2.2 km away)', 'Organic Tomatoes, Premium Hard Wheat, Roma Tomatoes', 12, 'verified', 4.8, 120, 72450),
            (2, 2, 'Suresh Desai Organics', 'Sanand, Gujarat (4.5 km away)', 'Fresh Potatoes, Groundnuts, Desi White Cotton', 8, 'verified', 4.6, 84, 45200)
        """))

        # 4. Customer Profiles
        db.execute(text("""
            INSERT IGNORE INTO `customer_profiles` (`id`, `userId`, `deliveryAddress`, `preferences`, `orderCount`, `totalSpent`) VALUES
            (1, 3, 'Flat 402, Shivalik Residency, Ahmedabad, Gujarat - 380015', 'Organic produce, fast morning delivery', 14, 18500)
        """))

        # 5. Products
        db.execute(text("""
            INSERT IGNORE INTO `products` (`id`, `farmerId`, `categoryId`, `name`, `description`, `pricePerKg`, `availableQuantity`, `unit`, `qualityGrade`, `harvestDate`, `location`, `isAvailable`, `salesCount`, `rating`, `reviewCount`, `primaryImage`) VALUES
            (1, 1, 3, 'Premium Organic Wheat', 'High-protein MP Sharbati wheat, sorted and cleaned with zero preservatives.', 210, 45, 'quintal', 'Grade A', '2026-10-28', 'Ahmedabad, Gujarat', 1, 45, 4.9, 32, 'wheat'),
            (2, 1, 3, 'Desi White Cotton', 'Long-staple raw seed cotton, naturally cultivated and sun-dried.', 620, 12, 'bale', 'Long Staple', '2026-10-25', 'Ahmedabad, Gujarat', 1, 28, 4.8, 18, 'cotton'),
            (3, 1, 1, 'Hybrid Roma Tomatoes', 'Firm, red, farm-fresh plum tomatoes ideal for processing and cooking.', 25, 120, 'crate', 'Farm Fresh', '2026-11-04', 'Ahmedabad, Gujarat', 1, 110, 4.7, 45, 'tomatoes'),
            (4, 1, 1, 'Organic Tomatoes', 'Pesticide-free vine-ripened sweet organic tomatoes delivered farm to table.', 40, 500, 'kg', 'Organic', '2026-11-03', 'Ahmedabad, Gujarat', 1, 240, 4.9, 88, 'tomatoes'),
            (5, 2, 1, 'Fresh Potatoes', 'Locally harvested golden potatoes with high starch content.', 25, 650, 'kg', 'Fresh', '2026-11-02', 'Surat, Gujarat', 1, 180, 4.6, 42, 'potatoes'),
            (6, 1, 3, 'Basmati Rice', 'Aged traditional Basmati grain, super long and aromatic upon cooking.', 85, 420, 'kg', 'Grade A', '2026-10-20', 'Ahmedabad, Gujarat', 1, 310, 4.9, 65, 'rice'),
            (7, 2, 3, 'Groundnuts', 'Unshelled fresh season oil-rich organic peanuts from Saurashtra.', 60, 320, 'kg', 'New Crop', '2026-10-30', 'Surat, Gujarat', 1, 95, 4.7, 24, 'groundnuts')
        """))

        # 6. Recommendations
        db.execute(text("""
            INSERT IGNORE INTO `smart_recommendations` (`id`, `title`, `confidence`, `description`, `profitIncrease`, `actionLabel`, `iconName`, `isApplied`) VALUES
            (1, 'Hold Wheat Inventory for 14 Days', '88% Confidence', 'Regional milling demand is projected to spike due to lower regional grain reserves. Releasing stock around the 22nd will maximize yield margins.', '+₹4,200', 'Apply Strategy', 'inventory_2_outlined', 0),
            (2, 'Route Roma Tomatoes to North Hub', '91% Confidence', 'Metropolitan buyers in North Hub are experiencing a 30% supply deficit for vine tomatoes. Direct transport yields 18% higher spot prices.', '+₹2,800', 'Dispatch Route', 'local_shipping_outlined', 0)
        """))

        # 7. Demand Predictions
        db.execute(text("""
            INSERT IGNORE INTO `demand_predictions` (`id`, `cropName`, `projectedPrice`, `trendPercentage`, `tag`, `isHighDemand`, `imageType`, `forecastWindow`) VALUES
            (1, 'Premium Hard Wheat', 'Projected Price: $310 / ton (+12%)', '+12%', 'High Demand', 1, 'wheat', '7 Days'),
            (2, 'Roma Tomatoes', 'Projected Price: $1.25 / kg (+18%)', '+18%', 'Peak Season', 0, 'tomatoes', '7 Days'),
            (3, 'Basmati Rice', 'Projected Price: $890 / ton (+8%)', '+8%', 'High Demand', 1, 'rice', '30 Days'),
            (4, 'Saurashtra Groundnuts', 'Projected Price: $750 / ton (+15%)', '+15%', 'Peak Season', 1, 'groundnuts', '30 Days')
        """))

        # 8. Sales History
        db.execute(text("""
            INSERT IGNORE INTO `sales_history` (`id`, `farmerId`, `day`, `value`, `label`) VALUES
            (1, 1, 'Mon', 0.35, '₹1,200'),
            (2, 1, 'Tue', 0.45, '₹1,500'),
            (3, 1, 'Wed', 0.58, '₹2,100'),
            (4, 1, 'Thu', 0.50, '₹1,800'),
            (5, 1, 'Fri', 0.95, '₹2,840'),
            (6, 1, 'Sat', 0.70, '₹2,300'),
            (7, 1, 'Sun', 0.30, '₹950')
        """))

        # 9. Orders
        db.execute(text("""
            INSERT IGNORE INTO `orders` (`id`, `orderNumber`, `customerId`, `farmerId`, `totalAmount`, `status`, `deliveryAddress`, `paymentMethod`, `paymentStatus`, `itemsJson`, `customerName`, `customerMobile`) VALUES
            (1, 'ORD-2026-8801', 3, 1, 1200, 'pending', 'Flat 402, Shivalik Residency, Ahmedabad, Gujarat', 'COD', 'pending', '[{"productId":4,"productName":"Organic Tomatoes","quantity":10,"price":40,"total":400},{"productId":6,"productName":"Basmati Rice","quantity":8,"price":85,"total":680}]', 'Priya Sharma', '+91 98765 43212'),
            (2, 'ORD-2026-8802', 3, 1, 2450, 'confirmed', 'Flat 402, Shivalik Residency, Ahmedabad, Gujarat', 'UPI', 'paid', '[{"productId":1,"productName":"Premium Organic Wheat","quantity":1,"price":210,"total":210}]', 'Priya Sharma', '+91 98765 43212'),
            (3, 'ORD-2026-8803', 3, 1, 850, 'pending', 'Bungalow 12, Satellite, Ahmedabad, Gujarat', 'COD', 'pending', '[{"productId":3,"productName":"Hybrid Roma Tomatoes","quantity":2,"price":25,"total":50}]', 'Kavita Patel', '+91 98765 11223'),
            (4, 'ORD-2026-8804', 3, 1, 3100, 'shipped', 'Drive-In Road, Ahmedabad, Gujarat', 'UPI', 'paid', '[{"productId":1,"productName":"Premium Organic Wheat","quantity":2,"price":210,"total":420}]', 'Amit Verma', '+91 98765 99887'),
            (5, 'ORD-2026-8805', 3, 1, 450, 'pending', 'Vastrapur, Ahmedabad, Gujarat', 'COD', 'pending', '[{"productId":4,"productName":"Organic Tomatoes","quantity":5,"price":40,"total":200}]', 'Meera Shah', '+91 98765 77665')
        """))

        # 10. Compliance
        db.execute(text("""
            INSERT IGNORE INTO `supplier_compliances` (`id`, `supplierName`, `certificationType`, `status`, `renewalDate`) VALUES
            (1, 'Ramesh Patel Organic Farms', 'NPOP India Organic', 'Due for Renewal', 'Expires in 14 days'),
            (2, 'Gujarat Bio Fertilizer Co.', 'ISO 22000 Food Safety', 'Due for Renewal', 'Expires in 21 days'),
            (3, 'Surat Agro Greens Hub', 'FSSAI Central License', 'Valid', 'Active until Nov 2027'),
            (4, 'Baramati Cold Chain Transport', 'Good Distribution Practice (GDP)', 'Due for Renewal', 'Expires in 8 days'),
            (5, 'Kisan Agro Seed Supplies', 'Seed Quality Certification', 'Valid', 'Active until Mar 2027'),
            (6, 'Deccan Grain Packers', 'HACCP Compliance', 'Due for Renewal', 'Expires in 18 days')
        """))

        # 11. Moderation Reports
        db.execute(text("""
            INSERT IGNORE INTO `moderation_reports` (`id`, `reportedBy`, `userName`, `userRole`, `reason`, `status`) VALUES
            (1, 1, 'KisanSamaj AgroTrader', 'Farmer', 'Bulk unverified pricing claim for cotton shipment', 'Pending Review'),
            (2, 3, 'Express Agrologistics #4', 'Logistics', 'Delivery delay dispute for perishable produce', 'Pending Review'),
            (3, 2, 'City Organics Retail', 'Customer', 'Payment settlement inquiry on batch delivery', 'Pending Review')
        """))

        # 12. Notifications
        db.execute(text("""
            INSERT IGNORE INTO `notifications` (`id`, `userId`, `title`, `message`, `type`, `isRead`) VALUES
            (1, 1, 'New Order Received!', 'You have 5 pending orders awaiting confirmation.', 'order', 0),
            (2, 1, 'AI Price Alert', 'Wheat demand expected to rise 22% next week. Check AI insights.', 'alert', 0),
            (3, 3, 'Discount Available', 'Claim 10% off on your next organic harvest order!', 'promo', 0),
            (4, 4, 'System Health Normal', 'All microservices and database latency running at 14ms.', 'system', 0)
        """))

        db.commit()
        print("✅ [Database] Seed data successfully populated.")
        return True
    except Exception as e:
        db.rollback()
        print(f"⚠️ [Database] Seed error notice: {e}")
        return False
    finally:
        db.close()
