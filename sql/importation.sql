-- Exercice 2
--
-- Q1
DROP TABLE IF EXISTS import_athletes;

-- L'option "if not exists" permet de ne pas recréer la table si elle existe déjà.
CREATE TABLE  import_athletes(
    id int,
    name varchar(500),
    sex char(1), -- on aurait pu ajouter une contrainte check ici, mais on a décidé de le faire uniquement dans la table ventilée asociée
    age int,
    height int,
    weight numeric(5, 2),
    team varchar(50),
    noc varchar(25),
    games varchar(25),
    year int,
    season varchar(10),
    city varchar(25),
    sport varchar(25),
    event varchar(150),
    medal varchar(15)
);

-- Q2
-- On importe les données du CSV dans la table import_athletes avec quelques options:
--  On précise le format CSV:
--      - Le paramètre 'header' permet de ne pas copier la première ligne du CSV (ligne des colonnes)
--      - Le paramètre 'quote' permet de prendre en considération les guillemets dans chaque colonne dans les lignes du CSV, utile pour interpréter l'id comme un entier
--      - Le paramètre 'delimiter' détermine avec quel caractère on délimite chaque colonne
--      - Le paramètre 'null as' permet de prendre en charge les valeurs nulles pour éviter les problèmes de type (ici representé par 'NA')
\copy import_athletes from 'csv/athlete_events.csv' with csv header quote '"' delimiter ',' null as 'NA';

-- Q3
DELETE FROM import_athletes
WHERE year < 1920
    OR sport = 'Art Competitions';

-- Q4
DROP TABLE IF EXISTS import_noc;

CREATE TABLE IF NOT EXISTS import_noc(
    noc char(3),
    region varchar(50),
    notes varchar(50)
);

\copy import_noc from 'csv/noc_regions.csv' with csv header delimiter ',' null as 'NA';

-- Ajout des pays manquants dans 'import_noc'
INSERT INTO import_noc SELECT DISTINCT
    a.noc,
    NULL AS region,
    NULL AS notes
FROM
    import_athletes AS a
WHERE
    a.noc NOT IN (
        SELECT n2.noc
        FROM
            import_noc AS n2);

-- ----------------------------
-- Exercice 4
--
-- Q3
-- On ventile les données des 2 tables créé au-dessus, en suivant le MLD fourni dans le rapport en Markdown.

-----------------

-- Region
--
DROP TABLE IF EXISTS Region CASCADE;

CREATE TABLE Region(noc, nom_pays, notes) AS
SELECT
    noc,
    region,
    notes
FROM
    import_noc;

-- Modification de la table 'Region' en y ajoutant une contrainte d'unicité (clé primaire) pointant vers la colonne noc
ALTER TABLE Region
    ADD CONSTRAINT pk_region PRIMARY KEY (noc);

-----------------

-- Equipe
--
DROP TABLE IF EXISTS Equipe CASCADE;

CREATE TABLE Equipe(nom_equipe, noc, nom_pays) AS
SELECT DISTINCT ON (a.team) -- La syntaxe 'distinct on (colonne) colonne' permet de supprimer les doublons d'une seule colonne
    a.team,
    n.noc,
    n.region
FROM
    import_athletes AS a,
    import_noc AS n
WHERE
    a.noc = n.noc;

ALTER TABLE Equipe
    ADD CONSTRAINT pk_equipe PRIMARY KEY (nom_equipe);

ALTER TABLE Equipe
    ADD CONSTRAINT fk_equipe FOREIGN KEY (noc) REFERENCES Region(noc);

-----------------

-- Edition
--
DROP TABLE IF EXISTS Edition CASCADE;

CREATE TABLE Edition(annee, saison) AS
SELECT DISTINCT ON (year, season)
    year,
    season,
    city
FROM
    import_athletes;

ALTER TABLE Edition
    ADD CONSTRAINT pk_edition PRIMARY KEY (annee, saison);

-- Dans le CSV, nous remarquons qu'il n'y a que 2 saisons possibles ('Winter', 'Summer'), on créé donc une contrainte 'check' pour vérifier lors de l'édition de la colonne saison d'une des lignes de la table, si elle est dans l'ensemble ('Winter', 'Summer')
ALTER TABLE Edition
    ADD CONSTRAINT check_saison CHECK (saison IN ('Winter', 'Summer'));

-----------------

-- Athlete
--
-- Pour vérifier que la requête supprime bien tous les doublons, on peut se référer au fichier 'requetes.sql' à la question 4, on devait compter le nombre d'athlètes différents dans la base. Le nombre doit être donc le même dans la table 'Athlete'
DROP TABLE IF EXISTS Athlete CASCADE;

CREATE TABLE Athlete(ano, nom, sexe, age, taille, poids, equipe) AS
SELECT DISTINCT ON (t1.id) -- On supprime les doublons de la colonne id pour arriver au même nobmre d'athlètes que dans la requête renseignée dans 'requetes.sql'
    t1.id,
    t1.name,
    t1.sex,
    t1.age,
    t1.height,
    t1.weight,
    t1.team
