--Goal Analysis (From the Goals table)

-- 1.	Which player scored the most goals in a each season?

with pl_mgls as (
select g.pid,count(*) as total_goal, m.season
from goals as g
inner join matches as m 
on g.match_id=m.match_id
where g.pid is not null
group by g.pid,m.season
order by total_goal desc
),
pl_tsgls as(
select *, dense_rank() 
over(partition by season
	order by total_goal desc) as ranks
from pl_mgls
)
select r.pid,r.total_goal,r.season,p.first_name,p.last_name,p.nationality,p.team 
from pl_tsgls as r
inner join players as p
on r.pid=p.player_id
where ranks=1
order by r.season

--2.	How many goals did each player score in a given season?

with pl_gls as (select g.pid,count(g.*) as total_goal, m.season
from goals as g
inner join matches as m 
on g.match_id=m.match_id
inner join players as p
on g.pid=p.player_id
where g.pid is not null
group by g.pid,m.season
order by total_goal desc
)
select pl_gls.*,p.*
from pl_gls 
inner join players as p 
on pl_gls.pid=p.player_id

--3.	What is the total number of goals scored in ‘mt403’ match?

select goals.match_id,count(*) as match_goals 
from goals
group by match_id
having match_id='mt403'

--4.	Which player assisted the most goals in a each season?


with pl_mgls as (
select g.assist,count(*) as total_goal, m.season
from goals as g
inner join matches as m 
on g.match_id=m.match_id
where g.assist is not null
group by g.assist,m.season
order by total_goal desc
),
pl_tsgls as(
select *, dense_rank() 
over(partition by season
	order by total_goal desc) as ranks
from pl_mgls
)
select r.assist,r.total_goal,r.season,p.first_name,p.last_name,p.nationality,p.team 
from pl_tsgls as r
inner join players as p
on r.assist=p.player_id
where ranks=1
order by r.season


--5.	Which players have scored goals in more than 10 matches?

with pl_mt as (
select pid,match_id,count(*)
from goals
group by pid,match_id
),
match_count as (select pid,count(*) as total_match
from pl_mt
group by pid
)
select m.*,p.* 
from match_count as m
inner join players as p 
on m.pid=p.player_id
where m.total_match>10 and m.pid is not null
order by m.total_match desc

--6.	What is the average number of goals scored per match in a given season?

with gls_pm as (
select m.match_id, count(*) as gpm,m.season
from goals as g
right join matches as m 
on g.match_id=m.match_id
group by m.match_id,m.season
)
select season,round(avg(gpm),2) as avg_goals
from gls_pm
group by season
order by season

--7.	Which player has the most goals in a single match?


with single_match as 
(select pid,match_id,count(*) as goals_scored
from goals 
group by pid,match_id
),
most_score as (
select *, dense_rank() over (order by goals_scored desc) as rnk
from single_match
)
select m.pid,m.match_id,m.goals_scored,p.first_name,p.last_name,p.nationality,p.team 
from most_score as m
inner join players as p
on m.pid=p.player_id
where rnk=1

--8.	Which team scored the most goals in the all seasons?

		-- The All-Time Total of a team combining all the seasons

with all_goals as (
select g.pid,g.match_id,count(goal_id) as total_goals ,m.season,p.team
from goals as g
inner join matches as m
on g.match_id=m.match_id 
inner join players as p 
on g.pid=p.player_id
group by g.pid,g.match_id,m.season,p.team
order by total_goals desc
)
select sum(total_goals) as most_goals,team
from all_goals
where team is not null
group by team
order by most_goals desc
limit 1

	-- Most goals combining all the matches per season

with all_goals as (
select g.pid,g.match_id,count(goal_id) as total_goals ,m.season,p.team
from goals as g
inner join matches as m
on g.match_id=m.match_id 
inner join players as p 
on g.pid=p.player_id
group by g.pid,g.match_id,m.season,p.team
order by total_goals desc
),
season_team_goals as (
select season,team,sum(total_goals) as total_goals
from all_goals
where team is not null
group by team,season
order by total_goals 
),
goal_rank_season as (
select *, dense_rank() 
over(partition by season
	order by total_goals desc) as rnk
from season_team_goals
)
select season,team,total_goals as most_goals
from goal_rank_season
where rnk=1


