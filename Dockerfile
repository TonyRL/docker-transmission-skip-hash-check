FROM lsiobase/alpine:3.11

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="transmission-skip-hash version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="TonyRL"

# install packages
RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
	autoconf \
	automake \
	build-base \
	cmake \
	curl \
	curl-dev \
	intltool \
	libevent-dev \
	libtool \
	m4 \
	miniupnpc-dev && \
 mkdir /transmission-build && \
 cd /transmission-build && \
 
 echo "**** download transmission ****" && \
 curl -O https://raw.githubusercontent.com/transmission/transmission-releases/master/transmission-2.94.tar.xz && \
 tar Jxf transmission-2.94.tar.xz && \
 cd transmission-2.94 && \
 
 echo "**** download patch ****" && \
 mkdir patches && \
 curl https://raw.githubusercontent.com/TonyRL/docker-transmission-skip-hash-check/master/patches/001-skip-hash-checking.patch \
	-o patches/001-skip-hash-checking.patch && \
 curl https://raw.githubusercontent.com/TonyRL/docker-transmission-skip-hash-check/master/patches/002-fdlimit.patch \
	-o patches/002-fdlimit.patch && \
 curl https://raw.githubusercontent.com/TonyRL/docker-transmission-skip-hash-check/master/patches/003-fdlimit.patch \
	-o patches/003-fdlimit.patch && \
 
 echo "**** apply patch ****" && \
 cd libtransmission && \
 patch < ../patches/001-skip-hash-checking.patch && \
 cd .. && \
 
 echo "**** setup artifact folder ****" && \
 mkdir build && \
 cd build && \
 
 echo "**** compile checks ****" && \
 ../configure --enable-daemon --with-gtk=no && \
 echo "**** compile start ****" && \
 make -j$(nproc) && \
 echo "**** compile finish ****" && \
 
 echo "**** overwrite base executable ****" && \
 make install && \
 cp -f /usr/local/bin/transmission-daemon /usr/bin/transmission-daemon && \
 cp -f /usr/local/bin/transmission-remote /usr/bin/transmission-remote && \
 cp -f /usr/local/bin/transmission-create /usr/bin/transmission-create && \
 
 echo "**** cleanup ****" && \
 apk del --no-cache \
	autoconf \
	automake \
	build-base \
	cmake \
	libtool \
	m4 && \
 rm -rf /transmission-build && \
 rm -rf /combustion-release && \
 rm -rf /kettu && \
 rm -rf /transmission-web-control && \
 
 echo "**** setup latest transmission-web-control ****" && \
 cd / && \
 curl -O https://codeload.github.com/ronggang/transmission-web-control/zip/master && \
 unzip -q master && \
 rm master && \
 mv /transmission-web-control-master/src/ /transmission-web-control/ && \
 rm -rf /transmission-web-control-master/ && \
 cd / && \
 echo "**** finish ****"

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9091 51413 51413/udp
VOLUME /config /downloads /watch
