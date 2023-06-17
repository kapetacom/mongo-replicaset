FROM mongo:6.0.6

COPY scripts/* /docker-entrypoint-initdb.d/
COPY mongo-keyfile /data/mongo-keyfile
RUN chown mongodb:mongodb /data/mongo-keyfile
RUN chmod 400 /data/mongo-keyfile

CMD [ "mongod", "--replSet", "rs0", "--auth", "--keyFile", "/data/mongo-keyfile"]