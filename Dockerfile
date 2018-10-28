# Origin: wurstmeister. https://github.com/wurstmeister/kafka-docker.git
# Fork: cuongtransc

FROM openjdk:8u171-jre-alpine

LABEL maintainer="cuongtransc@gmail.com"

# ARG kafka_version=2.0.0
ARG kafka_version=1.1.0
ARG scala_version=2.12
ARG glibc_version=2.27-r0

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka \
    GLIBC_VERSION=$glibc_version

ENV PATH=${PATH}:${KAFKA_HOME}/bin

COPY scripts/bin/*.sh /usr/local/bin/
COPY scripts/download-kafka.sh /tmp/

RUN apk add --no-cache bash curl jq docker \
 && mkdir /opt \
 && sync && /tmp/download-kafka.sh \
 && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
 && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
 && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka \
 && rm /tmp/* \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && apk add --no-cache --allow-untrusted glibc-${GLIBC_VERSION}.apk \
 && rm glibc-${GLIBC_VERSION}.apk

COPY overrides /opt/overrides

VOLUME ["/kafka"]

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]
