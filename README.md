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

## 3. Requisitos previos

Antes de ejecutar el proyecto, se requiere tener instalado:

- Python 3.11 o superior.
- SQL Server.
- SQL Server Management Studio.
- Power BI Desktop.
- Git.
- ODBC Driver 17 for SQL Server.

Instalar librerías de Python:

```bash
pip install pandas sqlalchemy pyodbc
```

Nota: En los scripts Python se debe configurar el nombre del servidor SQL Server en la variable `SERVER`.

Ejemplo:

```python
SERVER = "DESKTOP-2DJB5PC"
```

## 4. Estructura del proyecto

```text
prueba_data_enginner/
│
├── data/
│   └── raw/
│       └── colocar_aqui_los_csv_provistos/
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
├── outputs/
│   └── dashboard_powerbi.png
│
├── main.py
├── requirements.txt
├── .gitignore
└── README.md
```

> Nota: Los archivos CSV originales deben colocarse manualmente en `data/raw/` antes de ejecutar el pipeline.  
> Estos archivos no se suben al repositorio porque pueden contener datos sensibles y están excluidos en `.gitignore`.

## 5. Ejecución del pipeline completo

Desde la raíz del proyecto:

```bash
python main.py
```

Este comando ejecuta en orden:

1. Creación de base de datos y schemas.
2. Ingesta de CSV hacia la capa RAW.
3. Limpieza y transformación hacia la capa STAGE.
4. Creación de tablas analíticas en la capa ANALYTICS.

Resultado esperado:

```text
PIPELINE EJECUTADO CORRECTAMENTE
```

## 6. Base de datos

Base de datos utilizada:

```text
RetailLakehouse
```

Schemas principales:

```text
raw
stage
analytics
```

Schema opcional de seguridad:

```text
security
```

El schema `security` se crea al ejecutar el script de protección de PII:

```bash
python src/seguridad.py
```

## 7. Capa RAW

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
El objetivo de RAW es mantener una copia fiel de la fuente original.

## 8. Capa STAGE

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
- Estandarización de campos categóricos como `status` y `active`.
- Agregado de columna `fecha_actualizacion`.

## 9. Capa ANALYTICS

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

## 10. Reporte Power BI

El reporte fue desarrollado en Power BI usando las tablas de la capa `analytics`.

Preguntas de negocio respondidas:

1. ¿Cuáles son los 5 productos más vendidos por ingresos?
2. ¿Cómo evolucionaron las ventas mes a mes?
3. ¿Qué porcentaje de pedidos tiene cada estado?

Visualizaciones utilizadas:

- Gráfico de barras para el top 5 de productos por ingresos.
- Gráfico de líneas para la evolución mensual de ventas.
- Gráfico de dona o barras para la distribución de pedidos por estado.
- Segmentador por año para análisis interactivo.

El dashboard exportado como imagen se encuentra en:

```text
outputs/dashboard_powerbi.png
```

El archivo `.pbix` puede entregarse dentro del ZIP final si se solicita, pero no se recomienda subirlo al repositorio de GitHub porque puede contener datos importados y pesar demasiado.

## 11. Examen SQL

Las preguntas finales se resolvieron en SQL Server.

Script utilizado:

```sql
sql/06_examen_sql.sql
```

Preguntas respondidas:

1. Top 3 clientes con mayor número de pedidos en el último trimestre disponible.
2. Revenue mensual por categoría de producto.
3. Pedidos cuyo `total_amount_usd` supera 2 desviaciones estándar del promedio.

## 12. Seguridad de la Información - PII

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

Esta parte es opcional respecto al pipeline principal, pero demuestra protección de datos sensibles.

## 13. Consideraciones sobre Git y `.gitignore`

El proyecto incluye un archivo `.gitignore` para evitar subir archivos innecesarios o sensibles.

Archivos excluidos:

- Archivos `.pyc`.
- Carpetas `__pycache__/`.
- Entornos virtuales `venv/` o `.venv/`.
- Archivos CSV raw.
- Archivos `.env`.
- Logs.
- Bases locales.
- Archivos pesados o con datos importados, como `.pbix`, si se decide excluirlos.

## 14. Orden manual de ejecución

En caso de ejecutar manualmente, seguir este orden:

1. Ejecutar `sql/00_setup_database.sql`.
2. Ejecutar `python src/ingesta_raw_sqlserver.py`.
3. Ejecutar `sql/03_limpieza_stage.sql`.
4. Ejecutar `sql/04_tablas_analytics.sql`.
5. Ejecutar `python src/seguridad.py`, si se desea generar la tabla protegida.
6. Ejecutar `sql/06_examen_sql.sql` para las preguntas finales.

## 15. Entregables

El entregable final puede incluir:

- Repositorio GitHub con código, SQL, README y `.gitignore`.
- Archivo ZIP con el proyecto.
- Imagen del dashboard en `outputs/dashboard_powerbi.png`.
- Archivo Power BI `.pbix`, si se solicita en la entrega final.

## 16. Autor

Manolo Marcos Meza Rodriguez