FROM
    import_athletes AS t1;

ALTER TABLE Athlete
    ADD CONSTRAINT pk_athlete PRIMARY KEY (ano);

-- On considère que les 2 genres possibles sont le genre masculin et féminin, on restreint donc cela avec une contrainte 'check' sur le sexe
ALTER TABLE Athlete
    ADD CONSTRAINT check_sexe CHECK (sexe IN ('M', 'F'));

ALTER TABLE Athlete
    ADD CONSTRAINT fk_equipe FOREIGN KEY (equipe) REFERENCES Equipe(nom_equipe);

-----------------

-- Epreuve
--
DROP TABLE IF EXISTS Epreuve CASCADE;

-- Déclaration d'une fonction permettant d'extraire le genre d'un évenement donné
-- On décompose l'évenement en 3 parties pour plus de flexiblité, modélisé par 3 colonnes:
-- (le nom de l'evenement,
--  le genre associé à l'épreuve (Masculin ou Féminin), 
--  le sport associé à l'évenenement)
CREATE OR REPLACE FUNCTION extract_genre_event(event text)
    RETURNS text -- Type de retour de la focntion
    AS $$ -- est un délimiteur pour écrire à la suite une requête SQL sans passer par les guillemets et utile pour écrire sur plusieurs lignes plus facilement
    SELECT
        -- Utilisation de la structure conditionnelle case pour vérifier quel genre retourner avec le nom en entier selon les 3 premières lettres de la chaîne de caractères
        CASE WHEN substring(event, 1, 3) = 'Men' THEN
            'Men''s'
        WHEN substring(event, 1, 3) = 'Wom' THEN
            'Women''s'
        ELSE
            'Mixed'
        END
$$
LANGUAGE sql; -- On renseigne à PostgreSQL que le langage utilisé est le SQL standard

CREATE TABLE Epreuve(evenement, genre, nom_sport) AS
SELECT DISTINCT
    -- On appelle trim() à nouveau du au 1er replace()
    trim(
        -- On cast explicitement la fonction en varchar(150) car la fonction retourne une chaîne de type text (retourner un varchar(150) dans la fonction extract_genre_event() ne fonctionne pas)
        cast(
            -- On supprime le genre de l'evenement
            replace(
                -- On supprime le sport de l'evenement
                overlay(a.event placing '' from 1 for length(a.sport)),
                -- On supprime les espaces autour avec trim() après du à l'éxecution de la fonction replace
                extract_genre_event(trim(overlay(a.event placing '' from 1 for length(a.sport)))),
                ''
            )
            AS varchar(150)
    )) AS evenement,

    -- On vérifie si le genre est 'Mixed' pour ne pas appeler left(), fonction qui permettra de supprimer les 2 derniers caractères de 'Men''s' et 'Women''s', on ne veut pas ça pour 'Mixed' sinon il renverra 'Mix'
    cast(
            CASE extract_genre_event(trim(overlay(a.event placing '' from 1 for length(a.sport))))
                -- Si le genre est 'Mixed', on retourne le genre tel qu'il est actuellement
                WHEN 'Mixed' THEN extract_genre_event(trim(overlay(a.event placing '' from 1 for length(a.sport))))
                ELSE LEFT ( extract_genre_event(trim(overlay(a.event placing '' from 1 for length(a.sport)))),
                            -- On prend toute la taille de la chaine moins les 2 dernieres pour s'arrêter avant ces 2 derniers caractères
                            length(extract_genre_event(trim(overlay(a.event placing '' from 1 for length(a.sport))))) - 2)
        END AS varchar(10)) AS genre,
    a.sport
FROM
    import_athletes AS a;

ALTER TABLE Epreuve
    ADD CONSTRAINT pk_epreuve PRIMARY KEY (evenement, genre, nom_sport);

-----------------

-- participe
--
DROP TABLE IF EXISTS participe CASCADE;

CREATE TABLE IF NOT EXISTS participe(ano, evenement, genre, nom_sport, annee, saison, medaille)
    AS SELECT id, e.evenement, e.genre, e.nom_sport, year, season, medal
        FROM import_athletes, epreuve as e
        WHERE event = e.nom_sport || ' ' || CASE e.genre
                WHEN 'Men' then 'Men''s'
                WHEN 'Women' then 'Women''s'
                ELSE 'Mixed'
            END || ' ' || case
                WHEN e.evenement = '' then e.nom_sport
                ELSE e.evenement end;

ALTER TABLE participe ADD CONSTRAINT pk_participe PRIMARY KEY(ano, evenement, genre, nom_sport, annee, saison);
ALTER TABLE participe ADD CONSTRAINT fk_athlete FOREIGN KEY(ano) references Athlete(ano);
ALTER TABLE participe ADD CONSTRAINT fk_epreuve FOREIGN KEY(evenement, genre, nom_sport) references Epreuve(evenement, genre, nom_sport);
ALTER TABLE participe ADD CONSTRAINT fk_edition FOREIGN KEY(annee, saison) references Edition(annee, saison);