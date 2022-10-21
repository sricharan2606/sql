select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503
-- Assignment Queries
1) Find the artist who has contributed with the maximum no of songs. Display the artist 
name and the no of albums.

select a.name as artist_name,count(*) as number_of_songs
from artist a join album al on a.artistid=al.artistid join track t on  t.albumid=al.albumid
group by a.name
order by 2 desc
select a.name as artist_name,count(*) as number_of_albums
from artist a join album al on a.artistid=al.artistid
group by a.name
order by 2 desc

2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.

select concat(c.firstname,' ',c.lastname) as customer_name,c.email,c.country,g.name
from invoice i join invoiceline il on i.invoiceid=il.invoiceid join track t on t.trackid=il.trackid
join genre g on g.genreid=t.genreid join customer c on c.customerid=i.customerid
where g.name in ('Rock','Jazz','Pop')

3) Find the employee who has supported the most no of customers. Display the employee name and designation
with final as (
select concat(e.firstname,' ',e.lastname) as emplyee_name,count(*),rank() over(order by count(*) desc)
from employee e join customer c  on e.employeeid=c.supportrepid
group  by concat(e.firstname,' ',e.lastname))
select* from final where rank=1

4) Which city corresponds to the best customers?
with final as (
select c.city,count(*),rank() over(order by count(*) desc) as rnk
from customer c join invoice i on i.customerid=c.customerid join invoiceline il on il.invoiceid=i.invoiceid
group by c.city
order by 2 desc)
select* from final where rnk =1

5) The highest number of invoices belongs to which country?
with final as (
select c.country,count(*),rank() over(order by count(*) desc) as rnk
from customer c join invoice i on i.customerid=c.customerid join invoiceline il on il.invoiceid=i.invoiceid
group by c.country
order by 2 desc)
select* from final where rnk =1

6) Name the best customer (customer who spent the most money).
with final as (
select concat(c.firstname,' ',c.lastname),sum(i.total),dense_rank() over(order by sum(i.total) desc) as rnk
from customer c join invoice i on i.customerid=c.customerid join invoiceline il on il.invoiceid=i.invoiceid
group by concat(c.firstname,' ',c.lastname)
order by 2 desc)
select* from final where rnk=1
	
7) Suppose you want to host a rock concert in a city and want to know which location should host it.
with final as (
select i.billingcity,billingpostalcode,count(*),rank()over(partition by billingcity
														  order by count(*) desc)
from invoiceline il join invoice i on i.invoiceid=il.invoiceid 
join track t on t.trackid=il.trackid join genre g on g.genreid=t.genreid
where g.name='Rock'
group by billingcity,billingpostalcode
)select * from final where rank=1
order by 3 desc

8) Identify all the albums who have less then 5 track under them.
select al.title,count(*)
from album al join track t on al.albumid=t.albumid
group by al.title
having count(*)<5
order by 2 desc

9) Display the track, album, artist and the genre for all tracks which are not purchased.
with final as (
select t.name as track_name,al.title as album_name,a.name as artist_name,g.name as genre_name
	from album al join track t on al.albumid=t.albumid join artist a 
on a.artistid=al.artistid join genre g on g.genreid=t.genreid
) ,
 sold as (
select t.name  as artist_1
from invoice i join invoiceline il 
on i.invoiceid=il.invoiceid join track t on t.trackid=il.trackid)
select* from final where track_name not in (select artist_1 from sold)


10) Find artist who have performed in multiple genres. Diplay the aritst name and the genre.

select a.name as artist_name,g.name as genre_name,count(*)
from artist a join album al on a.artistid=al.artistid
join track t on t.albumid=al.albumid join genre g on g.genreid=t.genreid
group by artist_name,genre_name
order by 3 desc



11) Which is the most popular and least popular genre? (Popularity is defined based on how many 
														times it has been purchased.)
	with final as (	
	select g.name as genre_name,count(*) ,rank() over(order by count(*) desc) as max,
	rank() over(order by count(*) ) as min
	from genre g join track t on g.genreid=t.genreid join invoiceline il  on t.trackid=il.trackid
	group by g.name
	order by 2 desc),
	cte as (
	select *
	from final where max=1 union all select* from final where  min=1)
	select c.genre_name,case when max=1 then 'most_popular_genre' else '0'
	 end as genre,case when min=1 
	then 'least_popular_genre'  else '0'
	end as genre
	from cte c
	

12) Identify if there are tracks more expensive than others. If there are then display the track 
name along with the album title and artist name for these expensive tracks.

 select t.name as track_name, al.title as album_name, art.name as artist_name
    from Track t
    join album al on al.albumid = t.albumid
    join artist art on art.artistid = al.artistid
    where unitprice > (select min(unitprice) from Track)

13) Identify the 5 most popular artist for the most popular genre. Display the artist name along with 
the no of songs. (Popularity is defined based on how many songs an artist has performed in for the
				  particular genre.)

with cte1 as (
            select g.name as genre_name,count(*),rank()over(order by count(*) desc) as rnk
            from invoice i join invoiceline il on i.invoiceid=il.invoiceid join track t 
            on t.trackid=il.trackid join  genre g on g.genreid=t.genreid
            group by g.name
            order by 2 desc
	       ),
	most_popular_genre as (
	           select* from cte1 where rnk=1),
	cte2 as (
	           select genre_name
	           from most_popular_genre),
	total as (select a.name,g.name as genre_name
			  from
               artist a join album al on a.artistid=al.artistid join track t on al.albumid=t.albumid join
              genre g on g.genreid=t.genreid),
			  final as (
			  select t.name as artist_name,count(*),rank() over(order by count(*) desc) as rnk
			  from total t join most_popular_genre mpg on t.genre_name=mpg.genre_name
			  group by t.name
			  order by 2 desc)
			  select* from final where rnk<6
			  
    
           	   
			   
		  
     





