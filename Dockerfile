FROM ywengineer/oracle-jdk:1.8.251
MAINTAINER yangwei "79722513@qq.com"

ARG VERSION="2.2.1"
ENV BASE_DIR="/usr/local/soul-admin"
# set environment
ENV PREFER_HOST_MODE="ip"\
    CLASSPATH=".:$BASE_DIR/conf:$CLASSPATH" \
    USE_CMS="n" \
    JVM_XMS="1g" \
    JVM_XMX="1g" \
    JVM_XMN="512m" \
    JVM_MS="128m" \
    JVM_MMS="128m" \
    JVM_DEBUG="n" \
    JMX_ENABLE="n" \
    JMX_HOST="0.0.0.0" \
    TIME_ZONE="Asia/Shanghai" \
    LISTEN_PORT="9095" \
    MYSQL_HOST="localhost" \
    MYSQL_PORT="3306" \
    MYSQL_DB="soul" \
    MYSQL_USER="root" \
    MYSQL_PASSWORD="root"

WORKDIR /$BASE_DIR

RUN yum install -y wget

RUN set -x \
    && ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone

RUN wget https://github.com/dromara/soul/releases/download/${VERSION}/soul-admin.jar > Main.jar

COPY bin/docker-startup.sh bin/docker-startup.sh
COPY conf/application.yml conf/application.yml

# set startup log dir
RUN mkdir -p logs \
	&& cd logs \
	&& touch start.out \
	&& ln -sf /dev/stdout start.out \
	&& ln -sf /dev/stderr start.out

RUN chmod +x bin/docker-startup.sh

VOLUME $BASE_DIR/conf
VOLUME $BASE_DIR/logs

EXPOSE 9095

ENTRYPOINT ["bin/docker-startup.sh"]