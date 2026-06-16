USE RetailLakehouse;
GO

DROP TABLE IF EXISTS analytics.fact_cliente;
DROP TABLE IF EXISTS analytics.fact_producto;
DROP TABLE IF EXISTS analytics.dim_cliente;
DROP TABLE IF EXISTS analytics.dim_producto;
GO

--------------------------------
-- tabla de dimensión dim_cliente (guarda atributos descriptivos)
--------------------------------

CREATE TABLE analytics.dim_cliente (
    customer_id INT,
    nombre_completo VARCHAR(200),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    city VARCHAR(100),
    signup_date DATE,
    fecha_actualizacion DATETIME
);
GO

INSERT INTO analytics.dim_cliente (
    customer_id,
    nombre_completo,
    first_name,
    last_name,
    age,
    gender,
    city,
    signup_date,
    fecha_actualizacion
)

SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) AS nombre_completo,
    first_name,
    last_name,
    age,
    gender,
    city,
    signup_date,
    GETDATE() AS fecha_actualizacion
FROM stage.customers
WHERE customer_id IS NOT NULL;
GO

--------------------------------
--- tabla de dimensión dim_producto ( guarda atributos descriptivos)
--------------------------------

CREATE TABLE analytics.dim_producto (
    product_id INT,
    product_name VARCHAR(200),
    category VARCHAR(100),
    brand VARCHAR(100),
    price_usd DECIMAL(18,2),
    stock_qty INT,
    active BIT,
    created_at DATE,
    fecha_actualizacion DATETIME
);
GO

INSERT INTO analytics.dim_producto (
    product_id,
    product_name,
    category,
    brand,
    price_usd,
    stock_qty,
    active,
    created_at,
    fecha_actualizacion
)
SELECT
    product_id,
    product_name,
    category,
    brand,
    price_usd,
    stock_qty,
    active,
    created_at,
    GETDATE() AS fecha_actualizacion
FROM stage.products
WHERE product_id IS NOT NULL;
GO

--------------------------------
-- tabla de metircas fac_cliente ( guarda metricas o eventos medibles)
--------------------------------

CREATE TABLE analytics.fact_cliente (
    order_id INT,
    customer_id INT,
    order_date DATE,
    status VARCHAR(30),
    cantidad_pedidos INT,
    unidades_compradas INT,
    total_amount_usd DECIMAL(18,2),
    fecha_actualizacion DATETIME
);
GO

INSERT INTO analytics.fact_cliente (
    order_id,
    customer_id,
    order_date,
    status,
    cantidad_pedidos,
    unidades_compradas,
    total_amount_usd,
    fecha_actualizacion
)
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    1 AS cantidad_pedidos,
    o.quantity AS unidades_compradas,
    o.total_amount_usd,
    GETDATE() AS fecha_actualizacion
FROM stage.orders o
INNER JOIN analytics.dim_cliente c
    ON o.customer_id = c.customer_id
WHERE o.order_id IS NOT NULL
  AND o.customer_id IS NOT NULL;
GO


--------------------------------
-- tabla  de metricas fac_producto
--------------------------------

CREATE TABLE analytics.fact_producto (
    order_id INT,
    product_id INT,
    order_date DATE,
    status VARCHAR(30),
    quantity INT,
    unit_price_usd DECIMAL(18,2),
    discount_pct DECIMAL(18,2),
    total_amount_usd DECIMAL(18,2),
    fecha_actualizacion DATETIME
);
GO

INSERT INTO analytics.fact_producto (
    order_id,
    product_id,
    order_date,
    status,
    quantity,
    unit_price_usd,
    discount_pct,
    total_amount_usd,
    fecha_actualizacion
)
SELECT
    o.order_id,
    o.product_id,
    o.order_date,
    o.status,
    o.quantity,
    o.unit_price_usd,
    o.discount_pct,
    o.total_amount_usd,
    GETDATE() AS fecha_actualizacion
FROM stage.orders o
INNER JOIN analytics.dim_producto p
    ON o.product_id = p.product_id
WHERE o.order_id IS NOT NULL
  AND o.product_id IS NOT NULL;
GO





SELECT 
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'analytics';
GO


SELECT * FROM analytics.dim_cliente;
SELECT * FROM analytics.fact_cliente;
SELECT TOP 10 * FROM analytics.dim_producto;
SELECT TOP 10 * FROM analytics.fact_producto;
GO






























