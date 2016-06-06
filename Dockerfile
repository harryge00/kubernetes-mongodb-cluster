FROM mongo:latest
RUN chmod 755 /sys/kernel/mm/transparent_hugepage/enabled
RUN chmod 755 /sys/kernel/mm/transparent_hugepage/defrag
RUN echo never > /sys/kernel/mm/transparent_hugepage/enabled
RUN echo never > /sys/kernel/mm/transparent_hugepage/defrag
EXPOSE 27017
CMD mongod