FROM mongo:{{ base_image }}

COPY scripts/healthcheck.sh /opt/healthcheck.sh
COPY mongo-keyfile /data/mongo-keyfile
RUN chown mongodb:mongodb /data/mongo-keyfile
RUN chmod 400 /data/mongo-keyfile
RUN chmod +x /opt/healthcheck.sh

HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 CMD /opt/healthcheck.sh

CMD [ "--replSet", "rs0", "--bind_ip_all", "--keyFile", "/data/mongo-keyfile"]
