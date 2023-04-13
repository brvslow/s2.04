-- Exercice 3
-- Q1
-- Output: 15
SELECT
    count(*)
FROM
    information_schema.columns
WHERE
    table_schema = USER
    AND table_name = 'import_athletes';

-- Q2
-- Output: 255080
SELECT count(*)
FROM import_athletes;

-- Q3
-- Output: 230
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
-- Q1
-- Output:
SELECT
    r.nom_pays,
    count(*) AS nb_participation
FROM
    participe AS p,
    athlete AS a,
    region AS r
WHERE
    p.ano = a.ano
    AND r.noc = p.noc
    AND p.nom_equipe = r.nom_equipe
GROUP BY r.nom_pays
ORDER BY count(*) DESC;

-- Q2
-- Output:
SELECT
    r.nom_pays,
    count(p.medaille) AS nb_medaille_Or
FROM
    participe AS p,
    athlete AS a,
    region AS r
WHERE
    p.medaille = 'Gold'
    AND p.ano = a.ano
    AND p.noc = r.noc
    AND p.nom_equipe = r.nom_equipe
GROUP BY r.nom_pays
ORDER BY count(p.medaille) DESC;

-- Q3
-- Output:
SELECT
    r.nom_pays,
    count(p.medaille) AS nb_medaille_pays
FROM
    participe AS p,
    athlete AS a,
    region AS r
WHERE
    p.medaille IS NOT NULL
    AND p.ano = a.ano
    AND p.noc = r.noc
    AND p.nom_equipe = r.nom_equipe
GROUP BY r.nom_pays
ORDER BY count(p.medaille) DESC;

-- Q4
-- Output:
SELECT
    a.ano,
    a.nom,
    count(p.medaille) AS nb_medaille_Athlete
FROM
    athlete AS a
    JOIN participe AS p ON a.ano = p.ano
GROUP BY
    a.ano,
    a.nom
ORDER BY count(p.medaille) DESC;

-- Q5
-- Output:
SELECT
    r.nom_pays,
    count(p.medaille) AS nb_medaille_Albertville
FROM
    athlete AS a,
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
    AND a.ano = p.ano
GROUP BY r.nom_pays
ORDER BY count(p.medaille) DESC;

-- Q6
-- Output:
SELECT count(distinct a.ano)
FROM
    athlete AS a,
    participe AS p,
    equipe AS eq,
    equipe AS eq2,
    region AS r,
    region AS r2
WHERE
    a.ano = p.ano
    AND eq.nom_equipe = a.equipe 
    AND eq2.nom_equipe = a.equipe
    AND eq.noc = r.noc 
    AND eq2.noc = r2.noc
    AND eq.nom_pays <> eq2.nom_pays;

-- Q7
-- Output:


-- Q8
-- Output:
SELECT
    a.age,
    count(p.medaille)
FROM 
    athlete AS a
    JOIN participe AS p ON a.ano = p.ano
WHERE 
    p.medaille = 'Gold'
    AND a.age IS NOT NULL
GROUP BY a.age
ORDER BY count(p.medaille) DESC;

-- Q9
-- Output:


-- Q10
-- Output:


-- Q11
-- Output:






-- Exercice 6