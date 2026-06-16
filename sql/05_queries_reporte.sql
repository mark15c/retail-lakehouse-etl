USE RetailLakehouse;
GO

SELECT TOP 5
    p.product_name,
    p.category,
    SUM(f.total_amount_usd) AS revenue_total
FROM analytics.fact_producto f
INNER JOIN analytics.dim_producto p
    ON f.product_id = p.product_id
WHERE f.total_amount_usd IS NOT NULL
GROUP BY 
    p.product_name,
    p.category
ORDER BY revenue_total DESC;
GO

SELECT
    YEAR(order_date) AS anio,
    MONTH(order_date) AS mes,
    SUM(total_amount_usd) AS revenue_total
FROM analytics.fact_producto
WHERE order_date IS NOT NULL
  AND total_amount_usd IS NOT NULL
GROUP BY 
    YEAR(order_date),
    MONTH(order_date)
ORDER BY 
    anio,
    mes;
GO

SELECT
    status,
    COUNT(*) AS cantidad_pedidos,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(10,2)) AS porcentaje
FROM analytics.fact_cliente
WHERE status IS NOT NULL
GROUP BY status
ORDER BY porcentaje DESC;
GO