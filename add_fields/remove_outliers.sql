--##################################################################
--# Run
--##################################################################
--# REMOVE DUPES.
select workoutid from run group by altitude, heart_rate, latitude, longitude, speed, workoutid, time having count(*) > 1; 

--# Need to remove them.
ALTER TABLE run ADD COLUMN id SERIAL PRIMARY KEY;
DELETE FROM run
WHERE id IN (SELECT id
              FROM (SELECT id,
                             ROW_NUMBER() OVER (partition BY altitude, heart_rate, latitude, longitude, speed, workoutid, time ORDER BY id) AS rnum
                     FROM run) t
              WHERE t.rnum > 1);
ALTER TABLE run drop column id;
--# DELETE 136,868

--##################################################################
--##################################################################
--## First speed deriv is garbage - action :
--# Many < 0 speed look like a false negative, so lets make them positive
update run set speed = speed * -1 where speed < 0;
--# UPDATE 1422

--# Get average:
SELECT avg(speed) AS average FROM run where speed < 50 and speed > 0;
--# Use this value as default value


--# Still too many > 50kph (30mph, no one that fast).
--# 3,465 workouts with one or more speed entries over 50.
--# 28,342 / 139,920,713. Just set them to 10 (as it is .02% of the entries)
update run set speed = 10 where speed > 50;


endomondo=# select * from histogram('speed', 'run');

 bucket |             range             |   freq   |       bar       
--------+-------------------------------+----------+-----------------
      1 | [0.0000000000,2.4999998000]   |  1442567 | *
      2 | [2.5000000000,4.9999995000]   |  1683932 | *
      3 | [5.0000000000,7.4999995000]   |  4073669 | **
      4 | [7.5000000000,9.9999990000]   | 13902965 | ********
      5 | [10.0000000000,12.4999950000] | 25086432 | ***************
      6 | [12.5000000000,14.9999990000] | 12160945 | *******
      7 | [15.0000000000,17.4999660000] |  2931645 | **
      8 | [17.5000000000,19.9999800000] |   734838 | 
      9 | [20.0000000000,22.4999980000] |   267828 | 
     10 | [22.5000000000,24.9999050000] |   158415 | 
     11 | [25.0000000000,27.4998100000] |   116425 | 
     12 | [27.5000200000,29.9999710000] |    89660 | 
     13 | [30.0000000000,32.4999120000] |    69591 | 
     14 | [32.5002200000,34.9997940000] |    50037 | 
     15 | [35.0000000000,37.4994280000] |    34776 | 
     16 | [37.5000000000,39.9996760000] |    24732 | 
     17 | [40.0001070000,42.4999240000] |    18246 | 
     18 | [42.5002860000,44.9999960000] |    11817 | 
     19 | [45.0000000000,47.4984000000] |    47965 | 
     20 | [47.5019000000,49.9968000000] |     2663 | 
     21 | [50.0000000000,50.0000000000] |        2 | 
--# Much better, generate first deriv again


select now(); 
with dev_list as (
	select round((speed_difference / time_difference),5) as deriv, 
	       time, 
	       workoutid 
	       from ( 
		select speed_difference, 
		       case when time_difference = 0 then 1 else time_difference end as time_difference, 
		       time, 
		       workoutid 
		       from (
			select speed - lag(speed) over (partition by workoutid order by time) as speed_difference, 
			       time - lag(time) over (partition by workoutid order by time) as time_difference, 
			       speed, 
			       time, 
			       workoutid 
			    from run order by time) 
		as foo) 
	as bar 
	order by workoutid, 
	         time )
update run r1 
  set speed_first = d1.deriv 
  from dev_list as d1 
  where d1.workoutid = r1.workoutid and 
        d1.time = r1.time;
select now();



--##################################################################
--##################################################################
--## First altitude deriv is garbage - action :

select count(*) from (
	with dev_list as ( 
		select avg(altitude), stddev(altitude), workoutid from run group by workoutid )
select altitude, r1.workoutid 
  from run r1 
  join dev_list d1 on (d1.workoutid = r1.workoutid) 
  where r1.altitude < d1.avg - d1.stddev * 2 or r1.altitude > d1.avg + d1.stddev * 2) 
as foo;
--# 3,634,305 / 139,920,713 ( 2.5% )

--# Too High
with dev_list as ( 
	select avg(altitude), stddev(altitude), workoutid from run group by workoutid )
update run as r1 
  set altitude = d1.avg - (d1.stddev * 2) 
  from dev_list as d1 
  where d1.workoutid = r1.workoutid and r1.altitude < d1.avg - (d1.stddev * 2);
--# UPDATE 1363506
 
--# Too Low
with dev_list as ( 
	select avg(altitude), stddev(altitude), workoutid from run group by workoutid )
update run as r1 
  set altitude = d1.avg + (d1.stddev * 2) 
  from dev_list as d1 
  where d1.workoutid = r1.workoutid and r1.altitude > d1.avg + (d1.stddev * 2);
--# UPDATE 2364011

select count(*) from (
	with dev_list as ( 
		select avg(altitude), stddev(altitude), workoutid from bike group by workoutid )
select altitude, r1.workoutid 
  from bike r1 
  join dev_list d1 on (d1.workoutid = r1.workoutid) 
  where r1.altitude < d1.avg - d1.stddev * 2 or r1.altitude > d1.avg + d1.stddev * 2) as foo;
