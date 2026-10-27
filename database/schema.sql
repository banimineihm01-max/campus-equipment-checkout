CREATE DATABASE IF NOT EXISTS campus_equipment_checkout
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE campus_equipment_checkout;

CREATE TABLE categories (
    category_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

CREATE TABLE borrowers (
    borrower_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_number VARCHAR(30) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(25)
) ENGINE=InnoDB;

CREATE TABLE staff (
    staff_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE equipment (
    equipment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id INT UNSIGNED NOT NULL,
    asset_tag VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    condition_notes TEXT,
    service_status VARCHAR(20) NOT NULL DEFAULT 'in_service',
    CONSTRAINT chk_equipment_status
        CHECK (service_status IN ('in_service', 'maintenance', 'retired')),
    CONSTRAINT fk_equipment_category FOREIGN KEY (category_id)
        REFERENCES categories (category_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE checkouts (
    checkout_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    equipment_id INT UNSIGNED NOT NULL,
    borrower_id INT UNSIGNED NOT NULL,
    staff_id INT UNSIGNED NOT NULL,
    checked_out_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_at DATETIME NOT NULL,
    returned_at DATETIME NULL,
    notes TEXT,
    active_equipment_id INT UNSIGNED GENERATED ALWAYS AS
        (CASE WHEN returned_at IS NULL THEN equipment_id ELSE NULL END) PERSISTENT,
    CONSTRAINT uq_active_equipment UNIQUE (active_equipment_id),
    CONSTRAINT chk_checkout_due CHECK (due_at > checked_out_at),
    CONSTRAINT chk_checkout_return CHECK
        (returned_at IS NULL OR returned_at >= checked_out_at),
    CONSTRAINT fk_checkout_equipment FOREIGN KEY (equipment_id)
        REFERENCES equipment (equipment_id) ON DELETE RESTRICT,
    CONSTRAINT fk_checkout_borrower FOREIGN KEY (borrower_id)
        REFERENCES borrowers (borrower_id) ON DELETE RESTRICT,
    CONSTRAINT fk_checkout_staff FOREIGN KEY (staff_id)
        REFERENCES staff (staff_id) ON DELETE RESTRICT,
    INDEX idx_checkout_overdue (returned_at, due_at)
) ENGINE=InnoDB;
