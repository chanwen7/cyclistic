/*  Cleaning of dataset  */

-- Data cleaning operations are performed within a transaction with suitable savepoints, with changes made to a temporary table
BEGIN;
SAVEPOINT pre_cleaning;
--<operation to create temporary table + operation to rename member_casual>;
--<operation to remove duplicates by ride_id>;
SAVEPOINT dupes;
--<operation to drop entries with any null values>;
SAVEPOINT nulls;
--<operation to trim whitespaces and punctuations>;
SAVEPOINT trimmed;
--<operation to drop entries of indeterminate rideable_type>;
SAVEPOINT format_rideable_type;
--<operation to standardize station name formats>;
--<operation to changes station names to title case>
SAVEPOINT format_station_names;
--<operation to >;
SAVEPOINT format_station_ids;
--<operation to >;
SAVEPOINT format_coord;
--<operation to >;
SAVEPOINT enddate_check;

COMMIT;

-- 
