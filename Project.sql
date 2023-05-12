#Part 1
# precinct -> state, locality, geo
select *
from Penna s, Penna t
where  (s.precinct = t.precinct ) and (t.state!=s.state OR t.locality!= s.locality or t.geo != s.geo);

# Timestamp, precinct -> ID, totalvotes, Biden, Trump, filestamp
select *
from Penna s, Penna t
where  (s.Timestamp = t.Timestamp and s.precinct = t.precinct) and (t.ID != s.ID or t.totalvotes!=s.totalvotes OR t.Biden!= s.Biden or t.Trump != s.Trump or s.filestamp != t.filestamp);

#FDs: Precinct -> state, locality, and geo. Precinct and timestamp together become the super key

# decompose the table into 2 BCNF tables
#The first one is decomposed to state, locality, precinct, and geo. Precinct -> state, locality, and geo. This table is the referenced table for foreign key constraint.

CREATE TABLE `testDB`.`referenced` ( 
  `state` VARCHAR(255)  , 
  `locality` VARCHAR(255) , 
  `precinct` VARCHAR(255) , 
  `geo` VARCHAR(255) , 
  PRIMARY KEY (`precinct`));
  
#The second one is decomposed to ID, timestamp, precinct, totalvotes, Biden, Trump, filestamp. Precinct & timestamp -> ID, totalvotes, Biden, Trump and filestamp. This table is the referencing table and the foreign key is precinct.

CREATE TABLE `testDB`.`referencing` ( 
  `ID` INT NOT NULL PRIMARY KEY, 
  `Timestamp` DATETIME NULL, 
  `precinct` VARCHAR(255) NULL, 
  `totalvotes` INT NULL, 
  `Biden` INT NULL, 
  `Trump` INT NULL, 
  `filestamp` VARCHAR(255) NULL,
  foreign key (`precinct`) references referenced(precinct)); 
  
#Part 2 
# 1) Precinct
# a)
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

# b)
delimiter //
create procedure RankAll (In precinctname VARCHAR(255))
begin

select new.rankprecinct
from (select rank() over (order by totalvotes desc) as rankprecinct, precinct
from Penna
where timestamp = (select max(timestamp) from Penna)
order by rankprecinct) as new
where new.precinct = precinctname;

end;//

# c)
delimiter //
create procedure RankCounty (In precinctname VARCHAR(255))
begin

select new.rankprecinct
from (select rank() over (order by totalvotes desc) as rankprecinct, precinct
from Penna
where timestamp = (select max(timestamp) from Penna) and locality = (select locality 
from Penna
where precinct = precinctname limit 1)
) as new
where new.precinct = precinctname;

end;//

# d)
delimiter //
create procedure PlotPrecinct (In precinctname VARCHAR(255))
begin

select Biden, Trump, totalvotes, timestamp
from penna
where precinct = precinctname
order by timestamp;

end;//

# e)
delimiter //
create procedure EarliestPrecinct (In vote_count VARCHAR(255))
begin

select precinct, timestamp, totalvotes
from Penna
where totalvotes >= vote_count and timestamp = (select timestamp from penna where totalvotes >= vote_count order by timestamp limit 1)
order by totalvotes desc limit 1;

end;//

# 2) candidates
# a)
delimiter // 
create procedure PrecinctsWon (In candidate VARCHAR(255))
begin

if candidate = 'Biden' then
select precinct, (Biden - Trump) as difference, Biden
from penna
where timestamp = (select max(timestamp)
from Penna) and Biden > Trump
order by difference;

elseif candidate = 'Trump' then
select precinct, (Trump - Biden) as difference, Trump
from penna
where timestamp = (select max(timestamp)
from Penna) and Trump > Biden
order by difference;
end if;
end;//

# b)
delimiter //
create procedure PrecinctsWonCount (In candidate VARCHAR(255))
begin

if candidate = 'Biden' then
select 'Biden', count(precinct) as numBiden
from Penna
where timestamp = (select max(timestamp)
                   from Penna) and Biden > Trump
order by 'Biden';

elseif candidate = 'Trump' then
select 'Trump', count(precinct) as numTrump
from Penna
where timestamp = (select max(timestamp)
                   from Penna) and Trump > Biden
order by 'Trump';
end if;
end;//

# c)
create procedure PrecinctsFullLead (In candidate VARCHAR(255))
begin

if candidate = 'Biden' then
select precinct
from penna
where Biden > Trump 
group by precinct
having count(precinct) = 217;

elseif candidate = 'Trump' then
select precinct
from Penna
where Trump > Biden
group by precinct
having count(precinct) = 217;

end if;
end;//

