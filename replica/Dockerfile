#Deprecated, we can use "kubectl exec" to do mongo initialzation
FROM mongo:latest
COPY build_replica.js /
COPY start_replica.sh /
CMD /start_replica.sh
EXPOSE 27017
