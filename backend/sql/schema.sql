-- ========================================================
-- AgriSmart Database Schema
-- Compatible with MySQL 8.0+ and MySQL Workbench
-- ========================================================

CREATE DATABASE IF NOT EXISTS `agrismart_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `agrismart_db`;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `role` ENUM('farmer', 'customer', 'admin') NOT NULL DEFAULT 'customer',
  `phone` VARCHAR(50) DEFAULT NULL,
  `avatar` TEXT DEFAULT NULL,
  `location` VARCHAR(255) DEFAULT 'Ahmedabad, Gujarat',
  `status` ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_users_role` (`role`),
  INDEX `idx_users_email` (`email`)
) ENGINE=InnoDB;

-- 2. Farmer Profiles
CREATE TABLE IF NOT EXISTS `farmer_profiles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `userId` INT NOT NULL,
  `farmName` VARCHAR(255) NOT NULL,
  `farmLocation` VARCHAR(255) NOT NULL,
  `availableProducts` TEXT DEFAULT NULL,
  `farmingExperience` INT DEFAULT 5,
  `verificationStatus` ENUM('pending', 'verified', 'rejected') NOT NULL DEFAULT 'verified',
  `rating` FLOAT NOT NULL DEFAULT 5.0,
  `reviewCount` INT NOT NULL DEFAULT 0,
  `totalSalesKg` FLOAT NOT NULL DEFAULT 0,
  `profileImage` TEXT DEFAULT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_farmer_user` (`userId`)
) ENGINE=InnoDB;

-- 3. Customer Profiles
CREATE TABLE IF NOT EXISTS `customer_profiles` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `userId` INT NOT NULL,
  `deliveryAddress` TEXT DEFAULT NULL,
  `preferences` TEXT DEFAULT NULL,
  `orderCount` INT NOT NULL DEFAULT 0,
  `totalSpent` FLOAT NOT NULL DEFAULT 0,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_customer_user` (`userId`)
) ENGINE=InnoDB;

-- 4. Categories Table
CREATE TABLE IF NOT EXISTS `categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(255) NOT NULL UNIQUE,
  `icon` VARCHAR(100) DEFAULT 'grain',
  `description` TEXT DEFAULT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 5. Products Table
CREATE TABLE IF NOT EXISTS `products` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `farmerId` INT NOT NULL,
  `categoryId` INT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `pricePerKg` FLOAT NOT NULL DEFAULT 0,
  `availableQuantity` FLOAT NOT NULL DEFAULT 0,
  `unit` VARCHAR(50) NOT NULL DEFAULT 'kg',
  `qualityGrade` VARCHAR(100) NOT NULL DEFAULT 'Grade A',
  `harvestDate` VARCHAR(50) DEFAULT NULL,
  `location` VARCHAR(255) DEFAULT 'Ahmedabad, Gujarat',
  `isAvailable` TINYINT(1) NOT NULL DEFAULT 1,
  `views` INT NOT NULL DEFAULT 0,
  `salesCount` INT NOT NULL DEFAULT 0,
  `rating` FLOAT NOT NULL DEFAULT 5.0,
  `reviewCount` INT NOT NULL DEFAULT 0,
  `primaryImage` TEXT DEFAULT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`farmerId`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`categoryId`) REFERENCES `categories`(`id`) ON DELETE RESTRICT,
  INDEX `idx_products_farmer` (`farmerId`),
  INDEX `idx_products_category` (`categoryId`),
  INDEX `idx_products_available` (`isAvailable`)
) ENGINE=InnoDB;

-- 6. Product Images Table
CREATE TABLE IF NOT EXISTS `product_images` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `productId` INT NOT NULL,
  `imageUrl` TEXT NOT NULL,
  `isPrimary` TINYINT(1) NOT NULL DEFAULT 0,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`productId`) REFERENCES `products`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. Cart Items Table
