# Installing Spark

## Starting Apache-Spark docker cluster
Start Spark master and worker as per the configuration in the `docker-compose.yml` file.
```shell script
docker-compose up --scale spark-worker=3 # at most 10 workers are enough 
```
Now you can go to Spark master UI at http://localhost:8080.

## Testing by submitting an example application to Spark. 
Now on the master container run Spark example
```shell script
spark-submit --master spark://spark-master:7077 --class org.apache.spark.examples.SparkPi \
/usr/local/spark/examples/jars/spark-examples_2.12-3.0.1.jar 1000
```

