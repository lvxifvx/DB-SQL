-- Récupérer tous les sons de métal alternatif présents dans la DB --
SELECT 
    s.name AS song,
    ar.name AS artist,
    a.name AS album
FROM songs s
JOIN song_genre sg ON s.id = sg.song_id
JOIN genres g ON sg.genre_id = g.id
JOIN albums a ON s.album_id = a.id
JOIN artists ar ON a.artist_id = ar.id
WHERE g.name = 'alternative metal';


-- Récupérer tous les sons rock de Falling In Reverse --
SELECT 
    s.name AS song,
    a.name AS album,
    ar.name AS artist
FROM songs s
JOIN song_genre sg ON s.id = sg.song_id
JOIN genres g ON sg.genre_id = g.id
JOIN albums a ON s.album_id = a.id
JOIN artists ar ON a.artist_id = ar.id
WHERE g.name = 'rock' 
AND ar.name = 'Falling In Reverse';


-- Récupérer tous les sons de Spiritbox --
SELECT s.name AS song, a.name AS album
FROM songs s
JOIN albums a ON s.album_id = a.id
JOIN artists ar ON a.artist_id = ar.id
WHERE ar.name = 'Spiritbox';


-- Lister les chansons de plus de 3 minutes 20 secondes (200000 ms) --
-- en remplaçant la colonne en ms par une colonne avec la durée en minutes pour une meilleure lisibilité --
SELECT 
    s.name AS song,
    ar.name AS artist,
    ROUND(s.duration_ms / 60000.0, 2) AS duration_minutes
FROM songs s
JOIN albums a ON s.album_id = a.id
JOIN artists ar ON a.artist_id = ar.id
WHERE s.duration_ms > 200000;


-- Trouver tous les genres associés à une chanson donnée --
SELECT s.name AS song, g.name AS genre
FROM songs s
JOIN song_genre sg ON s.id = sg.song_id
JOIN genres g ON sg.genre_id = g.id
WHERE LOWER(s.name) = 'just pretend';


-- Compter combien de morceaux sont associés à chaque genre --
SELECT g.name AS genre, COUNT(*) AS total_songs
FROM song_genre sg
JOIN genres g ON sg.genre_id = g.id
GROUP BY g.id
ORDER BY total_songs DESC;


-- Récupérer les artistes qui ont AU MINIMUM 3 SONS À LA FOIS ROCK & METAL
SELECT ar.name AS artist
FROM artists ar
JOIN albums a ON ar.id = a.artist_id
JOIN songs s ON s.album_id = a.id
WHERE s.id IN (
    SELECT sg1.song_id
    FROM song_genre sg1
    JOIN genres g1 ON sg1.genre_id = g1.id
    WHERE g1.name = 'rock'
    INTERSECT
    SELECT sg2.song_id
    FROM song_genre sg2
    JOIN genres g2 ON sg2.genre_id = g2.id
    WHERE g2.name = 'metal'
)
GROUP BY ar.id
HAVING COUNT(DISTINCT s.id) >= 3;


-- Mettre à jour le nom d’un genre mal orthographié --
UPDATE genres
SET name = 'metalcore'
WHERE name = 'metal core';


-- Supprimer un genre qui n'a rien à faire dans la database --
DELETE FROM genres
WHERE name = 'intro';