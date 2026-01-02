-- Universal Data Model (UDM) compliant schema for NotNaked PIM
-- Variant-first Product Information Management (PIM)

-- =========================
-- PRODUCT
-- =========================

-- Logical product container (not directly sellable)
CREATE TABLE product (
    product_id VARCHAR(30) PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    product_type VARCHAR(100),
    vendor VARCHAR(100),
    status_id VARCHAR(30), -- ACTIVE, INACTIVE, ARCHIVED
    from_date DATE NOT NULL,
    thru_date DATE
);

-- =========================
-- PRODUCT IDENTIFICATION
-- =========================

-- Stores external identifiers for products and variants (Shopify, etc.)
CREATE TABLE product_identification (
    product_id VARCHAR(30) NOT NULL,
    product_identification_type_id VARCHAR(30) NOT NULL, -- SHOPIFY_PRODUCT_ID, SHOPIFY_VARIANT_ID
    id_value VARCHAR(100) NOT NULL,
    from_date DATE NOT NULL,
    thru_date DATE,
    PRIMARY KEY (product_id, product_identification_type_id, from_date),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- =========================
-- PRODUCT VARIANT
-- =========================

-- Sellable unit (SKU-level)
CREATE TABLE product_variant (
    product_variant_id VARCHAR(30) PRIMARY KEY,
    product_id VARCHAR(30) NOT NULL,
    sku VARCHAR(60) NOT NULL UNIQUE,
    barcode VARCHAR(60), -- UPC / GTIN
    status_id VARCHAR(30),
    from_date DATE NOT NULL,
    thru_date DATE,
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- =========================
-- PRODUCT OPTIONS (ATTRIBUTES)
-- =========================

-- Attribute definition (Size, Color, etc.)
CREATE TABLE product_option (
    product_option_id VARCHAR(30) PRIMARY KEY,
    product_id VARCHAR(30) NOT NULL,
    option_name VARCHAR(100) NOT NULL,
    position INT,
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

-- Attribute values (Small, Red, etc.)
CREATE TABLE product_option_value (
    product_option_value_id VARCHAR(30) PRIMARY KEY,
    product_option_id VARCHAR(30) NOT NULL,
    option_value VARCHAR(100) NOT NULL,
    FOREIGN KEY (product_option_id) REFERENCES product_option(product_option_id)
);

-- Variant-to-option-value mapping
CREATE TABLE product_variant_option (
    product_variant_id VARCHAR(30) NOT NULL,
    product_option_value_id VARCHAR(30) NOT NULL,
    PRIMARY KEY (product_variant_id, product_option_value_id),
    FOREIGN KEY (product_variant_id) REFERENCES product_variant(product_variant_id),
    FOREIGN KEY (product_option_value_id) REFERENCES product_option_value(product_option_value_id)
);

-- =========================
-- PRODUCT PRICING
-- =========================

-- Temporal pricing at variant level
CREATE TABLE product_price (
    product_variant_id VARCHAR(30) NOT NULL,
    price_type_id VARCHAR(30) NOT NULL, -- LIST_PRICE, SALE_PRICE, COMPARE_AT_PRICE
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    from_date DATE NOT NULL,
    thru_date DATE,
    PRIMARY KEY (product_variant_id, price_type_id, from_date),
    FOREIGN KEY (product_variant_id) REFERENCES product_variant(product_variant_id)
);

-- =========================
-- PRODUCT CATEGORY
-- =========================

CREATE TABLE product_category (
    product_category_id VARCHAR(30) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE product_category_member (
    product_id VARCHAR(30) NOT NULL,
    product_category_id VARCHAR(30) NOT NULL,
    from_date DATE NOT NULL,
    thru_date DATE,
    PRIMARY KEY (product_id, product_category_id, from_date),
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (product_category_id) REFERENCES product_category(product_category_id)
);

-- =========================
-- PRODUCT IMAGES
-- =========================

CREATE TABLE product_image (
    product_image_id VARCHAR(30) PRIMARY KEY,
    product_id VARCHAR(30) NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    position INT,
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);
