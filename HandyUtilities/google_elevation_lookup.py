#!/Users/pmulrooney/anaconda2/bin/python
import os.path
import googlemaps
import ast

#######
# Input format. Max 512 pairs per row. 
# Example:
#
# [[32.7422030000,-117.2538830000],[32.7422078233,35.2251520101],...,[32.7422030000,-117.2538830000],[32.7422078233,35.2251520101]]
# ...
# [[32.7422030000,-117.2538830000],[32.7422078233,35.2251520101],...,[32.7422030000,-117.2538830000],[32.7422078233,35.2251520101]]
#
######

path="/Users/pmulrooney/Desktop/lat_longs_google/"
fname="xak"

gmaps = googlemaps.Client(key='<<KEY HERE>>')


locations = []

content = []

with open(path + fname) as f:
    content = f.readlines()

for _content in content:
    locations.append(ast.literal_eval(_content.strip()))

output = []

ofile=path + fname + ".out"

of=open(ofile, 'a')

for _location in locations:
    # touch /tmp/stop to stop loop
    if os.path.isfile("/tmp/stop") == True:
        break 
    try:
        print _location
        _tmp = gmaps.elevation(_location)
        for _ent in _tmp:
            _lat = _ent['location']['lat']
            _lng = _ent['location']['lng']
            _ele = _ent['elevation']
            of.write(str(_lat) + "," + str(_lng) + "," + str(_ele) + "\n")
    except:
        pass


of.close()

