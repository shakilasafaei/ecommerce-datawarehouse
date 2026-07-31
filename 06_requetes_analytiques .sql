/* =========================================================================
   PARTIE 6 - REQUETES ANALYTIQUES (a mettre dans le rapport / dashboard)
   ========================================================================= */
USE dwh_ecommerce;

-- 6.0 Reconciliation : le fait doit contenir ~112 650 lignes
SELECT COUNT(*) AS lignes_fait, ROUND(SUM(montant_total), 2) AS ca_total FROM fact_sales;

-- 6.1 Chiffre d'affaires par annee et par mois
SELECT d.annee, d.mois, d.nom_mois,
       COUNT(DISTINCT f.order_id)     AS nb_commandes,
       ROUND(SUM(f.montant_total), 2) AS ca
FROM fact_sales f
JOIN dim_date d ON d.date_key = f.date_key
GROUP BY d.annee, d.mois, d.nom_mois
ORDER BY d.annee, d.mois;

-- 6.2 Top 10 des categories de produits
SELECT p.categorie_en,
       COUNT(*)                       AS articles_vendus,
       ROUND(SUM(f.montant_total), 2) AS ca,
       ROUND(AVG(f.prix_unitaire), 2) AS panier_moyen_article
FROM fact_sales f
JOIN dim_product p ON p.product_key = f.product_key
GROUP BY p.categorie_en
ORDER BY ca DESC
LIMIT 10;

-- 6.3 CA par etat (region) du client
SELECT c.etat,
       COUNT(DISTINCT c.customer_key) AS nb_clients,
       ROUND(SUM(f.montant_total), 2) AS ca
FROM fact_sales f
JOIN dim_customer c ON c.customer_key = f.customer_key
GROUP BY c.etat
ORDER BY ca DESC;

-- 6.4 Delai de livraison moyen et taux de retard par etat
SELECT c.etat,
       ROUND(AVG(f.delai_livraison), 1) AS delai_moyen_jours,
       ROUND(100.0 * SUM(CASE WHEN f.retard_livraison > 0 THEN 1 ELSE 0 END)
             / COUNT(*), 2)             AS taux_retard_pct
FROM fact_sales f
JOIN dim_customer c ON c.customer_key = f.customer_key
WHERE f.delai_livraison IS NOT NULL
GROUP BY c.etat
ORDER BY taux_retard_pct DESC;

-- 6.5 Correlation retard de livraison / satisfaction client
SELECT CASE WHEN f.retard_livraison <= 0 THEN 'A l heure'
            WHEN f.retard_livraison <= 7 THEN 'Retard 1-7j'
            ELSE 'Retard > 7j' END       AS segment_livraison,
       COUNT(*)                          AS nb,
       ROUND(AVG(f.note_avis), 2)        AS note_moyenne
FROM fact_sales f
WHERE f.note_avis IS NOT NULL AND f.retard_livraison IS NOT NULL
GROUP BY segment_livraison;

-- 6.6 Repartition du CA par mode de paiement
SELECT COALESCE(pt.type_paiement, 'non renseigne') AS mode_paiement,
       COUNT(*)                        AS nb_lignes,
       ROUND(SUM(f.montant_total), 2)  AS ca,
       ROUND(100.0 * SUM(f.montant_total) / (SELECT SUM(montant_total) FROM fact_sales), 2) AS part_pct
FROM fact_sales f
LEFT JOIN dim_payment_type pt ON pt.payment_key = f.payment_key
GROUP BY mode_paiement
ORDER BY ca DESC;

-- 6.7 Top 10 vendeurs + part cumulee (fonction fenetre)
SELECT s.seller_id, s.etat,
       ROUND(SUM(f.montant_total), 2) AS ca,
       RANK() OVER (ORDER BY SUM(f.montant_total) DESC) AS rang
FROM fact_sales f
JOIN dim_seller s ON s.seller_key = f.seller_key
GROUP BY s.seller_key, s.seller_id, s.etat
ORDER BY ca DESC
LIMIT 10;

-- 6.8 Evolution mensuelle du CA avec cumul et croissance (fonctions fenetre)
SELECT annee, mois, ca,
       SUM(ca) OVER (PARTITION BY annee ORDER BY mois) AS ca_cumule,
       ROUND(100.0 * (ca - LAG(ca) OVER (ORDER BY annee, mois))
             / NULLIF(LAG(ca) OVER (ORDER BY annee, mois), 0), 2) AS croissance_pct
FROM (
  SELECT d.annee, d.mois, ROUND(SUM(f.montant_total), 2) AS ca
  FROM fact_sales f
  JOIN dim_date d ON d.date_key = f.date_key
  GROUP BY d.annee, d.mois
) m
ORDER BY annee, mois;
