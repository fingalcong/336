CREATE TABLE `TripAdvisor` ( 
   `restaurant` VARCHAR(45) not NULL,  
   `rank` INT NULL, 
   `score` INT NULL, 
   `user_name` VARCHAR(45) NULL, 
   `review_stars` INT NULL, 
   `review_date` DATETIME NULL, 
   `user_reviews` INT NULL,
   `user_restaurant_reviews` INT NULL,
   `USER_HELPFUL_VOTES` INT NULL,
   PRIMARY KEY (`restaurant`));

SET SQL_SAFE_UPDATES=0;
DELETE
FROM testDB.tripadvisor t
where t.USER_NAME = '0';
DELETE
FROM testDB.tripadvisor t
where t.USER_NAME = 'GosiaKJ' ;
DELETE
FROM testDB.tripadvisor t
where t.USER_NAME like '%...%';
SET SQL_SAFE_UPDATES=1;

#3
select if (count(new.restaurantS) = 0, 'True', 'False')
from (select s.restaurant as restaurantS
from testdb.tripadvisor s, testdb.tripadvisor t
where  (t.Restaurant=s.Restaurant) and (t.rank!=s.rank OR t.score!= s.score)) new;

select if (count(new.UsernameS) = 0, 'True', 'False')
from (select s.USER_NAME as UsernameS
from testdb.tripadvisor s, testdb.tripadvisor t
where  (t.USER_NAME=s.USER_NAME) and (t.REVIEW_DATE =s.REVIEW_DATE) and (t.USER_REVIEWS !=s.USER_REVIEWS OR t.USER_RESTAURANT_REVIEWS !=s.USER_RESTAURANT_REVIEWS OR t.USER_HELPFUL_VOTES != s.USER_HELPFUL_VOTES)) new;

select if (count(new.ReviewS) = 0, 'True', 'False')
from (select s.review_stars as reviews
from testdb.tripadvisor s, testdb.tripadvisor t
where (t.USER_NAME=s.USER_NAME) and (t.REVIEW_DATE =s.REVIEW_DATE) and (t.Restaurant=s.Restaurant) and (t.REVIEW_STARS !=s.REVIEW_STARS))new;

#4
CREATE TABLE RESTAURANT as(
select distinct t.RESTAURANT,t.RANK,t.SCORE
FROM testDB.tripadvisor t);

CREATE TABLE USER as(
select t.USER_NAME,t.USER_REVIEWS,t.USER_HELPFUL_VOTES,t.REVIEW_DATE, USER_RESTAURANT_REVIEWS
FROM testDB.tripadvisor t);

CREATE TABLE REVIEWS as(
select t.RESTAURANT,t.USER_NAME,t.REVIEW_STARS,t.REVIEW_DATE
FROM testDB.tripadvisor t);

#6
Create table REJOIN as(
select new.restaurant, r.rank, r.score, new.USER_NAME, new.REVIEW_STARS, new.REVIEW_DATE, new.USER_REVIEWS, new.USER_RESTAURANT_REVIEWS, new.USER_HELPFUL_VOTES
from restaurant r Inner join
(select distinct s.RESTAURANT, t.USER_NAME, s.REVIEW_STARS, t.REVIEW_DATE, t.USER_REVIEWS, t.USER_HELPFUL_VOTES, USER_RESTAURANT_REVIEWS
from reviews s INNER JOIN user t 
on s.REVIEW_DATE = t.REVIEW_DATE and s.USER_NAME = t.USER_NAME) NEW
on r.restaurant = new.restaurant);

select count(restaurant) from rejoin1;
select count(restaurant) from tripadvisor


