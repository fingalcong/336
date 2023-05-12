select beer 
from Sells 
where beer <> 'Hefeweizen'  and bar = 'Gecko Grill';

select distinct l.drinker 
from Likes l ,(select beer 
from Likes 
where drinker = 'Justin')JD
where JD.beer = l.beer and l.drinker <> 'Justin';

select f.drinker ,f.bar
from Frequents f ,Sells s, Likes l
where s.beer = l.beer and f.drinker = l.drinker and f.bar = s.bar;

select bar
from Frequents
where drinker = 'Justin' or drinker = 'Rebecca' and not exists(select f1.bar, f2.bar 
from Frequents f1, Frequents f2
where f1.drinker = 'Justin' and f2.drinker = 'Rebecca' and f1.bar = f2.bar);

select distinct f.drinker
from Frequents f, Likes l, Sells s
where l.beer = s.beer and s.bar = f.bar and l.drinker = f.drinker;

select s.bar
from Sells s, Likes l
where s.beer = l.beer and (l.drinker = 'John' or l.drinker = 'Rebecca') and s.price < 5;

select l1.drinker
from Likes l1, Likes l2
where l1.beer = 'Hefeweizen' and l2.beer = 'Killian''s' and l1.drinker = l2.drinker;

select name
from Bars
where name like 'The%'