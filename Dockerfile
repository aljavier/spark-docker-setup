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
