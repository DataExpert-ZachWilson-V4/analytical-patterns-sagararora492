-- This query is creating grouping sets table as per the assignment instructions and using table nba_game_details_dedup.
-- This table will help in answering other set of queries in the assignment

CREATE OR REPLACE TABLE sagararora492.grouping_sets AS
SELECT
    CASE 
        WHEN GROUPING(GD.player_name, GD.team_abbreviation) = 0 THEN 'player_team'
        WHEN GROUPING(GD.player_name, G.season) = 0 THEN 'player_season'
        WHEN GROUPING(GD.team_abbreviation) = 0 THEN 'team'
    END as aggregation_level,
    COALESCE(GD.player_name, 'Overall') AS player, -- This coalesce is to handle null values
    COALESCE(GD.team_abbreviation, 'Overall') AS team,
    COALESCE(CAST(G.season AS VARCHAR), 'Overall') AS season,
    SUM(pts) AS total_points,
    SUM(
     IF(
       (team_id = home_team_id AND home_team_wins = 1)
       OR (team_id = visitor_team_id AND home_team_wins = 0)
     , 1, 0) 
     ) AS won_games 
FROM bootcamp.nba_game_details_dedup AS GD
JOIN bootcamp.nba_games AS G
  ON GD.game_id = G.game_id
GROUP BY GROUPING SETS (
  (GD.player_name, GD.team_abbreviation),
  (GD.player_name, G.season),
  (GD.team_abbreviation)
)