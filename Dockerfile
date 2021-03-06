FROM docker.io/alpine:3.5
LABEL maintainer="tjololo"
LABEL net.tjololo.maintainer="tjololo"

ENV GIT_VERSION 3
ENV MAVEN_VERSION 4
ENV GRADLE_VERSION 3.4.1
ENV DOCKER_VERSION 1.13
ENV JQ_VERSION 2
ENV NODEJS_VERSION 7
ENV GRADLE_HOME /usr/lib/gradle/gradle-${GRADLE_VERSION}
ENV PATH ${PATH}:${GRADLE_HOME}/bin

#TMP FOR LOCAL TEST
RUN mkdir -p /usr/lib/gradle \
     && mkdir -p /java
ADD gradle-bin.zip /usr/lib/gradle/

RUN set -x \
     && apk add --no-cache "git<${GIT_VERSION}" \
     && apk add --no-cache wget curl \
     && apk add --no-cache "maven<${MAVEN_VERSION}" \
     && apk add --no-cache "docker<${DOCKER_VERSION}" \
     && apk add --no-cache "jq<${JQ_VERSION}" \
     && apk add --no-cache "nodejs<${NODEJS_VERSION}" \
#     && mkdir -p /usr/lib/gradle \
#     && wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -O /usr/lib/gradle/gradle-bin.zip \
     && unzip /usr/lib/gradle/gradle-bin.zip -d /usr/lib/gradle \
     && rm /usr/lib/gradle/gradle-bin.zip
ADD parse_yaml.sh /tmp/
ADD value_of.sh /tmp/
ADD build.sh /tmp/
CMD ["/tmp/build.sh"]
