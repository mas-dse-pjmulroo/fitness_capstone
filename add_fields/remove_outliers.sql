# First speed deriv is garbage - action :
delete from bike where speed_first < -230.61619 or speed_first > 235.21071;
select * from histogram('speed_first', 'bike');
delete from run where speed_first < -811.83600 or speed_first > 2593.22471;
select * from histogram('speed_first', 'run');

# First altitude deriv is garbage - action :
delete from bike where altitude_first < -513.40000 or altitude > 39.40000;
select * from histogram('altitude_first', 'bike');
delete from run where altitude_first < -46.10000 or altitude_first > 928.60000;
select * from histogram('altitude_first', 'run');

# Second altitude deriv is garbage - action :
;delete from bike where altitude_second < -716.48750 or altitude_second > 654.50000;
delete from run where altitude_second < -421.76667 or altitude_second > 1414.95000 

# Elapsed distance is garbage - action :
delete from bike where elapsed_distance > 3764.9603200000;
select * from histogram('elapsed_distance', 'run');

# Elapsed time is garbage - action :
select * from histogram('elapsed_distance', 'bike');
select * from histogram('elapsed_distance', 'run');

# Speed ma 50 is garbage - action :

# Speed ma 100 is garbage - action :

# Heart rate ma 25 is garbage - action :
 