--9.	Which stadium hosted the most goals scored in a single season?

with all_goals as (
select g.pid,g.match_id,count(goal_id) as total_goals ,m.season,p.team,m.stadium
from goals as g
inner join matches as m
on g.match_id=m.match_id 
inner join players as p 
on g.pid=p.player_id
group by g.pid,g.match_id,m.season,p.team,m.stadium
order by total_goals desc
)
select season,stadium,sum(total_goals) as most_goals
from all_goals
group by stadium,season
order by most_goals desc
limit 1

--Match Analysis (From the Matches table)

--10.	What was the highest-scoring match in a particular season?

select g.match_id,count(goal_id) as total_goals ,m.season,m.stadium
from goals as g
inner join matches as m
on g.match_id=m.match_id 
inner join players as p 
on g.pid=p.player_id
group by g.match_id,m.season,m.stadium
order by total_goals desc
limit 1

--11.	How many matches ended in a draw in a given season?

select m.season,count(m.match_id) as drw_mtch
from matches as m
where home_team_score=away_team_score
group by season

--12.	Which team had the highest average score (home and away) in the season 2021-2022?

with all_team_goals as (
    select
        home_team as team_id,
        home_team_score as goals_scored
    from matches
    where season = '2021-2022'
    union all
    select
        away_team as team_id,
        away_team_score as goals_scored
    from matches
    where season = '2021-2022'
), 
team_summary as (
    select
        team_id,
        sum(goals_scored) as total_goals,
        count(*) as matches_played
    from all_team_goals
    group by team_id
)
select
    team_id,
    round(total_goals * 1.0 / matches_played, 2) as avg_goals
from team_summary
order by avg_goals desc
limit 1;

--13.	How many penalty shootouts occurred in a each season?

select count(*) as count_of_penalty_shoot,season
from matches
where penalty_shoot_out=1
group by season

--14.	What is the average attendance for home teams in the 2021-2022 season?

select home_team,round(avg(attendance),2) as avg_attendance
from matches
where season='2021-2022'
group by home_team
order by avg_attendance desc

--15.	Which stadium hosted the most matches in a each season?

with match_stadium as (
select season,stadium,count(match_id) as match_count
from matches
group by season,stadium
),
rank_match as (
select *,dense_rank() over(partition by season
							order by match_count desc) as rnk
from match_stadium
)
select season,stadium,match_count
from rank_match
where rnk=1

--16.	What is the distribution of matches played in different countries in a season?

select m.season,s.country,count(m.match_id) as matches_played
from matches as m 
inner join stadiums as s
on m.stadium=s.name
group by m.season,s.country
order by m.season


--17.	What was the most common result in matches (home win, away win, draw)?

select count(match_id) as match_count,
    case
        when home_team_score>away_team_score then 'home win'
        when home_team_score<away_team_score then 'away win'
        else 'draw'
    end as match_result
from matches
group by match_result
order by match_count desc
limit 1

--Player Analysis (From the Players table)

--18.	Which players have the highest total goals scored (including assists)?

with player_goals as (
select pid as player,count(goal_id) as goals
from goals
where pid is not null
group by pid
union all
select assist as player,count(goal_id) as goals
from goals
where assist is not null
group by assist
),
highest_scoring_player as (
select player, sum(goals) as total_gls_scored
from player_goals 
group by player
order by total_gls_scored desc
limit 1
)
select h.*,p.*
from highest_scoring_player as h
join players as p 
on h.player=p.player_id

--19.	What is the average height and weight of players per position?

with avg_calc as 
(
select position as positions, round(avg(height),2) as avg_height,round(avg(weight),2) as avg_weight
from players
group by position
)
select *
from avg_calc
where avg_height is not null and avg_weight is not null


--20.	Which player has the most goals scored with their left foot?

select *,count(goal_id) OVER(PARTITION BY player_id) as total_goals
from players as p
join goals as g
on g.pid=p.player_id
where p.foot='L'
order by total_goals desc
limit 1

--21.	What is the average age of players per team?

