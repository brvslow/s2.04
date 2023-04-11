# s2.04 - Exploitation BDD

<img src="images/Logo-IUT-de-Lille_2022.png" width="200" align="right">

## Introduction

*Pour éxécuter correctement le fichier sql '[importation.sql](./sql/importation.sql)', veuillez éxecuter la commande depuis la racine du projet soit:*

```
but1=> \i sql/importation.sql
```

**Compilation du Markdown**

*Il faut un moteur PDF permetant de générer le pdf au préalable, tel que **pdflatex**.*

Le fichier 'metadata.yml' inclut les données au-delà du fichier Markdown:

- Le titre du document
- Les noms des auteurs

```
pandoc --toc --metadata-file metadata.yml --template=template/eisvogel.tex -t pdf -f markdown README.md -o README.pdf
```

## Exercice 1

> Q1. Combien y-a t-il de lignes dans chaque fichier ?

```
cat <nom_fichier> | wc -l
```
Soit:

- **athlete_events.csv** : (271176 lignes)

```
cat csv/athlete_events.csv | wc -l
```

- **noc_regions.csv** : (230 lignes)

```
cat csv/noc_regions.csv | wc -l
```

> Q2. Afficher uniquement la première ligne du fichier athlète

```
cat csv/athlete_events.csv | head -n 1
```

> Q3. Quel est le séparateur de champs ?

Le séparateur est : « , »

> Q4. Que représente une ligne ?

Une ligne représente les informations relatives à chaque participant (sauf la première ligne qui représente le type et la nature des informations qu’il y a dans les colonnes).

> Q5. Combien y-a t-il de colonnes ?

- **athlete_events.csv** : (15 colonnes)

```
cat csv/athlete_events.csv | head -n 1 | tr ',' '\n' | wc -l
```

- **noc_regions.csv** : (3 colonnes)
```
cat csv/noc_regions.csv | tr "\r\n" "\n" | head -n 1 | tr "," "\n" | wc -l
```

> Q6. Quelle colonne distingue les jeux d’été et d’hivers ?

La colonne « Season » représente les jeux d’été et d’hiver. C’est la colonne n°11.

> Q7. Combien de lignes font référence à Jean-Claude Killy ?

- **athlete_events.csv** : (6 lignes)
```
cat csv/athlete_events.csv | grep "Jean-Claude Killy" | wc -l
```

> Q8. Quel encodage est utilisé pour ce fichier ?

- **athlete_events.csv** : (us-ascii)
```
file --mime-encoding csv/athlete_events.csv
```

> Q9. Comment envisagez vous l’import de ces données ?

On envisage d’importer les données en créeant une table dans le base PostgreSQL et en utilisant la commande ``\copy`` pour copier les données du CSV dans cette table.

## Exercice 2

(cf '[sql/importation.sql](./sql/importation.sql)')

## Exercice 3

(cf '[sql/requetes.sql](./sql/requetes.sql)')

## Exercice 4

MCD correspondant:

- Un athlète représente une équipe
- Une équipe est issue d'une région (composé du code de la région, du nom, info supplémentaire (notes))
- Un athlète a participé des éditions données pour des épreuves (composé de l'évènement, du genre dédié à l'évenement et du sport associé à l'évènement) donnés dans lesquelles il a éventuellement eu des médailles
- Ce qui fait au total 6 entités (5 entités dont 2 associations hiérarchiques + 1 association maillée (participe) car c'est une ternaire associant Athlete, Epreuve et Edition)

(*Dans l'entité Epreuve il y a un attribut genre car on décompose l'evenement en [nom_evenement] [genre] [sport]*)

![MCD du sujet](mcd/mcd.png)

MLD associé:

- Region(<u>**noc**</u>, nom_pays, notes)

- Equipe(<u>**nom_equipe**</u>, **#noc**)

- Athlete(<u>**ano**</u>, nom, sexe, age, taille, poids, **#equipe**)

- Edition(<u>**année**</u>, <u>**saison**</u>, ville)

- Epreuve(<u>**evenement**</u>, <u>**nom_sport**</u>, <u>**genre**</u>)

- participe(<u>**#ano**</u>, <u>**#evenement**</u>, <u>**#nom_sport**</u>, <u>**#genre**</u>, <u>**#annee**</u>, <u>**#saison**</u>, medaille)

> 1. Quelle taille en octet fait le fichier récupéré ?

- **data-olympique.zip** : (5544725 octets)

```
wc -c data-olympique.zip | cut -d ' ' -f 1
```

> 2. Quelle taille en octet fait la table import ?

- **import_athletes** : (46235648 octets)

```
but1=> SELECT pg_total_relation_size('import_athletes');
```

- **import_noc** : (40960 octets)
```
but1=> SELECT pg_total_relation_size('import_noc');
```

> 3. Quelle taille en octet fait la somme des tables créées ? 

Taille totale: (98.164736 Mo)

```
select sum(pg_total_relation_size) / 10^6 as taille_totale
from (
    SELECT pg_total_relation_size('import_athletes')
    union
    SELECT pg_total_relation_size('import_noc')
    union
    SELECT pg_total_relation_size('region')
    union
    SELECT pg_total_relation_size('equipe')
    union
    SELECT pg_total_relation_size('athlete')
    union
    SELECT pg_total_relation_size('edition')
    union
    SELECT pg_total_relation_size('epreuve')
    union
    SELECT pg_total_relation_size('participe')
    ) as union_tables;
```

> 4. Quelle taille en octet fait la somme des tailles des fichiers exportés correspondant à ces tables ?

Je n'ai pas les droits pour réaliser une exportation

```
COPY equipe TO 'equipe.csv'  WITH DELIMITER ',' CSV HEADER;
```