USE RetailLakehouse;
GO

WITH ultima_fecha AS (
    SELECT 
        MAX(order_date) AS fecha_maxima
    FROM analytics.fact_cliente
    WHERE order_date IS NOT NULL
),

ultimo_trimestre AS (
    SELECT
        YEAR(fecha_maxima) AS anio_maximo,
        DATEPART(QUARTER, fecha_maxima) AS trimestre_maximo
    FROM ultima_fecha
),

pedidos_ultimo_trimestre AS (
    SELECT 
        f.customer_id,
        f.order_id
    FROM analytics.fact_cliente f
    CROSS JOIN ultimo_trimestre u
    WHERE YEAR(f.order_date) = u.anio_maximo
      AND DATEPART(QUARTER, f.order_date) = u.trimestre_maximo
)

SELECT TOP 3
    c.customer_id,
    c.nombre_completo,
    COUNT(DISTINCT p.order_id) AS cantidad_pedidos
FROM pedidos_ultimo_trimestre p
INNER JOIN analytics.dim_cliente c
    ON p.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.nombre_completo
ORDER BY
    cantidad_pedidos DESC;
GO