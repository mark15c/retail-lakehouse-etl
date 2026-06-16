USE RetailLakehouse;
GO

-- 1. Cantidad de registros por tabla
SELECT 'raw.customers' AS tabla, COUNT(*) AS total_filas FROM raw.customers
UNION ALL
SELECT 'raw.products', COUNT(*) FROM raw.products
UNION ALL
SELECT 'raw.orders', COUNT(*) FROM raw.orders;
GO

-- 2. Ver columnas de customers
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
  AND TABLE_NAME = 'customers';
GO

-- 3. Ver columnas de products
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
  AND TABLE_NAME = 'products';
GO

-- 4. Ver columnas de orders
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
  AND TABLE_NAME = 'orders';
GO

-- 5. Primeras filas
SELECT TOP 10 * FROM raw.customers;
SELECT TOP 10 * FROM raw.products;
SELECT TOP 10 * FROM raw.orders;
GO