--# 3,290,430 / 111,494,911 ( 2.9% )

--# Too High
with dev_list as ( 
	select avg(altitude), stddev(altitude), workoutid from bike group by workoutid )
update bike as r1 
  set altitude = d1.avg - (d1.stddev * 2) 
  from dev_list as d1 
  where d1.workoutid = r1.workoutid and r1.altitude < d1.avg - (d1.stddev * 2);
--# UPDATE 825254


--# Too Low
with dev_list as ( 
	select avg(altitude), stddev(altitude), workoutid from bike group by workoutid )
update bike as r1 
  set altitude = d1.avg + (d1.stddev * 2) 
  from dev_list as d1 
  where d1.workoutid = r1.workoutid and r1.altitude > d1.avg + (d1.stddev * 2);
--# UPDATE 2510788

--##### Update deriv post cleaning
select now();
with dev_list as (
	select round((alt_difference / time_difference),5) as deriv, time, workoutid from ( 
		select alt_difference, case when time_difference = 0 then 1 else time_difference end as time_difference, altitude_first, time, workoutid, altitude from (
			select altitude - lag(altitude) over (partition by workoutid order by time) as alt_difference, time - lag(time) over (partition by workoutid order by time) as time_difference, altitude, altitude_first, time, workoutid from run order by time) 
		as foo) 
	as bar order by workoutid, time )
update run r1 
  set altitude_first = d1.deriv 
  from dev_list as d1 
  where d1.workoutid = r1.workoutid and d1.time = r1.time;
select now();


--##################################################################
--##################################################################
--## Second altitude deriv is garbage - action :

--##### Update deriv post cleaning
select now();
with dev_list as (
	select round((alt_difference / time_difference),5) as deriv, time, workoutid from ( 
		select alt_difference, case when time_difference = 0 then 1 else time_difference end as time_difference, altitude_first, time, workoutid, altitude from (
			select altitude_first - lag(altitude_first) over (partition by workoutid order by time) as alt_difference, time - lag(time) over (partition by workoutid order by time)
		       	as time_difference, altitude, altitude_first, time, workoutid from run order by time)
	       	as foo)
       	as bar order by workoutid, time )
update run r1
  set altitude_second = d1.deriv
  from dev_list as d1
  where d1.workoutid = r1.workoutid and d1.time = r1.time;
select now();


--##################################################################
--##################################################################
--## Elapsed distance is garbage - action :

select * from histogram('elapsed_distance', 'run');


--##################################################################
--##################################################################
--## Elapsed time is garbage - action :

select * from histogram('elapsed_time', 'run');

--##################################################################
--##################################################################
--## Speed ma 50 is garbage - action :


select now(); 
with dev_list as (
	select time, 
	       workoutid, 
	       avg(speed) over (partition by workoutid order by time rows between 50 preceding and current row) as mavg 
	from run 
	order by time
)
update run r1 set speed_ma_50 = d1.mavg from dev_list as d1 where d1.workoutid = r1.workoutid and d1.time = r1.time;
select now();

select * from histogram('speed_ma_50', 'run');

--##################################################################
--##################################################################
--## Speed ma 100 is garbage - action :

select now(); 
with dev_list as (
	select time, 
	       workoutid, 
	       avg(speed) over (partition by workoutid order by time rows between 100 preceding and current row) as mavg 
	from run 
	order by time
)
update run r1 set speed_ma_100 = d1.mavg from dev_list as d1 where d1.workoutid = r1.workoutid and d1.time = r1.time;
select now();

select * from histogram('speed_ma_100', 'run');

--##################################################################
--##################################################################
--## Heart rate ma 25 is garbage - action :

select now(); 
with dev_list as (
	select time,
	       workoutid, 
	       avg(heart_rate) over (partition by workoutid order by time rows between 25 preceding and current row) as mavg 
	from run 
	order by time
)
update run r1 set heart_rate_ma_25 = d1.mavg from dev_list as d1 where d1.workoutid = r1.workoutid and d1.time = r1.time;
select now();

select * from histogram('heart_rate_ma_25', 'run');


--##################################################################
--# BIKE - TBD
--##################################################################
--# Remove dupes

ALTER TABLE bike ADD COLUMN id SERIAL PRIMARY KEY;
DELETE FROM bike
WHERE id IN (SELECT id
              FROM (SELECT id,
                             ROW_NUMBER() OVER (partition BY altitude, heart_rate, latitude, longitude, speed, workoutid, time ORDER BY id) AS rnum
                     FROM bike) t
              WHERE t.rnum > 1);
ALTER TABLE bike drop column id;
--# DELETE 23,293


--# BIKE
update bike set speed = speed * -1 where speed < 0;
UPDATE 505

SELECT avg(speed) AS average FROM bike where speed < 110 and speed > 0;
--# > 110 kph (70 mph) pretty unrealistic for a bike. Use that as cutoff.
--# 6,658 / 111,494,911 ( .006% ) set them to 25.

update bike set speed = 25 where speed > 110;

--# re-run first deriv generation on bike / run


