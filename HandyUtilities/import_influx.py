from influxdb import InfluxDBClient
import copy
import numpy as np
import sys
import psycopg2
import sys

dbname = "endomondo"

client = InfluxDBClient('127.0.0.1', 8086, 'root', 'root', dbname)


try:
    print("Drop database: " + dbname)
    client.drop_database(dbname)
except:
    pass

client.create_database(dbname)

client.create_retention_policy('awesome_policy', 'INF', 1, default=True)

conn = psycopg2.connect("dbname=endomondo")

cur = conn.cursor('influx-cursor-run')
cur.itersize = 10000

sport = "run"

cur.execute("select * from %s"%sport)

count = 0

print "start import:"

#for _endoHR in cur.fetchall():
for _endoHR in cur:
    count += 1
    if count%10000 == 0:
        print count, "/ 140,060,246"

    #time, alt, hr, lat, lng, speed, workoutid, id (, timef)
    _points = []

    _dict = {}
    _dict["fields"] = {}

    _dict["measurement"] = sport

    _tags = {}
    _tags["workoutId"] = _endoHR[6]

    _dict["time"] = _endoHR[0]

    if _endoHR[1] != None:
        _dict["fields"]["altitude"] = _endoHR[1]

    if _endoHR[2] != None:
        _dict["fields"]["heart_rate"] = _endoHR[2]

    if _endoHR[3] != None:
        _dict["fields"]["latitude"] = _endoHR[3]

    if _endoHR[4] != None:
        _dict["fields"]["longitude"] = _endoHR[4]

    if _endoHR[5] != None:
        _dict["fields"]["speed"] = _endoHR[5]

    if _dict["fields"] == {}:
        continue

    try:
        client.write_points([_dict], time_precision='s', tags=_tags)
    except:
        print _dict
        print _tags
        break


