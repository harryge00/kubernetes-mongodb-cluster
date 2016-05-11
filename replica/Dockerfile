FROM mongo:latest
COPY build_replica.js /
CMD ["mongo","--host", "mongo-replica-svc-a", "<", "/build_replica.js"]
EXPOSE 27017
