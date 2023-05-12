select name 
from Beers b
left join (select beer
           from Sells
		   where bar = 'Gecko Grill') new
on new.beer = b.name
where new.beer is Null;

select distinct l.drinker 
from Likes l
left join Likes l1
on l.beer = l1.beer
where l.drinker <> 'Justin' and l1.drinker = 'Justin';

select distinct * 
from Frequents f
where not exists (Select * 
                  from Frequents f1, Sells s,Likes l 
			      where f1.bar = s.bar and l.drinker = f1.drinker and s.beer = l.beer and f1.bar = f.bar and f1.drinker = f.drinker)
order by f.drinker, f.bar;

select distinct b.name
from Bars b
left join (select f.bar 
           from Frequents f
           where f.drinker = 'Justin') new
on b.name = new.bar
left join (select f1.bar
		   from Frequents f1
           where f1.drinker = 'Rebecca') m
on m.bar = b.name
where new.bar is NULL and m.bar is NULL;

select distinct drinker 
from Frequents 
where drinker not in (Select f.drinker 
                      from Frequents f 
                      where not exists (select l.drinker
                                        from Sells s,Likes l 
										where s.beer = l.beer and f.drinker = l.drinker and f.bar = s.bar));

select distinct name
from Bars b
left join (select s.bar 
           from Sells s
           where s.price < 5) new
on b.name = new.bar
where new.bar is NULL;

select new.bar 
from (select bar, avg(price) as avgprice
		from Sells
		group by bar)new
		where new.avgprice = (Select max(new1.avgprice)
					from ( select s.bar ,avg(price) as avgprice
							from Sells s
							group by bar)new1);

select bar, avg(price) as avgprice
from Sells
group by bar
order by avgprice desc;

select b.name 
from Bars b
where b.name like '% %';

select new.drinker
from (select drinker, count(beer) as countbeer
	  from Likes
      group by drinker) new
where new.countbeer = (select max(new1.countbeer)
                       from (select drinker, count(beer) as countbeer
                             from Likes
                             group by drinker) new1);
                       
select new.beer
from (select beer, avg(price) as avgprice
      from Sells
      group by beer) new
where new.avgprice = (select max(new1.avgprice)
                  from (select beer, avg(price) as avgprice
                        from Sells
                        group by beer) new1);

select new.bar 
from (select bar, price
		from Sells
        where beer = 'Budweiser'
		order by bar)new
		where new.price = (Select min(new1.price)
					from (select bar, price
		                  from Sells
						  where beer = 'Budweiser'
		                  order by bar)new1);		
                          
select f.drinker 
from Frequents f 
left join (select distinct f1.drinker 
           from Frequents f1
           left join Sells s 
           on f1.bar = s.bar
           where s.beer = 'Budweiser') new
on f.drinker = new.drinker
where new.drinker is NULL;

select b.name 
from Beers b
left join (select distinct s.beer
		   from Sells s
           left join Frequents f
           on s.bar = f.bar
           where f.drinker = 'Mike') new
on new.beer = b.name
where new.beer is NULL;

SELECT if(count(*)=(SELECT count(distinct l.drinker) FROM Likes l),'YES','NO') 
FROM Likes l1 group by l1.beer order by count(*) desc 
limit 1;

SELECT if(count(*)=(SELECT count(distinct l.drinker) FROM Likes l), l1.beer,'NO such a beer exists') 
FROM Likes l1 group by l1.beer order by count(*) desc 
limit 1