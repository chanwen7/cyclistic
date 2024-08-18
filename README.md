# Cyclistic Bike-share Data Analysis project

### What is this repo?
This repo contains my capstone project for the Google Data Analytics Course, which is an exercise of the data analytics skills I learnt from the course.

In this project, I will be utilizing the Google's process of data analytics to solve a business scenario, of a bike-share company's strategy to convert casual riders into annual members of its bike-share program.

**SQL** and **R** have been chosen as tools used for this project, with this Markdown document as the project report accompanied by a Microsoft PowerPoint slide deck.
At a later date, a dashboard extension of the project will be available on **Tableau** as well.



## Introduction
### Project background
#### The story of Cyclistic
Cyclistic is a successful bike-share offering launched in 2016. The program has grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago.

Cyclistic's marketing strategy to-date relied largely on building general awareness and appealing to the broad consumer base. One such approach is the flexibility of its pricing plans: single-ride passes, full-day passes, and annual memberships. Customers who purchase single-ride or full-day passes are referred to as *casual riders*, and those who purchase annual memberships as *Cyclistic members*.


#### A new strategy
Over time, Cyclistic’s finance analysts have concluded that annual members are much more profitable than casual riders. The marketing director, Lily Moreno, believes that maximizing the number of annual members will be key to future growth. Rather than a marketing campaign targeting all-new customers, Moreno believes there's a solid opportunity to convert casual riders into members. She notes that casual riders are already aware of the Cyclistic program and have chosen Cyclistic for their mobility needs.


#### Project stakeholders
We play the role of a junior data analyst working on the marketing analyst team at Cyclistic, to utilize data in support of Cyclistic's new strategy.

The stakeholders for this project include **Lily Moreno**, the director of marketing and our manager, responsible for the development of campaigns and initiatives promoting Cyclistic, the **Cyclistic marketing analytics team**, responsible for collecting/analyzing/reporting data to guide Cyclistic's marketing strategy, and the **Cyclistic executive team**, a detail-oriented executive team deciding whether to approve the recommended marketing program.


### Business problem and tasks
Our goal is to convert Cyclistic's casual riders into annual members, thereby ensuring longer-term profits.

We can break this problem down into multiple key questions as follows, serving as guideposts for our data analysis:
	1. How do annual members and casual riders use Cyclistic bikes differently?
	2. Why would casual riders buy Cyclistic annual memberships?
  3. How can Cyclistic use digital media to influence casual riders to become members?



