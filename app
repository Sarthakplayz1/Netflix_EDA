import streamlit as st
import pandas as pd
import plotly.express as px
from datasets import load_dataset

# Page config
st.set_page_config(
    page_title="Netflix Dashboard",
    layout="wide"
)

st.markdown("<h1 style='text-align:center;'>Netflix Analytics Dashboard</h1>", unsafe_allow_html=True)

# Load Data
@st.cache_data
def load_data():
    ds = load_dataset("hugginglearners/netflix-shows")
    df = ds["train"].to_pandas()
    df['date_added'] = pd.to_datetime(df['date_added'], errors='coerce')
    df['year_added'] = df['date_added'].dt.year
    return df

df = load_data()

# ---------------- KPI ROW ----------------
col1, col2, col3 = st.columns(3)

col1.metric("Total Titles", len(df))
col2.metric("Movies", len(df[df['type']=="Movie"]))
col3.metric("TV Shows", len(df[df['type']=="TV Show"]))

# ---------------- SECOND ROW ----------------
col4, col5 = st.columns(2)

# Content Growth
year_trend = df['year_added'].value_counts().sort_index()

fig1 = px.line(
    x=year_trend.index,
    y=year_trend.values
)
fig1.update_traces(line_color='#E50914')
fig1.update_layout(
    template="plotly_dark",
    margin=dict(l=10,r=10,t=30,b=10),
    height=350
)

col4.plotly_chart(fig1, use_container_width=True)

# Top Genres
df['listed_in'] = df['listed_in'].fillna('')
df_genre = df.assign(
    genre=df['listed_in'].str.split(', ')
).explode('genre')

top_genres = df_genre['genre'].value_counts().head(5)

fig2 = px.bar(
    x=top_genres.values,
    y=top_genres.index,
    orientation='h'
)
fig2.update_traces(marker_color='#E50914')
fig2.update_layout(
    template="plotly_dark",
    margin=dict(l=10,r=10,t=30,b=10),
    height=350
)

col5.plotly_chart(fig2, use_container_width=True)

# ---------------- THIRD ROW ----------------
col6, col7 = st.columns(2)

# Runtime Distribution
df_movies = df[df['type']=="Movie"].copy()
df_movies['duration'] = df_movies['duration'].str.replace(' min','', regex=False)
df_movies['duration'] = pd.to_numeric(df_movies['duration'], errors='coerce')

fig3 = px.histogram(
    df_movies,
    x='duration',
    nbins=25
)
fig3.update_traces(marker_color='#E50914')
fig3.update_layout(
    template="plotly_dark",
    margin=dict(l=10,r=10,t=30,b=10),
    height=350
)

col6.plotly_chart(fig3, use_container_width=True)

# Top Countries
df['country'] = df['country'].fillna('')
df_country = df.assign(
    country_split=df['country'].str.split(', ')
).explode('country_split')

top_countries = df_country['country_split'].value_counts().head(5)

fig4 = px.bar(
    x=top_countries.index,
    y=top_countries.values
)
fig4.update_traces(marker_color='#E50914')
fig4.update_layout(
    template="plotly_dark",
    margin=dict(l=10,r=10,t=30,b=10),
    height=350
)

col7.plotly_chart(fig4, use_container_width=True)

st.markdown("<div style='text-align:center;'>Built by Sarthak 🚀</div>", unsafe_allow_html=True)