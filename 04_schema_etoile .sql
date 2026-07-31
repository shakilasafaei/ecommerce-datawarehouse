/* =========================================================================
   PARTIE 4 - MODELE EN ETOILE (DDL)
   1 table de faits (FACT_SALES) + 6 dimensions
   Grain : une ligne = un article d'une commande (order_item)
   ========================================================================= */
USE dwh_ecommerce;

-- ---------- DIM_DATE ----------
CREATE TABLE dim_date (
  date_key      INT          NOT NULL,          -- format AAAAMMJJ
  full_date     DATE         NOT NULL,
  annee         SMALLINT     NOT NULL,
  trimestre     TINYINT      NOT NULL,
  mois          TINYINT      NOT NULL,
  nom_mois      VARCHAR(20)  NOT NULL,
  jour          TINYINT      NOT NULL,
  jour_semaine  TINYINT      NOT NULL,
  nom_jour      VARCHAR(20)  NOT NULL,
  semaine_annee TINYINT      NOT NULL,
  est_weekend   TINYINT(1)   NOT NULL,
  PRIMARY KEY (date_key),
  UNIQUE KEY uk_full_date (full_date)
) ENGINE=InnoDB;

-- ---------- DIM_CUSTOMER ----------
CREATE TABLE dim_customer (
  customer_key        INT AUTO_INCREMENT,       -- cle de substitution
  customer_id         VARCHAR(50) NOT NULL,     -- cle naturelle
  customer_unique_id  VARCHAR(50),
  code_postal         VARCHAR(10),
  ville               VARCHAR(100),
  etat                VARCHAR(5),
  PRIMARY KEY (customer_key),
  UNIQUE KEY uk_customer_id (customer_id),
  KEY idx_cust_etat (etat)
) ENGINE=InnoDB;

-- ---------- DIM_SELLER ----------
CREATE TABLE dim_seller (
  seller_key   INT AUTO_INCREMENT,
  seller_id    VARCHAR(50) NOT NULL,
  code_postal  VARCHAR(10),
  ville        VARCHAR(100),
  etat         VARCHAR(5),
  PRIMARY KEY (seller_key),
  UNIQUE KEY uk_seller_id (seller_id)
) ENGINE=InnoDB;

-- ---------- DIM_PRODUCT ----------
CREATE TABLE dim_product (
  product_key     INT AUTO_INCREMENT,
  product_id      VARCHAR(50) NOT NULL,
  categorie_pt    VARCHAR(100),
  categorie_en    VARCHAR(100),
  poids_g         INT,
  longueur_cm     INT,
  hauteur_cm      INT,
  largeur_cm      INT,
  nb_photos       INT,
  PRIMARY KEY (product_key),
  UNIQUE KEY uk_product_id (product_id),
  KEY idx_categorie (categorie_en)
) ENGINE=InnoDB;

-- ---------- DIM_ORDER_STATUS ----------
CREATE TABLE dim_order_status (
  status_key   INT AUTO_INCREMENT,
  statut       VARCHAR(30) NOT NULL,
  est_livree   TINYINT(1)  NOT NULL DEFAULT 0,
  PRIMARY KEY (status_key),
  UNIQUE KEY uk_statut (statut)
) ENGINE=InnoDB;

-- ---------- DIM_PAYMENT_TYPE ----------
CREATE TABLE dim_payment_type (
  payment_key   INT AUTO_INCREMENT,
  type_paiement VARCHAR(30) NOT NULL,
  PRIMARY KEY (payment_key),
  UNIQUE KEY uk_type_paiement (type_paiement)
) ENGINE=InnoDB;

-- ---------- FACT_SALES ----------
CREATE TABLE fact_sales (
  sales_key        BIGINT AUTO_INCREMENT,
  -- dimensions degenerees (identifiants metier conserves dans le fait)
  order_id         VARCHAR(50) NOT NULL,
  order_item_id    INT         NOT NULL,
  -- cles etrangeres vers les dimensions
  date_key         INT         NOT NULL,
  customer_key     INT         NOT NULL,
  product_key      INT         NOT NULL,
  seller_key       INT         NOT NULL,
  status_key       INT         NOT NULL,
  payment_key      INT,
  -- mesures
  quantite         INT            NOT NULL DEFAULT 1,
  prix_unitaire    DECIMAL(12,2)  NOT NULL,
  frais_port       DECIMAL(12,2)  NOT NULL DEFAULT 0,
  montant_total    DECIMAL(12,2)  NOT NULL,
  delai_livraison  INT,                     -- jours achat -> livraison client
  retard_livraison INT,                     -- jours vs date estimee (>0 = retard)
  note_avis        TINYINT,                 -- score 1..5
  PRIMARY KEY (sales_key),
  UNIQUE KEY uk_fait (order_id, order_item_id),
  CONSTRAINT fk_f_date     FOREIGN KEY (date_key)     REFERENCES dim_date(date_key),
  CONSTRAINT fk_f_customer FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
  CONSTRAINT fk_f_product  FOREIGN KEY (product_key)  REFERENCES dim_product(product_key),
  CONSTRAINT fk_f_seller   FOREIGN KEY (seller_key)   REFERENCES dim_seller(seller_key),
  CONSTRAINT fk_f_status   FOREIGN KEY (status_key)   REFERENCES dim_order_status(status_key),
  CONSTRAINT fk_f_payment  FOREIGN KEY (payment_key)  REFERENCES dim_payment_type(payment_key),
  KEY idx_f_date (date_key),
  KEY idx_f_product (product_key),
  KEY idx_f_customer (customer_key)
) ENGINE=InnoDB;
