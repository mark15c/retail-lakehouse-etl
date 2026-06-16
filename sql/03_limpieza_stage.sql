USE RetailLakehouse;
GO

DROP TABLE IF EXISTS stage.customers;
GO

WITH customers_limpio AS (
    SELECT
        -- ID: quitamos letras C, espacios y convertimos a entero
        TRY_CONVERT(
            INT,
            TRY_CONVERT(
                DECIMAL(18,2),
                REPLACE(UPPER(TRIM(customer_id)), 'C', '')
            )
        ) AS customer_id,   --  primero estamos eliminando espacios en blanco con TRIM, luego quitamos la letra 'C' con REPLACE, convertimos a decimal para manejar casos con caracteres no numéricos y finalmente a entero. Si no se puede convertir, quedará como NULL.

        -- Textos en mayúscula
        UPPER(TRIM(first_name)) AS first_name,  -- Para los nombres, convertimos a mayúscula y eliminamos espacios. No eliminamos caracteres especiales porque pueden ser parte del nombre.
        UPPER(TRIM(last_name)) AS last_name,    -- Para los apellidos, igual que los nombres, convertimos a mayúscula y eliminamos espacios, pero no tocamos caracteres especiales.
        UPPER(TRIM(email)) AS email,
        TRIM(phone) AS phone,   -- Para el teléfono, solo eliminamos espacios, ya que puede contener caracteres especiales como +, -, etc.

        -- Edad: convertimos a número y anulamos edades imposibles
        CASE
            WHEN TRY_CONVERT(DECIMAL(10,2), age) BETWEEN 0 AND 100
                THEN TRY_CONVERT(INT, TRY_CONVERT(DECIMAL(10,2), age))
            ELSE NULL
        END AS age, -- Para la edad, primero intentamos convertir a decimal para manejar casos con caracteres no numéricos, luego verificamos que esté entre 0 y 100, y finalmente convertimos a entero. Si no se puede convertir o está fuera de rango, quedará como NULL.

        UPPER(TRIM(gender)) AS gender,
        UPPER(TRIM(city)) AS city,  -- Para el género y la ciudad, convertimos a mayúscula y eliminamos espacios. No eliminamos caracteres especiales porque pueden ser parte del nombre de la ciudad o del género (e.g., "Non-Binary").

        -- Fecha: probamos varios formatos
        COALESCE(
            TRY_CONVERT(DATE, signup_date, 23),   -- yyyy-mm-dd
            TRY_CONVERT(DATE, signup_date, 111),  -- yyyy/mm/dd
            TRY_CONVERT(DATE, signup_date, 103),  -- dd/mm/yyyy
            TRY_CONVERT(DATE, signup_date, 110),  -- mm-dd-yyyy
            TRY_CONVERT(DATE, signup_date, 106)   -- dd-mon-yyyy
        ) AS signup_date,   -- Para la fecha de registro, usamos COALESCE para intentar convertir la fecha en varios formatos comunes. Si ninguno funciona, quedará como NULL.

        TRIM(credit_card) AS credit_card    -- Para el número de tarjeta de crédito, solo eliminamos espacios. No eliminamos caracteres especiales porque pueden ser parte del número (e.g., guiones).

    FROM raw.customers  -- todo este preposesamiento se hizo justamente desde los datos de la tabla raw.customers y con el whit aun no se creo la tabla customers_limpio, por lo que no se puede hacer un select directo a esta tabla, sino que se hace el preprocesamiento dentro del with y luego se selecciona desde esta tabla temporal customers_limpio.

    -- Eliminamos registros donde todos los campos estén vacíos o nulos
    WHERE COALESCE(
        NULLIF(TRIM(customer_id), ''),
        NULLIF(TRIM(first_name), ''),
        NULLIF(TRIM(last_name), ''),
        NULLIF(TRIM(email), ''),
        NULLIF(TRIM(phone), ''),
        NULLIF(TRIM(age), ''),
        NULLIF(TRIM(gender), ''),
        NULLIF(TRIM(city), ''),
        NULLIF(TRIM(signup_date), ''),
        NULLIF(TRIM(credit_card), '')
    ) IS NOT NULL   --eliminamos todas las filas donde todos los campos estén vacíos o nulos. Para esto, usamos COALESCE junto con NULLIF para verificar cada campo. Si todos los campos son vacíos o nulos, entonces la fila se elimina.
)

