-- Spotify Project


-- create table
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

select * from spotify

-- EDA
select  count(*) from  spotify


select count(distinct artist) from spotify

select distinct album_type from spotify


select max(duration_min) from spotify
select min(duration_min) from spotify

select * from spotify
where duration_min = 0

-- Delete the data
delete from spotify
where duration_min = 0


select distinct channel from spotify


select distinct most_played_on from spotify
-- -------------------------------------------------------
-- Data Analysis Easy Catgory


-- Q1 Retrieve the names of all tracks that have more than 1 billion streams.

select * from spotify
where stream > 1000000000


-- Q2 List all albums along with their respective artists.
select 
	distinct album,
	artist
from spotify
order by 1


-- Q3 Get the total number of comments for tracks where `licensed = TRUE`.

select  
	sum(comments) as total_comments
from spotify
where licensed = 'true'


-- Q4 Find all tracks that belong to the album type `single`.

select * from spotify
where album_type = 'single'


-- Q5 Count the total number of tracks by each artist.

select 
	artist,
	count(*) as total_no_tracks
from spotify
group by 1
order by 2 desc


-- --------------------------------------------------------------------

-- Medium LEVEL

-- Q6 Calculate the average danceability of tracks in each album.

select 
	album,
	avg(danceability) as avg_danceability
from spotify 
group by 1
order by 2 desc


-- Q7  Find the top 5 tracks with the highest energy values.

select 
	track,
	avg(energy) as avg_energy
	
from spotify
group by 1
order by 2 desc


-- Q8 List all tracks along with their views and likes where `official_video = TRUE`.

select 
	track,
	sum(views) as total_views,
	sum(likes) as total_likes
	
from spotify
where official_video = 'true'
GROUP by 1
order by 2 desc
limit 5


-- Q9 For each album, calculate the total views of all associated tracks.

select 
	album,
	track,
	sum(views)
from spotify
group by 1,2
order by 3 desc

-- Q10  Retrieve the track names that have been streamed on Spotify more than YouTube.

select * from
(
select 
	track,
	-- most_played_on,
	COALESCE(sum(case when most_played_on = 'Youtube' then stream end),0) as stremed_on_youtube,
	coalesce(sum(case when most_played_on = 'Spotify' then stream end),0) as stremed_on_spotify
from spotify
group by 1
) as t1
where 
	stremed_on_spotify > stremed_on_youtube
	and
	stremed_on_youtube != 0





-------------------------------------------------------------
-- Hard Level

-- Q11   Find the top 3 most-viewed tracks for each artist using window functions.

with  ranking_artist as
(
select 
	artist,
	track,
	sum(views) as total_views,
	dense_rank() over(partition by artist order by sum(views)  desc) as rank
from spotify
group by 1 , 2
order by 1 , 3 desc
) 

select * from ranking_artist
where rank <= 3


-- Q12 	Write a query to find tracks where the liveness score is above the average.

select * from spotify
where  liveness > (select 
					avg(liveness)
					from spotify)


-- Q13 Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album

with cte as
(
select 
	album,
	max(energy) as highest_energy,
	min(energy) as lowest_energy
from spotify
group by 1
)
select 
	album,
	highest_energy - lowest_energy as energy_avg
	
from cte
order by 2 desc


-- Q14 Find tracks where the energy-to-liveness ratio is greater than 1.2.

select track ,energy_liveness  from spotify
where energy_liveness > 1.2


-- Q15 Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

select 
	track,
	views,
	likes,
	sum(likes) over(order by views desc) as cumulative_likes
from spotify



-- Q16 Correlation Check: Do more energetic tracks get more views?

select 
	corr(energy , views) as enegery_views_corr
from spotify
where views is not null and energy is not null
/*

- 0.069 is a very weak positive correlation.

- This suggests that there is almost no linear relationship between a track's energy and its views.

- In other words, energetic songs are not significantly more likely to get more views than less energetic ones — at least in your current dataset.
*/




-- Q17  Top 10 Most Liked Tracks Per Channel (Window Function)

with most_liked as
(
select 
	track,
	channel,
	likes as total_likes,
	dense_rank() over(partition by channel order by likes desc ) as rank
from spotify
where likes is not null
)
select * from  most_liked
where rank<= 10




-- Q18 Artist Stream Share (% of Total Streams)

select 
	artist,
	sum(stream) as total_stream,
	round((sum(stream) / (select sum(stream) from spotify)) * 100.0,2) as percent_of_stream_share
from spotify
group by 1
order by 2 desc
limit 10


-- Q19 Tracks with Above-Average 
--		Loudness and Tempo (Energetic & Fast)

select avg(loudness) from spotify -- -7.67
select avg(Tempo) from spotify -- 120.57

select 
	track,
	loudness,
	Tempo
from spotify
where 
	loudness > (select avg(loudness) from spotify)
	and
	Tempo > (select avg(Tempo) from spotify)



-- 20 Track-to-Track Progression for Each Artist

select 
	artist,
	track,
	stream,
	lag(stream) over(partition by artist order by stream) as prev_stream,
	stream - LAG(stream) over(partition by artist order by stream) as stream_change
from spotify
where stream is not null







-- query optimaztion

Explain analyze
select 
	artist,
	track,
	views
from spotify
where 
	most_played_on = 'Youtube'
order by stream desc



create index artist_index on spotify(artist)
drop index artist_index