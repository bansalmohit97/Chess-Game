USE [Chess Game]
GO

SELECT COUNT(*) FROM [RAW_Chess_Game]		--20059 rows entered

--Looking at the input data into the RAW Table
SELECT * FROM [RAW_Chess_Game]

--Dropping the table in case
IF OBJECT_ID('[tmp_Chess_Game]') IS NOT NULL
DROP TABLE [tmp_Chess_Game]

--Since, the format of the colums is in Text, Creating a Working table with the proper column data types
--Creating a temporary table initially to check the normalised form (1NF) of this
CREATE TABLE tmp_Chess_Game(
	id VARCHAR(100),
	rated VARCHAR(10),
	created_at VARCHAR(100),
	last_move_at VARCHAR(100),
	turns INTEGER,
	victory_status VARCHAR(100),
	winner VARCHAR(10),
	increment_code VARCHAR(100),
	white_id VARCHAR(100),
	white_rating INTEGER,
	black_id VARCHAR(100),
	black_rating INTEGER,
	moves VARCHAR(2000),
	opening_eco VARCHAR(3),
	opening_name VARCHAR(100),
	opening_ply INTEGER
)

--Copying values from RAW to actual table
INSERT INTO tmp_Chess_Game(
	id,
	rated,
	created_at,
	last_move_at,
	turns,
	victory_status,
	winner,
	increment_code,
	white_id,
	white_rating,
	black_id,
	black_rating,
	moves,
	opening_eco,
	opening_name,
	opening_ply 
)
SELECT id,
	rated,
	created_at,
	last_move_at,
	turns,
	victory_status,
	winner,
	increment_code,
	white_id,
	white_rating,
	black_id,
	black_rating,
	moves,
	opening_eco,
	opening_name,
	opening_ply 
FROM [RAW_Chess_Game]
--20059 rows affected

--Having a look at the temporary table
SELECT * FROM [tmp_Chess_Game]

--INF INVESTIGATION
--CASE 1: Relational Schema has atomic cell value: Justified
--CASE 2: Dupliction of records
SELECT COUNT(*) FROM [tmp_Chess_Game]		--20059 rows
SELECT COUNT(*) FROM (
	SELECT DISTINCT * FROM [tmp_Chess_Game]
) AS tmp									--19630 distinct rows
--The above query displays the unique tuples in the table but there are some entries where the game id is the same but there is a mismatch of the case of the data entered.
--Hence, checking the unique Game ids
SELECT COUNT(DISTINCT [id]) FROM [tmp_Chess_Game]		--19114 distinct game ids
--The difference in the rows denote the presence of duplicate value, hence removing all the duplicate entries into a new table

/*
Checking the rows with same game id:

SELECT [id], COUNT([id]) FROM [tmp_Chess_Game]
GROUP BY [id]
HAVING COUNT([id]) = 1
ORDER BY COUNT([id]) DESC

SELECT * FROM [tmp_Chess_Game]
WHERE [id] = '079kHDqh'

SELECT [id], COUNT([id]) FROM (
	SELECT DISTINCT * FROM [tmp_Chess_Game]
) AS tmp
GROUP BY [id]
HAVING COUNT([id]) >1 
ORDER BY COUNT([id]) DESC

SELECT * FROM (
	SELECT DISTINCT * FROM [tmp_Chess_Game]
) AS tmp
WHERE [id] = '079kHDqh'

SELECT [id], COUNT([created_at]) FROM (
	SELECT DISTINCT * FROM [tmp_Chess_Game]
) AS tmp
WHERE [created_at] NOT LIKE '%+%'
GROUP BY [id]
HAVING COUNT([id]) = 1
ORDER BY COUNT([id]) DESC

SELECT * FROM [tmp_Chess_Game]
WHERE [id] = 'ZPHBiKBY'

*/

--Dropping table Chess_Game
IF OBJECT_ID('[Chess_Game]') IS NOT NULL
DROP TABLE [Chess_Game]

--Creating a new Chess table from the non dupliacte values
SELECT * 
INTO [Chess_Game]
FROM (
	SELECT DISTINCT * FROM [tmp_Chess_Game]
) AS tmp
WHERE [id] IN (
	SELECT [id] FROM (
	SELECT DISTINCT * FROM [tmp_Chess_Game]
) AS tmp
GROUP BY [id]
HAVING COUNT([id]) = 1
)
OR
(
[id] IN (
SELECT [id] FROM (
	SELECT DISTINCT * FROM [tmp_Chess_Game]
) AS tmp
GROUP BY [id]
HAVING COUNT([id]) > 1
) 
AND 
[created_at]  NOT LIKE '%+%'
)

--19114 rows affected

/*
Now just double checking  the count of all game ids
SELECT COUNT(DISTINCT [id]) FROM [Chess_Game]
--19114 rows
--Code Justified
*/

--The first row in the table has missing values, hence dropping the row
DELETE FROM [Chess_Game]
WHERE [turns] = 0
--1 row affected

--Now adding a row colun to the relational schema
ALTER TABLE [Chess_Game]
ADD [RowNumber] int identity(1,1)

SELECT COUNT(*) FROM [Chess_Game]		--19113 rows total
SELECT * FROM [Chess_Game]

--1NF JUSTIFIED

--2NF INVESTIGATION
--Case: Functional Dependencies
--Candidate keys in question:
--Checking Candidate Keys

--Candidate Key 1: RowNumber

SELECT COUNT(id) FROM [Chess_Game]				--19113 rows
SELECT COUNT(DISTINCT [id]) FROM [Chess_Game]	--19113 distinct Game ids
--Candidate key 2: Game id

--There are just 2 candidte keys, and each column is dependent on th whole of candidate keys, hence no functional dependency exists.
--2NF JUSTIFIED

--3NF Investigation
--1. opening_ply is dependent on a combination of non-prime attributes i.e. opening_eco & opening_name
--Moving these three columns into a separate table

SELECT [opening_eco],[opening_name],[opening_ply]
INTO tmp_Game_openings
FROM [Chess_Game]
--19113 rows affected

SELECT * FROM tmp_Game_openings

--Checking the normalized forms for the temporary table created
SELECT COUNT(*) FROM tmp_Game_openings				--19113 rows
SELECT COUNT(*) FROM (
	SELECT DISTINCT * FROM tmp_Game_openings
) AS tmp											--1545 distinct rows

SELECT DISTINCT * 
INTO [Game_Openings]
FROM tmp_Game_openings
--1545 rows affected

SELECT * FROM Game_Openings
--Candidate key for the table created above is a combiaton of opening_eco & opening_name
--NORMALISATION JUSTIFIED

--Dropping the rows in main table Chess_table
ALTER TABLE [Chess_Game]
DROP COLUMN [opening_ply]

--Dropping the temporary Game Openings Table
DROP TABLE tmp_Game_openings

--Dropping the temporary Chess Game Table
DROP TABLE tmp_Chess_Game

/*
The final 2 tables created are:
Chess Game:
Candidate Key: RowNumber, id
Foreign Key: Combination of opening_eco & opening_name
SELECT * FROM [Chess_Game]

Game Openings:
Candidate Key: Combination of opening_eco & opening_name
SELECT * FROM [Game_Openings]
*/