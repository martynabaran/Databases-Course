\o lab3_exercise1.txt
CREATE TABLE cities (city_name VARCHAR(255),center_point GEOMETRY(Point, 4326));
INSERT INTO cities (city_name, center_point) VALUES 
('Kraków', ST_SetSRID(ST_MakePoint(19.938333, 50.061389), 4326)),   ('Gdansk', ST_SetSRID(ST_MakePoint(18.645278, 54.3475), 4326));

select st_distance(city1.center_point, city2.center_point) 
from cities as city1 
cross join cities as city2 where city1.city_name='Kraków' and city2.city_name='Gdansk';

select st_distance(st_transform(city1.center_point,2180), st_transform(city2.center_point,2180)) from cities as city1 cross join cities as city2 where city1.city_name='Kraków' and city2.city_name='Gdansk';

select st_distance(st_transform(city1.center_point,3035), st_transform(city2.center_point,3035)) from cities as city1 cross join cities as city2 where city1.city_name='Kraków' and city2.city_name='Gdansk';
select st_distance(st_transform(city1.center_point,2178), st_transform(city2.center_point,2178)) from cities as city1 cross join cities as city2 whe
re city1.city_name='Kraków' and city2.city_name='Gdansk';
\o

\o lab3_exercise2.txt
create table cities2(name varchar(25), center_point geography(point,4326));
insert into cities2 (name, center_point) values ('Krakow', st_setsrid(st_makepoint(50.061389, 19.938333),4326)::geography),('Gdansk', st_setsrid(st_makepoint(54.3475, 18.645278),4326)::geography);
select st_distance(city1.center_point, city2.center_point) from cities2 as city1 cross join cities2 as city2 where city1.name='Krakow' and city2.name=
'Gdansk';

\o

\o lab3_exercise3.txt
shp2pgsql -s 4326 admin.shp > admin.sql

shp2pgsql -s 2180 lamps.shp > lamps.sql

shp2pgsql -s 4326 roads.shp > roads.sql

 

\i krakow/admin/admin.sql

\i krakow/lamps/lamps.sql

\i krakow/lamps/roads.sql


ALTER TABLE admin ADD COLUMN geog GEOGRAPHY(MULTIPOLYGON, 4326);
UPDATE admin SET geog = ST_Transform(geom, 4326)::GEOGRAPHY;
 
ALTER TABLE lamps ADD COLUMN geog GEOGRAPHY(POINT, 4326);
UPDATE lamps SET geog = ST_Transform(geom, 4326)::GEOGRAPHY;

ALTER TABLE roads ADD COLUMN geog GEOGRAPHY(MULTILINESTRING, 4326);
UPDATE roads SET geog = ST_Transform(geom, 4326)::GEOGRAPHY;
\o

\o lab3_exercise4.txt
select st_area(st_transform(geom, 2180)) as area_in_m2 from admin where city_name=Krakow;
select st_area(geog) as area_in_m2, st_area(geog)/1000000 as area_in_km2 from admin where name='Kraków';
\o

\o lab3_exercise5.txt
SELECT SUM(ST_Length(ST_Transform(r.geom, 3785))) / 1000 AS total_length_km
FROM roads r
JOIN admin a ON ST_Intersects(r.geom, a.geom)
WHERE a.name = 'Kraków'
AND r.road_type IN ('motorway', 'trunk', 'primary', 'secondary', 'tertiary', 'motorway_link', 'trunk_link', 'track', 'residential', 'secondary_link',
 'primary_link', 'living_stret', 'living street', 'teritary_link');
\o

\o lab3_exercise6.txt
WITH road_buffer AS (
    SELECT
        road_name,
        ST_Buffer(geog::geography, 
                  COALESCE(road_width, lane_count * 3.5, 6) / 2, 
                  'endcap=flat') AS buffer_geog
    FROM roads
),
lamps_near_road AS (
    SELECT
        r.road_name,
        l.gid AS lamp_id
    FROM road_buffer r
    JOIN lamps l ON ST_DWithin(l.geog::geography, r.buffer_geog, 10)
)
SELECT
    r.road_name AS street_name,
    COUNT(lnr.lamp_id) AS number_of_lamps
FROM roads r
LEFT JOIN lamps_near_road lnr ON r.road_name = lnr.road_name
GROUP BY r.road_name
ORDER BY number_of_lamps asC
LIMIT 20;
\o