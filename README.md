# 2017_UCSD_MSE_Group4_Fitness_Capstone

## Collection of notebooks, code, and other notes for the 2017 UCSD MAS Group 4 fitness tracking capstone project

#### Overview

```
├── ClusteringNotebooks
# Notebooks that execute clustering portion of pipeline

│   └── old
# Early attempts at clustering

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

├── Other
# Old CSV and notebooks included for completeness

├── Presentations
# Copies of progress presentations and reports

├── ReferenceEndomondoWorkouts
# Some workouts generated in Endomondo for reference

├── RegressionNotebooks
# Notebooks that execute regression portion of pipeline

├── SparkNotes
# Notes & scripts about the AWS Spark cluster

├── VisualizationNotebooks
# Notebooks that generate analysis and presentation visualizations

└── field_dictionary.txt
# File explaining the fields in the DB, their format, and where they came from
```

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

The most recent copy of the database is stored externally of this repo due to it's size. It is labelled `endomondo.20170508.sql.gz` and is approximately 10GB. Uncompressed it takes up approximately 40GB. It can imported into PostgreSQL using `psql` utility.

The file `altitude_lookup.20170605.sql.gz` contains an incomplete mapping of latitude / longitude to altitude (meters) from an external API.

## Clustering Notes

#### Dependencies:

*PySpark v2.1.0*, *Python 2.7*

#### Summary:
The goal of the notebook is to utilize a two-step clustering method using K-Means based first on route attributes and then performance attributes. Each of the three route clusters has five dependent performance clusters. The notebook pulls data from Postgres into a PySpark dataframe, and normalizes the data using the Standard Scaler class in the PySpark ML library. By changing the scaling factor, attributes are weighted differently for the first, route based, clustering. By default, the route cluster centers will be saved in the file `route_clusters_6_2_2017_1.csv`. The CSV includes a header of column names.

Once the route clusters are established, each of them will be independently clustered based on performance attributes: speed, heart rate, and duration of workout. The centers of each performance cluster will be saved in the file `route0_perf.csv`. The numeric value after 'route' is the route cluster identifier to which it belongs. The combined dataframe, including the attributes of interest and the cluster values for route and performance, is saved in the file `endo_sample_6_2_1.csv`.

## Classifier Notes

#### Dependencies:

*PySpark v2.1.0*, *Python 2.7*, *Bokeh*

#### Summary:

The `Regression_5th_Iteration` directory contains the finalized regression training loop within the `Regression with Model Saving.ipynb`. This notebook loads in data from the output of the final clustering notebook, reformats it into a dataframe that can be used in regression with dense vectors of features for inputs and a elapsed_time converted into a label. Parameter maps are built for each of the models for hypertuning in a dictionary. Then, a nested loop goes through each model in the hypertuning dictionary for each combination of route and performance cluster and fits a model. The model is trained with 10 folds cross-validation across the parameter map, and the CrossValidator object chooses the best model automatically. The predictions are fed back into the original dataframe, and another dictionary is created to record various regression metrics. The model is saved to a recorded path for future access (we encountered issues going from a single node to master with slaves configuration that required a HDFS, which we didn't have in place at the time the final models were created). Finally, the resulting dataframes are saved into csvs. Our final training of these models took approximately 18 hours on the full data set with our cluster configuration. This can be reduced by at least half by removing gradient-boosted trees; however, they are the best performing regressors at this point.

The notebook `Regression Results Analysis.ipynb` takes the dataframes created from training the models and creates several new fields for further evaluation of the models, which are saved in a new csv for quick access. There are also some bokeh plots, which were used for publication.

The notebook `Stacking Playground.ipynb` was originally not going to be included; however, stacking did a good job of improving our model overall, so it was included. This follows a similar format to `Regression with Model Saving.ipynb`. The bokeh plot at the end of this notebook can freeze up a notebook due to the extremely large number of datapoints, so you should keep it hidden or delete it and visualize it with another tool.

The notebook `Pat_Prediction.ipynb` employs the models from the cluster that the test data for our poster was labelled in. It creates predictions for the route and applies the stacking regression equation to make the final predictions included in the poster.

# Visualization Notes

#### Dependencies:

*Python 2.7*, *Bokeh*, *Seaborn*, *Matplotlib*

#### Summary:

The visualizations for this project were generated in two notebooks.

The first `Spider Chart Visualization of Cluster Centers` generates the spider charts used in our poster, presentation, and paper. The code was primarily sourced from: https://gist.github.com/kylerbrown/29ce940165b22b8f25f4. It reads the files:

```
route0_perf2.csv
route1_perf2.csv
route2_perf2.csv
route3_perf2.csv
route4_perf2.csv
route_clusters_6_1_2017_1.csv
```

The second notebook `Jason-Loading-Visualizing-Endomondo` generates the histograms of the database from queries directly against the database.