## Data cleaning and processing
### Dataset
I will be using Cyclistic bike share data from the past 12 months (July 2023 to June 2024) provided by the Google Data Analytics Course. This dataset is in comma-separated value format (.csv), and is emulated from an actual bike-share company operating in Chicago, USA: Lyft Bikes and Scooters, LLC (“Bikeshare”), under the [respective license](https://divvybikes.com/data-license-agreement). Data from each calendar month is stored in its own .csv file.

The raw dataset (.csv) can be viewed [here](https://divvy-tripdata.s3.amazonaws.com/index.html).

The dataset contains entries for each trip/ride taken with Cyclistic bicycles.


This pre-cleaned dataset contains a total of X entries across 12 tables, and includes the following fields:
Column name	Data type	Column name	Data type
ride_id	String (unique)	end_station_id	String
rideable_type	String	start_lat	Float
started_at	Datetime (DD/MM/YYYY HH:MM:SS)	start_lng	Float
ended_at	Datetime (DD/MM/YYYY HH:MM:SS)	end_lat	Float
start_station_name	String	end_lng	Float
start_station_id	String	member_casual	String
end_station_name	String		
(also add description)
<use below method to put table in markdown format>
https://www.codecademy.com/resources/docs/markdown/tables

Due to privacy issues, the personal & identifiable information of riders are not used. This means that some important data such as purchase history of individual riders and their demographics cannot be explored in the scope of this project.


Using the ROCCC test, we see that the integrity and reliability of data is largely ensured, with the exception of being comprehensive:
	- **Reliable**: Data is directly scraped from the source, and is reflective of our population.
	- **Original**: Data has been adapted from the primary source, Divvy.
	- **Comprehensive**: While all rides have been logged during the selected study period, key information about the demographics and purchase history of riders are absent.
	- **Current**: Data is current, taken from the latest 12 months available (July 2023 to June 2024), which are within 14 months' time from the initiation of this project on August 2024.
	- **Cited**: Data has been obtained from a vetted and credible source.


### Data cleaning
PostgreSQL is used to clean and organize the dataset, through the pgAdmin 4 interface.

While data cleaning and joining is possible to perform with R, I chose to use this project as an opportunity to practice multiple languages, in both PostgreSQL and R.

The full code from this section can be viewed [here](https://github.com/chanwen7/cyclistic/blob/main/data_cleaning_processing.sql).


#### Setting up our database
Raw data is first uploaded into the "cyclistic" database, with the table name following "raw_YYYY_MM", for each of the 12 months of data. This is performed by first creating an empty table with the appropriate field names and data types, followed by importing of each month's .csv file data into the respective table.

```
CREATE DATABASE cyclistic
	WITH ENCODING 'UTF-8';
	
COMMENT ON DATABASE cyclistic IS
	'Database contains data for the Google Data Analytics Course capstone project, for the case study on Cyclistic bike-share.';

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
```


All 12 tables are then merged into a single table "bikeshare_data_raw" using UNION, with a total of **5734381 entries**:
```
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
```


#### Data cleaning operations
For the cleaning process, I decided to code the entire process as a **SQL transaction** with appropriate savepoints, such that in the event where a query needs to be revised, I can do so easily without losing changes from earlier steps. Temporary tables are also utilize created to simplify some operations, and as an additional level of safety if errors occur during rollbacks.

We start the transaction with the creation of our first temporary table "bikeshare_temp":
```
BEGIN;
CREATE TEMP TABLE IF NOT EXISTS bikeshare_temp AS (
	SELECT * FROM bikeshare_data_raw);

SAVEPOINT pre_cleaning;
```


Data cleaning operations are performed in the following order:

1. Renamed "member_casual" column to "customer_type", to better clarify what it contains.
```
ALTER TABLE bikeshare_temp
	RENAME COLUMN member_casual TO customer_type;
SAVEPOINT rename_member;
```


2. Removed duplicates. (211 entries removed, 5734170 entries left)

Repeated ride_ids were identified with the following code:
```
SELECT ride_id FROM bikeshare_temp
GROUP BY ride_id
HAVING COUNT(*) > 1;
```

These were removed from the temporary table by removing second entries of repeated ride_ids:
```
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
```


3. Removed rows with incomplete data (1459943 entries removed, 4274227 entries left)

Incomplete data can lead to lack of comparability, making it difficult for us to identify relationships between data variables. While ideally we should strive to find missing data for these entries, this is not possible for the scope of the project, and it is more viable to remove entries with any null values.

This step is also performed earlier to reduce processing time for subsequent steps.

```
DELETE FROM bikeshare_temp
WHERE ride_id IS NULL OR rideable_type IS NULL OR started_at IS NULL OR
	ended_at IS NULL OR start_station_name IS NULL OR start_station_id IS NULL OR
	end_station_name IS NULL OR end_station_id IS NULL OR start_lat IS NULL OR
	start_lng IS NULL OR end_lat IS NULL OR end_lng IS NULL OR
	customer_type IS NULL;

SAVEPOINT delete_nulls;
```


4. Stripped whitespaces and inappropriate punctuation with station names and IDs

This step will allow for proper grouping of bicycle stations during data analysis.

Cleaned station names and IDs are subsequently converted back to variable character data type (varchar) in order to conserve space. A new temporary table is created so as to simplify operation of modifying data values.

```
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
```


5. Removed abnormal values in "rideable_type". (33303 entries removed, 4240924 left)

The 'docked_bike' category was identified under type of bicycle used, which does not actually tell us the type of bicycle being used. All bikes should have been considered docked in the first place. Hence, this value was treated as null and respective entries removed accordingly.

```
SELECT DISTINCT rideable_type
FROM bikeshare_temp_2;

DELETE FROM bikeshare_temp_2
WHERE rideable_type = 'docked_bike';

SAVEPOINT format_rideable;
```


6. Adjusted abnormal/repeated station names & IDs

There were some odd values identified in the "start_station_name" and "end_station_name" columns, namely station names which began with 'Public Rack - ' prefix that often had similar counterpart values without this prefix. These prefixes were hence removed to ensure proper grouping by station names.

Station names were also changed into title-case for consistency in grouping, then converted back to varchar to conserve memory.

The "start_station_id" and "end_station_id" often had numerical values with and without a '.0 suffix. These suffixes were likewise removed for consistency in grouping.
	
```
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
```

7. Remove impossible values of trip ending time. (removed 66 entries, left 4240858)

Trips with "end_date" before "start_date" are impossible, and hence are removed from the database.

```
SELECT ended_at - started_at as time_check FROM bikeshare_temp_3
WHERE ended_at < started_at;

DELETE FROM bikeshare_temp_3
WHERE ended_at < started_at;

SAVEPOINT check_datetime;
```


8. Checked for impossible coordinate values. (no entries removed)

Coordinates are bound by certain ranges, ±90 for latitude and ±180 for longitude. Hence, coordinate values under "start_lat", "start_lng", "end_lat", "end_lng" are checked against these ranges to remove impossible values.

No impossible coordinate values were identified.

```
SELECT start_lat, start_lng, end_lat, end_lng FROM bikeshare_temp_3
WHERE
	ABS(start_lat) > 90 OR ABS(end_lat) > 90 OR
	ABS(start_lng) > 180 OR ABS(end_lng) > 180

SAVEPOINT check_coord;
```


To ensure data used for analysis is as complete, correct, and relevant to business tasks as possible, the cleaned dataset is then assessed for any further incomplete and dirty data.

We then end the transaction by dropping unnecessary temporary tables and committing changes:
```
DROP TABLE bikeshare_temp, bikeshare_temp_2;
COMMIT;
```


### Data processing

To facilitate data analysis, we further added columns to the temporary table created above.

This includes "ride_length" describing length of each trip/ride, "time_of_day" describing time which rides started, "day_of_week" describing which day of the week rides took place, and "month" describing which month rides took place.

```
ALTER TABLE bikeshare_cleaned
	ADD COLUMN ride_length INTERVAL
	ADD COLUMN time_of_day TIME
	ADD COLUMN day_of_week SMALLINT
	ADD COLUMN month SMALLINT;
	
UPDATE bikeshare_cleaned
	SET ride_length = ended_at - started_at;

UPDATE bikeshare_cleaned
	SET time_of_day = CAST(started_at AS time);

UPDATE bikeshare_cleaned
	SET day_of_week = EXTRACT(dow FROM started_at);
	
UPDATE bikeshare_cleaned
	SET "month" = EXTRACT(month FROM started_at);
```

Lastly, we save the processed temporary table into a finalized table for data analysis.
```
CREATE TABLE bikeshare_data AS (
	SELECT * FROM bikeshare_cleaned);
```


#### Exporting processed data
Data from the "bikeshare_data" table is then exported as bikeshare_data.csv, to be analyzed in RStudio.

