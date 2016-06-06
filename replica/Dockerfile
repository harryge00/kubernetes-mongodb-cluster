# mongo-cluster
FROM mongo:latest

EXPOSE 27017

RUN mkdir -p /opt/mongo/ && \
	apt-get update && apt-get install -y netcat

COPY start_replica.sh /opt/mongo/

WORKDIR /opt/mongo

CMD /opt/mongo/start_replica.sh
