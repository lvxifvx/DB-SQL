import os
import csv
import time
import requests
import pandas as pd
from spotipy import Spotify
from spotipy.oauth2 import SpotifyClientCredentials

# Clés API
SPOTIFY_CLIENT_ID = "35f4499afc49491b915887eb03c663e8"
SPOTIFY_CLIENT_SECRET = "0ae95de62141463c910cbcaaed311d43"
LASTFM_API_KEY = "23ae0a5f0017650e8ca16c03f24d72d1"

# Initialiser l'API Spotify
sp = Spotify(auth_manager=SpotifyClientCredentials(
    client_id=SPOTIFY_CLIENT_ID,
    client_secret=SPOTIFY_CLIENT_SECRET
))

# Artistes à rechercher
ARTISTS = [
    "Bring Me The Horizon", "Bad Omens", "Slipknot", "Poppy", "Nirvana",
    "Spiritbox", "Linkin Park", "Falling in Reverse", "Sleep Token",
    "Motionless In White", "Architects", "YUNGBLUD", "System Of A Down", 
    "Evanescence"
]

# Initialisation
songs, albums, artists, genres = [], {}, {}, {}
song_genre_links = []

def get_lastfm_tags(track_name, artist_name):
    url = "http://ws.audioscrobbler.com/2.0/"
    params = {
        "method": "track.gettoptags",
        "artist": artist_name,
        "track": track_name,
        "api_key": LASTFM_API_KEY,
        "format": "json"
    }
    try:
        r = requests.get(url, params=params)
        data = r.json()
        tags = [tag["name"].lower() for tag in data.get("toptags", {}).get("tag", [])[:3]]
        return tags
    except:
        return []

for artist_name in ARTISTS:
    results = sp.search(q=f"artist:{artist_name}", type="artist", limit=1)
    if not results["artists"]["items"]:
        continue
    artist = results["artists"]["items"][0]
    artist_id = artist["id"]
    artists[artist_id] = artist["name"]

    albums_result = sp.artist_albums(artist_id, album_type="album", limit=3)
    for album in albums_result["items"]:
        album_id = album["id"]
        albums[album_id] = {
            "name": album["name"],
            "release_date": album["release_date"],
            "artist_id": artist_id
        }
        tracks = sp.album_tracks(album_id)
        for track in tracks["items"]:
            track_id = track["id"]
            track_name = track["name"]
            duration = track["duration_ms"]
            songs.append({
                "id": track_id,
                "name": track_name,
                "album_id": album_id,
                "duration_ms": duration
            })
            tags = get_lastfm_tags(track_name, artist["name"])
            for tag in tags:
                if tag not in genres:
                    genres[tag] = len(genres) + 1
                song_genre_links.append({
                    "song_id": track_id,
                    "genre_id": genres[tag]
                })
            time.sleep(0.2)

# Écriture des fichiers CSV
os.makedirs("data", exist_ok=True)

pd.DataFrame(songs).to_csv("data/songs.csv", index=False)
pd.DataFrame([{"id": k, "name": v} for k, v in artists.items()]).to_csv("data/artists.csv", index=False)
pd.DataFrame([{"id": k, **v} for k, v in albums.items()]).to_csv("data/albums.csv", index=False)
pd.DataFrame([{"id": v, "name": k} for k, v in genres.items()]).to_csv("data/genres.csv", index=False)
pd.DataFrame(song_genre_links).to_csv("data/song_genre.csv", index=False)

print("✅ Données exportées avec succès dans le dossier /data")
