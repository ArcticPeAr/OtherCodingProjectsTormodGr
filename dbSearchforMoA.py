 
import sqlite3
import pandas as pd
# Connect to database
conn = sqlite3.connect('/home/petear/nonMegaFiles/chembl_33/chembl_33_sqlite/chembl_33.db')
table_name = 'component_synonyms'

df = pd.read_sql_query(f'SELECT * FROM {table_name}', conn)

df.to_excel('component_synonyms.xlsx', index=False)