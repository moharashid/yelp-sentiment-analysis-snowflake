USE DATABASE MY_PROJECTS
--select * from tbl_yelp_businesses
--1. find number of businesses in each category
--need to split the categories column
with cte as (
select business_id, trim(A.value) as category
from tbl_yelp_businesses,
lateral split_to_table(categories,',') A
)
select category, count(*) as no_of_businesses
from cte
group by 1
order by 2 desc

--2. Find the top 10 users who have reviewed the most businesses in the "Restaurant" categories
select r.user_id, count(DISTINCT r.business_id)
from tbl_reviews r
inner join tbl_yelp_businesses b on r.BUSINESS_ID=b.BUSINESS_ID
where b.categories ilike '%restaurant%'
group by 1
order by 2 desc
limit 10

--3. Find the most popular categories of businesses based on the number of reviews
select * from tbl_reviews limit 5
with cte as (
select business_id, trim(A.value) as category
from tbl_yelp_businesses,
lateral split_to_table(categories,',') A
)
select category, count(*) as no_of_reviews
from cte
inner join tbl_reviews r on cte.business_id = r.business_id
group by 1
order by 2 desc
--find 5 star reviews based on category
with cte as (
select business_id, trim(A.value) as category
from tbl_yelp_businesses,
lateral split_to_table(categories,',') A
)
select category, count(*) as no_of_reviews
from cte
inner join tbl_reviews r on cte.business_id = r.business_id
where r.review_stars =5
group by 1
order by 2 desc
--4-Find the top 3 most recent reviews for each business
select * from tbl_reviews limit 5
with cte as (
select business_id, trim(A.value) as category
from tbl_yelp_businesses,
lateral split_to_table(categories,',') A
)
select category, count(*) as no_of_reviews, r.review_date
from cte
inner join tbl_reviews r on cte.business_id = r.business_id
group by 1,3
order by 3 desc
limit 3
--5-find month with the highest number of reviews
select * from tbl_reviews limit 5
select month(review_date) as review_month, year(review_date) as review_year, count(*) as no_of_reviews
from tbl_reviews
group by 1,2
order by 3 desc
--6-Find the percentage of 5-star reviews for each business
select b.name,r.business_id, count(*) as total_reviews,
count(case when r.review_stars =5 then 1 else null end) as five_star_reviews,
round(five_star_reviews*100/total_reviews,2) as percentage_of_five_star_reviews
from tbl_reviews r
inner join tbl_yelp_businesses b on r.business_id=b.business_id
group by 1,2
select * from tbl_yelp_businesses limit 5
--7 Find the top 5 most reviewed businesses in each city
with cte as(
select b.city,b.name,r.business_id,count(*) as total_reviews 
from tbl_reviews r
inner join tbl_yelp_businesses b on r.business_id=b.business_id
group by 1,2,3
)
select *
from cte
qualify row_number() over (partition by city order by total_reviews desc) <=5

--8 Find the average rating of businesses that have atleast 100 reviews
with cte as (
select r.business_id, b.name, count(*) as total_reviews, round(avg(r.review_stars),2) as average_rating
from tbl_reviews r
inner join tbl_yelp_businesses b on r.business_id = b.business_id
group by 1,2
)
select *
from cte
having total_reviews >= 100
order by total_reviews desc
--method 2
select r.business_id, b.name, count(*) as total_reviews, round(avg(r.review_stars),2) as average_rating
from tbl_reviews r
inner join tbl_yelp_businesses b on r.business_id = b.business_id
group by 1,2
having total_reviews >=100
order by 3 desc

--9- List the top 10 users with the most reviews, along with the business they reviewed
select r.user_id,b.name,count(*) as no_of_reviews
from tbl_reviews r
inner join tbl_yelp_businesses b on r.business_id = b.business_id
group by 1,2
order by 3 desc
limit 10

--method 2
with cte as(
select r.user_id, count(*) as total_reviews 
from tbl_reviews r 
inner join tbl_yelp_businesses b on r.business_id=b.business_id
group by 1
order by 2 desc
limit 10
)
select user_id, business_id
from tbl_reviews where user_id in (select user_id from cte)
group by 1,2
order by 1

--10 - Find top 10 businesses with highest positive sentiment reviews
select r.business_id, b.name, count(case when sentiment ='Positive' then 1 else null end) as positive_sentiment
from tbl_reviews r
inner join tbl_yelp_businesses b on r.business_id=b.business_id
group by 1,2
order by 3 desc
limit 10

--method 2 -- use countif if supported
SELECT r.business_id, b.name, COUNTIF(sentiment = 'Positive') AS positive_sentiment
FROM tbl_reviews r
INNER JOIN tbl_yelp_businesses b ON r.business_id = b.business_id
GROUP BY 1, 2
ORDER BY positive_sentiment DESC
LIMIT 10;


