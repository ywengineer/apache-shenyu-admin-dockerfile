#!/bin/bash
set -x
export DEFAULT_SEARCH_LOCATIONS="classpath:/,classpath:/config/,file:./,file:./config/"
export CUSTOM_SEARCH_LOCATIONS=${DEFAULT_SEARCH_LOCATIONS},file:${BASE_DIR}/conf/
export CUSTOM_SEARCH_NAMES="application"
export LOG_PATH="${BASE_DIR}/logs"
#===========================================================================================
# JVM Configuration
#===========================================================================================
JAVA_OPT="${JAVA_OPT} -server -Xms${JVM_XMS} -Xmx${JVM_XMX} -XX:MetaspaceSize=${JVM_MS} -XX:MaxMetaspaceSize=${JVM_MMS}"
JAVA_OPT="${JAVA_OPT} -XX:+UseFastAccessorMethods -XX:+DisableExplicitGC -XX:+UseCompressedOops -XX:+AlwaysPreTouch"
#===========================================================================================
# DEBUG
#===========================================================================================
if [[ "${JVM_DEBUG}" == "y" ]]; then
  JAVA_OPT="${JAVA_OPT} -Xdebug -Xrunjdwp:transport=dt_socket,address=9555,server=y,suspend=n"
fi
# headless
if [[ "${JVM_HEADLESS}" == "y" ]]; then
  JAVA_OPT="${JAVA_OPT} -Djava.awt.headless=true "
fi
#===========================================================================================
# Garbage Collection
#===========================================================================================
if [[ "${USE_CMS}" == "y" ]]; then
  JAVA_OPT="${JAVA_OPT} -XX:+UseConcMarkSweepGC -XX:+UseCMSInitiatingOccupancyOnly -XX:+CMSScavengeBeforeRemark -XX:+CMSParallelInitialMarkEnabled -XX:+CMSParallelRemarkEnabled"
  JAVA_OPT="${JAVA_OPT} -XX:+CMSClassUnloadingEnabled"
  JAVA_OPT="${JAVA_OPT} -Xmn${JVM_XMN}"
else
#  JAVA_OPT="${JAVA_OPT} -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=50"
  JAVA_OPT="${JAVA_OPT} -XX:+UseG1GC -Xmn${JVM_XMN}"
fi
#===========================================================================================
# JMX
#===========================================================================================
JMX_ENABLE=${JMX_ENABLE:-n}
if [[ "${JMX_ENABLE}" == "y" ]]; then
  JAVA_OPT="${JAVA_OPT} -Dcom.sun.management.jmxremote.port=5432 -Djava.rmi.server.hostname=${JMX_HOST}"
  JAVA_OPT="${JAVA_OPT} -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
fi
#===========================================================================================
# HeapDump
#===========================================================================================
JAVA_OPT="${JAVA_OPT} -XX:-OmitStackTraceInFastThrow -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=${LOG_PATH}/java_heapdump.hprof"
JAVA_OPT="${JAVA_OPT} -XX:-UseLargePages -XX:+PrintCommandLineFlags"
#===========================================================================================
# Setting system properties
#===========================================================================================
if [[ "${PREFER_HOST_MODE}" == "hostname" ]]; then
    JAVA_OPT="${JAVA_OPT} -Dnacos.preferHostnameOverIp=true"
