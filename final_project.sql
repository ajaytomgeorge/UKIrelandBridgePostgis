CREATE TABLE ireland_cities (
  id SERIAL,
  city VARCHAR(50),
  lat double precision,
  long double precision,
	country VARCHAR(50),
	iso2 VARCHAR(50),
  admin_name VARCHAR(50),
	capital VARCHAR(50),
	population double precision,
  PRIMARY KEY (id)
)



CREATE TABLE gb_cities (
  id SERIAL,
  city VARCHAR(50),
  lat double precision,
  long double precision,
	country VARCHAR(50),
	iso2 VARCHAR(50),
  admin_name VARCHAR(50),
	capital VARCHAR(50),
	population double precision,
  PRIMARY KEY (id)
)


-- Alter_Data
ALTER TABLE ireland_cities ADD COLUMN geom geometry(Point, 4326);
ALTER TABLE gb_cities ADD COLUMN geom geometry(Point, 4326);
ALTER TABLE merged_cities2 ADD COLUMN population INTEGER;
UPDATE merged_cities2 SET population = ireland_population + gb_population;


UPDATE ireland_cities SET geom = ST_SetSRID(ST_MakePoint(long, lat), 4326);
UPDATE gb_cities SET geom = ST_SetSRID(ST_MakePoint(long, lat), 4326);

  create table merged_cities as
  SELECT 
	coalesce(a.id, b.id) as id,
	a.city as ireland_city,
	b.city as gb_city,
	a.population as ireland_population,
	b.population as gb_population,
    ST_MakeLine(a.geom, b.geom) 
  FROM ireland_cities a, gb_cities b

  UPDATE merged_cities  SET roadlength = 
  ST_LENGTH(st_makeline::geography) / 1000;


  CREATE OR REPLACE VIEW
  CityView AS
  select *, ireland_population +
   gb_population 
  as population
  from merged_cities order by 
  roadlength limit 100



SELECT a.city ,b.city, (ST_Distance(
St_Transform(a.geom,3857),
St_Transform(b.geom,3857)))/1000 as 
distance from ireland_cities 
as a, gb_cities as b where  
a.city ='Dublin' order by distance  


ALTER table merged_cities ADD COLUMN roadlength real;
UPDATE merged_cities  SET roadlength = ST_LENGTH(st_makeline::geography) / 1000;

create table merged_cities2 as
select * from merged_cities order by roadlength limit 100

DROP VIEW IF EXISTS CityView;
CREATE OR REPLACE VIEW
CityView AS
select * from merged_cities order by roadlength limit 100



CREATE TABLE intersections_ireland as
SELECT      
    ST_Intersection(a.geom, b.geom),
    Count(Distinct a.id)
FROM
    irelandhighway as a,
    irelandhighway as b
WHERE
    ST_Touches(a.geom, b.geom)
    AND a.id != b.id
GROUP BY
    ST_Intersection(a.geom, b.geom)


CREATE TABLE intersections_gb1 as
SELECT      
    ST_Intersection(a.geom, b.geom),
    Count(Distinct a.id)
FROM
    uk_highway1 as a,
    uk_highway1 as b
WHERE
    ST_Touches(a.geom, b.geom)
    AND a.id != b.id
GROUP BY
    ST_Intersection(a.geom, b.geom)

  CREATE TABLE intersections_gb2 as
SELECT      
    ST_Intersection(a.geom, b.geom),
    Count(Distinct a.id)
FROM
    uk_highway2 as a,
    uk_highway2 as b
WHERE
    ST_Touches(a.geom, b.geom)
    AND a.id != b.id
GROUP BY
    ST_Intersection(a.geom, b.geom)
	