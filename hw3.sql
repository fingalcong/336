#hw3 for Yinfeng Cong
#1
select distinct timestamp
from Penna
group by timestamp
having sum(biden) - sum(Trump) >= 100000
limit 1;

#2
select timestamp, precinct
from Penna
where timestamp = (select min(timestamp) as earliest 
from Penna
where totalvotes <> 0) and totalvotes <> 0
order by timestamp;

#3
select new.precinct
from (select precinct, abs(max(Trump) - max(Biden)) as absvotes
      from Penna
	  group by precinct)new
where new.absvotes = (Select min(new1.absvotes) 
                              from ( select precinct, abs(max(Trump) - max(Biden)) as absvotes
                                     from Penna
                                     group by precinct)new1);

#4
select timestamp
from (select timestamp, abs(sum(Trump) - sum(Biden)) as absvotes
	  from Penna
      group by timestamp) new
where new.absvotes = (select max(new1.absvotes) 
                   from (select timestamp, abs(sum(Trump) - sum(Biden)) as absvotes
                         from Penna
                         group by timestamp) new1);
                          
#5
select timestamp, sum(Biden), sum(Trump)
from Penna
group by timestamp
having sum(Trump) > sum(Biden)
order by timestamp;
#Trump never wins

#6
select if (sum(maxB)>Sum(maxT),'Biden','Trump') as whowin, sum(maxB) as Bidenvotes, sum(maxT) as Trumpvotes
from(select precinct, max(Biden) as maxB, max(Trump) as maxT
	 from Penna
	 group by precinct
     having precinct like '%Township%') new;

select if (sum(maxB)>Sum(maxT),'Biden','Trump') as whowin, sum(maxB) as Bidenvotes, sum(maxT) as Trumpvotes
from(select precinct, max(Biden) as maxB, max(Trump) as maxT
	 from Penna
	 group by precinct
     having precinct like '%Borough%') new;

select if (sum(maxB)>Sum(maxT),'Biden','Trump') as whowin, sum(maxB) as Bidenvotes, sum(maxT) as Trumpvotes
from(select precinct, max(Biden) as maxB, max(Trump) as maxT
	 from Penna
	 group by precinct
     having precinct like '%Ward%') new;
     
#7
select if (sum(maxB)>Sum(maxT),'Biden','Trump') as whowin, if (sum(maxB)>Sum(maxT), sum(maxB), sum(maxT))
from (select precinct, max(Biden) as maxB, max(Trump) as maxT
	 from Penna
	 group by precinct) new;
     
select if (sum(maxB)=Sum(maxT), 'They got the same number of votes',if (sum(maxB)>Sum(maxT),'Biden','Trump')) as whowin
from (select precinct, max(Biden) as maxB, max(Trump) as maxT
	 from Penna
     where timestamp like '2020-11-03%'
	 group by precinct) new;
     
select if (sum(maxB)=Sum(maxT), 'Tie',if (sum(maxB)>Sum(maxT),'Biden','Trump')) as whowin
from (select precinct, max(Biden) as maxB, max(Trump) as maxT
	 from Penna
     where timestamp like '2020-11-11%'
	 group by precinct) new;
     
#8
select count(new.precinct) as Trumpwin
from (select precinct
      from Penna
      group by precinct
	  having max(Trump) > max(Biden)) new;

#9
select new.precinct, new.absvotes
from (select precinct, abs(max(Trump) - max(Biden)) as absvotes
      from Penna
	  group by precinct)new
where new.absvotes = (Select max(new1.absvotes) 
                              from ( select precinct, abs(max(Trump) - max(Biden)) as absvotes
                                     from Penna
                                     group by precinct)new1);
# my ninth query is trying to find which precinct has the largest difference in the final Vote, and what amout the difference is.