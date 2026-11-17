# AgriSmart - Mobile Application UI (Flutter & Dart)

Pixel-perfect Flutter recreation of the uploaded **AgriSmart** mobile application UI design, built strictly in Dart using **Material 3**.

---

## 📱 Recreated Screens Overview

The design comprises 5 distinct mobile screens (reference canvas dimension `390 x 884`):

### 1. Onboarding / Role Selection (`lib/screens/onboarding_screen.dart`)
- **Brand Header**: AgriSmart leaf logo emblem with soft mint container.
- **Language Switcher**: Interactive language pills (`English` active, `हिन्दी`, `ગુજરાતી`).
- **Hero Title & Subtitle**: *"Smart Farming, Direct Marketplace"*, explaining direct producer-to-buyer transactions and AI-driven yield forecasts.
- **Role Selection Cards** (Step 1 of 2):
  - **Farmer / Producer**: Tractor badge, tags `[ AI Forecasts ]` `[ Direct Sales ]`, selection state.
  - **Customer / Buyer**: Basket badge, tags `[ Farm Fresh ]` `[ Best Prices ]`, selection state.
  - **Platform Admin**: Amber shield badge, tags `[ Analytics ]` `[ Moderation ]`, selection state.
- **Primary Action**: *"Continue to AgriSmart ->"* button routing to the selected role's workspace.
- **Bottom Navigation Bar**: 5 items (`Home`, `Explore`, `Orders`, `Insights`, `Profile`).

---

### 2. Farmer Dashboard (`lib/screens/farmer_dashboard_screen.dart`)
- **App Bar**: AgriSmart leaf brand mark, notification bell with active badge, user avatar with online indicator.
- **Header**: `DASHBOARD` caption, *"Namaste, Rajesh Kumar!"* with green verified checkmark.
- **Key Metrics Row**:
  - `Total Sales`: **₹72,450** (`+12.4%` green trend).
  - `Products`: **16** (`Active` tag).
  - `Pending`: **5 Orders** (`Action` badge).
- **AI Insight Hero Card**: Dark forest green container (`#114C29`) with brain watermark, *"AI INSIGHT"* header (*"Updated 2m ago"*), *"Wheat demand expected to rise 22% next week"*, and `[ + Optimize Pricing ]` pill button.
- **Quick Actions Row**: `[ + Add Product ]`, `[ View Orders ]`, and `[ AI Price Check ]`.
- **Weekly Sales Overview**: Performance across last 7 days with interactive bar chart (Mon-Sun) highlighting Friday peak (**₹2,840 this week**).
- **Trending Products**:
  - *Premium Organic Wheat* (`[ High Demand ]`, `Grade A`, ₹210/quintal, 45 left).
  - *Desi White Cotton* (`[ Trending Up ]`, `Long Staple`, ₹620/bale, 12 left).
  - *Hybrid Roma Tomatoes* (`[ Harvest Ready ]`, `Farm Fresh`, ₹25/crate, 120 left).
- **Floating Action**: `[ ✨ Ask AI ]` pill button linking to AI Insights.

---

### 3. Customer Home / Marketplace (`lib/screens/customer_home_screen.dart`)
- **App Bar**: AgriSmart brand, notification bell, filter action.
- **Location Selector**: Pin icon with *"Ahmedabad, Gujarat"*.
- **Search Bar**: *"Search fresh tomatoes, wheat, organic produce..."* with dedicated `[ Find ]` button.
- **Special Offer Banner**: *"Direct from Farm to Table"* (10% off organic wheat), `[ Claim Discount ]` button, and wheat visual.
- **Explore Categories**: 4 categories (`Grains`, `Vegetables`, `Fruits`, `Spices`) with rounded cards and icons.
- **Recommended for You (2x2 Grid)**:
  - *Organic Tomatoes* (`[ Organic ]`, by Ramesh Patel, ₹40/kg, `[+]`).
  - *Fresh Potatoes* (`[ Fresh ]`, by Suresh Desai, ₹25/kg, `[+]`).
  - *Basmati Rice* (`[ Grade A ]`, by KisanSamaj, ₹85/kg, `[+]`).
  - *Groundnuts* (`[ New Crop ]`, by Dhanyadnya, ₹60/kg, `[+]`).
- **Nearby Farmers**:
  - *Ramesh Patel Farms* (★ 4.8, 120 reviews, 2.2 km away, `[ Visit ]`).
  - *Suresh Desai Organics* (★ 4.6, 84 reviews, 4.5 km away, `[ Visit ]`).

---

### 4. AI Insights & Advisory (`lib/screens/ai_insights_screen.dart`)
- **Market Intelligence Hub**: Dark forest green hero banner with `[ AI Neural Engine v2.3 ]`, 3 KPI indicators:
  - *Accuracy Rate*: **96.4%**
  - *Active Markets*: **14 Hubs**
  - *Trend Outlook*: **Bullish**
