-- Exercice 2

-- Q1
-- L'option "if not exists" permet de ne pas recréer la table si
-- elle existe déjà.
create table if not exists import_athletes (
    id int,
    name varchar(500),
    sex char(1) check(sex in ('M', 'F')),
    age int,
    height int,
    weight numeric(5,2),
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
-- Pour éviter d'accumuler les copies on supprime au préalable les données de la table.
delete from import_athletes;
-- On importe les données du CSV dans la table import_athletes avec quelques options:
--  On précise le format CSV:
--      - Le paramètre 'header' permet de ne pas copier la première ligne du CSV (ligne des colonnes)
--      - Le paramètre 'escape' permet d'échapper les double guillemets pour intérpreter l'id comme un entier
--      - Le paramètre 'delimiter' détermine avec quel caractère on délimite chaque colonne
--      - Le paramètre 'null as' permet de prendre en charge les valeurs nulles pour éviter les problèmes de type (ici representé par 'NA')
\copy import_athletes from 'csv/athlete_events.csv' with csv header quote '"' delimiter ',' null as 'NA';

-- Q3
delete from import_athletes where year < 1920 or sport = 'Art Competitions';

-- Q4
create table if not exists import_noc(
    noc char(3),
    region varchar(50),
    notes varchar(50)
);

delete from import_noc;
\copy import_noc from 'csv/noc_regions.csv' with csv header delimiter ',' null as 'NA';

-- Ajout des pays manquants dans 'import_noc'
insert into import_noc
    select distinct a.noc, null as region, null as notes
    from import_athletes as a
    where a.noc not in (select n2.noc from import_noc as n2);

-- Exercice 4

-- Q3
-- Region
create table if not exists Region(noc, nom_pays, notes)
    as select noc, region, notes
       from import_noc;

alter table Region drop constraint if exists pk_region;
alter table Region add constraint pk_region primary key(noc);

-- Equipe
create table if not exists Equipe(nom_equipe, noc, nom_pays)
    as select distinct on (a.team) a.team, n.noc, n.region
       from import_athletes as a, import_noc as n
       where a.noc = n.noc;

alter table Equipe drop constraint if exists pk_equipe;
alter table Equipe drop constraint if exists fk_equipe;

alter table Equipe add constraint pk_equipe primary key(nom_equipe);
alter table Equipe add constraint fk_equipe foreign key(noc) references Region(noc);

-- Edition
create table if not exists Edition(annee, saison)
    as select distinct on(year, season) year, season, city from import_athletes;

alter table Edition drop constraint if exists pk_edition;
alter table Edition add constraint pk_edition primary key(annee, saison);

alter table Edition drop constraint if exists check_saison;
alter table Edition add constraint check_saison check(saison in ('Winter', 'Summer'));

-- Athlete
create table if not exists Athlete(ano, nom, sexe, age, taille, poids, equipe)
    as select distinct on (t1.id)
    t1.id, t1.name, t1.sex, t1.age, t1.height, t1.weight, t1.team
        from import_athletes as t1;

alter table Athlete drop constraint if exists pk_athlete;
alter table Athlete drop constraint if exists check_sexe;
alter table Athlete drop constraint if exists fk_equipe;

alter table Athlete add constraint pk_athlete primary key(ano);
alter table Athlete add constraint check_sexe check (sexe in ('M', 'F'));
alter table Athlete add constraint fk_equipe foreign key(equipe) references Equipe(nom_equipe);

-- Epreuve
-- On indique uniquement le nom de l'évenement pour éviter de la redondance avec le nom du sport associé
-- WIP !
create table if not exists Epreuve(evenement, genre, nom_sport)
    as select replace(distinct a.event, a.sport, ''), a.sport
        from import_athletes as a;

alter table Epreuve drop constraint if exists pk_epreuve;
alter table Epreuve add constraint pk_epreuve primary key(evenement, nom_sport);

-- participe
create table if not exists participe(ano, ville, annee, saison, evenement, médaille)
    as select id, city, year, season, event, medal from import_athletes;

alter table participe drop constraint if exists pk_participe;
alter table participe drop constraint if exists fk_athlete;
alter table participe drop constraint if exists fk_epreuve;
alter table participe drop constraint if exists fk_edition;

alter table participe add constraint pk_participe primary key(ano, evenement, annee, saison);
alter table participe add constraint fk_athlete foreign key(ano) references Athlete(ano);
alter table participe add constraint fk_epreuve foreign key(evenement, nom_sport) references Epreuve(evenement, nom_sport);
alter table participe add constraint fk_edition foreign key(annee, saison) references Edition(annee, saison);

drop table import_athletes, import_noc;