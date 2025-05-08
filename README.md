# Music Genre Recommender DB
Projet final du cours CS50 SQL

---

## 🎯 Objectif du projet

Ce projet est né d'un besoin personnel que beaucoup de personnes partagent : on tombe souvent amoureux d'un genre musical, mais il est fastidieux d'explorer toutes les discographies d'un artiste pour retrouver les morceaux qui correspondent vraiment à ce style. En tant qu'amateur de métal alternatif, j'ai souvent été confronté à ce problème. Tous les titres d'un artiste métal ou rock ne sont pas forcément dans ce sous-genre précis, d'où l'idée de créer une base de données relationnelle permettant de retrouver facilement les morceaux correspondant à un genre donné, et bien plus encore.

---

## 📦 Portée du projet

Cette base de données permet :
- D'afficher tous les morceaux d'un genre spécifique (ex : metal alternatif)
- D'explorer les morceaux d'un artiste
- De combiner des critères (ex : morceaux metalcore + plus de 3 minutes + appartenant à un album d'un artiste précis)

Le projet se concentre sur un ensemble manuel d'artistes metal/rock connus, afin d'avoir un ensemble cohérent et pertinent pour ce type d'exploration musicale.

---

## 🧠 Choix techniques et architecture

### Système de gestion de base de données : SQLite

Le système SQLite a été retenu pour sa légèreté, sa simplicité de déploiement (aucun serveur requis), et sa compatibilité avec les outils pédagogiques tels que SQLiteStudio. Il permet de regrouper l’ensemble des données dans un fichier unique, ce qui facilite la portabilité, la sauvegarde et l’analyse. Malgré sa simplicité apparente, SQLite prend en charge des fonctionnalités avancées comme les clés étrangères, les vues, et les index, qui ont été exploitées dans ce projet.

### Sources de données : APIs Spotify et Last.fm

Le projet repose sur deux APIs complémentaires :

- **Spotify Web API** a été utilisée pour récupérer les informations de base : artistes, albums, morceaux, durées, etc. Toutefois, Spotify n’associe pas directement les genres aux titres, mais uniquement aux artistes.
- **Last.fm API** a donc été intégrée en complément, car elle permet d’associer des *tags* (souvent assimilés à des genres) à chaque morceau individuellement. Ce comportement est particulièrement pertinent dans le cadre du projet, car un même artiste peut explorer différents styles au sein de sa discographie. Grâce à Last.fm, chaque chanson bénéficie d’une identification plus fine de ses caractéristiques stylistiques.

### Format des données et importation

Les données extraites via API ont été stockées dans des fichiers `.csv` afin d'assurer la traçabilité, la reproductibilité du traitement, et la clarté de l'importation. Ces fichiers ont ensuite été chargés dans SQLite pour constituer les différentes tables.

### Conception relationnelle et structure

La base a été conçue selon les principes de la normalisation relationnelle. Les entités principales :

- `artists` : les artistes musicaux  
- `albums` : les albums publiés  
- `songs` : les chansons avec durée et lien vers album  
- `genres` : liste des genres  
- `song_genre` : table de liaison entre chansons et genres  

ont été séparées dans des tables distinctes afin de limiter la redondance. Une table de liaison `song_genre` a été mise en place pour modéliser la relation many-to-many entre les morceaux et les genres. Cette architecture permet une grande souplesse dans les requêtes analytiques.

---

## ⚙️ Optimisations

Des **index** ont été créés sur les champs les plus sollicités par les requêtes (`songs.name`, `artists.name`, `genres.name`, `songs.duration_ms`) afin de garantir des performances satisfaisantes, même en cas de montée en volume.

Des **vues** ont également été définies pour simplifier les requêtes fréquentes et offrir une meilleure lisibilité lors des analyses (par exemple, conversion de la durée des morceaux en minutes).

---

## 🔧 Diagramme entité-relation (ER) — Mermaid

```mermaid
erDiagram
    ARTISTS ||--o{ ALBUMS : has
    ALBUMS ||--o{ SONGS : contains
    SONGS ||--o{ SONG_GENRE : categorized
    GENRES ||--o{ SONG_GENRE : includes

    ARTISTS {
        TEXT id PK
        TEXT name
    }

    ALBUMS {
        TEXT id PK
        TEXT name
        TEXT release_date
        TEXT artist_id FK
    }

    SONGS {
        TEXT id PK
        TEXT name
        TEXT album_id FK
        INTEGER duration_ms
    }

    GENRES {
        INTEGER id PK
        TEXT name
    }

    SONG_GENRE {
        TEXT song_id FK
        INTEGER genre_id FK
    }
