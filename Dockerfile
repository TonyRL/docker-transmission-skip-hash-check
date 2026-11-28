FROM ubuntu:resolute AS builder

# set version label
ARG BUILD_DATE
ARG VERSION
ARG DEBIAN_FRONTEND=noninteractive
LABEL build_version="transmission-skip-hash version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="TonyRL"

COPY root/ /s6-config
COPY patches/ /transmission-build/patches/
# install packages
RUN \
 echo "**** install packages ****" && \
 apt update && \
 apt install -qqy \
	apt-utils \
	build-essential \
	cmake \
	curl \
	libcurl4-openssl-dev \
	libdeflate-dev \
	libevent-dev \
	libminiupnpc-dev \
	libnatpmp-dev \
	libssl-dev \
	pkg-config \
	unzip \
	zlib1g-dev && \
 cd /transmission-build && \
 echo "**** download transmission ****" && \
 TRANSMISSION_VERSION=$(basename $(curl -Ls -o /dev/null -w '%{url_effective}' https://github.com/transmission/transmission/releases/latest)) && \
 curl -LO https://github.com/transmission/transmission/releases/download/${TRANSMISSION_VERSION}/transmission-${TRANSMISSION_VERSION}.tar.xz && \
 tar Jxf transmission-${TRANSMISSION_VERSION}.tar.xz && \
 cd transmission-${TRANSMISSION_VERSION} && \
 echo "**** apply patch ****" && \
# patch -N -p0 < ../patches/001-skip-hash-checking.patch && \
 patch -N -p0 < ../patches/003-random-announce.patch && \
 patch -N -p0 < ../patches/004-skip-stat-on-load.patch && \
 echo "**** compile checks ****" && \
 cmake -B build -DCMAKE_BUILD_TYPE=Release -DENABLE_GTK=OFF -DENABLE_QT=OFF -DENABLE_TESTS=OFF -DENABLE_NLS=OFF -DINSTALL_DOC=OFF && \
 echo "**** compile start ****" && \
 cmake --build build -j$(nproc) && \
 echo "**** compile finish ****" && \
 cmake --install build && \
 echo "**** setup default web interface  + transmission-web-control ****" && \
 cp -rp /usr/local/share/transmission/public_html /web && \
 cd / && \
 curl -LO https://nightly.link/TonyRL/transmission-web-control/workflows/ci.yaml/master/dist.zip && \
 unzip -q dist.zip && \
 rm dist.zip && \
 mv /dist/ /transmission-web-control/ && \
 echo "**** setup flood-for-transmission ****" && \
 curl -LO https://github.com/johman10/flood-for-transmission/releases/latest/download/flood-for-transmission.zip && \
 unzip -q flood-for-transmission.zip && \
 rm flood-for-transmission.zip && \
 echo "**** setup Shift ****" && \
 curl -O https://codeload.github.com/killemov/Shift/zip/master && \
 unzip -q master && \
 rm master && \
 mv /Shift-master/ /shift/ && \
 echo "**** setup TrguiNG ****" && \
 TRGUING_VERSION=$(basename $(curl -Ls -o /dev/null -w '%{url_effective}' https://github.com/openscopeproject/TrguiNG/releases/latest)) && \
 curl -LO https://github.com/openscopeproject/TrguiNG/releases/download/${TRGUING_VERSION}/trguing-web-${TRGUING_VERSION}.zip && \
 unzip -q trguing-web-${TRGUING_VERSION}.zip -d /trguing && \
 rm trguing-web-${TRGUING_VERSION}.zip && \
 cd / && \
 echo "**** cleanup ****" && \
 apt clean && \
 rm -rf /transmission-build && \
 echo "**** finish ****"

FROM ghcr.io/linuxserver/baseimage-ubuntu:resolute AS build

RUN \
 echo "**** install packages ****" && \
 apt update && \
 apt install -qqy \
	libcurl4t64 \
	libdeflate0 \
	libevent-2.1-7t64 \
	libminiupnpc21 \
	libnatpmp1t64 && \
 echo "**** cleanup ****" && \
 apt clean

# copy local files
COPY --from=builder /usr/local/bin/ /usr/bin/
COPY --from=builder /web  /web
COPY --from=builder /transmission-web-control  /transmission-web-control
COPY --from=builder /flood-for-transmission  /flood-for-transmission
COPY --from=builder /shift  /shift
COPY --from=builder /trguing  /trguing
COPY --from=builder /s6-config /

RUN \
 echo "**** setup web interface ****" && \
 mkdir /usr/local/share/transmission && \
 ln -s /web/ /usr/local/share/transmission/public_html && \
 ln -s /web/index.html /transmission-web-control/index.original.html && \
 ln -s /web/images/ /transmission-web-control/images && \
 ln -s /web/transmission-app.css /transmission-web-control/transmission-app.css && \
 ln -s /web/transmission-app.js /transmission-web-control/transmission-app.js

# ports and volumes
EXPOSE 9091 51413 51413/udp
VOLUME /config /downloads /watch