# d)
delimiter //
create procedure PlotCandidate (In candidate VARCHAR(255))
begin

if candidate = 'Biden' then
select sum(Biden), timestamp
from penna
group by timestamp;

elseif candidate = 'Trump' then
select sum(Trump), timestamp
from penna
group by timestamp;

end if;
end;//

# e)
delimiter //
create procedure PrecinctsWonTownships() #(IN candidate VARCHAR(255))
begin

select if (maxB>maxT,'Biden','Trump') as winner, precinct, abs(maxT - maxB) as difference, maxT, maxB
from (select precinct, max(Biden) as maxB, max(Trump) as maxT
	 from Penna
	 group by precinct
     having precinct like '%Township%') new
     group by precinct;

end;//

# 3) timestamp
# a)
delimiter //
create procedure TotalVotes(IN timespecified VARCHAR(255), IN category VARCHAR(255))
begin

if category = 'Biden' then
select precinct, Biden
from penna
where timestamp = timespecified
group by precinct;

elseif category = 'Trump' then
select precinct, Trump
from penna
where timestamp = timespecified
group by precinct;

elseif category = 'ALL' then
select precinct, totalvotes
from penna
where timestamp = timespecified
group by precinct;

end if;
end;//
delimiter;

# b)
create table `testdb`.`DeltaGain` (
   `rank` int,
   `timestamp` VARCHAR (255),
   `SumOfVotes` VARCHAR (255),
   PRIMARY KEY (`RANK`));

Insert into DeltaGain
    select rank() over (order by timestamp) as 'Rank', timestamp, sum(totalvotes)
    from Penna
    group by timestamp;
    
delimiter //
create procedure GainDelta(IN timespecified DATEtime) 
begin

select timestampdiff(minute, b.timestamp, a.timestamp) as Delta,  (a.SumOfVotes - b.SumOfVotes) as Gain, (a.SumOfVotes - b.SumOfVotes)/timestampdiff(minute, b.timestamp, a.timestamp) as ratio
from DeltaGain a
left join DeltaGain b on (b.Rank = a.Rank - 1)
where a.timestamp = timespecified;

end;//

# c)
delimiter //
create procedure RankTimestamp() 
begin

select rank() over (order by (a.SumOfVotes - b.SumOfVotes)/timestampdiff(minute, b.timestamp, a.timestamp) desc) as ranktimestamp, a.timestamp, (a.SumOfVotes - b.SumOfVotes)/timestampdiff(minute, b.timestamp, a.timestamp) as ratio
from DeltaGain a
left join DeltaGain b on (b.Rank = a.Rank - 1);

end;//

# d)
delimiter //
create procedure VotesPerDay(IN day VARCHAR(255)) 
begin

select timestamp, precinct, Biden, Trump, totalvotes
from Penna
where timestamp like concat ('2020-11-%', day, ' %');

end;//

# 4) suspicious or interesting data
# For this part I would like to check if there is one candidate (either Biden or Trump) won a whole locality at last, 
#if there is someone who won the whole locality. 
#It may be suspicious.
delimiter // 
create procedure LocalityWon (In candidate VARCHAR(255))
begin

if candidate = 'Biden' then
select locality, sum(Biden)
from penna
where timestamp =  (select max(timestamp)
from Penna)
group by locality
having sum(Biden) > sum(Trump);

elseif candidate = 'Trump' then
select locality, sum(Trump)
from penna
where timestamp =  (select max(timestamp)
from Penna)
group by locality
having sum(Trump) > sum(Biden);

end if;
end;//

# after running this procedure, we can find that Trump only won three localities, and Biden won six localities.
# There was a huge difference of votes in Philedophia, but for the other localities, the difference was not that huge.
# It is suspicious, and the result of the voting in Philedophia should be checked carefully again to find if there is some problem with it.

#Part 3
# a)
select if(Trump + Biden <= totalvotes, 'True', 'False') as SumDecision
from Penna;

# b)
select if(timestamp >= '2020-11-12 00:00' or timestamp < '2020-11-03 00:00', 'False', 'True') as IfCorrectTime
from Penna
group by timestamp;

# c)
select if(p.totalvotes<a.totalvotes,'False','True') as totalvotes,if(p.Biden<a.Biden,'False','True') as Biden,if(p.Trump<a.Trump,'False','True') as Trump
from penna p,
(select precinct,totalvotes,Biden,Trump
from penna
where timestamp = (select timestamp from penna
where timestamp < '2020-11-05 00:00'
order by timestamp desc limit 1))a
where timestamp >'2020-11-05 00:00' and p.precinct = a.precinct
order by p.timestamp;

