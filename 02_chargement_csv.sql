/* =========================================================================
   PARTIE 2 - CHARGEMENT DES CSV BRUTS
   Option A : Talend (tFileInputDelimited -> tMap -> tDBOutput MySQL)
   Option B : LOAD DATA ci-dessous (necessite local_infile=1)
   -------------------------------------------------------------------------
   Activer d'abord :   SET GLOBAL local_infile = 1;
   et lancer le client :  mysql --local-infile=1 -u root -p
   ========================================================================= */
USE stg_ecommerce;

-- Exemple type, a repeter pour chaque fichier :
LOAD DATA LOCAL INFILE 'C:/data/olist/olist_customers_dataset.csv'
INTO TABLE stg_customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/data/olist/olist_sellers_dataset.csv'
INTO TABLE stg_sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/data/olist/olist_products_dataset.csv'
INTO TABLE stg_products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/data/olist/product_category_name_translation.csv'
INTO TABLE stg_category_translation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/data/olist/olist_orders_dataset.csv'
INTO TABLE stg_orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/data/olist/olist_order_items_dataset.csv'
INTO TABLE stg_order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/data/olist/olist_order_payments_dataset.csv'
INTO TABLE stg_order_payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/data/olist/olist_order_reviews_dataset.csv'
INTO TABLE stg_order_reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n' IGNORE 1 ROWS;
