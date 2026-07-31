/* =========================================================================
   PARTIE 5 - CHARGEMENT ELT
   Regle d'or : TOUJOURS charger les dimensions AVANT les faits.
   ========================================================================= */
USE dwh_ecommerce;

-- ---------- 5.1 DIM_DATE (generation d'un calendrier 2016-2019) ----------
-- La profondeur de recursion par defaut (1000) est insuffisante : on la releve.
SET SESSION cte_max_recursion_depth = 5000;

-- En MySQL, la clause WITH se place APRES INSERT INTO, jamais avant.
INSERT INTO dim_date
WITH RECURSIVE seq(n) AS (
  SELECT 0 UNION ALL SELECT n + 1 FROM seq WHERE n < 2000
)
SELECT
  CAST(DATE_FORMAT(d, '%Y%m%d') AS UNSIGNED),
  d,
  YEAR(d), QUARTER(d), MONTH(d), MONTHNAME(d),
  DAYOFMONTH(d), DAYOFWEEK(d), DAYNAME(d), WEEK(d, 3),
  CASE WHEN DAYOFWEEK(d) IN (1, 7) THEN 1 ELSE 0 END
FROM (SELECT DATE_ADD('2016-01-01', INTERVAL n DAY) AS d FROM seq) x
WHERE d <= '2019-12-31';

-- ---------- 5.2 DIM_CUSTOMER ----------
INSERT INTO dim_customer (customer_id, customer_unique_id, code_postal, ville, etat)
SELECT DISTINCT
  customer_id, customer_unique_id, customer_zip_code_prefix,
  customer_city, customer_state
FROM stg_ecommerce.stg_customers
WHERE customer_id IS NOT NULL;

-- ---------- 5.3 DIM_SELLER ----------
INSERT INTO dim_seller (seller_id, code_postal, ville, etat)
SELECT DISTINCT seller_id, seller_zip_code_prefix, seller_city, seller_state
FROM stg_ecommerce.stg_sellers
WHERE seller_id IS NOT NULL;

-- ---------- 5.4 DIM_PRODUCT (jointure avec la traduction des categories) ----------
INSERT INTO dim_product
  (product_id, categorie_pt, categorie_en, poids_g, longueur_cm,
   hauteur_cm, largeur_cm, nb_photos)
SELECT
  p.product_id,
  COALESCE(p.product_category_name, 'inconnu'),
  COALESCE(t.product_category_name_english, 'unknown'),
  NULLIF(p.product_weight_g, ''), NULLIF(p.product_length_cm, ''),
  NULLIF(p.product_height_cm, ''), NULLIF(p.product_width_cm, ''),
  NULLIF(p.product_photos_qty, '')
FROM stg_ecommerce.stg_products p
LEFT JOIN stg_ecommerce.stg_category_translation t
       ON t.product_category_name = p.product_category_name;

-- ---------- 5.5 DIM_ORDER_STATUS ----------
INSERT INTO dim_order_status (statut, est_livree)
SELECT DISTINCT order_status,
       CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END
FROM stg_ecommerce.stg_orders
WHERE order_status IS NOT NULL;

-- ---------- 5.6 DIM_PAYMENT_TYPE ----------
INSERT INTO dim_payment_type (type_paiement)
SELECT DISTINCT payment_type
FROM stg_ecommerce.stg_order_payments
WHERE payment_type IS NOT NULL;

-- ---------- 5.7 FACT_SALES ----------
/* Le paiement est au niveau COMMANDE, le fait au niveau ARTICLE :
   on retient le type de paiement de plus gros montant par commande. */
INSERT INTO fact_sales
  (order_id, order_item_id, date_key, customer_key, product_key, seller_key,
   status_key, payment_key, quantite, prix_unitaire, frais_port,
   montant_total, delai_livraison, retard_livraison, note_avis)
SELECT
  i.order_id,
  i.order_item_id,
  CAST(DATE_FORMAT(STR_TO_DATE(NULLIF(o.order_purchase_timestamp,''), '%Y-%m-%d %H:%i:%s'), '%Y%m%d') AS UNSIGNED),
  dc.customer_key,
  dp.product_key,
  ds.seller_key,
  dst.status_key,
  dpt.payment_key,
  1,
  i.price,
  i.freight_value,
  i.price + i.freight_value,
  DATEDIFF(STR_TO_DATE(NULLIF(o.order_delivered_customer_date,''), '%Y-%m-%d %H:%i:%s'),
           STR_TO_DATE(NULLIF(o.order_purchase_timestamp,''),      '%Y-%m-%d %H:%i:%s')),
  DATEDIFF(STR_TO_DATE(NULLIF(o.order_delivered_customer_date,''),  '%Y-%m-%d %H:%i:%s'),
           STR_TO_DATE(NULLIF(o.order_estimated_delivery_date,''),  '%Y-%m-%d %H:%i:%s')),
  r.review_score
FROM stg_ecommerce.stg_order_items i
JOIN stg_ecommerce.stg_orders  o  ON o.order_id    = i.order_id
JOIN dim_customer              dc ON dc.customer_id = o.customer_id
JOIN dim_product               dp ON dp.product_id  = i.product_id
JOIN dim_seller                ds ON ds.seller_id   = i.seller_id
JOIN dim_order_status          dst ON dst.statut    = o.order_status
LEFT JOIN (
    SELECT order_id, payment_type
    FROM (
      SELECT order_id, payment_type,
             ROW_NUMBER() OVER (PARTITION BY order_id
                                ORDER BY SUM(payment_value) DESC) AS rn
      FROM stg_ecommerce.stg_order_payments
      GROUP BY order_id, payment_type
    ) z WHERE rn = 1
) pay ON pay.order_id = i.order_id
LEFT JOIN dim_payment_type dpt ON dpt.type_paiement = pay.payment_type
LEFT JOIN (
    SELECT order_id, MAX(review_score) AS review_score
    FROM stg_ecommerce.stg_order_reviews GROUP BY order_id
) r ON r.order_id = i.order_id
WHERE STR_TO_DATE(NULLIF(o.order_purchase_timestamp,''), '%Y-%m-%d %H:%i:%s') IS NOT NULL;
