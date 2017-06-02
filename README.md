# fitness_capstone

## Collection of notebooks, code, and other information for the 2017 UCSD DSE MAS Group 4 Fitness Tracking capstone project 

### Folder Tree 

```
├── DataLoadingNotebooks # Notebooks that explain how the data was loaded into postgres
│   ├── FirstAttemptNotebooks # Initial attempt at import
├── FeatureGenerationAndCleaningNotebooks # Notebooks with code used to clean data and generate features
│   └── FirstPassFeatureGenerationAndCleaning # First attempt to clean data and generate features
│       └── sql_scripts # Second attempt at feature generation and cleaning in SQL
│           └── old # First attempt at feature generation and cleaning in SQL
├── HandyUtilities # Some utilities we wrote or found that were handy
├── Presentation_Final_Images # ToBeRemoved
├── Presentation_I_Images # ToBeRemoved
├── ReferenceEndomondoWorkouts # Some workouts generated in Endomondo for reference
├── SparkNotes # Notes / scripts about spark and how we setup the cluster
└── field_dictionary.txt # File explaining the fields in the DB, their format, and where they came from
```

### Datasource Notes

The data in the postgres database dump was provided by our advisor, Dr Julian McAuley. It was scraped from endomondo, and collected from: http://jmcauley.ucsd.edu/data/endomondo/. The individual files in the format [0-9]\*.txt.gz where used to generate the database. The data contains public workout data provided by the Endomondo API.

The data was divided up by workout type for the time series data (run, bike, etc), and a corresponding workout metadata table was created for each workout type (run_by_workout, bike_by_workout, etc) stores the metadata data for each unique workout.

PostgresSQL was used to store the data, with indexes the final version of the table utilized ~60GB of space.

The file `field_dictionary.txt` contains information on all the fields in each table.

The majority of time series data (~95% of records) is found in the 'bike' and 'run' tables.


### Spark Notes

We stood up our own small spark cluster in AWS that consisted of one head node, that also stored our database, and three worker nodes. This kept our cost down, but did involve additional work.

The dashbaord provided by modern versions of Spark was an extremely useful tool to track issues, and make sure code and cluster were working as expected.

Trouble we ran into:
- Hive. Spark wanted to right hive metastore files to one location. Running multiple instances at the same time caused trouble. Using the hive.xml config provided resolve that issue.
- Single Spark Context. We provided the entire cluster to each running job, but starting multiple pyspark instances caused any instance after the first to not have any available cluster resources. We simply communicated better, and made sure to only run one instance at a time.
- Spark slave default memory. By default the slaves only utilized a fraction of the memory they had available. Setting appropiate values in configs resolved this.
- Firewall. We found it easiest to allow all communication between all nodes, which is difficult in a large cluster configuration.
- Logging. By default the logging in Spark is verbose, and the log files utilized the limited disk space per node.
- Cluster file access. We did not set up a distributed filesystem such as gluster across the nodes, so writing CSV files would result in them being randomly placed across the nodes.
 




