SELECT pgr_astar('SELECT gid AS id, source, target, cost, reverse_cost, x1, y1, x2, y2 FROM mapity.cuyahoga_ways',
	9927,
	449471)

WITH dd AS (
	SELECT *
	FROM pgr_drivingdistance(
		'SELECT gid AS id
						, source_osm AS source
						, target_osm AS target
						, length_m AS cost
						, length_m as reverse_cost, x1, y1, x2, y2
			FROM mapity.cuyahoga_ways'
			, 4392936441, 360)
			),
dd_collect AS (
	SELECT ST_collect(the_geom) AS the_collection
	FROM dd
		LEFT JOIN mapity.cuyahoga_ways_vertices_pgr vrt
		ON dd.pred = vrt.osm_id
		)
SELECT ST_ConcaveHull(the_collection, 0.2) FROM dd_collect;

CREATE OR REPLACE FUNCTION mapity.knn(pod geometry)
	RETURNS bigint AS
$BODY$
	WITH dearest AS (
		SELECT osm_id,
		vrt.the_geom <-> pod AS dist
		FROM
			mapity.cuyahoga_ways_vertices_pgr vrt
		ORDER BY
			dist
		LIMIT 1
		)
	SELECT osm_id FROM dearest;
$BODY$
	LANGUAGE sql VOLATILE;

--SELECT mapity.knn(geom) FROM mapity.ccbh_pods;

CREATE OR REPLACE FUNCTION mapity.sammy_drivingdistance(osm_id bigint, dist numeric)
	RETURNS geometry AS
$BODY$
	WITH dd AS (
			SELECT *
			FROM pgr_drivingdistance(
				'SELECT gid AS id
								, source_osm AS source
								, target_osm AS target
								, length_m AS cost
								, length_m as reverse_cost, x1, y1, x2, y2
					FROM mapity.cuyahoga_ways'
					, osm_id, dist)
					),
		dd_collect AS (
			SELECT ST_collect(the_geom) AS the_collection
			FROM dd
				LEFT JOIN mapity.cuyahoga_ways_vertices_pgr vrt
				ON dd.pred = vrt.osm_id
				)
		SELECT ST_ConcaveHull(the_collection, 0.2) FROM dd_collect;
$BODY$
	LANGUAGE sql VOLATILE;

SELECT mapity.sammy_drivingdistance(mapity.knn(geom),1500.0) FROM mapity.ccbh_pods;


-- SELECT * FROM mapity.ohio_census_tracts;

--ALTER TABLE mapity.ohio_census_tracts 
--RENAME COLUMN geoid TO idgeo;

-- ALTER TABLE mapity.ohio_census_tracts 
-- RENAME COLUMN "id" TO gid;
-- ALTER TABLE mapity.ohio_census_tracts 
-- RENAME COLUMN "geom" TO gid;

CREATE TABLE mapity.tracts_pop_65 AS
	SELECT * FROM mapity.population_over_age_65 pop
		LEFT JOIN mapity.ohio_census_tracts oct
		ON pop.geoid = oct.idgeo;

SELECT * FROM mapity.ohio_census_tracts;

--ALTER TABLE mapity.tracts_pop_65
--    ALTER COLUMN "indicator count value" TYPE numeric USING ("indicator count value"::numeric);
