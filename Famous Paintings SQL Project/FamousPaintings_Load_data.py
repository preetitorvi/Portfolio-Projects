import pandas as pd
from sqlalchemy import create_engine
import psycopg2
conn_string = 'postgresql://postgres:Chidambar6*@localhost/paintings'
db = create_engine(conn_string)
conn = db.connect()

files = ['artist', 'canvas_size', 'image_link','museum_hours', 'museum','product_size','subject','work']

for file in files:
    df = pd.read_csv(f'/Users/preetiku/Documents/Famous Paintings SQL Project/{file}.csv')
    df.to_sql(file, con = conn, if_exists = 'replace', index=False)

