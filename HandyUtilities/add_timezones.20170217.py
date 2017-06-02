import psycopg2

import ujson
import copy
import numpy as np
import scipy.stats
import sys

dbname = 'endomondo'
conn = psycopg2.connect("dbname=endomondo user=ubuntu")

# Open a cursor to perform database operations
cur = conn.cursor()

cur.execute("select relname from pg_class where relkind='r' and relname !~ '^(pg_|sql_)';")
series_tables = []
workout_tables = []
for _i in cur.fetchall():
    if 'user_workout_counts' in _i[0]:
        continue
    
    if 'by_workout' in _i[0]:
        workout_tables.append(_i[0])
        continue
        
    series_tables.append(_i[0])



print series_tables

print workout_tables

import datetime
import pytz

from decimal import Decimal

from timezonefinder import TimezoneFinder

tf = TimezoneFinder()

print TimezoneFinder.using_numba() 

# add timezone
for _table in workout_tables:
    failed = 0
    print _table
    query = "select start_latitude, start_longitude, workoutId from {}".format(_table)
    cur.execute(query)
    _tmp = cur.fetchall()
    workoutIds = []
    for _i in _tmp:
        if _i[0] == None or _i[1] == None:
            continue
        if _i[0] < -180 or _i[0] > 180:
            continue
            
        workoutIds.append([_i[2], tf.timezone_at(lat=float(str(_i[0])), lng=float(str(_i[1])))])

    for _workout in workoutIds:
        if _workout[1] == None:
            failed += 1
            continue
        query = "update {} set timezone = '{}' where workoutId = {};".format(_table, _workout[1], _workout[0])
        
        cur.execute(query)
        conn.commit()
    print "failed: ",failed


