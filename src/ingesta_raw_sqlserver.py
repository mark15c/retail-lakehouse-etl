import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine
from urllib.parse import quote_plus


BASE_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = BASE_DIR / "data" / "raw"

SERVER = "DESKTOP-2DJB5PC"
DATABASE = "RetailLakehouse"
DRIVER = "ODBC Driver 17 for SQL Server"


connection_string = (
    f"DRIVER={{{DRIVER}}};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

connection_url = "mssql+pyodbc:///?odbc_connect=" + quote_plus(connection_string)

engine = create_engine(connection_url)


customers = pd.read_csv(RAW_DIR / "customers.csv", dtype=str)
products = pd.read_csv(RAW_DIR / "products.csv", dtype=str)
orders = pd.read_csv(RAW_DIR / "orders.csv", dtype=str)


customers.to_sql("customers", engine, schema="raw", if_exists="replace", index=False)
products.to_sql("products", engine, schema="raw", if_exists="replace", index=False)
orders.to_sql("orders", engine, schema="raw", if_exists="replace", index=False)


print("Carga RAW completada correctamente.")
print("Tablas creadas:")
print("raw.customers")
print("raw.products")
print("raw.orders")