CREATE TABLE IF NOT EXISTS `cart_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `userId` INT NOT NULL,
  `productId` INT NOT NULL,
  `quantity` FLOAT NOT NULL DEFAULT 1.0,
  `price` FLOAT NOT NULL DEFAULT 0,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`productId`) REFERENCES `products`(`id`) ON DELETE CASCADE,
  INDEX `idx_cart_user` (`userId`)
) ENGINE=InnoDB;

-- 8. Orders Table
CREATE TABLE IF NOT EXISTS `orders` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `orderNumber` VARCHAR(100) NOT NULL UNIQUE,
  `customerId` INT NOT NULL,
  `farmerId` INT DEFAULT NULL,
  `totalAmount` FLOAT NOT NULL DEFAULT 0,
  `status` ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'rejected') NOT NULL DEFAULT 'pending',
  `deliveryAddress` TEXT DEFAULT NULL,
  `paymentMethod` VARCHAR(100) DEFAULT 'COD',
  `paymentStatus` ENUM('pending', 'paid', 'refunded', 'failed') NOT NULL DEFAULT 'pending',
  `itemsJson` LONGTEXT DEFAULT NULL,
  `customerName` VARCHAR(255) DEFAULT NULL,
  `customerMobile` VARCHAR(50) DEFAULT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`customerId`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  INDEX `idx_orders_customer` (`customerId`),
  INDEX `idx_orders_farmer` (`farmerId`),
  INDEX `idx_orders_status` (`status`)
) ENGINE=InnoDB;

-- 9. Order Items Table
CREATE TABLE IF NOT EXISTS `order_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `orderId` INT NOT NULL,
  `productId` INT DEFAULT NULL,
  `productName` VARCHAR(255) NOT NULL,
  `quantity` FLOAT NOT NULL DEFAULT 1,
  `price` FLOAT NOT NULL DEFAULT 0,
  `total` FLOAT NOT NULL DEFAULT 0,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`orderId`) REFERENCES `orders`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 10. Payments Table
CREATE TABLE IF NOT EXISTS `payments` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `orderId` INT NOT NULL,
  `userId` INT NOT NULL,
  `amount` FLOAT NOT NULL DEFAULT 0,
  `paymentMethod` VARCHAR(100) DEFAULT 'UPI',
  `transactionId` VARCHAR(255) DEFAULT NULL,
  `status` ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'completed',
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`orderId`) REFERENCES `orders`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 11. Notifications Table
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `userId` INT DEFAULT NULL,
  `title` VARCHAR(255) NOT NULL,
  `message` TEXT NOT NULL,
  `type` VARCHAR(100) DEFAULT 'general',
  `isRead` TINYINT(1) NOT NULL DEFAULT 0,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_notifications_user` (`userId`)
) ENGINE=InnoDB;

-- 12. Smart Recommendations Table (AI Insights)
CREATE TABLE IF NOT EXISTS `smart_recommendations` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `confidence` VARCHAR(50) NOT NULL DEFAULT '88% Confidence',
  `description` TEXT NOT NULL,
  `profitIncrease` VARCHAR(50) NOT NULL DEFAULT '+₹4,200',
  `actionLabel` VARCHAR(100) NOT NULL DEFAULT 'Apply Strategy',
  `iconName` VARCHAR(100) DEFAULT 'inventory_2_outlined',
  `isApplied` TINYINT(1) NOT NULL DEFAULT 0,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 13. Demand Forecasts Table
CREATE TABLE IF NOT EXISTS `demand_predictions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `cropName` VARCHAR(255) NOT NULL,
  `projectedPrice` VARCHAR(100) NOT NULL,
  `trendPercentage` VARCHAR(50) NOT NULL DEFAULT '+12%',
  `tag` VARCHAR(100) NOT NULL DEFAULT 'High Demand',
  `isHighDemand` TINYINT(1) NOT NULL DEFAULT 1,
  `imageType` VARCHAR(50) NOT NULL DEFAULT 'wheat',
  `forecastWindow` VARCHAR(50) NOT NULL DEFAULT '7 Days',
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 14. Weekly Sales History
CREATE TABLE IF NOT EXISTS `sales_history` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `farmerId` INT DEFAULT NULL,
  `day` VARCHAR(10) NOT NULL,
  `value` FLOAT NOT NULL DEFAULT 0.5,
  `label` VARCHAR(50) NOT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 15. Supplier Compliance Table
CREATE TABLE IF NOT EXISTS `supplier_compliances` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `supplierName` VARCHAR(255) NOT NULL,
  `certificationType` VARCHAR(255) NOT NULL,
  `status` ENUM('Valid', 'Due for Renewal', 'Pending Approval', 'Flagged') NOT NULL DEFAULT 'Due for Renewal',
  `renewalDate` VARCHAR(100) NOT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 16. Moderation Reports Table
CREATE TABLE IF NOT EXISTS `moderation_reports` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `reportedBy` INT DEFAULT NULL,
  `userName` VARCHAR(255) NOT NULL,
  `userRole` VARCHAR(50) NOT NULL,
  `reason` TEXT NOT NULL,
  `status` ENUM('Pending Review', 'Approved', 'Flagged', 'Banned') NOT NULL DEFAULT 'Pending Review',
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

