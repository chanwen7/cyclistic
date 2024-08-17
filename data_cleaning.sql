/*  Cleaning of dataset  */

-- Data cleaning operations are performed within a transaction with suitable savepoints, with assistance of temporary tables.
BEGIN;
-- Start by creating temporary table (5734381 entries)
CREATE TEMP TABLE IF NOT EXISTS bikeshare_temp AS (
	SELECT * FROM bikeshare_data_raw);

SAVEPOINT pre_cleaning;

-- (1) Rename member_casual to customer_type
ALTER TABLE bikeshare_temp
	RENAME COLUMN member_casual TO customer_type;

SAVEPOINT rename_member;

-- (2) Remove duplicates (211 entries removed, left 5734170)
ALTER TABLE bikeshare_temp
	ADD id SERIAL,
	ADD dupe_counter SMALLINT;

WITH dupe AS (
	SELECT id, ROW_NUMBER() OVER(PARTITION BY ride_id) as dupe_counter
	FROM bikeshare_temp)
UPDATE bikeshare_temp
	SET dupe_counter = dupe.dupe_counter
	FROM dupe WHERE dupe.id = bikeshare_temp.id;

DELETE FROM bikeshare_temp
WHERE dupe_counter > 1;

ALTER TABLE bikeshare_temp
	DROP COLUMN dupe_counter, id;

SAVEPOINT delete_dupes;

-- (3) Remove null values (1459943 entries removed, 4274227 left)
DELETE FROM bikeshare_temp
WHERE ride_id IS NULL OR rideable_type IS NULL OR started_at IS NULL OR
	ended_at IS NULL OR start_station_name IS NULL OR start_station_id IS NULL OR
	end_station_name IS NULL OR end_station_id IS NULL OR start_lat IS NULL OR
	start_lng IS NULL OR end_lat IS NULL OR end_lng IS NULL OR
	customer_type IS NULL;

SAVEPOINT delete_nulls;

-- (4) Strip whitespaces and inappropriate punctuation with station names and IDs, converting back to varchar type to conserve space
CREATE TEMP TABLE IF NOT EXISTS bikeshare_temp_2 AS (
	SELECT
		ride_id, rideable_type, started_at, ended_at,
		TRIM(start_station_name, ' .,-_/')::VARCHAR as start_station_name,
		TRIM(start_station_id, ' .,-_/')::VARCHAR as start_station_id,
		TRIM(end_station_name, ' .,-_/')::VARCHAR as end_station_name,
		TRIM(end_station_id, ' .,-_/')::VARCHAR as end_station_id,
		start_lat, start_lng, end_lat, end_lng, customer_type
	FROM bikeshare_temp);

SAVEPOINT strip;

-- (5) Remove abnormal values in rideable_type (identified unknown 'docked_bike', 33303 entries removed, 4240924 left)
SELECT DISTINCT rideable_type
FROM bikeshare_temp_2;

DELETE FROM bikeshare_temp_2
WHERE rideable_type = 'docked_bike';

SAVEPOINT format_rideable;

-- (6) Adjust abnormal/repeated station names & IDs
-- Identified 'Public Rack - ' prefixes in station names that have counterpart without predix (popped out from 21872 entries)
-- Identified unnecessary '.0' suffixes in station ids (popped out from 41981 entries)
-- Additionally, changed station names to title-case for consistency.

SELECT DISTINCT start_station_name FROM bikeshare_temp_2;
SELECT DISTINCT end_station_name FROM bikeshare_temp_2;
SELECT DISTINCT start_station_id FROM bikeshare_temp_2;
SELECT DISTINCT end_station_id FROM bikeshare_temp_2;

CREATE TEMP TABLE IF NOT EXISTS bikeshare_temp_3 AS (	
	SELECT
		ride_id, rideable_type, started_at, ended_at,
		INITCAP(REPLACE(start_station_name, 'Public Rack - ', ''))::VARCHAR as start_station_name,
		REPLACE(start_station_id, '.0', '')::VARCHAR as start_station_id,
		INITCAP(REPLACE(end_station_name, 'Public Rack - ', ''))::VARCHAR as end_station_name,
		REPLACE(end_station_id, '.0', '')::VARCHAR as end_station_id,
		start_lat, start_lng, end_lat, end_lng, customer_type
	FROM bikeshare_temp_2)
	
SAVEPOINT format_station;

-- (7) Remove impossible values of trip ending time (removed 66 entries, left 4240858)
SELECT ended_at - started_at as time_check FROM bikeshare_temp_3
WHERE ended_at < started_at;

DELETE FROM bikeshare_temp_3
WHERE ended_at < started_at;

SAVEPOINT check_datetime;

-- (8) Check impossible coordinate values (none identified)
SELECT start_lat, start_lng, end_lat, end_lng FROM bikeshare_temp_3
WHERE
	ABS(start_lat) > 90 OR ABS(end_lat) > 90 OR
	ABS(start_lng) > 180 OR ABS(end_lng) > 180

SAVEPOINT check_coord;

-- Drop unused temporary tables and end transaction
DROP TABLE bikeshare_temp, bikeshare_temp_2;
COMMIT;
