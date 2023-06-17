FROM mongo:6.0.6

COPY scripts/* /docker-entrypoint-initdb.d/
COPY mongo-keyfile /data/mongo-keyfile
RUN chown mongodb:mongodb /data/mongo-keyfile
RUN chmod 400 /data/mongo-keyfile

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 CMD mongosh --eval "rs.status().ok" || exit 1

CMD [ "mongod", "--keyFile", "/data/mongo-keyfile", "--replSet", "rs0"]