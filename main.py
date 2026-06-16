import subprocess
import sys
from pathlib import Path
from urllib.parse import quote_plus

import pyodbc


# ============================================================
# Configuración principal
# ============================================================

BASE_DIR = Path(__file__).resolve().parent

SERVER = "DESKTOP-2DJB5PC"
DATABASE = "RetailLakehouse"
DRIVER = "ODBC Driver 17 for SQL Server"


# ============================================================
# Conexión a SQL Server
# ============================================================

def obtener_conexion(database: str = "master"):
    """
    Crea una conexión a SQL Server.
    Por defecto se conecta a master para poder crear la base RetailLakehouse.
    """
    connection_string = (
        f"DRIVER={{{DRIVER}}};"
        f"SERVER={SERVER};"
        f"DATABASE={database};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

    return pyodbc.connect(connection_string, autocommit=True)


# ============================================================
# Ejecutar archivos SQL
# ============================================================

def ejecutar_sql_file(ruta_sql: Path):
    """
    Ejecuta un archivo SQL en SQL Server.

    Como los scripts de SQL Server usan GO, separamos el archivo
    por bloques antes de ejecutarlo.
    """
    print(f"\nEjecutando script SQL: {ruta_sql.name}")

    if not ruta_sql.exists():
        raise FileNotFoundError(f"No se encontró el archivo SQL: {ruta_sql}")

    contenido = ruta_sql.read_text(encoding="utf-8")

    bloques = []
    bloque_actual = []

    for linea in contenido.splitlines():
        if linea.strip().upper() == "GO":
            if bloque_actual:
                bloques.append("\n".join(bloque_actual))
                bloque_actual = []
        else:
            bloque_actual.append(linea)

    if bloque_actual:
        bloques.append("\n".join(bloque_actual))

    conn = obtener_conexion("master")
    cursor = conn.cursor()

    for bloque in bloques:
        if bloque.strip():
            cursor.execute(bloque)

    cursor.close()
    conn.close()

    print(f"Script completado: {ruta_sql.name}")


# ============================================================
# Ejecutar scripts Python
# ============================================================

def ejecutar_python(ruta_script: Path):
    """
    Ejecuta un script Python usando el mismo intérprete actual.
    """
    print(f"\nEjecutando script Python: {ruta_script.name}")

    if not ruta_script.exists():
        raise FileNotFoundError(f"No se encontró el script Python: {ruta_script}")

    resultado = subprocess.run(
        [sys.executable, str(ruta_script)],
        cwd=BASE_DIR
    )

    if resultado.returncode != 0:
        raise RuntimeError(f"Error ejecutando: {ruta_script.name}")

    print(f"Script completado: {ruta_script.name}")


# ============================================================
# Pipeline principal
# ============================================================

def main():
    print("=" * 70)
    print("INICIANDO PIPELINE ETL - RETAIL LAKEHOUSE")
    print("=" * 70)

    # 1. Crear base de datos y schemas
    ejecutar_sql_file(BASE_DIR / "sql" / "00_setup_database.sql")

    # 2. Ingesta RAW
    ejecutar_python(BASE_DIR / "src" / "ingesta_raw_sqlserver.py")

    # 3. Limpieza STAGE
    ejecutar_sql_file(BASE_DIR / "sql" / "03_limpieza_stage.sql")

    # 4. Creación de tablas ANALYTICS
    ejecutar_sql_file(BASE_DIR / "sql" / "04_tablas_analytics.sql")

    print("\n" + "=" * 70)
    print("PIPELINE EJECUTADO CORRECTAMENTE")
    print("=" * 70)
    print("Tablas generadas:")
    print("- raw.customers, raw.products, raw.orders")
    print("- stage.customers, stage.products, stage.orders")
    print("- analytics.dim_cliente, analytics.fact_cliente")
    print("- analytics.dim_producto, analytics.fact_producto")


if __name__ == "__main__":
    main()