# Part 4
delimiter // 
create procedure insertionmodification (In IDS INT, In timestamp Varchar(255), IN state VARCHAR(255), IN locality VARCHAR(255), IN precinct VARCHAR(255),
IN geo VARCHAR(255), IN totalvotes INT, IN Biden INT, IN Trump INT, IN filestamp VARCHAR(45))
begin

if totalvotes < Biden + Trump then
  SIGNAL SQLSTATE '45000'
  set message_text = 'Violation part3 a';
elseif timestamp >= '2020-11-12 00:00' or timestamp < '2020-11-03 00:00' then
  SIGNAL SQLSTATE '45000'
  set message_text = 'Violation part3 b';
elseif IDS = (select DISTINCT IDS from penna where IDS = ID) then
  SIGNAL SQLSTATE '45000'
  set message_text = 'Violation of primary key';
#elseif foreignkey != (select foreignkey from penna) then
 # SIGNAL SQLSTATE '45000'
  #set message_text = 'Violation of foreign key';
else
  SIGNAL SQLSTATE '45000'
  set message_text = 'insertion accepted';
end if;
end;//
# 4.1
# a)
CREATE TABLE `testDB`.`UpdatedTuples` ( 
  `ID` INT NULL, 
  `Timestamp` DATETIME NULL, 
  `state` VARCHAR(45) NULL, 
  `locality` VARCHAR(45) NULL, 
  `precinct` VARCHAR(45) NULL, 
  `geo` VARCHAR(45) NULL, 
  `totalvotes` INT NULL, 
  `Biden` INT NULL, 
  `Trump` INT NULL, 
  `filestamp` VARCHAR(45) NULL);
  
  CREATE TABLE `testDB`.`InsertedTuples` ( 
  `ID` INT NULL, 
  `Timestamp` DATETIME NULL, 
  `state` VARCHAR(45) NULL, 
  `locality` VARCHAR(45) NULL, 
  `precinct` VARCHAR(45) NULL, 
  `geo` VARCHAR(45) NULL, 
  `totalvotes` INT NULL, 
  `Biden` INT NULL, 
  `Trump` INT NULL, 
  `filestamp` VARCHAR(45) NULL);
  
  CREATE TABLE `testDB`.`DeletedTuples` ( 
  `ID` INT NULL, 
  `Timestamp` DATETIME NULL, 
  `state` VARCHAR(45) NULL, 
  `locality` VARCHAR(45) NULL, 
  `precinct` VARCHAR(45) NULL, 
  `geo` VARCHAR(45) NULL, 
  `totalvotes` INT NULL, 
  `Biden` INT NULL, 
  `Trump` INT NULL, 
  `filestamp` VARCHAR(45) NULL);
  
#create triger for insertion for penna
delimiter // 
create trigger InsertionTrigger
before insert on penna
for each row
begin 
insert into Insertedforreferenced Values( new.state, new.locality, new.precinct, new.geo);
end;//

#create trigger for deletion for penna
delimiter // 
create trigger DeletionTrigger
before delete on penna
for each row
begin 
insert into DeletedTuples Values(old.ID, old.timestamp, old.state, old.locality, old.precinct, old.geo, old.totalvotes, old.Biden, old.Trump, old.filestamp);
end;//

#create trigger for update for penna
delimiter // 
create trigger UpdateTrigger
before Update on penna
for each row
begin 
insert into UpdatedTuples Values(old.ID, old.timestamp, old.state, old.locality, old.precinct, old.geo, old.totalvotes, old.Biden, old.Trump, old.filestamp);
end;//

#create tables for referencing
CREATE TABLE `testDB`.`UpdatedforReferencing` ( 
  `ID` INT NULL, 
  `Timestamp` DATETIME NULL, 
  `precinct` VARCHAR(45) NULL, 
  `totalvotes` INT NULL, 
  `Biden` INT NULL, 
  `Trump` INT NULL, 
  `filestamp` VARCHAR(45) NULL);
  
  CREATE TABLE `testDB`.`InsertedforReferencing` ( 
  `ID` INT NULL, 
  `Timestamp` DATETIME NULL, 
  `precinct` VARCHAR(45) NULL, 
  `totalvotes` INT NULL, 
  `Biden` INT NULL, 
  `Trump` INT NULL, 
  `filestamp` VARCHAR(45) NULL);
  
  CREATE TABLE `testDB`.`DeletedforReferencing` ( 
  `ID` INT NULL, 
  `Timestamp` DATETIME NULL, 
  `precinct` VARCHAR(45) NULL, 
  `totalvotes` INT NULL, 
  `Biden` INT NULL, 
  `Trump` INT NULL, 
  `filestamp` VARCHAR(45) NULL);
  
  # create trigger for referencing 
