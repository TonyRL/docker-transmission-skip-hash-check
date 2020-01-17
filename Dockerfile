FROM linuxserver/transmission:latest

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="transmission-skip-hash version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="TonyRL"

# install packages
RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
	build-base \
	curl \
	curl-dev \
	intltool \
	libevent-dev \
	miniupnpc-dev && \
 mkdir /transmission-build && \
 cd /transmission-build && \
 
 echo "**** download transmission ****" && \
 curl -O https://raw.githubusercontent.com/transmission/transmission-releases/master/transmission-2.94.tar.xz && \
 tar Jxf transmission-2.94.tar.xz && \
 cd transmission-2.94 && \
 
 echo "**** download skip hash check patch ****" && \
 curl -O https://raw.githubusercontent.com/TonyRL/spksrc-origin/master/cross/transmission/patches/002-skip-hash-checking.patch && \
 
 echo "**** apply patch ****" && \
 cd libtransmission && \
 patch < ../002-skip-hash-checking.patch && \
 cd .. && \
 
 echo "**** setup artifact folder ****" && \
 mkdir build && \
 cd build && \
 
 echo "**** compile checks ****" && \
 ../configure --enable-daemon --with-gtk=no && \
 
 echo "**** compile start ****" && \
 make -j$(nproc) && \
 echo "**** compile finish ****" && \
 
 echo "**** copy artifact ****" && \
 cp ./daemon/transmission-daemon /usr/bin/ && \
 cp ./daemon/transmission-remote /usr/bin/ && \
 cp ./utils/transmission-create /usr/bin/ && \
 cp ./utils/transmission-edit /usr/bin/ && \
 cp ./utils/transmission-show /usr/bin/ && \
 
 echo "**** cleanup ****" && \
 apk del build-base && \
 rm -rf /transmission-build && \
 rm -rf /combustion-release && \
 rm -rf /kettu && \
 rm -rf /transmission-web-control && \
 
 echo "**** setup latest transmission-web-control ****" && \
 cd / && \
 curl -O https://codeload.github.com/ronggang/transmission-web-control/zip/master && \
 unzip -q master && \
 rm master && \
 mv transmission-web-control-master/ transmission-web-control/ && \
 echo "**** finish ****"

# ports and volumes
EXPOSE 9091 51413 51413/udp
VOLUME /config /downloads /watch
