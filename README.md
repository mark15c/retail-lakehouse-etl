# Prueba Técnica - Practicante Data Engineer

Proyecto ETL para datos de ventas retail usando Python, SQL Server y Power BI.

## 1. Objetivo

Construir un flujo completo de datos desde archivos CSV hasta tablas analíticas y reporte final.

Flujo implementado:

```text
CSV → RAW → STAGE → ANALYTICS → REPORTE
```

## 2. Tecnologías utilizadas

- Python
- Pandas
- SQL Server
- SQL Server Management Studio
- Power BI
- Git

## 3. Estructura del proyecto

```text
prueba_data_enginner/
│
├── data/
│   └── raw/
│       ├── customers.csv
│       ├── products.csv
│       └── orders.csv
│
├── src/
│   ├── ingesta_raw_sqlserver.py
│   └── seguridad.py
│
├── sql/
│   ├── 00_setup_database.sql
│   ├── 01_verificar_raw.sql
│   ├── 02_diagnostico_raw.sql
│   ├── 03_limpieza_stage.sql
│   ├── 04_tablas_analytics.sql
│   ├── 05_queries_reporte.sql
│   └── 06_examen_sql.sql
│
├── main.py
├── .gitignore
└── README.md
```

## 4. Ejecución del pipeline completo

Desde la raíz del proyecto:

```bash
python main.py
```

Este comando ejecuta en orden:

1. Creación de base de datos y schemas.
2. Ingesta de CSV hacia la capa RAW.
3. Limpieza y transformación hacia la capa STAGE.
4. Creación de tablas analíticas en la capa ANALYTICS.

## 5. Base de datos

Base de datos utilizada:

```text
RetailLakehouse
```

Schemas creados:

```text
raw
stage
analytics
security
```

## 6. Capa RAW

Los archivos CSV originales se cargan al schema `raw`.

Tablas creadas:

- `raw.customers`
- `raw.products`
- `raw.orders`

Script utilizado:

```bash
python src/ingesta_raw_sqlserver.py
```

En esta capa los datos se conservan en formato crudo, sin aplicar limpieza fuerte.

## 7. Capa STAGE

Los datos se limpian y transforman desde RAW hacia STAGE.

Tablas creadas:

- `stage.customers`
- `stage.products`
- `stage.orders`

Script utilizado:

```sql
sql/03_limpieza_stage.sql
```

Reglas principales aplicadas:

- Conversión de textos a mayúscula.
- Limpieza de espacios en blanco.
- Conversión de identificadores a enteros.
- Conversión de montos a decimales.
- Conversión de fechas a tipo `DATE`.
- Eliminación de filas completamente nulas.
- Eliminación de duplicados.
- Tratamiento de precios negativos.
- Tratamiento de cantidades menores o iguales a cero.
- Tratamiento de edades imposibles.
- Tratamiento de descuentos fuera del rango 0 a 100.
- Agregado de columna `fecha_actualizacion`.

## 8. Capa ANALYTICS

Se crearon tablas finales para análisis y reporte.

Tablas creadas:

- `analytics.dim_cliente`
- `analytics.fact_cliente`
- `analytics.dim_producto`
- `analytics.fact_producto`

Script utilizado:

```sql
sql/04_tablas_analytics.sql
```

| Tabla | Descripción |
|---|---|
| `analytics.dim_cliente` | Dimensión con atributos descriptivos de clientes. |
| `analytics.fact_cliente` | Tabla de hechos con métricas de pedidos por cliente. |
| `analytics.dim_producto` | Dimensión con atributos descriptivos de productos. |
| `analytics.fact_producto` | Tabla de hechos con métricas de ventas por producto. |

## 9. Reporte Power BI

El reporte fue desarrollado en Power BI usando las tablas de la capa `analytics`.

Preguntas de negocio respondidas:

1. ¿Cuáles son los 5 productos más vendidos por ingresos?
2. ¿Cómo evolucionaron las ventas mes a mes?
3. ¿Qué porcentaje de pedidos tiene cada estado?

Visualizaciones utilizadas:

- Gráfico de barras para top 5 productos por ingresos.
- Gráfico de líneas para evolución mensual de ventas.
- Gráfico de dona o barras para distribución de pedidos por estado.
- Segmentador por año para análisis interactivo.

## 10. Examen SQL

Las preguntas finales se resolvieron en SQL Server.

Script utilizado:

```sql
sql/06_examen_sql.sql
```

Preguntas respondidas:

1. Top 3 clientes con mayor número de pedidos en el último trimestre disponible.
2. Revenue mensual por categoría de producto.
3. Pedidos cuyo `total_amount_usd` supera 2 desviaciones estándar del promedio.

## 11. Seguridad de la Información - PII

Se identificaron como columnas PII las siguientes:

- `first_name`: nombre del cliente.
- `last_name`: apellido del cliente.
- `email`: correo electrónico.
- `phone`: número telefónico.
- `credit_card`: número de tarjeta sintética.

Técnicas aplicadas:

- `email` fue protegido usando hash SHA-256 y se generó la columna `email_hash`.
- `credit_card` fue enmascarado mostrando solo los últimos 4 dígitos en `credit_card_masked`.
- `phone` fue enmascarado mostrando solo los últimos 3 dígitos en `phone_masked`.

Tabla protegida generada:

```sql
security.customers_pii_protected
```

Script utilizado:

```bash
python src/seguridad.py
```

## 12. Consideraciones sobre Git

El proyecto incluye un archivo `.gitignore` para evitar subir archivos innecesarios o sensibles.

Archivos excluidos:

- Archivos `.pyc`.
- Carpetas `__pycache__/`.
- Entornos virtuales `venv/` o `.venv/`.
- Archivos CSV raw.
- Archivos `.env`.
- Logs.
- Bases locales.

## 13. Orden manual de ejecución

En caso de ejecutar manualmente, seguir este orden:

1. Ejecutar `sql/00_setup_database.sql`.
2. Ejecutar `python src/ingesta_raw_sqlserver.py`.
3. Ejecutar `sql/03_limpieza_stage.sql`.
4. Ejecutar `sql/04_tablas_analytics.sql`.
5. Ejecutar `python src/seguridad.py`, si se desea generar la tabla protegida.
6. Ejecutar `sql/06_examen_sql.sql` para las preguntas finales.

## 14. Autor

Manolo Meza