fi
#===========================================================================================
# Alibaba Dragonwell
#===========================================================================================
DRAGONWELL=$($JAVA -version 2>&1 | grep "Alibaba Dragonwell")
if [[ -n "${DRAGONWELL}" ]]; then
    echo "${DRAGONWELL}"
    #### JFR
    JFR_ENABLE=${JFR_ENABLE:-n}
    if [[ "${JFR_ENABLE}" == "y" ]]; then
      JAVA_OPT="${JAVA_OPT} -XX:+EnableJFR -XX:StartFlightRecording=duration=1m,filename=${LOG_PATH}/rec.jfr"
    fi
    #### JWarmup
    JWARMUP_ENABLE=${JWARMUP_ENABLE:-n}
    if [[ "${JWARMUP_ENABLE}" == "y" ]]; then
      ##
      JWARMUP_ENV=${JWARMUP_ENV:-beta}
      if [[ "${JWARMUP_ENV}" == "beta" ]]; then
        JAVA_OPT="${JAVA_OPT} -XX:-ClassUnloading -XX:-ClassUnloadingWithConcurrentMark -XX:CompilationWarmUpLogfile=${LOG_PATH}/jwarmup.log -XX:+CompilationWarmUpRecording -XX:CompilationWarmUpRecordTime=300"
        ##
        if [[ "${USE_CMS}" == "y" ]]; then
          JAVA_OPT="${JAVA_OPT} -XX:-CMSClassUnloadingEnabled"
        fi
      else
        JAVA_OPT="${JAVA_OPT} -XX:+CompilationWarmUp -XX:-TieredCompilation -XX:CompilationWarmUpLogfile=${LOG_PATH}/jwarmup.log -XX:CompilationWarmUpDeoptTime=0"
      fi
    fi
fi
#===========================================================================================
# JAVA Major Version Detect
#===========================================================================================
JVM_VNEDOR=$($JAVA -version 2>&1 | sed -E -n 's/(.*) version.*/\1/p')
JAVA_MAJOR_VERSION=$($JAVA -version 2>&1 | sed -E -n 's/.* version "[0-9]*\.([0-9]*).*$/\1/p')
if [[ "${JVM_VNEDOR}" == "openjdk" ]]; then
  JAVA_MAJOR_VERSION=$($JAVA -version 2>&1 | sed -E -n 's/.* version "([0-9]*).*$/\1/p')
fi
#===========================================================================================
# JVM log options
#===========================================================================================
if [[ "$JAVA_MAJOR_VERSION" -ge "9" ]] ; then
  JAVA_OPT="${JAVA_OPT} -cp .:${BASE_DIR}/plugins/cmdb/*.jar:${BASE_DIR}/plugins/mysql/*.jar"
  JAVA_OPT="${JAVA_OPT} -Xlog:gc*:file=${LOG_PATH}/gc.log:time,tags:filecount=10,filesize=102400"
else
  JAVA_OPT="${JAVA_OPT} -Djava.ext.dirs=${JAVA_HOME}/jre/lib/ext:${JAVA_HOME}/lib/ext:${BASE_DIR}/plugins/cmdb:${BASE_DIR}/plugins/mysql"
  JAVA_OPT="${JAVA_OPT} -Xnoclassgc -Xloggc:${LOG_PATH}/gc.log -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps"
  JAVA_OPT="${JAVA_OPT} -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=100 -XX:GCLogFileSize=50m"
fi

JAVA_OPT="${JAVA_OPT} -Dwork.home=${BASE_DIR}"
JAVA_OPT="${JAVA_OPT} -jar ${BASE_DIR}/Main.jar"
JAVA_OPT="${JAVA_OPT} ${JAVA_OPT_EXT}"
JAVA_OPT="${JAVA_OPT} --spring.config.location=${CUSTOM_SEARCH_LOCATIONS}"
JAVA_OPT="${JAVA_OPT} --spring.config.name=${CUSTOM_SEARCH_NAMES}"
#JAVA_OPT="${JAVA_OPT} --logging.config=${BASE_DIR}/conf/.xml"
JAVA_OPT="${JAVA_OPT} --server.max-http-header-size=10KB"

echo "application is starting,you can check the ${LOG_PATH}/start.out"
# exec $JAVA ${JAVA_OPT} > ${LOG_PATH}/start.out 2>&1
# $JAVA ${JAVA_OPT} > ${LOG_PATH}/start.out 2>&1
nohup $JAVA ${JAVA_OPT} > ${LOG_PATH}/start.out 2>&1 < /dev/null