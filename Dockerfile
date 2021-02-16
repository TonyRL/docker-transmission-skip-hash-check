FROM ubuntu:focal as builder

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="transmission-skip-hash version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="TonyRL"

COPY root/ /s6-config
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
	libssl-dev \
	libtool \
	pkg-config \
	unzip \
	zlib1g-dev && \
 mkdir /transmission-build && \
 cd /transmission-build && \
 
 echo "**** download transmission ****" && \
 curl -O https://raw.githubusercontent.com/transmission/transmission-releases/master/transmission-3.00.tar.xz && \
 tar Jxf transmission-3.00.tar.xz && \
 cd transmission-3.00 && \
 
 echo "**** download patch ****" && \
 mkdir patches && \
 curl https://raw.githubusercontent.com/TonyRL/docker-transmission-skip-hash-check/focal/patches/001-skip-hash-checking.patch \
	-o patches/001-skip-hash-checking.patch && \
 curl https://raw.githubusercontent.com/TonyRL/docker-transmission-skip-hash-check/focal/patches/002-fdlimit.patch \
	-o patches/002-fdlimit.patch && \
 curl https://raw.githubusercontent.com/TonyRL/docker-transmission-skip-hash-check/focal/patches/003-random-announce.patch \
	-o patches/003-random-announce.patch && \
 
 echo "**** apply patch ****" && \
 patch -N -p0 < patches/001-skip-hash-checking.patch && \
 patch -N -p0 < patches/002-fdlimit.patch && \
 patch -N -p0 < patches/003-random-announce.patch && \
 
 echo "**** setup artifact folder ****" && \
 mkdir build && \
 cd build && \
 
 echo "**** compile checks ****" && \
 ../autogen.sh --enable-daemon --disable-nls && \
 echo "**** compile start ****" && \
 make -j$(nproc) && \
 echo "**** compile finish ****" && \
 make install && \
 
 echo "**** overwrite base executable ****" && \
  
 echo "**** setup default web interface  + transmission-web-control ****" && \
 cp -rp /usr/local/share/transmission/web /web && \
 cd / && \
 curl -O https://codeload.github.com/ronggang/transmission-web-control/zip/master && \
 unzip -q master && \
 rm master && \
 mv /transmission-web-control-master/src/ /transmission-web-control/ && \
 rm -rf /transmission-web-control-master/ && \
 cd / && \

 echo "**** cleanup ****" && \
 apt clean && \
 rm -rf /transmission-build && \
 echo "**** finish ****"

FROM lsiobase/ubuntu:focal

RUN \
 echo "**** install packages ****" && \
 apt update && \
 apt install -qqy \
	libcurl4 \
	libevent-2.1-7 \
	libminiupnpc17 \
	libnatpmp1 && \
 echo "**** cleanup ****" && \
 apt clean

# copy local files
COPY --from=builder /usr/local/bin/ /usr/bin/
COPY --from=builder /web  /web
COPY --from=builder /transmission-web-control  /transmission-web-control
COPY --from=builder /s6-config /

# ports and volumes
EXPOSE 9091 51413 51413/udp
VOLUME /config /downloads /watch