select 
    team,  
    round(avg(extract(year from age(dob))),2) as avg_age_in_years
from players
where team is not null
group by team

--22.	How many players are listed as playing for a each team in a season?

select team,count(player_id) as total_players
from players
where team is not null
group by team

--23.	Which player has played in the most matches in the each season?
-- cant be answered not enough data

--24.	What is the most common position for players across all teams?

select position, count(*) as total_players
from players
where position is not null
group by position
order by total_players desc
limit 1

--25.	Which players have never scored a goal?

with no_score as (
select player_id
from players
except
select pid
from goals
)
select * 
from no_score as n
inner join players as p
on n.player_id=p.player_id


--Team Analysis (From the Teams table)

--26.	Which team has the largest home stadium in terms of capacity?

select *
from teams as t
inner join stadiums as s
on t.home_stadium=s.name
order by capacity desc
limit 1

--27.	Which teams from a each country participated in the UEFA competition in a season?

with tms as (
select home_team as team,season
from matches
union
select away_team,season
from matches
)
select * 
from tms as tm
inner join teams as t
on tm.team=t.team_name

--28.	Which team scored the most goals across home and away matches in a given season?

with home_away_comb as (
select season,home_team as team,home_team_score as team_score
from matches
union all
select season,away_team as team,away_team_score as team_score
from matches
),
most_season_goals as (
select season,team,sum(team_score) as total_goals,dense_rank() over (partition by season
order by sum(team_score) desc) as rnk
from home_away_comb
group by season,team
)
select season,team,total_goals
from most_season_goals
where rnk=1

--29.	How many teams have home stadiums in a each city or country?

select s.city, s.country, COUNT(t.team_name) AS team_count
from teams as t
inner join stadiums as s
on t.home_stadium=s.name
and t.country = s.country
group by s.city,s.country
order by team_count desc

--30.	Which teams had the most home wins in the 2021-2022 season?

select home_team,count(*) as mt_won 
from matches
where home_team_score > away_team_score
and season='2021-2022'
group by home_team
order by mt_won desc
limit 1


--Stadium Analysis (From the Stadiums table)

--31.	Which stadium has the highest capacity?

select * 
from stadiums
order by capacity desc
limit 1

--32.	How many stadiums are located in a ‘Russia’ country or ‘London’ city?

select count(*) as st_count 
from stadiums
where country='Russia'
or city='London'

--33.	Which stadium hosted the most matches during a season?

with std_mt as (
select season,stadium,count(*) as mt_count
from matches
group by season,stadium
order by mt_count desc
),
std_mt_rnk as (
select * , dense_rank() over(partition by season order by mt_count desc) as rnk
from std_mt
)
select season,stadium,mt_count 
from std_mt_rnk
where rnk=1

--34.	What is the average stadium capacity for teams participating in a each season?

with seasonalteams as (
    select distinct season, home_team as team from matches
    union
    select distinct season, away_team as team from matches
)
select 
    st.season, 
    avg(s.capacity) as average_stadium_capacity
from seasonalteams st
join teams t on st.team = t.team_name
join stadiums s on t.home_stadium = s.name and t.country = s.country
group by st.season
order by st.season desc;


--35.	How many teams play in stadiums with a capacity of more than 50,000?

select count(*) as teams_count
from teams as t
join stadiums as  s
on t.home_stadium=s.name
and t.country=s.country
where capacity>50000

--36.	Which stadium had the highest attendance on average during a season?

with season_std_attnd as(
select season,stadium,round(avg(attendance),2) as avg_attendance 
from matches
group by season,stadium
),
rnk_attnd as (
select *,dense_rank() over(partition by season order by avg_attendance desc) as rnk
from season_std_attnd
)
select season,stadium,avg_attendance
from rnk_attnd
where rnk=1


--37.	What is the distribution of stadium capacities by country?


select 
    country, 
    count(*) as stadium_count,
    min(capacity) as min_capacity,
    max(capacity) as max_capacity,
    round(avg(capacity), 2) as avg_capacity
from stadiums
group by country
order by stadium_count desc;

--Cross-Table Analysis (Combining multiple tables)

--38.	Which players scored the most goals in matches held at a specific stadium?