- **Demand Forecast Window**: Interactive time tabs: `[ 7 Days ]` (active), `[ 30 Days ]`, `[ 90 Days ]` with live sync indicator.
- **Predictive Trend Multi-Line Chart**: Dual Bézier line curves for *Wheat & Tomato Demand Index* (`+14.8%`), gradient area fill, and active point indicator.
- **Top High-Demand Crops**:
  - *Premium Hard Wheat* (`[ High Demand ]`, Projected Price: $310/ton, +12%).
  - *Roma Tomatoes* (`[ Peak Season ]`, Projected Price: $1.25/kg, +18%).
- **Smart Selling Recommendations**:
  - *Hold Wheat Inventory for 14 Days* (88% Confidence, +₹4,200 profit, `[ Apply Strategy ]`).
  - *Route Roma Tomatoes to North Hub* (91% Confidence, +₹2,800 profit, `[ Dispatch Route ]`).
- **Location-Based Market Insights**: *Central Valley Ag-Hub #4* with custom styled map graphic (winding river, roads, and *"Radius: 50km active supply zone"*), freight cost ($1.12/ton-km), and buyer saturation (*Very High*).

---

### 5. Platform Admin Control Center (`lib/screens/admin_control_center_screen.dart`)
- **Status Banner**: *"• ALL SYSTEMS NORMAL - Control Center"* with security shield.
- **4 KPI Metric Cards (2x2 Grid)**:
  - `TOTAL REVENUE`: **₹142,800** (+18.2% MoM).
  - `TOTAL USERS`: **12,450** (1.4k Farmers • 10.8k Cust).
  - `PRODUCTS LISTED`: **4,520** (98% Active Quality).
  - `ACTIVE ORDERS`: **342** (12 in transit).
- **Revenue Growth Overview**: Weekly performance bar chart with `[ Live Data ]` badge and Sunday peak.
- **Management Portal**:
  - *User Moderation* (14 pending approvals & flag reports).
  - *Supplier Compliance* (6 certifications due for renewal).
  - *Order Logistics & Hubs* (Manage dispatch centers & carriers).
- **Platform Health**:
  - Server Load (CPU): **24%**
  - Database Latency: **14ms**
  - Cloud Storage: **62% (1.8 TB / 2 TB)**
- **Broadcast Alert**: *"Send weather warning to active farmers"* with `[ Send ]` button.

---

## 🎨 Design System & Theme Specs

- **Primary Brand Color**: `Color(0xFF135C31)` (Deep Forest Green)
- **Primary Container / Tint**: `Color(0xFFEAF5ED)`
- **Accent Amber / Gold**: `Color(0xFFD97706)`
- **Surface / Cards**: `Colors.white`
- **Background**: `Color(0xFFF5F7F3)` (Soft Sage / Off-white)
- **Text Primary**: `Color(0xFF19241C)`
- **Text Secondary**: `Color(0xFF58675C)`
- **Borders**: `Color(0xFFE2E7DF)`
- **Corner Radii**: 12px – 16px rounded corners matching the UI cards.

---

## 📂 Project Structure

```
d:\agre_smart_fast\
├── pubspec.yaml
├── README.md
└── lib\
    ├── main.dart                          # App entry & responsive wrapper
    ├── theme\
    │   ├── app_colors.dart                # Brand palette from UI design
    │   └── app_theme.dart                 # Material 3 ThemeData
    ├── models\
    │   └── models.dart                    # Data models for products, stats, KPIs
    ├── widgets\
    │   ├── agrismart_app_bar.dart         # Standard header app bar
    │   ├── agrismart_bottom_nav.dart      # 5-tab bottom navigation bar
    │   ├── custom_bar_chart.dart          # Bar chart for Weekly Sales & Revenue
    │   ├── trend_line_chart.dart          # Dual-line chart for AI forecast
    │   ├── map_preview_widget.dart        # Ag-Hub #4 map painter
    │   └── crop_visual_widget.dart        # Crisp crop visual renderer
    └── screens\
        ├── main_shell_screen.dart         # Shell coordinating bottom nav & screen previews
        ├── onboarding_screen.dart         # Screen 1: Role Selection
        ├── farmer_dashboard_screen.dart   # Screen 2: Farmer Dashboard
        ├── customer_home_screen.dart      # Screen 3: Customer Home
        ├── ai_insights_screen.dart        # Screen 4: AI Insights & Advisory
        └── admin_control_center_screen.dart # Screen 5: Admin Control Center
```

---

## 🚀 How to Run

```bash
cd d:\agre_smart_fast
flutter pub get
flutter run
```
