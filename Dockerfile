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
 
 echo "**** overwrite base executable ****" && \
 cp -f ./daemon/transmission-daemon /usr/bin/transmission-daemon && \
 cp -f ./daemon/transmission-remote /usr/bin/transmission-remote && \
 cp -f ./utils/transmission-create /usr/bin/transmission-create && \
 cp -f ./utils/transmission-edit /usr/bin/transmission-edit && \
 cp -f ./utils/transmission-show /usr/bin/transmission-show && \
 
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
 mv /transmission-web-control-master/src/ /transmission-web-control/ && \
 rm -rf /transmission-web-control-master/ && \
 echo "**** finish ****"

# ports and volumes
EXPOSE 9091 51413 51413/udp
VOLUME /config /downloads /watch
