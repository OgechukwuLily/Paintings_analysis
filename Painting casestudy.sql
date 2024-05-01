
--Problem Statements
--1. Fetch all the paintings which are not displayed on any museums?
Select *
from work$
where Museum_id is null;

--2. Are there museums without any paintings?
Select *
from museum$ m
where not exists(select 1 from work$ w where w.museum_id=m.museum_id);

--3. How many paintings have an asking price of more than their regular price?
select *
from product_size$
where sale_price > regular_price;
--4. Identify the paintings whose asking price is less than 50% of its regular price
select *
from product_size$
where sale_price <(regular_price*0.5);
--5. Which canva size costs the most?
select top 1 cs.label as canvas_size,Ps.sale_price
from product_size$ Ps
join canvas_size$ cs
	on Cs.size_id =ps.size_id
order by ps.sale_price desc;

--6. Delete duplicate records from work, product_size, subject and image_link tables
With CTE as (
select *, row_number() over (partition by work_id order by (select null)) as rn
from work$)
delete from CTE
where rn>1;

--product_size
With CTE as (
select *, row_number() over (partition by work_id order by (select null)) as ps
from product_size$)
delete from CTE
where ps>1;

--subject
With CTE as (
select *, row_number() over (partition by subject order by (select null)) as cs
from subject$)
delete from CTE
where cs>1;

--image_link
With CTE as (
select *, row_number() over (partition by work_id order by (select null)) as ps
from image_link$)
delete from CTE
where ps>1;


--7. Identify the museums with invalid city information in the given dataset
select *
from museum$
where city like '%0%';

--8. Museum_Hours table has 1 invalid entry. Identify it and remove it.

select *
from museum_hours$
where day not in ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')
Update  museum_hours$ set day = 'Thursday'
where day = 'Thusday';
--9. Fetch the top 10 most famous painting subject
select top 10 subject, count(*) as Number_of_paintings
from Subject$
group by subject
order by subject;
--10. Identify the museums which are open on both Sunday and Monday. Display
--museum name, city.
select m.name as museum_name,m.city as museum_city
from museum_hours$ mh1
join museum_hours$ mh2
on mh1.museum_id = mh2.museum_id
join museum$ m on m.museum_id = mh1.museum_id
where mh1.day ='sunday'and
mh2.day= 'monday';
--11. How many museums are open every single day?
select  museum_id, count(distinct day) as open_day_count
from museum_hours$
where day in ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')
group by museum_id
having count(distinct day) = 7;

--12. Which are the top 5 most popular museum? (Popularity is defined based on most
--no of paintings in a museum)
select top 5 m.name,m.city,m.country, count(w.work_id) as Number_of_paintings
from museum$ m
join work$ w on m.museum_id = w.museum_id
group by m.name,m.city,m.country
order by Number_of_paintings desc;

--13. Who are the top 5 most popular artist? (Popularity is defined based on most no of
--paintings done by an artist)
select top 5 a.full_name,a.nationality, count(w.artist_id) as Number_of_paintings
from work$ w
join artist$ a on a.artist_id = w.artist_id
group by a.full_name,a.nationality
order by Number_of_paintings desc;

--14. Display the 3 least popular canva sizes
select top 3 cs.label, count(*)as Number_of_paintings
from work$ w
join canvas_size$ cs on w.work_id = cs.size_id
group by cs.label
order by Number_of_paintings asc;
--15. Which museum is open for the longest during a day. Dispay museum name, state
--and hours open and which day?
select top 1 m.name, m.state, h.day, h.[open], h.[close], datediff(minute,try_convert(time,h.[open]),try_convert(time,h.[close])) As duration
from museum$ m
join museum_hours$ h
on m.museum_id = h.museum_id
where h.[open] is not null and h.[close] is not null
order by duration desc;

--16. Which museum has the most no of most popular painting style?
select top 1 m.name as museum_name,w.style,count( w.work_id) as painting_style
from museum$ m
join work$ w on
m.museum_id = w.museum_id
group by m.name,w.style
order by painting_style desc;


--17. Identify the artists whose paintings are displayed in multiple countries
select top 9 a.full_name,count(w.work_id) as paintings_displayed
from work$ w
join artist$ a on a.artist_id = w.artist_id
--join museum$ m on m.museum_id = w.museum_id
group by a.full_name
order by paintings_displayed desc;

--18. Display the country and the city with most no of museums. Output 2 seperate
--columns to mention the city and country. If there are multiple value, seperate them
--with comma.
select top 1 country,city ,count(museum_id) as number_of_museums
from museum$
group by country, city
order by number_of_museums desc;

--19. Identify the artist and the museum where the most expensive and least expensive
--painting is placed. Display the artist name, sale_price, painting name, museum
--name, museum city and canvas label
select top 1 cs.label, a.full_name,w.name,ps.sale_price,m.name as museum_name,m.city
from artist$ a
Join work$ w on a.artist_id = w.artist_id
join museum$ m on w.museum_id = m.museum_id
join product_size$ ps on ps.size_id = w.work_id
Left join canvas_size$ cs on cs.size_id = ps.size_id
where ps.regular_price > ps.sale_price
Order by ps.sale_price desc;


--20. Which country has the 5th highest no of paintings?

select Top 1 country
from (select m.country, count(w.work_id) As number_of_paintings, row_number() over (order by count(w.work_id) desc) As ranking
from museum$ m
join work$ w on m.museum_id = w.museum_id 
group by m.country) As ranked_country
where ranking = 5;

--21. Which are the 3 most popular and 3 least popular painting styles?

select top 3 w.style, count(w.work_id) as painting_styles
from work$ w
group by w.style
order by painting_styles desc;
--least 3 popular

select top 3 w.style, count(w.work_id) as painting_styles
from work$ w
group by w.style
order by painting_styles Asc;
--22. Which artist has the most no of Portraits paintings outside USA?. Display artist
--name, no of paintings and the artist nationality.
select top 1 a.full_name,a.nationality,count(w.work_id) as No_of_Portraits
from artist$ a
join work$ w on a.artist_id = w.artist_id
join museum$ m on m.museum_id = w.museum_id
where m.country != 'USA'
group by a.full_name,a.nationality
order by count(w.work_id) desc;
