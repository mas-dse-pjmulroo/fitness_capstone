# 2017_UCSD_MSE_Group4_Fitness_Capstone

## Collection of notebooks, code, and other notes for the 2017 UCSD MAS Group 4 fitness tracking capstone project

#### Overview

```
├── DataLoadingNotebooks
# Notebooks that explain how the data was loaded into PostgreSQL

│   ├── FirstAttemptNotebooks
# Initial attempt at import

├── FeatureGenerationAndCleaningNotebooks
# Notebooks with code used to clean data and generate features

│   └── FirstPassFeatureGenerationAndCleaning
# First attempt to clean data and generate features

│       └── sql_scripts
# Second attempt at feature generation and cleaning in SQL

│           └── old
# First attempt at feature generation and cleaning in SQL

├── HandyUtilities
# Some utilities we wrote or found that were handy

├── Presentations
# Copies of progress presentations and reports

├── ReferenceEndomondoWorkouts
# Some workouts generated in Endomondo for reference

├── SparkNotes
# Notes & scripts about the AWS Spark cluster

└── field_dictionary.txt
# File explaining the fields in the DB, their format, and where they came from```

### Datasource Notes

The data in the PostgreSQL database dump was provided by our advisor, Dr Julian McAuley. It was scraped from Endomondo, and collected from: http://jmcauley.ucsd.edu/data/endomondo/. The individual files, in the format `[0-9]\*.txt.gz`, where used to generate the database. The data contains public workout data provided by the Endomondo API.

### Spark Notes

We stood up our own small spark cluster in AWS that consisted of one head node, that also stored our database, and three worker nodes. This kept our cost down, but did involve additional work.

The dashboard provided by modern versions of Spark was an extremely useful tool to track issues, and make sure code and cluster were working as expected.

Trouble we ran into:
- **Hive**. Spark wanted to right hive metastore files to one location. Running multiple instances at the same time caused trouble. Using the hive.xml config provided resolve that issue.
- **Single Spark Context**. We provided the entire cluster to each running job, but starting multiple PySpark instances caused any instance after the first to not have any available cluster resources. We simply communicated better, and made sure to only run one instance at a time.
- **Spark slave default memory**. By default the slaves only utilized a fraction of the memory they had available. Setting appropriate values in configs resolved this.
- **Firewall**. We found it easiest to allow all communication between all nodes, which is difficult in a large cluster configuration.
- **Verbose Logging**. By default the logging in Spark is verbose, and the log files utilized the limited disk space per node.
- **Cluster wide file access**. We did not set up a distributed filesystem such as GlusterFS across the nodes, so writing CSV files would result in them being randomly placed across the nodes.

## Database Notes

#### Dependencies

*PostgreSQL 9.6*

#### Summary

The data was divided up by workout type for the time series data (run, bike, etc), and a corresponding workout metadata table was created for each workout type (run_by_workout, bike_by_workout, etc) stores the metadata data for each unique workout.

PostgreSQL was used to store the data, with indexes the final version of the table utilized ~60GB of space.

The majority of time series data (~95% of records) is found in the 'bike' and 'run' tables.

The file `field_dictionary.txt` contains information on all the fields in each table.

## Clustering Notes

#### Dependencies:

*PySpark v2.1.0*, *Python 2.7*

#### Summary:
The goal of the notebook is to utilize a two-step clustering method using K-Means based first on route attributes and then performance attributes. Each of the three route clusters has five dependent performance clusters. The notebook pulls data from Postgres into a PySpark dataframe, and normalizes the data using the Standard Scaler class in the PySpark ML library. By changing the scaling factor, attributes are weighted differently for the first, route based, clustering. By default, the route cluster centers will be saved in the file `route_clusters_6_2_2017_1.csv`. The CSV includes a header of column names.

Once the route clusters are established, each of them will be independently clustered based on performance attributes: speed, heart rate, and duration of workout. The centers of each performance cluster will be saved in the file `route0_perf.csv`. The numeric value after 'route' is the route cluster identifier to which it belongs. The combined dataframe, including the attributes of interest and the cluster values for route and performance, is saved in the file `endo_sample_6_2_1.csv`.

## Classifier Notes

#### Dependencies:

*PySpark v2.1.0*, *Python 2.7*

#### Summary:
