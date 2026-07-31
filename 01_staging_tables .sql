/* =========================================================================
   PARTIE 1 - BASES ET STAGING
   ========================================================================= */
DROP DATABASE IF EXISTS stg_ecommerce;
DROP DATABASE IF EXISTS dwh_ecommerce;
CREATE DATABASE stg_ecommerce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE dwh_ecommerce CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE stg_ecommerce;

/* Les tables de staging sont volontairement "permissives" (VARCHAR partout
   pour les dates) : on charge d'abord le brut, on nettoie ensuite. */

CREATE TABLE stg_customers (
  customer_id               VARCHAR(50),
  customer_unique_id        VARCHAR(50),
  customer_zip_code_prefix  VARCHAR(10),
  customer_city             VARCHAR(100),
  customer_state            VARCHAR(5)
);

CREATE TABLE stg_sellers (
  seller_id                 VARCHAR(50),
  seller_zip_code_prefix    VARCHAR(10),
  seller_city               VARCHAR(100),
  seller_state              VARCHAR(5)
);

CREATE TABLE stg_products (
  product_id                  VARCHAR(50),
  product_category_name       VARCHAR(100),
  product_name_lenght         VARCHAR(10),
  product_description_lenght  VARCHAR(10),
  product_photos_qty          VARCHAR(10),
  product_weight_g            VARCHAR(10),
  product_length_cm           VARCHAR(10),
  product_height_cm           VARCHAR(10),
  product_width_cm            VARCHAR(10)
);

CREATE TABLE stg_category_translation (
  product_category_name          VARCHAR(100),
  product_category_name_english  VARCHAR(100)
);

CREATE TABLE stg_orders (
  order_id                       VARCHAR(50),
  customer_id                    VARCHAR(50),
  order_status                   VARCHAR(30),
  order_purchase_timestamp       VARCHAR(30),
  order_approved_at              VARCHAR(30),
  order_delivered_carrier_date   VARCHAR(30),
  order_delivered_customer_date  VARCHAR(30),
  order_estimated_delivery_date  VARCHAR(30)
);

CREATE TABLE stg_order_items (
  order_id             VARCHAR(50),
  order_item_id        INT,
  product_id           VARCHAR(50),
  seller_id            VARCHAR(50),
  shipping_limit_date  VARCHAR(30),
  price                DECIMAL(12,2),
  freight_value        DECIMAL(12,2)
);

CREATE TABLE stg_order_payments (
  order_id              VARCHAR(50),
  payment_sequential    INT,
  payment_type          VARCHAR(30),
  payment_installments  INT,
  payment_value         DECIMAL(12,2)
);

CREATE TABLE stg_order_reviews (
  review_id               VARCHAR(50),
  order_id                VARCHAR(50),
  review_score            INT,
  review_comment_title    TEXT,
  review_comment_message  TEXT,
  review_creation_date    VARCHAR(30),
  review_answer_timestamp VARCHAR(30)
);