delimiter // 
create trigger InsertionTriggerReferencing
before insert on Referencing
for each row
begin 
insert into InsertedforReferenced Values(new.ID, new.timestamp, new.precinct,  new.totalvotes, new.Biden, new.Trump, new.filestamp);
end;//

delimiter // 
create trigger DeletionTriggerReferencing
before delete on Referencing
for each row
begin 
insert into DeletedforReferenced Values(old.ID, old.timestamp,  old.precinct,  old.totalvotes, old.Biden, old.Trump, old.filestamp);
end;//

delimiter // 
create trigger UpdateTriggerReferencing
before Update on Referencing
for each row
begin 
insert into updatedforreferenced Values(old.ID, old.timestamp,  old.precinct, old.totalvotes, old.Biden, old.Trump, old.filestamp);
end;//

#create tables for referenced
CREATE TABLE `testDB`.`UpdatedforReferenced` ( 
  `state` VARCHAR(45) NULL, 
  `locality` VARCHAR(45) NULL, 
  `precinct` VARCHAR(45) NULL, 
  `geo` VARCHAR(45) NULL);
  
  CREATE TABLE `testDB`.`InsertedforReferenced` ( 
  `state` VARCHAR(45) NULL, 
  `locality` VARCHAR(45) NULL, 
  `precinct` VARCHAR(45) NULL, 
  `geo` VARCHAR(45) NULL);
  
  CREATE TABLE `testDB`.`DeletedforReferenced` ( 
  `state` VARCHAR(45) NULL, 
  `locality` VARCHAR(45) NULL, 
  `precinct` VARCHAR(45) NULL, 
  `geo` VARCHAR(45) NULL);
  
  # create trigger for referenced
  delimiter // 
create trigger InsertionTriggerreferenced
before insert on referenced
for each row
begin 
insert into Insertedforreferenced Values( new.state, new.locality, new.precinct, new.geo);
end;//

delimiter // 
create trigger DeletionTriggerreferenced
before delete on referenced
for each row
begin 
insert into deletedforreferenced Values(old.state, old.locality, old.precinct, old.geo);
end;//

delimiter // 
create trigger UpdateTriggerreferenced
before Update on referenced
for each row
begin 
insert into updatedforreferenced Values(old.state, old.locality, old.precinct, old.geo);
end;//

# 4.2
#delimiter // 
#create procedure MoveVotes(IN Precinct VARCHAR(255), IN Timest VARCHAR(255), IN CoreCandidate VARCHAR(255), IN Number_of_Moved_Votes INT)
#begin

delimiter //
create procedure MoveVotes(IN PrecinctIn VARCHAR(255),IN Timest VARCHAR(255),IN CoreCandidate VARCHAR(255),IN Number_of_Moved_Votes INT)  
begin 
IF (EXISTS(select precinct from penna where precinct = PrecinctIn)) then 
 IF (EXISTS(select timestamp from penna where timestamp = Timest)) then
  IF CoreCandidate = 'Biden' then 
   IF (exists (select Biden from Penna where Biden >= Number_of_Moved_Votes)) THEN
	SET SQL_SAFE_UPDATES=0;
    update penna 
    set Biden = Biden - Number_of_Moved_Votes, Trump = Trump + Number_of_Moved_Votes 
    where precinct = PrecinctIn and timestamp >= Timest;
    SET SQL_SAFE_UPDATES=1;
    ElSE
    SIGNAL SQLSTATE '45000'
    set message_text = 'Not enough votes';
    end if;
  ELSEIF CoreCandidate = 'Trump' then 
    IF (exists (select Trump from Penna where Trump >= Number_of_Moved_Votes)) THEN
      SET SQL_SAFE_UPDATES=0;
      update penna 
      set Trump = Trump - Number_of_Moved_Votes, Biden = Biden + Number_of_Moved_Votes 
      where precinct = PrecinctIn and timestamp >= Timest;
      SET SQL_SAFE_UPDATES=1;
    ELSE
      SIGNAL SQLSTATE '45000'
      set message_text = 'Not enough votes';
    end if;
  ELSE
    SIGNAL SQLSTATE '45000'
    set message_text ='Wrong Candidate';
  end if;
 ELSE
  SIGNAL SQLSTATE '45000'
  set message_text = 'Unknown Timestamp';
 end if;
ELSE    
   SIGNAL SQLSTATE '45000'
   set message_text = 'Unknown Precinct';
        end if;
 end; //
delimiter ;

# a simple test
call MoveVotes('HAINES','2020-11-11 00:16:54','Biden','14');
call MoveVotes('HAINES','2020-11-11 00:16:54','Biden',1)

