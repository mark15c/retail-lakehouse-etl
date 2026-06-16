import hashlib
import pandas as pd
from sqlalchemy import create_engine, text
from urllib.parse import quote_plus


# ============================================================
# Configuración de conexión
# ============================================================

SERVER = "DESKTOP-2DJB5PC"
DATABASE = "RetailLakehouse"
DRIVER = "ODBC Driver 17 for SQL Server"


def crear_engine():
    """
    Crea conexión hacia SQL Server usando autenticación de Windows.
    """

    connection_string = (
        f"DRIVER={{{DRIVER}}};"
        f"SERVER={SERVER};"
        f"DATABASE={DATABASE};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )

    connection_url = "mssql+pyodbc:///?odbc_connect=" + quote_plus(connection_string)

    return create_engine(connection_url)


# ============================================================
# Funciones de seguridad
# ============================================================

def hash_sha256(valor):
    """
    Aplica hash SHA-256 a un valor sensible.
    Si el valor es nulo, devuelve None.
    """

    if pd.isna(valor):
        return None

    valor = str(valor).strip().lower()

    return hashlib.sha256(valor.encode("utf-8")).hexdigest()


def mask_last4(valor):
    """
    Enmascara un dato dejando visibles solo los últimos 4 caracteres.
    Ejemplo:
    4999000000000001 -> ****0001
    """

    if pd.isna(valor):
        return None

    valor = str(valor).strip()

    if len(valor) <= 4:
        return "****"

    return "****" + valor[-4:]


def mask_phone(valor):
    """
    Enmascara un teléfono dejando visibles solo los últimos 3 dígitos.
    Ejemplo:
    +51 999888777 -> ****777
    """

    if pd.isna(valor):
        return None

    valor = str(valor).strip()

    if len(valor) <= 3:
        return "****"

    return "****" + valor[-3:]


# ============================================================
# Proceso principal
# ============================================================

def proteger_pii():
    """
    Lee stage.customers, protege columnas PII y crea una tabla segura.
    """

    engine = crear_engine()

    print("Leyendo datos desde stage.customers...")

    customers = pd.read_sql(
        "SELECT * FROM stage.customers",
        engine
    )

    print(f"Filas leídas: {customers.shape[0]}")

    # Aplicar técnicas de protección
    customers["email_hash"] = customers["email"].apply(hash_sha256)
    customers["credit_card_masked"] = customers["credit_card"].apply(mask_last4)
    customers["phone_masked"] = customers["phone"].apply(mask_phone)

    # Creamos una versión segura sin exponer email, phone ni credit_card originales
    customers_seguro = customers[
        [
            "customer_id",
            "first_name",
            "last_name",
            "email_hash",
            "phone_masked",
            "credit_card_masked",
            "age",
            "gender",
            "city",
            "signup_date",
            "fecha_actualizacion"
        ]
    ]

    # Crear schema security si no existe
    with engine.begin() as conn:
        conn.execute(text("""
            IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'security')
            BEGIN
                EXEC('CREATE SCHEMA security');
            END;
        """))

    # Guardar tabla protegida
    customers_seguro.to_sql(
        name="customers_pii_protected",
        con=engine,
        schema="security",
        if_exists="replace",
        index=False
    )

    print("Tabla segura creada correctamente:")
    print("security.customers_pii_protected")


if __name__ == "__main__":
    proteger_pii()