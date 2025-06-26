# 20220909, Jan Tjalling van der Wal
# Amongst others based on https://www.cdata.com/kb/tech/postgresql-python-dash.rst
# But with the Ibis-approach to access PostgreSQl as hinted at here:
# https://dash.plotly.com/dash-enterprise/database-connections at the end of bullet point no. 6

# Aim: connect to Postgres, load some useful data, make a visual and present it with DASH.
# This visual is to become a bubble map with colours as specified in hex_code.

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
import numpy as np

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)
app.title = 'PostgreSQL-sources DynaMOS-data'

host = config.DashMytilusTestconfig['PGSQLserver']
user = config.DashMytilusTestconfig['PGSQLuser']
password = config.DashMytilusTestconfig['PGSQLpass']
database = config.DashMytilusTestconfig['PGSQLdatabase']
port = config.DashMytilusTestconfig['PGSQLport']
schema = 'poc_mossels'


sql_string = 'select sys, jaar, comp, locatie, visgew, overleving, lon, lat, crs, hex_code from poc_mossels.groei_data;'

alchemyEngine = sa.create_engine(f'postgresql+psycopg2://{user}:{password}@{host}:{port}/{database}')
checked_sql = sa.text(sql_string)
connection = alchemyEngine.connect()
df = pd.read_sql(checked_sql, connection)
df['ISO3']='NED'
# df['overleving']=df['overleving'].replace('NA', np.nan)
# df['visgew']=df['visgew'].replace('NA', np.nan)
# df = df.astype({'visgew': 'float', 'overleving': 'float'})
df['overleving'] = pd.to_numeric(df['overleving'], errors='coerce')
df['visgew'] = pd.to_numeric(df['visgew'], errors='coerce')
# Data for plotting on a map needs to be numeric (not string, error in the database or possibly in the original data)
df = df[df['visgew'] >0 ]
# trace = go.Bar(x=df.jaar, y=df.overleving, name='Overleving %')

fig = go.Figure()

# https://plotly.com/python/bubble-maps/ recommends calculating a sizeref for the marker
# sizeref = 2. * max(array_of_size_values)/(desired_maximum_marker_size **2)
# Note that setting sizeref > $1$ decreases the rendered maker sizes ....
sizeref = 2. * df['visgew'].max()/(12**2)

fig.add_traces(go.Scattergeo(
    locationmode='ISO-3',
    lon = df['lon'],
    lat= df['lat'],
    text= df['locatie'],
    marker= dict(
        size = df['visgew']*5, # /sizeref,
        color = df['hex_code'],
        line_color='rgb(40,40,40)',
        line_width=0.5,
        sizemode='area'
    ),        
    name = 'kaart')
)

fig.update_layout(
    title_text = 'Recent years of Mussel Growth in Eastern Scheldt and Wadden Sea (click legend to toggle traces)',
    showlegend = True,
    geo = dict(
        scope = 'europe',
        landcolor = 'rgb(271,271,271)',
    )
)

# <PLOTLY output, not for DASH>
# fig.show()  # Result also turns up in a browser (127.0.0.1:<port>)
# </PLOTLY output, not for DASH>

app.layout = html.Div([
    dcc.Graph(figure=fig)
])

if __name__ == '__main__':
    app.run_server(debug=True)
    # app shows in browser (127.0.0.1:8050) (could be another port number on other machines or days).
    # The terminal window of Visual Studio Code shows this information:
    # Dash is running on http://127.0.0.1:8050/