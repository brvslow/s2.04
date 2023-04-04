-- Exercice 3
-- Q1
-- Output: 15
select count(*) from information_schema.columns where table_schema = user and table_name = 'import_athletes';

-- Q2
-- Output: 255080
select count(*) from import_athletes;

-- Q3
-- Output: 230
select count(noc) from import_noc;

-- Q4
-- Output: 127575
select count(distinct id) from import_athletes;

-- Q5
-- Output: 12116
select count(medal) from import_athletes where medal = 'Gold';

-- Q6
-- Output: 2
select count(*) from import_athletes where name LIKE 'Carl Lewis%';

-- Exercice 5
-- Q1
-- Output: 
select r.region, count (*)
from participe as p, athlete as a, equipe as e, region as r
where p.ano = a.ano
and p.nom_equipe = e.nom_equipe
and e.noc = r.noc
and r.nom_payes = e.nom_equipe
group by r.region
order by count(*) desc;

-- Q2
-- Output: 
select p.medaille, count (*)
from participe as p, athlete as a, equipe as e, region as r
where medaille = 'Gold'
and p.ano = a.ano
and p.nom_equipe = e.nom_equipe
and e.noc = r.noc
and r.nom_payes = e.nom_equipe
group by r.region
order by count(*) desc;

-- Q3
-- Output: 
select p.medaille, count (*)
from participe as p, athlete as a, equipe as e, region as r
where p.ano = a.ano
and p.nom_equipe = e.nom_equipe
and e.noc = r.noc
and r.nom_payes = e.nom_equipe
group by r.region
order by count(*) desc;

-- Q4
-- Output: 
select a.ano, a.name, p.medaille
from athlete as a join participe as p on (ano)
group by a.id, a.name
order by count(*) desc;

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