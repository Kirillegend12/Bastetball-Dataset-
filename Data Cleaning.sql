-- Importing the Datasets 

SET GLOBAL local_infile = 1;


DELETE FROM game;

LOAD DATA LOCAL INFILE "C:/Users/Kiril/Desktop/SQL/Basketball Dataset/game.csv"
INTO TABLE game
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SELECT * 
FROM game
ORDER BY game_date DESC;



-- Data Cleaning 

SELECT * 
FROM game;

UPDATE game SET fga_home = NULL WHERE trim(fga_home) = '';
UPDATE game SET fg_pct_home = NULL WHERE trim(fg_pct_home) = '';
UPDATE game SET fg3m_home = NULL WHERE trim(fg3m_home) = '';
UPDATE game SET fg3m_home = NULL WHERE trim(fg3m_home) = '';
UPDATE game SET fg3a_home = NULL WHERE trim(fg3a_home) = '';
UPDATE game SET fg3_pct_home = NULL WHERE trim(fg3_pct_home) = '';
UPDATE game SET fta_home = NULL WHERE trim(fta_home) = '';
UPDATE game SET ft_pct_home = NULL WHERE trim(ft_pct_home) = '';
UPDATE game SET oreb_home = NULL WHERE trim(oreb_home) = '';
UPDATE game SET dreb_home = NULL WHERE trim(dreb_home) = '';
UPDATE game SET reb_home = NULL WHERE trim(reb_home) = '';
UPDATE game SET ast_home = NULL WHERE trim(ast_home) = '';
UPDATE game SET stl_home = NULL WHERE trim(stl_home) = '';
UPDATE game SET blk_home = NULL WHERE trim(blk_home) = '';
UPDATE game SET tov_home = NULL WHERE trim(tov_home) = '';
UPDATE game SET pf_home = NULL WHERE trim(pf_home) = '';
UPDATE game set ast_home = NULL WHERE trim(ast_home) = '';

UPDATE game SET fga_away = NULL WHERE trim(fga_away) = '';
UPDATE game SET fg_pct_away = NULL WHERE trim(fg_pct_away) = '';
UPDATE game SET fg3m_away = NULL WHERE trim(fg3m_away) = '';
UPDATE game SET fg3a_away = NULL WHERE trim(fg3a_away) = '';
UPDATE game SET fg3_pct_away = NULL WHERE trim(fg3_pct_away) = '';
UPDATE game SET fta_away = NULL WHERE trim(fta_away) = '';
UPDATE game SET ft_pct_away = NULL WHERE trim(ft_pct_away) = '';
UPDATE game SET oreb_away = NULL WHERE trim(oreb_away) = '';
UPDATE game SET dreb_away = NULL WHERE trim(dreb_away) = '';
UPDATE game SET reb_away = NULL WHERE trim(reb_away) = '';
UPDATE game SET ast_away = NULL WHERE trim(ast_away) = '';
UPDATE game SET stl_away = NULL WHERE trim(stl_away) = '';
UPDATE game SET blk_away = NULL WHERE trim(blk_away) = '';
UPDATE game SET tov_away = NULL WHERE trim(tov_away) = '';
UPDATE game SET pf_away = NULL WHERE trim(pf_away) = '';
UPDATE game set ast_away = NULL WHERE trim(ast_away) = '';

-- Fixing Dates column 

SELECT str_to_date(game_date, '%Y-%m-%d'), LEFT(game_date,10)
from game;

ALTER TABLE game 
ADD COLUMN game_date_clean DATE;

UPDATE game 
SET game_date_clean = str_to_date(LEFT(game_date,10), '%Y-%m-%d');

ALTER TABLE game 
DROP COLUMN game_date;

ALTER TABLE game 
RENAME COLUMN game_date_clean TO game_date;

SELECT * 
FROM game;

-- Looking for seasons with incomplete statistical background 


SELECT RIGHT(season_id,4) as season, COUNT(fga_home) as Count1
FROM game
GROUP BY RIGHT(season_id,4);


