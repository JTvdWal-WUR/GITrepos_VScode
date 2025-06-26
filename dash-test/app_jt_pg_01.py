# 20220909, Jan Tjalling van der Wal
# Amongst others based on https://www.cdata.com/kb/tech/postgresql-python-dash.rst
# But with the Ibis-approach to access PostgreSQl as hinted at here:
# https://dash.plotly.com/dash-enterprise/database-connections at the end of bullet point no. 6

# Aim: connect to Postgres, load some useful data, make a visual and present it with DASH.

import config
import psycopg2
import dash
import pandas as pd
import sqlalchemy as sa
# import ibis
import plotly.graph_objs as go
# import dash_core_components as dcc  # deprecated
# import dash_html_components as html  # deprecated
from dash import dcc
from dash import html

def print_config():
    print(f"{config.DashMytilusTestconfig}")


external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
app.title = 'PostgreSQL-sources DynaMOS-data'

host = config.DashMytilusTestconfig['PGSQLserver']
user = config.DashMytilusTestconfig['PGSQLuser']
password = config.DashMytilusTestconfig['PGSQLpass']
database = config.DashMytilusTestconfig['PGSQLdatabase']
port = config.DashMytilusTestconfig['PGSQLport']
schema = 'poc_mossels'

# print(f" {host}: {port}: {database}: {user}: secret-password")

# ibis.options.interactive = True

# con = ibis.postgres.connect(
#     database=database,
#     host=host, 
#     user=user,
#     password=password 
#     )
# con = ibis.BaseBackend.do_connect(self, host=host, user=user, password=password, port=port, database=database, url=None, driver='psycopg2')
# con.list_tables()

# db_list = con.list_databases()
# print(db_list)
# schema_list = con.list_schemas()
# print(schema_list)
# table_list = con.list_tables('otetrapoda.poc_mossels')
# print(table_list)
# t= con.table('otetrapoda.poc_mossels.groei_data')
# print(t)
# print(con.db_identity)
sql_string = 'select sys, jaar, comp, locatie, visgew, overleving, lon, lat, crs, hex_code from poc_mossels.groei_data;'

alchemyEngine = sa.create_engine(f'postgresql+psycopg2://{user}:{password}@{host}:{port}/{database}')
checked_sql = sa.text(sql_string)
connection = alchemyEngine.connect()
df = pd.read_sql(checked_sql, connection)

# df = pd.read_sql(sql_string, con)
# print(df.head())


trace = go.Bar(x=df.jaar, y=df.overleving, name='Overleving %')

app.layout = html.Div(children=[html.H1("Postgres 2 Dash: M.edulis - Survival", style={'textAlign': 'center'}),
    dcc.Graph(
        id='MYTIEDUL_survival',
        figure= {
            'data': [trace],
            'layout':
            go.Layout(title='M.edulis - Survival %', barmode='stack')
        })
        ], className='container')

if __name__ == '__main__':
    app.run_server(debug=True)