# Apache Spark docker

TL;DR

```
git clone git@github.com:aljavier/spark-docker-setup.git
cd spark-docker-setup
docker build -t learning/spark:latest .      
docker-compose up
```

---

Create a custom docker image for Spark. First, create a `Dockerfile` with the content below

```
FROM openjdk:8-alpine

ARG SCALA_SDK_URL="https://downloads.lightbend.com/scala/2.12.8/scala-2.12.8.tgz"  
ARG SCALA_SBT_URL="https://piccolo.link/sbt-1.2.8.tgz"
ARG SPARK_URL="http://apache.mirror.anlx.net/spark/spark-2.4.1/spark-2.4.1-bin-hadoop2.7.tgz" 
ARG HADOOP_URL="http://archive.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz"

RUN apk --update add bash
RUN wget $SCALA_SDK_URL -O scala.tgz 
RUN wget $SCALA_SBT_URL -O sbt.tgz 
RUN wget $SPARK_URL -O spark.tgz 
RUN wget $HADOOP_URL -O hadoop.tgz
RUN tar zxf scala.tgz && mv scala-* /usr/local/scala && rm scala.tgz  
RUN tar zxf sbt.tgz && mv sbt /usr/local/scala/ && rm sbt.tgz 
RUN tar xzf spark.tgz && mv spark-* /usr/local/spark && rm spark.tgz 
RUN tar xzf hadoop.tgz && mv hadoop-* /usr/local/hadoop && rm hadoop.tgz

COPY start-master.sh /start-master.sh
COPY start-worker.sh /start-worker.sh

ENV SCALA_HOME=/usr/local/scala 
ENV SPARK_HOME=/usr/local/spark 
ENV HADOOP_HOME=/usr/local/hadoop
ENV LD_LIBRARY_PATH=$HADOOP_HOME/lib/native
ENV PATH=${PATH}:${SCALA_HOME}/bin:${SCALA_HOME}/sbt/bin:${SPARK_HOME}/bin:${HADOOP_HOME}/bin:${LD_LIBRARY_PATH}
```

Now run the command below

```
docker build -t learning/spark:latest .      
```

Create network for Spark cluster

```
docker create network spark_network
```

Create docker container for Spark
```
docker run --rm -it --name spark-master --hostname spark-master -p 7077:7077 \ 
-p 8080:8080 --network spark_network learning/spark:latest /bin/sh
```

Start Spark master inside container
```
spark-class org.apache.spark.deploy.master.Master --ip `hostname` --port 7077 --webui-port 8080
```

Start docker container for Spark worker
```
docker run --rm -it --name spark-worker1 --hostname spark-worker1 \
--network spark_network learning/spark:latest /bin/sh
```

Start Spark worker inside container
```
spark-class org.apache.spark.deploy.worker.Worker --webui-port 8080 spark://spark-master:7077
```

 Let's test it by submitting an example application to Spark. Open a new container using the same `learning/spark` image we created
```
docker run --rm -it --network spark_network learning/spark /bin/sh  
```

Now on this container run Spark example
```
spark-submit --master spark://spark-master:7077 --class org.apache.spark.examples.SparkPi \
/usr/local/spark/examples/jars/spark-examples_2.11-2.4.1.jar 1000
```

##  Using docker-compose
 
Let's skip running so many commands by using `docker-compose`. 

First, create a script `start-master.sh` with the content below

```bash
#!/bin/sh

/usr/local/spark/bin/spark-class org.apache.spark.deploy.master.Master \
    --ip $SPARK_LOCAL_IP \
    --port $SPARK_MASTER_PORT \
    --webui-port $SPARK_MASTER_WEBUI_PORT
```

Also, create a `start-worker.sh` one with the content below

```bash
#!/bin/sh

/usr/local/spark/bin/spark-class org.apache.spark.deploy.worker.Worker \
    --webui-port $SPARK_WORKER_WEBUI_PORT $SPARK_MASTER
```

*Note: Both scripts should have permissions as executable.*

Now, create a `docker-compose.yml` file with the content below

```
version: "3.3"
services:
  spark-master:
    image: learning/spark:latest
    container_name: spark-master
    hostname: spark-master
    ports:
      - "8080:8080"
      - "7077:7077"
    networks:
      - spark-network
    environment:
      - "SPARK_LOCAL_IP=spark-master"
      - "SPARK_MASTER_PORT=7077"
      - "SPARK_MASTER_WEBUI_PORT=8080"
    command: "/start-master.sh"
  spark-worker:
    image: learning/spark:latest
    depends_on:
      - spark-master
    ports:
      - 8080
    networks:
      - spark-network
    environment:
      - "SPARK_MASTER=spark://spark-master:7077"
      - "SPARK_WORKER_WEBUI_PORT=8080"
    command: "/start-worker.sh"
networks:
  spark-network:
    driver: bridge
    ipam:
      driver: default
```

Start Spark master and worker as per the configuration in the `docker-compose.yml` file.

```
docker-compose up
```

Want to use more than one Spark worker? Then, run something like

```
docker-compose up --scale spark-worker=3
```

Command above run the whole thing with 3 Spark workers.


Reference:

- [A Journey Into Big Data with Apache Spark: Part 1](https://towardsdatascience.com/a-journey-into-big-data-with-apache-spark-part-1-5dfcc2bccdd2)