with player_stadium_goals as (
select pid,stadium, count(*) as goal_count, dense_rank() over(order by count(*) desc) as rnk
from goals as g
left join matches as m
on g.match_id=m.match_id
group by pid,stadium
order by goal_count desc
)
select pid,stadium,goal_count,p.*
from player_stadium_goals as pg
left join players as p
on pg.pid=p.player_id
where rnk=1

--39.	Which team won the most home matches in the season 2021-2022 (based on match scores)?

select home_team,count(*) as win_count
from matches
where home_team_score>away_team_score
and season='2021-2022'
group by home_team
order by win_count desc
limit 1

--40.	Which players played for a team that scored the most goals in the 2021-2022 season?

with team_goals as (
select home_team as team,home_team_score as goals_scored
from matches
where season='2021-2022'
union all
select away_team as team,away_team_score as goals_scored
from matches
where season='2021-2022'
),
most_goals_team as(
select team,sum(goals_scored) as goals_scored
from team_goals
group by team
order by goals_scored desc
limit 1
)
select p.* 
from players as p
inner join most_goals_team as mt
on p.team=mt.team

--41.	How many goals were scored by home teams in matches where the attendance was above 50,000?

select sum(home_team_score) as total_goals
from matches
where attendance >50000

--42.	Which players played in matches where the score difference (home team score - away team score) was the highest?

with team_scr_rnk as (
select home_team,away_team,(home_team_score-away_team_score) as scr_diff, 
dense_rank() over(order by (home_team_score-away_team_score) desc) as rnk
from matches
order by scr_diff desc
),
teams_diff as (
select home_team as team 
from team_scr_rnk
where rnk=1
union
select away_team as team 
from team_scr_rnk
where rnk=1
)
select p.*
from players as p
where p.team in (select * from teams_diff)

--43.	How many goals did players score in matches that ended in penalty shootouts?

select sum(home_team_score+away_team_score)
from matches
where penalty_shoot_out=1

--44.	What is the distribution of home team wins vs away team wins by country for all seasons?

select 
    s.country,
    sum(case when m.home_team_score > m.away_team_score then 1 else 0 end) as home_wins,
    sum(case when m.home_team_score < m.away_team_score then 1 else 0 end) as away_wins,
    sum(case when m.home_team_score = m.away_team_score then 1 else 0 end) as draws,
    count(*) as total_matches
from matches m
join stadiums s on m.stadium = s.name
group by s.country
order by total_matches desc;

--45.	Which team scored the most goals in the highest-attended matches?

with max_attendance_matches as (
    select home_team, away_team, home_team_score, away_team_score
    from matches
    where attendance = (select max(attendance) from matches)
),
team_goals as (
    select home_team as team, home_team_score as goals from max_attendance_matches
    union all
    select away_team as team, away_team_score as goals from max_attendance_matches
)
select team, sum(goals) as total_goals
from team_goals
group by team
order by total_goals desc
limit 1;

--46.	Which players assisted the most goals in matches where their team lost(you can include 3)?

with losing_matches as (
    select match_id, 
    case when home_team_score < away_team_score then home_team else away_team end as loser
    from matches
    where home_team_score != away_team_score 
),
player_losing_assists as (
    select g.assist as player_id, count(*) as assist_count
    from goals as g
    inner join losing_matches as lm on g.match_id = lm.match_id
    inner join players as p on g.assist = p.player_id
    where g.assist is not null 
      and p.team = lm.loser 
    group by g.assist
)
select p.first_name, p.last_name, p.team, pla.assist_count
from player_losing_assists as pla
inner join players as p on pla.player_id = p.player_id
order by pla.assist_count desc
limit 3;

--47.	What is the total number of goals scored by players who are positioned as defenders?

select count(*) as goal_count 
from goals as g
inner join players as p
on g.pid=p.player_id
where p.position='Defender'

--48.	Which players scored goals in matches that were held in stadiums with a capacity over 60,000?

select distinct p.first_name, p.last_name, p.team, s.name as stadium_name, s.capacity
from goals as g
inner join matches as m
on g.match_id=m.match_id
inner join stadiums as s
on m.stadium=s.name
inner join players as p
on g.pid=p.player_id
where s.capacity>60000
order by s.capacity desc