SELECT DISTINCT
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    age,
    gender,
    city,
    signup_date,
    credit_card,
    GETDATE() AS fecha_actualizacion
INTO stage.customers
FROM customers_limpio;  -- Finalmente, seleccionamos los datos limpios y distintos de la tabla temporal customers_limpio y los insertamos en la tabla stage.customers. Agregamos una columna fecha_actualizacion con la fecha y hora actual para tener un registro de cuándo se realizó la limpieza de datos.
GO

SELECT TOP 20 *
FROM stage.customers;
GO

SELECT COUNT(*) AS total_stage_customers
FROM stage.customers;
GO




DROP TABLE IF EXISTS stage.products;
GO

WITH products_limpio AS (
    SELECT
        -- ID: quitamos P, espacios y convertimos a entero
        TRY_CONVERT(
            INT,
            REPLACE(UPPER(TRIM(product_id)), 'P', '')
        ) AS product_id,

        -- Textos en mayúscula
        UPPER(TRIM(product_name)) AS product_name,
        UPPER(TRIM(category)) AS category,
        UPPER(TRIM(brand)) AS brand,

        -- Precio: quitamos USD, comas y convertimos a decimal.
        -- Si es negativo, lo dejamos como NULL.
        CASE
            WHEN TRY_CONVERT(
                DECIMAL(18,2),
                REPLACE(REPLACE(UPPER(TRIM(price_usd)), 'USD', ''), ',', '')
            ) >= 0
            THEN TRY_CONVERT(
                DECIMAL(18,2),
                REPLACE(REPLACE(UPPER(TRIM(price_usd)), 'USD', ''), ',', '')    -- Primero eliminamos espacios con TRIM, luego quitamos 'USD' con REPLACE, después quitamos comas con otro REPLACE, y finalmente convertimos a decimal. Si el resultado es negativo o no se puede convertir, quedará como NULL.
            )
            ELSE NULL
        END AS price_usd,

        -- Stock: debe ser mayor o igual a 0
        CASE
            WHEN TRY_CONVERT(INT, stock_qty) >= 0
                THEN TRY_CONVERT(INT, stock_qty)
            ELSE NULL
        END AS stock_qty,

        -- Active estandarizado
        CASE
            WHEN UPPER(TRIM(active)) IN ('Y', 'YES', 'TRUE', '1') THEN 1
            WHEN UPPER(TRIM(active)) IN ('N', 'NO', 'FALSE', '0') THEN 0
            ELSE NULL
        END AS active,

        -- Fecha con varios formatos
        COALESCE(
            TRY_CONVERT(DATE, created_at, 23),
            TRY_CONVERT(DATE, created_at, 111),
            TRY_CONVERT(DATE, created_at, 103),
            TRY_CONVERT(DATE, created_at, 110),
            TRY_CONVERT(DATE, created_at, 106)
        ) AS created_at

    FROM raw.products

    -- Eliminamos filas completamente nulas
    WHERE COALESCE(
        NULLIF(TRIM(product_id), ''),
        NULLIF(TRIM(product_name), ''),
        NULLIF(TRIM(category), ''),
        NULLIF(TRIM(brand), ''),
        NULLIF(TRIM(price_usd), ''),
        NULLIF(TRIM(stock_qty), ''),
        NULLIF(TRIM(active), ''),
        NULLIF(TRIM(created_at), '')
    ) IS NOT NULL
)

SELECT DISTINCT
    product_id,
    product_name,
    category,
    brand,
    price_usd,
    stock_qty,
    active,
    created_at,
    GETDATE() AS fecha_actualizacion
INTO stage.products
FROM products_limpio;
GO




SELECT  *
FROM stage.products
order by created_at asc ;
GO



SELECT COUNT(*) AS total_stage_products
FROM stage.products;
GO


DROP TABLE IF EXISTS stage.orders;
GO

