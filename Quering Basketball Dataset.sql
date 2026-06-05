
SELECT * 
FROM game_clean;


SELECT team_id_home, team_name_home, game_date, matchup_home, wl_home, pts_home, plus_minus_home,team_name_away,wl_away,pts_away,plus_minus_away,season_type
FROM game_clean
ORDER BY game_date DESC;



-----  HOME COURT ADVANTAGE

-- Does home teams win more often ? 

SELECT
SUM(CASE WHEN wl_home = 'W' THEN 1
ElSE 0 
END) as Total_home_wins,
SUM(CASE WHEN wl_home = 'L' THEN 1
ElSE 0 
END) as Total_away_wins
FROM game_clean;



-- Wining Percentage Starting from 2000 year 

SELECT RIGHT(season_id,4) as season,
ROUND(SUM(CASE WHEN wl_home = 'W' THEN 1
ElSE 0 
END)/COUNT(*) * 100,2) as home_wins_pct,
ROUND(SUM(CASE WHEN wl_home = 'L' THEN 1
ElSE 0 
END)/COUNT(*) * 100,2)  as away_wins_pct
FROM game_clean
WHERE game_date >= '2000-01-01'
GROUP BY RIGHT(season_id,4);


-- Season types

SELECT DISTINCT(season_type)
FROM game;


-- Home wins percentage 

with total_wins as (
SELECT RIGHT(season_id, 4) as season,
SUM(CASE WHEN wl_home = 'W' THEN 1
ElSE 0 
END) as Home_wins,
SUM(CASE WHEN wl_home = 'L' THEN 1
ElSE 0 
END) as Home_losses
FROM game_clean
WHERE season_type = 'Regular Season'
GROUP BY RIGHT(season_id, 4)  
ORDER BY RIGHT(season_id, 4) DESC
) 
SELECT *, (Home_wins + Home_losses) as total_games, 
ROUND(home_wins * 100.0 / (home_wins + home_losses), 2) AS home_win_pct,
ROUND((home_wins * 1.0 / home_losses),2) AS home_to_away_ratio 
FROM total_wins;


-- Shooting Effeciency difference at home vs away (by season)

WITH average_pct AS (
    SELECT
        RIGHT(season_id, 4) AS season,
        AVG(fg_pct_home)  AS avg_fg_pct_home,
        AVG(fg_pct_away)  AS avg_fg_pct_away,
        AVG(fg3_pct_home) AS avg_fg3_pct_home,
        AVG(fg3_pct_away) AS avg_fg3_pct_away,
        AVG(ft_pct_home)  AS avg_ft_pct_home,
        AVG(ft_pct_away)  AS avg_ft_pct_away
    FROM game_clean
    WHERE season_type = 'Regular Season'
    GROUP BY RIGHT(season_id, 4)
)
SELECT
    season,
    ROUND((avg_fg_pct_home - avg_fg_pct_away) * 100, 2) AS fg_difference,
    ROUND((avg_fg3_pct_home - avg_fg3_pct_away) * 100, 2) AS fg3_difference,
    ROUND((avg_ft_pct_home - avg_ft_pct_away) * 100, 2) AS ft_difference
FROM average_pct
ORDER BY season DESC;


-- Average Shooting Efficiency home vs away from 2000-th (modern era)

SELECT 
ROUND(AVG(fg_pct_home) * 100,2) as avg_fg_pct_home,
ROUND(AVG(fg_pct_away) * 100,2) as avg_fg_pct_away,
ROUND(AVG(fg3_pct_home) * 100,2)as avg_fg3_pct_home,
ROUND(AVG(fg3_pct_away) * 100,2)as avg_fg3_pct_away,
ROUND(AVG(ft_pct_home) * 100,2)as avg_ft_pct_home,
ROUND(AVG(ft_pct_away) * 100,2) as avg_ft_pct_away
FROM game_clean
WHERE game_date > 2000-01-01
ORDER BY season_id DESC;


-- THREE-POINT ERA ANALYSIS 

-- Does teams attempting more 3-pointers over time? 

