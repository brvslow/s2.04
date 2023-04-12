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
    equipe AS e,
    region AS r
WHERE
    p.ano = a.ano
    AND a.equipe = e.nom_equipe
    AND r.noc = e.noc
GROUP BY r.nom_pays
ORDER BY count(*) DESC;

-- Q2
-- Output:
SELECT
    r.nom_pays,
    count(*) AS nb_medaille_Or
FROM
    participe AS p,
    athlete AS a,
    equipe AS e,
    region AS r
WHERE
    medaille = 'Gold'
    AND p.ano = a.ano
    AND a.equipe = e.nom_equipe
    AND e.noc = r.noc
GROUP BY r.nom_pays
ORDER BY count(*) DESC;

-- Q3
-- Output:
SELECT
    r.nom_pays,
    count(*) AS nb_medaille
FROM
    participe AS p,
    athlete AS a,
    equipe AS e,
    region AS r
WHERE
    medaille = 'Gold'
    OR medaille = 'Bronze'
    OR medaille = 'Silver'
    AND p.ano = a.ano
    AND a.equipe = e.nom_equipe
    AND e.noc = r.noc
GROUP BY r.nom_pays
ORDER BY count(*) DESC;

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


-- Q6
-- Output:


-- Q7
-- Output:


-- Q8
-- Output:


-- Q9
-- Output:


-- Q10
-- Output:


-- Q11
-- Output:
