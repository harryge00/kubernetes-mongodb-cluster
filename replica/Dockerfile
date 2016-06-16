#Deprecated, we can use "kubectl exec" to do mongo initialzation
FROM mongo:latest
EXPOSE 27017
RUN apt-get update
RUN apt-get install -y netcat 
RUN mkdir /opt/mongo
WORKDIR /opt/mongo
COPY start_replica.sh /opt/mongo
CMD ["./start_replica.sh"]