SELECT RIGHT(season_id, 4) as season, 
ROUND(AVG(fg3a_home+fg3a_away),2) as Average_fg3_attempts
FROM game_clean 
WHERE season_type = 'Regular Season'
GROUP BY season_id 
ORDER BY season_id DESC;

-- Amount of three point attempts in Playoffs 

SELECT RIGHT(season_id, 4) as season, 
ROUND(AVG(fg3a_home+fg3a_away),2) as Average_fg3_attempts
FROM game_clean 
WHERE season_type = 'Playoffs'
GROUP BY season_id 
ORDER BY season_id DESC;


-- How three point atempts increased from 1980 - 2023


WITH season_3pa AS (
    SELECT
        RIGHT(season_id, 4) AS season,
        AVG(fg3a_home) AS avg_fg3a_home,
        AVG(fg3a_away) AS avg_fg3a_away
    FROM game_clean
    GROUP BY RIGHT(season_id, 4)
),
avg_3pa AS (
    SELECT
        season,
        (avg_fg3a_home + avg_fg3a_away) / 2 AS avg_fg3a
    FROM season_3pa
)
SELECT
    season,
    ROUND(avg_fg3a, 2) AS avg_fg3a,
    ROUND(
        avg_fg3a - LAG(avg_fg3a) OVER (ORDER BY CAST(season AS UNSIGNED)), 
        2
    ) AS fg3a_change,

    ROUND(
        (avg_fg3a - LAG(avg_fg3a) OVER (ORDER BY CAST(season AS UNSIGNED)))
        / NULLIF(LAG(avg_fg3a) OVER (ORDER BY CAST(season AS UNSIGNED)), 0)
        * 100,
        2
    ) AS pct_change
FROM avg_3pa
ORDER BY CAST(season AS UNSIGNED) DESC;



-- Fg3a in Playoffs vs Regular Season
SELECT RIGHT(season_id, 4) as season, 
ROUND(AVG(CASE 
		WHEN season_type = 'Playoffs' 
        THEN fg3a_home+fg3a_away
        END),2) as fg3a_in_Playoffs,
ROUND(AVG(CASE
		WHEN season_type = 'Regular Season'
        THEN fg3a_home+fg3a_away
        END),2) as fg3a_in_RegularSeason
FROM game_clean 
GROUP BY RIGHT(season_id, 4)
ORDER BY RIGHT(season_id, 4) DESC; 




SELECT * 
FROM game_clean 
WHERE season_id LIKE '%2012';



-- OFFENSIVE EFFICIENCY ANALYSIS 

SELECT * 
FROM game_clean
ORDER BY game_date DESC;


 -- Where Team scores more effeciently at home vs away
 
 WITH team_games AS (
    
    SELECT
        RIGHT(season_id,4) AS season,
        team_name_home AS team,
        'Home' AS location,
        fg_pct_home AS fg_pct,
        fg3_pct_home AS fg3_pct,
        ft_pct_home AS ft_pct
    FROM game_clean
    WHERE season_type = 'Regular Season'

    UNION ALL

    SELECT
        RIGHT(season_id,4),
        team_name_away,
        'Away',
        fg_pct_away,
        fg3_pct_away,
        ft_pct_away
    FROM game_clean
    WHERE season_type = 'Regular Season'
)
SELECT season,team,
ROUND(AVG(CASE
	WHEN location = 'Home' THEN fg_pct
    END)*100,2) as average_fgpct_home,
ROUND(AVG(CASE
	WHEN location = 'Away' THEN fg_pct
    END)*100,2) as average_fgpct_away,
ROUND(
	(
    AVG(CASE
	WHEN location = 'Home' THEN fg_pct
    END) 
    - 
    AVG(CASE
	WHEN location = 'Away' THEN fg_pct
    END))
    *100,2) as fgpct_difference
