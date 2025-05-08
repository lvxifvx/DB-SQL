-- ============================================
-- Projet CS50 SQL — Recommandation musicale
-- ============================================

-- ============================================
-- Table des artistes
-- ============================================
CREATE TABLE artists (
    id TEXT PRIMARY KEY,
    name TEXT
);

-- ============================================
-- Table des albums
-- ============================================
CREATE TABLE albums (
    id TEXT PRIMARY KEY,
    name TEXT,
    release_date TEXT,
    artist_id TEXT REFERENCES artists(id)
);

-- ============================================
-- Table des chansons
-- ============================================
CREATE TABLE songs (
    id TEXT PRIMARY KEY,
    name TEXT,
    album_id TEXT REFERENCES albums(id),
    duration_ms INTEGER
);

-- ============================================
-- Table des genres
-- ============================================
CREATE TABLE genres (
    id INTEGER PRIMARY KEY,
    name TEXT
);

-- ============================================
-- Table de liaison song_genre
-- (relation many-to-many)
-- ============================================
CREATE TABLE song_genre (
    song_id TEXT REFERENCES songs(id),
    genre_id INTEGER REFERENCES genres(id)
);

-- ============================================
-- Index pour optimiser les requêtes
-- ============================================
CREATE INDEX idx_artist_name ON artists(name);
CREATE INDEX idx_song_name ON songs(name);
CREATE INDEX idx_genre_name ON genres(name);
CREATE INDEX idx_song_duration ON songs(duration_ms);

-- ============================================
-- Vue : chanson avec son genre, artiste et album
-- ============================================
CREATE VIEW song_with_genres AS
SELECT 
    ar.name AS artist,
    a.name AS album,
    s.name AS song,
    g.name AS genre
FROM songs s
JOIN albums a ON s.album_id = a.id
JOIN artists ar ON a.artist_id = ar.id
JOIN song_genre sg ON s.id = sg.song_id
JOIN genres g ON sg.genre_id = g.id;

-- ============================================
-- Vue : chanson avec durée en minutes
-- ============================================
CREATE VIEW song_duration_readable AS
SELECT
    ar.name AS artist,
    a.name AS album,
    s.name AS song,
    ROUND(s.duration_ms / 60000.0, 2) AS duration_minutes
FROM songs s
JOIN albums a ON s.album_id = a.id
JOIN artists ar ON a.artist_id = ar.id;