WITH orders_limpio AS (
    SELECT
        -- IDs: quitamos letras y convertimos a enteros
        TRY_CONVERT(INT, REPLACE(UPPER(TRIM(order_id)), 'O', '')) AS order_id,
        TRY_CONVERT(INT, REPLACE(UPPER(TRIM(customer_id)), 'C', '')) AS customer_id,
        TRY_CONVERT(INT, REPLACE(UPPER(TRIM(product_id)), 'P', '')) AS product_id,

        -- Fecha del pedido
        COALESCE(
            TRY_CONVERT(DATE, order_date, 23),
            TRY_CONVERT(DATE, order_date, 111),
            TRY_CONVERT(DATE, order_date, 103),
            TRY_CONVERT(DATE, order_date, 110),
            TRY_CONVERT(DATE, order_date, 106)
        ) AS order_date,

        -- Cantidad: debe ser mayor a 0
        CASE
            WHEN TRY_CONVERT(INT, quantity) > 0
                THEN TRY_CONVERT(INT, quantity)
            ELSE NULL
        END AS quantity,

        -- Precio unitario: quitamos USD y comas. No puede ser negativo
        CASE
            WHEN TRY_CONVERT(DECIMAL(18,2), REPLACE(REPLACE(UPPER(TRIM(unit_price_usd)), 'USD', ''), ',', '')) >= 0
                THEN TRY_CONVERT(DECIMAL(18,2), REPLACE(REPLACE(UPPER(TRIM(unit_price_usd)), 'USD', ''), ',', ''))
            ELSE NULL
        END AS unit_price_usd,

        -- Descuento: debe estar entre 0 y 100
        CASE
            WHEN TRY_CONVERT(DECIMAL(18,2), discount_pct) BETWEEN 0 AND 100
                THEN TRY_CONVERT(DECIMAL(18,2), discount_pct)
            ELSE NULL
        END AS discount_pct,

        -- Total: quitamos comas. Si es negativo, se vuelve NULL
        CASE
            WHEN TRY_CONVERT(DECIMAL(18,2), REPLACE(TRIM(total_amount_usd), ',', '')) >= 0
                THEN TRY_CONVERT(DECIMAL(18,2), REPLACE(TRIM(total_amount_usd), ',', ''))
            ELSE NULL
        END AS total_amount_usd,

        -- Estado estandarizado
        CASE
            WHEN UPPER(TRIM(status)) IN ('COMPLETED', 'PENDING', 'CANCELLED')
                THEN UPPER(TRIM(status))
            ELSE NULL
        END AS status,

        UPPER(TRIM(payment_method)) AS payment_method,
        UPPER(TRIM(shipping_city)) AS shipping_city,

        COALESCE(
            TRY_CONVERT(DATE, updated_at, 23),
            TRY_CONVERT(DATE, updated_at, 111),
            TRY_CONVERT(DATE, updated_at, 103),
            TRY_CONVERT(DATE, updated_at, 110),
            TRY_CONVERT(DATE, updated_at, 106)
        ) AS updated_at

    FROM raw.orders

    -- Eliminamos filas completamente nulas
    WHERE COALESCE(
        NULLIF(TRIM(order_id), ''),
        NULLIF(TRIM(customer_id), ''),
        NULLIF(TRIM(product_id), ''),
        NULLIF(TRIM(order_date), ''),
        NULLIF(TRIM(quantity), ''),
        NULLIF(TRIM(unit_price_usd), ''),
        NULLIF(TRIM(discount_pct), ''),
        NULLIF(TRIM(total_amount_usd), ''),
        NULLIF(TRIM(status), ''),
        NULLIF(TRIM(payment_method), ''),
        NULLIF(TRIM(shipping_city), ''),
        NULLIF(TRIM(updated_at), '')
    ) IS NOT NULL
)

SELECT DISTINCT
    order_id,
    customer_id,
    product_id,
    order_date,
    quantity,
    unit_price_usd,
    discount_pct,
    total_amount_usd,
    status,
    payment_method,
    shipping_city,
    updated_at,
    GETDATE() AS fecha_actualizacion
INTO stage.orders
FROM orders_limpio;
GO

SELECT TOP 20 *
FROM stage.orders;
GO


SELECT COUNT(*) AS total_stage_orders
FROM stage.orders;
GO