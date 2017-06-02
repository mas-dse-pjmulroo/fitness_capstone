import psycopg2

dbname = "endomondo"
#dbname = "endomondo_sample"
conn = psycopg2.connect("dbname=%s user=ubuntu"%dbname)

# Open a cursor to perform database operations
cur = conn.cursor()

series_tables = ["aerobics", "american_football", "badminton", "baseball", "basketball", "beach_volleyball", "bike", "bike_transport", "boxing", "circuit_training", "climbing", "core_stability_training", "cricket", "cross_country_skiing", "dancing", "downhill_skiing", "elliptical", "fencing", "fitness_walking", "golf", "gymnastics", "handball", "hiking", "hockey", "horseback_riding", "indoor_cycling", "kayaking", "kite_surfing", "martial_arts", "mountain_bike", "orienteering", "pilates", "polo", "roller_skiing", "rowing", "rugby", "run", "sailing", "scuba_diving", "skate", "skateboarding", "snowboarding", "snowshoeing", "soccer", "squash", "stair_climing", "step_counter", "surfing", "swimming", "table_tennis", "tennis", "treadmill_running", "treadmill_walking", "volleyball", "walk", "walk_transport", "weight_lifting", "weight_training", "wheelchair", "windsurfing", "yoga"]


workout_tables = ["aerobics_by_workout", "american_football_by_workout", "badminton_by_workout", "baseball_by_workout", "basketball_by_workout", "beach_volleyball_by_workout", "bike_by_workout", "bike_transport_by_workout", "boxing_by_workout", "circuit_training_by_workout", "climbing_by_workout", "core_stability_training_by_workout", "cricket_by_workout", "cross_country_skiing_by_workout", "dancing_by_workout", "downhill_skiing_by_workout", "elliptical_by_workout", "fencing_by_workout", "fitness_walking_by_workout", "golf_by_workout", "gymnastics_by_workout", "handball_by_workout", "hiking_by_workout", "hockey_by_workout", "horseback_riding_by_workout", "indoor_cycling_by_workout", "kayaking_by_workout", "kite_surfing_by_workout", "martial_arts_by_workout", "mountain_bike_by_workout", "orienteering_by_workout", "pilates_by_workout", "polo_by_workout", "roller_skiing_by_workout", "rowing_by_workout", "rugby_by_workout", "run_by_workout", "sailing_by_workout", "scuba_diving_by_workout", "skate_by_workout", "skateboarding_by_workout", "snowboarding_by_workout", "snowshoeing_by_workout", "soccer_by_workout", "squash_by_workout", "stair_climing_by_workout", "step_counter_by_workout", "surfing_by_workout", "swimming_by_workout", "table_tennis_by_workout", "tennis_by_workout", "treadmill_running_by_workout", "treadmill_walking_by_workout", "volleyball_by_workout", "walk_by_workout", "walk_transport_by_workout", "weight_lifting_by_workout", "weight_training_by_workout", "wheelchair_by_workout", "windsurfing_by_workout", "yoga_by_workout" ]


for _table in series_tables:
    print _table
    # For cleanup / testing
    query = "ALTER TABLE {} DROP COLUMN if exists elapsed_time;".format(_table)
    cur.execute(query)

    query = "ALTER TABLE {} ADD COLUMN elapsed_time integer;".format(_table)
    cur.execute(query)
    conn.commit()

series_tables = ['bike', 'run']
workout_tables = ['bike_by_workout', 'run_by_workout']

count = 0
for _table in sorted(series_tables):
    print _table
    
    query = "select workoutId from {}_by_workout".format(_table)
    cur.execute(query)
    
    workoutIds = [_i[0] for _i in cur.fetchall()]
    
    print "    ", len(workoutIds)
    print ""
    
    for _workout in workoutIds:
        count += 1
        if count % 1000 == 0:
            print count

        query = "select time, r.time - (select r2.time from {} r2 where r2.workoutid = {} order by time limit 1) from {} r where workoutid = {} order by time".format(_table, _workout, _table, _workout)
        cur.execute(query)
        
        for _j in cur.fetchall():
                
            query = "update {} set elapsed_time = {} where workoutid = {} and time = {};".format(_table, _j[1], _workout, _j[0])

            cur.execute(query)
        conn.commit()


