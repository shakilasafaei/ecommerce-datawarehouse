/* =========================================================================
   PARTIE 3 - CONTROLE QUALITE & NETTOYAGE (a documenter dans le rapport)
   ========================================================================= */
USE stg_ecommerce;

-- 3.1 Volumetrie : verifier que le nombre de lignes correspond aux CSV
SELECT 'customers' AS t, COUNT(*) FROM stg_customers
UNION ALL SELECT 'orders',      COUNT(*) FROM stg_orders
UNION ALL SELECT 'order_items', COUNT(*) FROM stg_order_items
UNION ALL SELECT 'products',    COUNT(*) FROM stg_products
UNION ALL SELECT 'sellers',     COUNT(*) FROM stg_sellers
UNION ALL SELECT 'payments',    COUNT(*) FROM stg_order_payments
UNION ALL SELECT 'reviews',     COUNT(*) FROM stg_order_reviews;

-- 3.2 Doublons sur les cles naturelles
SELECT customer_id, COUNT(*) FROM stg_customers GROUP BY customer_id HAVING COUNT(*) > 1;
SELECT product_id,  COUNT(*) FROM stg_products  GROUP BY product_id  HAVING COUNT(*) > 1;
SELECT order_id, order_item_id, COUNT(*) FROM stg_order_items
GROUP BY order_id, order_item_id HAVING COUNT(*) > 1;

-- 3.3 Valeurs manquantes (categorie produit absente sur ~600 produits)
SELECT COUNT(*) AS produits_sans_categorie
FROM stg_products
WHERE product_category_name IS NULL OR TRIM(product_category_name) = '';

-- 3.4 Integrite referentielle : orphelins entre faits et dimensions
SELECT COUNT(*) AS items_sans_produit
FROM stg_order_items i
LEFT JOIN stg_products p ON p.product_id = i.product_id
WHERE p.product_id IS NULL;

-- 3.5 Coherence metier : montants negatifs ou nuls
SELECT COUNT(*) FROM stg_order_items WHERE price <= 0 OR freight_value < 0;

-- 3.6 Normalisation du texte (villes en minuscules, espaces parasites)
UPDATE stg_customers SET customer_city = LOWER(TRIM(customer_city));
UPDATE stg_sellers   SET seller_city   = LOWER(TRIM(seller_city));

-- 3.7 Remplacement des chaines vides par NULL (facilite les traitements)
UPDATE stg_products
SET product_category_name = NULL
WHERE TRIM(COALESCE(product_category_name,'')) = '';
