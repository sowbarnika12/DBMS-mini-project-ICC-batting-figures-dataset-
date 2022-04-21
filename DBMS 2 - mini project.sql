#ICC test cricket mini project

create database test_cricket;
use test_cricket;

#2.	Remove the column 'Player Profile' from the table.
alter table batting_figures
drop column `Player Profile`;

#3.	Extract the country name and player names from the given data and store it in seperate columns for further usage.
SELECT 
    *
FROM
    batting_figures
LIMIT 20;

alter table batting_figures add column player_name varchar(25);
set sql_safe_updates = 0;
UPDATE batting_figures 
SET 
    player_name = SUBSTR(player,
        1,
        POSITION('(' IN player) - 1)
WHERE
    player_name IS NULL;
alter table batting_figures modify column player_name varchar(25) after player;

alter table batting_figures add column country_name varchar(10);
UPDATE batting_figures 
SET 
    country_name = SUBSTR(player,
        POSITION('(' IN player) + 1,
        LENGTH(player) - POSITION('(' IN player) - 2);

select * from batting_figures limit 20;

#4.	From the column 'Span' extract the start_year and end_year and store them in seperate columns for further usage.

alter table batting_figures add column start_year int ;
UPDATE batting_figures 
SET 
    start_year = SUBSTR(span, 1, 4)
WHERE
    start_year IS NULL;
    
alter table batting_figures modify column start_year int after span;
select * from batting_figures limit 20;

alter table batting_figures add column end_year int;
UPDATE batting_figures 
SET 
    end_year = SUBSTR(span, 6, 9)
WHERE
    end_year IS NULL; 
    
alter table batting_figures modify column end_year int after start_year;


#5.	The column 'HS' has the highest score scored by the player so far in any given match. 
#The column also has details if the player had completed the match in a NOT OUT status. 
#Extract the data and store the highest runs and the NOT OUT status in different columns.

select * from batting_figures limit 20;
alter table batting_figures add column out_status varchar(25);

update batting_figures set out_status = (case
										when substr(HS,length(HS))='*' then 'not out'
                                        else 'out'
                                        end) where out_status is null;
		
alter table batting_figures add column highest_runs int;
update batting_figures set highest_runs = (case when substr(HS,length(HS)) = '*'
then substr(HS,1,length(HS)-1)
else HS 
end);
alter table batting_figures modify column highest_runs int after runs;
alter table batting_figures modify column out_status varchar(25) after highest_runs;

select * from batting_figures limit 30;
#6.	Using the data given, considering the players who were active in the year of 2019, 
#create a set of batting order of best 6 players using the selection criteria of those who have a good average score
#across all matches for India.

select player as 'batting order'
from batting_figures
where 2019 between start_year and end_year
order by avg desc limit 6;

select * from batting_figures limit 20;

#7.	Using the data given, considering the players who were active in the year of 2019, 
#create a set of batting order of best 6 players using the selection criteria of those who have highest number
# of 100s across all matches for India.

select player as 'batting order',sum(`100`) as no_of_100s
from batting_figures
where 2019 between start_year and end_year
group by player
order by no_of_100s desc limit 6;

select distinct player from batting_figures;

#8.	Using the data given, considering the players who were active in the year of 2019, 
#create a set of batting order of best 6 players using 2 selection criterias of your own for India.

select *
from batting_figures
where country_name = 'INDIA' and 2019 between start_year and end_year
order by `100` desc,avg desc limit 6;

#9.	Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given,
#considering the players who were active in the year of 2019, create a set of batting order of best 6 players
# using the selection criteria of those who have a good average score across all matches for South Africa.

alter table batting_figures modify column country_name varchar(25) after player_name;
select * from batting_figures limit 20;

CREATE OR REPLACE VIEW Batting_Order_GoodAvgScorers_SA AS
    SELECT 
        player_name, start_year, country_name, Avg,row_number() over(order by avg desc)
    FROM
        batting_figures
    WHERE
        2019 BETWEEN start_year AND end_year
            AND country_name = 'SA'
    LIMIT 6;

select * from Batting_Order_GoodAvgScorers_SA;
#10.Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ Using the data given, 
#considering the players who were active in the year of 2019, create a set of batting order of best 6 players
#using the selection criteria of those who have highest number of 100s across all matches for South Africa.

CREATE OR REPLACE VIEW Batting_Order_HighestCenturyScorers_SA AS
    SELECT 
        player_name, Span, `100`
    FROM
        batting_figures
    WHERE
        span LIKE '%2019'
            AND country_name = 'SA'
    GROUP BY player_name
    ORDER BY `100` DESC
    LIMIT 6;

select * from Batting_Order_HighestCenturyScorers_SA;