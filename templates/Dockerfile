FROM gitinsky/baseimage:0.1.9
MAINTAINER Git In Sky <support@gitinsky.com>

RUN \
  cd / && \
  curl -s -o /influxdb_latest_amd64.deb https://s3.amazonaws.com/influxdb/influxdb_0.9.3-rc1_amd64.deb && \
  dpkg -i /influxdb_latest_amd64.deb && \
  mkdir /config && mkdir /data && \
  rm -f /influxdb_latest_amd64.deb

ENV PRE_CREATE_DB **None**
ENV SSL_SUPPORT **False**
ENV SSL_CERT **None**

COPY start.sh /start.sh

EXPOSE 8083

EXPOSE 8086

CMD ["/start.sh"]
