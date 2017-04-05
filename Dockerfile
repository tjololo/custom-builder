FROM alpine-openjdk8:latest

ENV GIT_VERSION 2.11.1-r0
ENV MAVEN_VERSION 3.3.9-r1
ENV GRADLE_VERSION 3.4.1
ENV DOCKER_VERSION 1.12.6-r0
ENV GRADLE_HOME /usr/lib/gradle/gradle-${GRADLE_VERSION}
ENV PATH ${PATH}:${GRADLE_HOME}/bin

#TMP FOR LOCAL TEST
RUN mkdir -p /usr/lib/gradle \
     && mkdir -p /java
ADD gradle-bin.zip /usr/lib/gradle/
ADD java/* /java/

RUN set -x \
     && apk add --no-cache wget \
     && apk add --no-cache git="${GIT_VERSION}" \
     && apk add --no-cache maven="${MAVEN_VERSION}" \
     && apk add --no-cache docker="${DOCKER_VERSION}" \
#     && mkdir -p /usr/lib/gradle \
#     && wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -O /usr/lib/gradle/gradle-bin.zip \
     && unzip /usr/lib/gradle/gradle-bin.zip -d /usr/lib/gradle \
     && rm /usr/lib/gradle/gradle-bin.zip

ADD build.sh /tmp/
CMD ["/tmp/build.sh"]