FROM team_games
GROUP BY season,team
ORDER BY season DESC;
    
 -- Creating a Temporary Table to more effective querying 
 
 DROP TEMPORARY TABLE IF EXISTS all_games;
 
 CREATE temporary TABLE all_games 
 SELECT
        RIGHT(season_id,4) AS season,
        team_name_home AS team,
        fg_pct_home * 100 AS fg_pct,
        fg3_pct_home * 100 AS fg3_pct,
        ft_pct_home* 100 AS ft_pct,
        fgm_home as fgm,
        fga_home as fga,
        fg3m_home as fg3m,
        fg3a_home as fg3a,
        ftm_home as ftm,
        fta_home as fta,
        reb_home as reb,
        stl_home stl, 
        blk_home as blk,
        tov_home as tov,
        wl_home as wl,
        game_date 
    FROM game_clean
    WHERE season_type = 'Regular Season'

    UNION ALL

    SELECT
        RIGHT(season_id,4),
        team_name_away,
        fg_pct_away * 100,
        fg3_pct_away * 100,
        ft_pct_away * 100,
		fgm_away,
        fga_away,
        fg3m_away,
        fg3a_away,
        ftm_away,
        fta_away,
        reb_away,
        stl_away, 
        blk_away, 
        tov_away,
        wl_away,
        game_date
    FROM game_clean
    WHERE season_type = 'Regulargame_clean Season';
    
    
    
 SELECT * 
 FROM all_games
 ORDER BY game_date DESC;

 -- Top-5 most efficient NBA Teams by season
 
with team_stats as 
(
SELECT season, team, ROUND(AVG(fg_pct),2) as average_fg, ROUND(AVG(fg3_pct),2) as avg_fg3_pct, ROUND(AVG(ft_pct),2) as avg_ft_pct
FROM all_games 
GROUP BY season,team
),
ranked as (
SELECT *, 
DENSE_RANK()OVER(PARTITION BY season ORDER BY average_fg DESC, avg_fg3_pct DESC, avg_ft_pct DESC ) as rnk
FROM team_stats
ORDER BY season DESC, rnk 
)
SELECT season, team, average_fg, avg_fg3_pct, avg_ft_pct, rnk
FROM ranked 
WHERE rnk <= 5
AND season> 2000;


 
 
 -- What were the average FGA and FG% of the top-winning teams each season?
 
 with fga_vs_fgpct as (
 SELECT season, team, ROUND(AVG(fga),2) as avg_fga, ROUND(AVG(fg_pct),2) as avg_pct,
 SUM(CASE
	WHEN wl = 'W' THEN 1 
    END) as total_wins 
FROM all_games
GROUP BY season, team
),
ranking as 
(
SELECT *,
DENSE_RANK()OVER(PARTITION BY season ORDER BY total_wins DESC) as rnk
FROM fga_vs_fgpct
)
SELECT *
FROM ranking
WHERE rnk <= 5
ORDER BY season DESC, rnk ;
 
 
 
 -- Season Statistics 
 

 WITH team_season AS (
    SELECT
        season,

        COUNT(*) AS games_played,

        SUM(CASE WHEN wl = 'W' THEN 1 ELSE 0 END) AS wins,

        ROUND(AVG(fg_pct), 2)  AS avg_fg_pct,
        ROUND(AVG(fg3_pct), 2) AS avg_fg3_pct,
        ROUND(AVG(ft_pct), 2)  AS avg_ft_pct,

        ROUND(AVG(fga), 2)  AS avg_fga,
        ROUND(AVG(fgm),2) as avg_fgm,
        ROUND(AVG(fg3a), 2) AS avg_fg3a,
        ROUND(AVG(fg3m),2) AS avg_fg3m,
        ROUND(AVG(fta), 2)  AS avg_fta,
        ROUND(AVG(ftm),2) as avg_ftm,
        
        

        ROUND(AVG(reb), 2) AS avg_reb,
        ROUND(AVG(stl), 2) AS avg_stl,
        ROUND(AVG(blk), 2) AS avg_blk,
        ROUND(AVG(tov), 2) AS avg_tov

    FROM all_games
    GROUP BY season
)
SELECT *
FROM team_season;
 
