-- Exercice 3
--

-- Q1
-- Output: 15
SELECT count(*)
FROM information_schema.columns
WHERE
    table_schema = USER
    AND table_name = 'import_athletes';

-- Q2
-- Output: 255080
SELECT count(*)
FROM import_athletes;

-- Q3
-- Output: 231 (avec l'ajout de Singapour)
SELECT count(noc)
FROM import_noc;

-- Q4
-- Output: 127575
SELECT count(DISTINCT id)
FROM import_athletes;

-- Q5
-- Output: 12116
SELECT count(medal)
FROM import_athletes
WHERE medal = 'Gold';

-- Q6
-- Output: 2
SELECT count(*)
FROM import_athletes
WHERE name LIKE 'Carl Lewis%';

-- Exercice 5
--

-- Q1
SELECT
    r.nom_pays,
    count(*) AS nb_participations
FROM
    participe AS p,
    region AS r
WHERE
    r.noc = p.noc
    AND p.nom_equipe = r.nom_equipe
GROUP BY r.nom_pays
ORDER BY count(*) DESC;

-- Q2
SELECT
    r.nom_pays,
    count(p.medaille) AS nb_medailles_Or
FROM
    participe AS p,
    region AS r
WHERE
    p.medaille = 'Gold'
    AND p.noc = r.noc
    AND p.nom_equipe = r.nom_equipe
GROUP BY r.nom_pays
ORDER BY count(p.medaille) DESC;

-- Q3
SELECT
    r.nom_pays,
    count(p.medaille) AS nb_medailles_pays
FROM
    participe AS p,
    region AS r
WHERE
    p.medaille IS NOT NULL
    AND p.noc = r.noc
    AND p.nom_equipe = r.nom_equipe
GROUP BY r.nom_pays
ORDER BY count(p.medaille) DESC;

-- Q4
SELECT
    a.ano,
    a.nom,
    count(p.medaille) AS nb_medailles_Or
FROM
    athlete AS a
    JOIN participe AS p ON a.ano = p.ano
WHERE p.medaille = 'Gold'
GROUP BY
    a.ano,
    a.nom
ORDER BY
    count(p.medaille) DESC;

-- Q5
SELECT
    r.nom_pays,
    count(p.medaille) AS nb_medailles_Albertville
FROM
    participe AS p,
    edition AS e,
    region AS r
WHERE
    e.ville = 'Albertville'
    AND p.medaille IS NOT NULL
    AND e.annee = p.annee
    AND e.saison = p.saison
    AND p.noc = r.noc
    AND p.nom_equipe = r.nom_equipe
GROUP BY r.nom_pays
ORDER BY count(p.medaille) DESC;

-- Q6
SELECT DISTINCT p.ano
FROM
    participe AS p,
    region AS r,
    region AS r2
WHERE
    p.noc = r.noc
    AND p.nom_equipe = r.nom_equipe
    AND p.noc = r2.noc
    AND p.nom_equipe = r2.nom_equipe
    AND r.nom_pays <> r2.nom_pays
    AND r.nom_pays = 'France';

-- Q7
-- Même requête que la Q6

-- Q8
SELECT
    a.age,
    count(p.medaille) nb_medailles_Or
FROM
    athlete AS a
    JOIN participe AS p ON a.ano = p.ano
WHERE
    p.medaille = 'Gold'
    AND a.age IS NOT NULL
GROUP BY a.age
ORDER BY count(p.medaille) DESC;

-- Q9
SELECT
    e.nom_sport,
    count(p.medaille) AS nb_médailles_plus_de_50ans
FROM
    epreuve AS e,
    athlete AS a,
    participe AS p
WHERE
    a.age >= 50
    AND e.evenement = p.evenement
    AND e.nom_sport = p.nom_sport
    AND e.genre = p.genre
    AND a.ano = p.ano
GROUP BY e.nom_sport
ORDER BY count(p.medaille) DESC;

-- Q10
SELECT
    ed.annee,
    ed.saison,
    count(ep.evenement) nb_epreuves
FROM
    edition AS ed,
    epreuve AS ep,
    participe AS p
WHERE
    ep.evenement = p.evenement
    AND ep.nom_sport = p.nom_sport
    AND ep.genre = p.genre
    AND ed.annee = p.annee
    AND ed.saison = p.saison
GROUP BY
    ed.annee,
    ed.saison
ORDER BY ed.annee ASC;

-- Q11
SELECT
    ed.annee,
    count(p.medaille) AS nb_médailles_femme_en_été
FROM
    edition AS ed,
    participe AS p,
    athlete AS a
WHERE
    a.sexe = 'F'
    AND ed.saison = 'Summer'
    AND ed.annee = p.annee
    AND ed.saison = p.saison
    AND a.ano = p.ano
GROUP BY ed.annee
ORDER BY ed.annee ASC;

-- Exercice 6
--
-- Sport : Basketball
-- Pays : USA
--

-- Requête n°1 : Moyenne d'âge des athletes masculins
SELECT avg(a.age) AS Moyenne_age
FROM
    athlete AS a,
    epreuve AS e,
    region AS r,
    participe AS p
WHERE
    r.nom_pays = 'USA'
    AND e.nom_sport = 'Basketball'
    AND a.sexe = 'M'
    AND a.ano = p.ano
    AND e.evenement = p.evenement
    AND e.nom_sport = p.nom_sport
    AND e.genre = p.genre
    AND r.noc = p.noc
    AND r.nom_equipe = p.nom_equipe;

-- Requête n°2 : Athlètes ayant participé au moins 3 fois à une édition
SELECT a.ano, a.nom, count(*)
FROM
    athlete AS a,
    epreuve AS e,
    region AS r,
    participe AS p,
    edition as ed
WHERE
    r.nom_pays = 'USA'
    AND e.nom_sport = 'Basketball'
    AND a.ano = p.ano
    AND e.evenement = p.evenement
    AND e.nom_sport = p.nom_sport
    AND e.genre = p.genre
    AND r.noc = p.noc
    AND r.nom_equipe = p.nom_equipe
    AND ed.annee = p.annee
    AND ed.saison = p.saison
GROUP BY a.ano, a.nom
HAVING count(*) >= 3;

-- Requête n°3 : Athlètes qui ont participé à 3 éditions d'affilé
SELECT a.nom, ed.annee, ed2.annee, ed3.annee
FROM
    athlete AS a,
    epreuve AS e,
    region AS r,
    participe AS p,
    edition AS ed,
    edition AS ed2,
    edition AS ed3
WHERE
    r.nom_pays = 'USA'
    AND e.nom_sport = 'Basketball'
    AND a.ano = p.ano
    AND e.evenement = p.evenement
    AND e.nom_sport = p.nom_sport
    AND e.genre = p.genre
    AND r.noc = p.noc
    AND r.nom_equipe = p.nom_equipe
    AND ed.annee = p.annee
    AND ed.saison = p.saison
    AND ed2.annee = ed.annee+4
    AND ed2.saison = p.saison
    AND ed3.annee = ed2.annee+4
    AND ed3.saison = p.saison;

-- Requête n°4 : Athlètes classés par taille du plus petit au plus grand
SELECT
    a.nom,
    a.taille
FROM
    athlete AS a
    JOIN participe AS p
        ON a.ano = p.ano
    JOIN region AS r
        ON r.noc = p.noc AND r.nom_equipe = p.nom_equipe
    JOIN epreuve AS e
        ON e.evenement = p.evenement
           AND e.nom_sport = p.nom_sport
           AND e.genre = p.genre
WHERE r.nom_pays = 'USA'
      AND e.nom_sport = 'Basketball'
      AND a.taille IS NOT NULL
ORDER BY a.taille ASC;