--49.	How many goals were scored in matches played in cities with specific stadiums in a season?

select m.season,s.city,s.name,count(g.goal_id) as goal_count
from goals as g
inner join matches as m
on g.match_id=m.match_id
inner join stadiums as s
on m.stadium=s.name
group by m.season,s.city,s.name
order by goal_count desc

--50.	Which players scored goals in matches with the highest attendance (over 100,000)?

select distinct p.first_name, p.last_name, p.team, m.stadium, m.attendance
from goals as g
inner join matches as m
on g.match_id=m.match_id
inner join players as p
on g.pid=p.player_id
where m.attendance>100000

--Additional Complex Queries (Combining multiple aspects)

--51.	What is the average number of goals scored by each team in the first 30 minutes of a match?


with team_match_counts as (
    -- get total matches played by each team (home + away)
    select team, count(*) as total_games
    from (
        select home_team as team from matches
        union all
        select away_team as team from matches
    ) as combined
    group by team
),
early_goals as (
    -- get total goals scored within first 30 minutes by linking to the player's team
    select 
        p.team,
        count(*) as goal_count
    from goals g
    join players p on g.pid = p.player_id
    where g.duration <= 30
    group by p.team
)
-- combine and calculate average
select 
    tmc.team,
    tmc.total_games,
    coalesce(eg.goal_count, 0) as early_goals,
    round(coalesce(eg.goal_count, 0) * 1.0 / tmc.total_games, 3) as avg_goals_first_30
from team_match_counts tmc
left join early_goals eg on tmc.team = eg.team
order by avg_goals_first_30 desc;

--52.	Which stadium had the highest average score difference between home and away teams?

with stadium_diff as (
select stadium,round(avg(abs(home_team_score - away_team_score)), 2) as avg_score_diff,
dense_rank() over(order by avg(abs(home_team_score - away_team_score)) desc) as rnk
from matches
group by stadium
order by avg_score_diff desc
)
select stadium, avg_score_diff
from stadium_diff
where rnk = 1;

--53.	How many players scored in every match they played during a given season?

with team_match_counts as (
    -- count total matches played by each team per season
    select team, season, count(*) as total_team_matches
    from (
        select home_team as team, season from matches
        union all
        select away_team as team, season from matches
    ) as all_games
    group by team, season
),
player_scoring_matches as (
    -- count distinct matches where each player scored per season
    select g.pid, m.season, count(distinct g.match_id) as matches_scored
    from goals g
    join matches m on g.match_id = m.match_id
    group by g.pid, m.season
)
select 
    p.first_name, 
    p.last_name, 
    p.team, 
    tmc.season, 
    tmc.total_team_matches
from player_scoring_matches psm
join team_match_counts tmc on psm.season = tmc.season
join players p on psm.pid = p.player_id and p.team = tmc.team
where psm.matches_scored = tmc.total_team_matches
order by tmc.total_team_matches desc;

--54.	Which teams won the most matches with a goal difference of 3 or more in the 2021-2022 season?

select case when home_team_score > away_team_score then home_team else away_team end as winning_team,count(*) as win_count
from matches 
where season ='2021-2022'
and (abs(home_team_score-away_team_score)>=3)
group by winning_team
order by win_count desc
limit 1

--55.	Which player from a specific country has the highest goals per match ratio?

with team_match_count as(
select team,country,count(*) as total_team_matches
    from (
        select home_team as team from matches
        union all
        select away_team as team from matches
    ) as all_games
	inner join teams t
	on all_games.team=t.team_name
    group by team,country
),
player_scores as(
select g.pid,p.team,p.first_name, p.last_name,  count(g.goal_id) as goal_count
from goals as g
inner join players as p
on g.pid=p.player_id
group by g.pid,p.team,p.first_name, p.last_name
)
select tmc.team,tmc.country,pid,first_name,last_name, goal_count,total_team_matches,
round(ps.goal_count* 1.0 /tmc.total_team_matches,2) as goal_match_ratio
from team_match_count tmc
inner join player_scores ps
on tmc.team=ps.team
order by goal_match_ratio desc
limit 1
