FROM mongo:6.0.6

COPY scripts/* /docker-entrypoint-initdb.d/

CMD [ "mongod", "--replSet", "rs0"]