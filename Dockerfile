FROM mongo:8

COPY scripts/healthcheck.sh /opt/healthcheck.sh
COPY mongo-keyfile /data/mongo-keyfile
COPY start-mongod.sh /opt/start-mongod.sh

RUN chown mongodb:mongodb /data/mongo-keyfile
RUN chmod 400 /data/mongo-keyfile
RUN chmod +x /opt/healthcheck.sh
RUN chmod +x /opt/start-mongod.sh


HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 CMD /opt/healthcheck.sh

ENTRYPOINT ["/opt/start-mongod.sh"]
