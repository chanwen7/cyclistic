/*  Preparation of dataset for cleaning  */

-- Setting up database inside PostgreSQL interface PgAdmin4
CREATE DATABASE cyclistic
	WITH ENCODING 'UTF-8';
	
COMMENT ON DATABASE cyclistic IS
	'Database contains data for the Google Data Analytics Course capstone project, for the case study on Cyclistic bike-share.';

-- Code to create table, repeated for each of the 12 tables
CREATE TABLE IF NOT EXISTS raw_2023_07 (
	ride_id VARCHAR(20) PRIMARY KEY,
	rideable_type VARCHAR(20),
	started_at TIMESTAMP,
	ended_at TIMESTAMP,
	start_station_name VARCHAR(80),
	start_station_id VARCHAR(50),
	end_station_name VARCHAR(80),
	end_station_id VARCHAR(50),
	start_lat numeric(9,6),
	start_lng numeric(9,6),
	end_lat numeric(9,6),
	end_lng numeric(9,6),
	member_casual VARCHAR(10)
	);

-- Merging of all 12 datasets into a single table with UNION
CREATE TABLE bikeshare_data_raw AS
	SELECT * FROM raw_2023_07 UNION ALL
	SELECT * FROM raw_2023_08 UNION ALL
	SELECT * FROM raw_2023_09 UNION ALL
	SELECT * FROM raw_2023_10 UNION ALL
	SELECT * FROM raw_2023_11 UNION ALL
	SELECT * FROM raw_2023_12 UNION ALL
	SELECT * FROM raw_2024_01 UNION ALL
	SELECT * FROM raw_2024_02 UNION ALL
	SELECT * FROM raw_2024_03 UNION ALL
	SELECT * FROM raw_2024_04 UNION ALL
	SELECT * FROM raw_2024_05 UNION ALL
	SELECT * FROM raw_2024_06;
