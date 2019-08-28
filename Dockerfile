FROM alpine:3.10
LABEL description="Slim (-ish) image for Sonarr 2 based on Alpine"
LABEL url="https://sonarr.tv"
LABEL vcs-ref="https://github.com/ppoloskov/docker-sonarr"

ENV PUID 1001
ENV PGID 1001
ENV TZ "Europe/Moscow"
ENV SETTINGS "/config/config.xml"

WORKDIR /opt

# URL base is set to ../sonarr by default 
# since I use reverse-proxy and dont like 3rd level domains
RUN apk add --no-cache mono --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing && \
    apk add --no-cache tzdata sqlite-libs mediainfo curl && \
    curl -sL http://update.sonarr.tv/v2/master/mono/NzbDrone.master.tar.gz | tar xz && \
    apk del curl && \
    addgroup -g ${PGID} notroot && \
    adduser -D -H -G notroot -u ${PUID} notroot && \
    mkdir /config && \
    echo -e '<Config>\n<UrlBase>/sonarr</UrlBase>\n</Config>' > $SETTINGS && \
    chown -R notroot:notroot /opt /config

# Folder to store configs and path to series
VOLUME ["/config", "/tv"]

EXPOSE 8989

HEALTHCHECK CMD netstat -an | grep 8989 > /dev/null; if [ 0 != $? ]; then exit 1; fi;

USER notroot
ENTRYPOINT ["mono"]
CMD ["/opt/NzbDrone/NzbDrone.exe", "--nobrowser", "--data=/config" ]

