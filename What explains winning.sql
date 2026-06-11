-- What explains winning?

-- We will create couple usefull datasets for future analysis in Python and Vizualisations in Tableau 


SELECT * 
FROM game_clean
ORDER BY game_date DESC;

SELECT DISTINCT season_type 
FROM game_clean;

-- For more logical analysis, let's remove all 'Pre Seasons' and 'All Star' games 


SELECT * 
FROM game_clean
WHERE season_type in ('Regular Season', 'Playoffs'); 



-- 'season_id' column, differentiate for different season_type.

SELECT season_id, SUM(fga_home)
FROM game_clean 
WHERE season_id like '%2022'
GROUP BY season_id; 


-- We will use Right function in order to sum all the stat lines for the whole season, taking together Playoff games and Regular Season games 

SELECT right(season_id,4) as season, SUM(fga_home)
FROM NBA_games
WHERE season_id like '%2022'
GROUP BY right(season_id,4);


-- Creating a united dataset
-- We will make a table that separately takes every statistical line for each teams group by the game_id. 

SELECT * 
FROM game_clean 
ORDER by game_date DESC;



with all_games as (
SELECT RIGHT(season_id,4) as season, team_name_home as team_name, game_id, 
fgm_home as fgm, 
fga_home as fga, 
fg_pct_home as fg_pct,
fg3m_home as fg3m, 
fg3a_home as fg3a, 
fg3_pct_home as fg3_pct,
 ftm_home as ftm, 
 fta_home as fta,
 ft_pct_home as ft_pct, 
 oreb_home as oreb, 
 dreb_home as dreb, 
 reb_home as reb,
 ast_home as ast,
 stl_home as stl, 
 blk_home as blk, 
 tov_home as tov, 
 pf_home as pf, 
 pts_home as pts,
 CASE WHEN wl_home = 'W' THEN 1 
ELSE 0 
END as won
 FROM game_clean
 WHERE season_type in ('Regular Season', 'Playoffs')
 
 UNION ALL 
 
 SELECT RIGHT(season_id,4), team_name_away, game_id,
 fgm_away, 
 fga_away, 
 fg_pct_away, 
 fg3m_away, 
 fg3a_away, 
 fg3_pct_away, 
 ftm_away, 
 fta_away, 
 ft_pct_away,
 oreb_away, 
 dreb_away, 
 reb_away, 
 ast_away, 
 stl_away, 
 blk_away, 
 tov_away, 
 pf_away, 
 pts_away,
  CASE WHEN wl_away = 'W' THEN 1 
ELSE 0 
END as won
 FROM game_clean
 WHERE season_type in ('Regular Season', 'Playoffs')
 )
 SELECT * 
 FROM all_games
 ORDER BY game_id;
 
 
 -- Now we have Dataset for future visualizations in Tableau 
 

 -- Prepearing a dataset for Correlation and Regression Analysis  
 -- The best way is to create a table with a difference between team, to clearly showcase which stat is the most crucial for winning 
 
with difference as (
SELECT
game_id,
RIGHT(season_id,4) as season,
game_date,
fgm_home - fgm_away AS fgm_diff,
fga_home - fga_away AS fga_diff,
ROUND(fg_pct_home - fg_pct_away,2) AS fg_pct_diff,
fg3m_home - fg3m_away AS fg3m_diff,
fg3a_home - fg3a_away AS fg3a_diff,
ROUND(fg3_pct_home - fg3_pct_away,2) AS fg3_pct_diff,
ftm_home - ftm_away AS ftm_diff,
fta_home - fta_away AS fta_diff,
ROUND(ft_pct_home - ft_pct_away,2) AS ft_pct_diff,
oreb_home - oreb_away AS oreb_diff,
dreb_home - dreb_away AS dreb_diff,
reb_home - reb_away AS reb_diff,
ast_home - ast_away AS ast_diff,
stl_home - stl_away AS stl_diff,
blk_home - blk_away AS blk_diff,
tov_home - tov_away AS tov_diff,
pf_home - pf_away AS pf_diff,
pts_home - pts_away AS pts_diff,
CASE WHEN wl_home = 'W' THEN 1 
ELSE 0 
END as home_win 
FROM game_clean
WHERE season_type in ('Regular Season', 'Playoffs')
)
SELECT * 
FROM difference 
ORDER BY game_date DESC;


-- Both Datasets was succesfully imported to the Excel File for Diagnostic Analysis and Dashboard Creation.