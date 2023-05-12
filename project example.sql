delimiter 
create procedure Winner (In precinctname VARCHAR(255))
begin

#If Biden > Trump then
select 'Biden' as winner, (Biden / totalvotes) as percentage, totalvotes as finaltotal
from Penna
where precinct = precinctname and timestamp = (select max(timestamp) from Penna) and Biden > Trump
order by winner; 

#elseif Trump > Biden then
select 'Trump' as winner, (Trump / totalvotes) as percentage, totalvotes as finaltotal
from Penna
where precinct = precinctname and timestamp = (select max(timestamp) from Penna) and Trump > Biden
order by winner; 
#end if;

end;//

delimiter;

delimiter //
create procedure RankAll (In precinctname VARCHAR(255))
begin

#select dense_rank() over (order by totalvotes) rankprecinct
select new.rankprecinct
from (select dense_rank() over (order by totalvotes) as rankprecinct, precinct
from Penna
where timestamp = (select max(timestamp) from Penna)
order by rankprecinct) as new
#where precinct = precinctname and timestamp = (select max(timestamp) from Penna)
#where timestamp = (select max(timestamp) from Penna)
where new.precinct = precinctname
order by rankprecinct;

end;//

#delimiter;