-- Investigating the data with incomplete statistics

with cte as
(
SELECT RIGHT(season_id,4) as season, COUNT(fga_home) as Count1
FROM game
GROUP BY RIGHT(season_id,4)
)
SELECT * 
FROM game g
RIGHT JOIN cte c
ON RIGHT(g.season_id,4) = c.season;

-- After the investigation it was identified that all rows are just missing or null values, which won't make bring any benefits for future analysis. 
-- They will be removed further, so they won't impact the clean version of the dataset.

-- Creating a new table with cleaned data 

DROP TABLE game_clean;

TRUNCATE TABLE game_clean;

CREATE TABLE game_clean (
  `season_id` text,
  `team_id_home` int DEFAULT NULL,
  `team_abbreviation_home` text,
  `team_name_home` text,
  `game_id` text,
  `matchup_home` text,
  `wl_home` text,
  `min` int DEFAULT NULL,
  `fgm_home` double DEFAULT NULL,
  `fga_home` double DEFAULT NULL,
  `fg_pct_home` double DEFAULT NULL,
  `fg3m_home` double DEFAULT NULL,
  `fg3a_home` double DEFAULT NULL,
  `fg3_pct_home` double DEFAULT NULL,
  `ftm_home` double DEFAULT NULL,
  `fta_home` double DEFAULT NULL,
  `ft_pct_home` double DEFAULT NULL,
  `oreb_home` double DEFAULT NULL,
  `dreb_home` double DEFAULT NULL,
  `reb_home` double DEFAULT NULL,
  `ast_home` double DEFAULT NULL,
  `stl_home` double DEFAULT NULL,
  `blk_home` double DEFAULT NULL,
  `tov_home` double DEFAULT NULL,
  `pf_home` double DEFAULT NULL,
  `pts_home` double DEFAULT NULL,
  `plus_minus_home` int DEFAULT NULL,
  `video_available_home` int DEFAULT NULL,
  `team_id_away` int DEFAULT NULL,
  `team_abbreviation_away` text,
  `team_name_away` text,
  `matchup_away` text,
  `wl_away` text,
  `fgm_away` double DEFAULT NULL,
  `fga_away` double DEFAULT NULL,
  `fg_pct_away` double DEFAULT NULL,
  `fg3m_away` double DEFAULT NULL,
  `fg3a_away` double DEFAULT NULL,
  `fg3_pct_away` double DEFAULT NULL,
  `ftm_away` double DEFAULT NULL,
  `fta_away` double DEFAULT NULL,
  `ft_pct_away` double DEFAULT NULL,
  `oreb_away` double DEFAULT NULL,
  `dreb_away` double DEFAULT NULL,
  `reb_away` double DEFAULT NULL,
  `ast_away` double DEFAULT NULL,
  `stl_away` double DEFAULT NULL,
  `blk_away` double DEFAULT NULL,
  `tov_away` double DEFAULT NULL,
  `pf_away` double DEFAULT NULL,
  `pts_away` double DEFAULT NULL,
  `plus_minus_away` int DEFAULT NULL,
  `video_available_away` int DEFAULT NULL,
  `season_type` text,
  `game_date` date DEFAULT NULL,
  `row_num` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * 
FROM game_clean
ORDER BY right(season_id, 4) DESC;


-- Insearting additional column, to delete missing rows 


INSERT INTO game_clean 
SELECT *, ROW_NUMBER()OVER(PARTITION BY season_id, team_id_home,game_id,matchup_home ORDER BY game_id) as row_num 
FROM game 
WHERE RIGHT(season_id,4) >= 1982
AND game_id IS NOT NULL  
AND season_id IS NOT NULL;


-- Standardizing the All-Star valie for season-type column 


UPDATE game_clean 
SET season_type = REPLACE(season_type, 'All-Star','All Star');

-- Remowing duplicate columns 

DELETE FROM game_clean 
WHERE row_num = 2;

ALTER TABLE game_clean
DROP COLUMN row_num;









