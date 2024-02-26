--Q1: What are the top 3 values of total invoice
select * from (select billing_country as country , count(1),
rank()over(order by count(1) desc) as rank
from invoice
group by 1) x
where x.rank = 1

--Q2. What are the top 3 values of total invoice
select round(total::decimal , 2) as value from invoice
order by value desc
limit 3

--Q3.Which City has the best customers? We would like to throw a promotional Music Festival in
-- the city that has made the highest sum of invoice totals. Return both city names and sum of 
---all invoice totals

select billing_city as city  , round(sum(total)::decimal,2) from invoice
group by 1 
order by 2 desc
limit 1

--Q4. How each customer spent on each artist . Return customer name , artist name and total spent
with cte as
(select customer.last_name customer_name ,artist.name artist_name,
 invoice_line.unit_price * invoice_line.quantity total
from customer ---support_rep_id , customer id
join invoice   --invoice id , customer id , total 
on invoice.customer_id = customer.customer_id
join invoice_line  ---invoice id and track id 
on invoice.invoice_id = invoice_line.invoice_id
join  track
on track.track_id = invoice_line.track_id--track id  and genre id and album id
join  album --album_id artist id 
on album.album_id = track.album_id
join artist  --artist id
on artist.artist_id = album.artist_id)

select customer_name ,artist_name , round(sum(total)::decimal,2) total_spent from cte
group by customer_name ,artist_name
order by 1

--Q5. Find Out the most popular music Genre for each country . We determine the Most popular genre as the 
--genre with highest amount of purchases. Write a query that returns each country along with top genre.
--for countries where maximum number of purchases is shared return all genres

with cte as 
(select invoice.billing_country country , genre.name genre
from invoice
join invoice_line
on invoice.invoice_id  = invoice_line.invoice_id
join track
on track.track_id = invoice_line.track_id
join genre
on genre.genre_id = track.genre_id) 

select country , genre from 
(select country, genre , count(genre),
row_number()over(partition by country order by count(genre) desc) rn
from cte
group by country , genre) x
where x.rn = 1


--Q6.Write a query that determines the cusotmer that has spent the most on music for each country . write 
--a query that returns the country along with the top customer and how much they spent.
with cte as 
(select customer.last_name as name ,invoice.billing_country as country ,invl.unit_price * invl.quantity as total
from invoice
join customer
on invoice.customer_id = customer.customer_id
join  invoice_line invl
on invoice.invoice_id = invl.invoice_id)

select country ,name from 
(select name, country , sum(total),
row_number()over(partition by country order by 3 desc) rn
from cte
group by name,country 
) x
where x.rn =1

--Q7.write a query to return the email, first_name, last_name & genre of all Rock Music Lestener.
select * from
(select c.first_name, c.last_name,c.email,gn.name as genre_name
from customer  c--customer_id
join  invoice  inc --customer_id ,invoice_id
on inc.customer_id = c.customer_id
join invoice_line inl 
on  inl.invoice_id = inc.invoice_id-- invoice id and track_id
join track  tr
on tr.track_id = inl.track_id--track id , album_id , genre_id
join genre gn -- genre id
on gn.genre_id = tr.genre_id
order by 1) x
where x.genre_name = 'Rock'

--Q8.Return all track names that have a song lenth longer than the average song length.Return the Name
--Milliseconds for each track.Order by the song length with the longest songs listed first.

select name , milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc









