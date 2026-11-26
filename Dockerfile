FROM ubuntu:resolute AS builder

# set version label
ARG BUILD_DATE
ARG VERSION
ARG DEBIAN_FRONTEND=noninteractive
LABEL build_version="transmission-skip-hash version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="TonyRL"

COPY root/ /s6-config
COPY patches/ /transmission-build/transmission-3.00/patches/
# install packages
RUN \
 echo "**** install packages ****" && \
 apt update && \
 apt install -qqy \
	apt-utils \
	build-essential \
	curl \
	intltool  \
	libcurl4-openssl-dev \
	libevent-dev \
	libminiupnpc-dev \
	libnatpmp-dev \
	libssl-dev \
	libtool \
	pkg-config \
	unzip \
	zlib1g-dev && \
 cd /transmission-build && \
 echo "**** download transmission ****" && \
 curl -O https://raw.githubusercontent.com/transmission/transmission-releases/master/transmission-3.00.tar.xz && \
 tar Jxf transmission-3.00.tar.xz && \
 cd transmission-3.00 && \
 echo "**** apply patch ****" && \
 patch -N -p0 < patches/001-skip-hash-checking.patch && \
 patch -N -p0 < patches/002-fdlimit.patch && \
 patch -N -p0 < patches/003-random-announce.patch && \
 patch -N -p0 < patches/004-openssl3-rc4.patch && \
 patch -N -p0 < patches/005-miniupnpc-api-18.patch && \
 echo "**** setup artifact folder ****" && \
 mkdir build && \
 cd build && \
 echo "**** compile checks ****" && \
 INTLTOOLIZE=true ../autogen.sh --enable-daemon --enable-external-natpmp --disable-nls && \
 echo "**** compile start ****" && \
 make -j$(nproc) && \
 echo "**** compile finish ****" && \
 make install && \
 echo "**** setup default web interface  + transmission-web-control ****" && \
 cp -rp /usr/local/share/transmission/web /web && \
 cd / && \
 curl -O https://codeload.github.com/ronggang/transmission-web-control/zip/master && \
 unzip -q master && \
 rm master && \
 mv /transmission-web-control-master/src/ /transmission-web-control/ && \
 rm -rf /transmission-web-control-master/ && \
 echo "**** setup flood-for-transmission ****" && \
 curl -LO https://github.com/johman10/flood-for-transmission/releases/latest/download/flood-for-transmission.zip && \
 unzip -q flood-for-transmission.zip && \
 rm flood-for-transmission.zip && \
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
COPY --from=builder /trguing  /trguing
COPY --from=builder /s6-config /

RUN \
 echo "**** setup web interface ****" && \
 mkdir /usr/local/share/transmission && \
 ln -s /web/ /usr/local/share/transmission/web && \
 ln -s /web/index.html /transmission-web-control/index.original.html && \
 ln -s /web/images/ /transmission-web-control/images && \
 ln -s /web/javascript/ /transmission-web-control/javascript && \
 ln -s /web/style/ /transmission-web-control/style

# ports and volumes
EXPOSE 9091 51413 51413/udp
VOLUME /config /downloads /watch
