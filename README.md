# docker-transmission-skip-hash

A Ubuntu based container images for [Transmission](https://www.transmissionbt.com/) with [customized features](https://github.com/TonyRL/docker-transmission-skip-hash-check/#customized-features).

* Compatible with well-known [linuxserver/transmission](https://hub.docker.com/r/linuxserver/transmission)
* Optional feature-rich Web UI [ronggang/transmission-web-control](https://github.com/ronggang/transmission-web-control), [johman10/flood-for-transmission](https://github.com/johman10/flood-for-transmission) and [openscopeproject/TrguiNG](https://github.com/openscopeproject/TrguiNG)
* Weekly base OS updates from [upstream](https://github.com/linuxserver/docker-baseimage-ubuntu)

![GitHub Repo stars](https://img.shields.io/github/stars/tonyrl/docker-transmission-skip-hash-check?style=for-the-badge)
[![Docker Pulls](https://img.shields.io/docker/pulls/tonyrl/transmission-skip-hash-check?style=for-the-badge)](https://hub.docker.com/r/tonyrl/transmission-skip-hash-check)

## Customized Features

* Skip hash check ([details](https://github.com/TonyRL/docker-transmission-skip-hash-check#how-to-skip-hash-check))
* Lift 1024 open files limit (backport [transmission/transmission#893](https://github.com/transmission/transmission/pull/893))
* Skew Scrape/Announce intervals (backport [transmission/transmission#936](https://github.com/transmission/transmission/pull/936))
* OpenSSL 3 legacy provider support

## Support Version

| Transmission Release   | Base OS       | Tag  | Size  |
| :--------------------: |:-------------:| :---:| :----:|
| 4.x (latest release) | Ubuntu 26.04 LTS | `latest` | [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/tonyrl/transmission-skip-hash-check/latest?style=flat-square)](https://hub.docker.com/r/tonyrl/transmission-skip-hash-check/tags?name=latest)
| 3.00  | Ubuntu 26.04 LTS | `v3` | [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/tonyrl/transmission-skip-hash-check/v3?style=flat-square)](https://hub.docker.com/r/tonyrl/transmission-skip-hash-check/tags?name=v3)
| 2.94 | Ubuntu 26.04 LTS | `v2.94` | [![Docker Image Size (tag)](https://img.shields.io/docker/image-size/tonyrl/transmission-skip-hash-check/v2.94?style=flat-square)](https://hub.docker.com/r/tonyrl/transmission-skip-hash-check/tags?name=v2.94)

## Support Architectures

`linux/amd64` and `linux/arm64`

`linux/arm/v7` is not supported.

## Usage

### docker compose

```yaml
---
services:
  transmission:
    image: tonyrl/transmission-skip-hash-check
    container_name: transmission
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - TRANSMISSION_WEB_HOME=/transmission-web-control #optional, or /flood-for-transmission or /trguing
      - USER=username #optional
      - PASS=password #optional
      - WHITELIST=iplist #optional
    volumes:
      - <path to data>:/config
      - <path to downloads>:/downloads
      - <path to watch folder>:/watch
    ports:
      - 9091:9091
      - 51413:51413
      - 51413:51413/udp
    restart: unless-stopped
```

### docker-cli

```shell
docker run -d \
  --name=transmission \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e TRANSMISSION_WEB_HOME=/transmission-web-control `#optional, or /flood-for-transmission or /trguing` \
  -e USER=username `#optional` \
  -e PASS=password `#optional` \
  -e WHITELIST=iplist `#optional` \
  -p 9091:9091 \
  -p 51413:51413 \
  -p 51413:51413/udp \
  -v <path to data>:/config \
  -v <path to downloads>:/downloads \
  -v <path to watch folder>:/watch \
  --restart unless-stopped \
  tonyrl/transmission-skip-hash-check
```

### Parameters

| Parameter | Function |
| :----: | --- |
| `-p 9091` | WebUI |
| `-p 51413` | Torrent Port TCP |
| `-p 51413/udp` | Torrent Port UDP |
| `-e PUID=1000` | UserID |
| `-e PGID=1000` | GroupID |
| `-e TZ=Europe/London` | Specify a timezone. [Time Zones list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List) |
| `-e TRANSMISSION_WEB_HOME=/transmission-web-control` | Use [transmission-web-control](https://github.com/ronggang/transmission-web-control). Set to `/flood-for-transmission` to use [Flood for Transmission](https://github.com/johman10/flood-for-transmission) or `/trguing` to use [TrguiNG](https://github.com/openscopeproject/TrguiNG). (**optional**) |
| `-e USER=username` | Specify an **optional** username for the interface |
| `-e PASS=password` | Specify an **optional** password for the interface |
| `-e WHITELIST=iplist` | Specify an **optional** list of comma separated host whitelist |
| `-v /config` | Where transmission should store config files and logs. |
| `-v /downloads` | Local path for downloads. |
| `-v /watch` | Watch folder for torrent files. |

### How to skip hash check

In the web interface http://ip:9091/transmission/web/ or [Transmission Remote GUI](https://github.com/transmission-remote-gui/transgui). Right click on ANY SEEDING torrent, choose `Ask tracker for more peers` (or tick ANY torrent and click the ![Ask tracker for more peers](https://user-images.githubusercontent.com/11386903/134805662-c52dfc85-1b80-40cf-8674-5780071a7c85.PNG) icon
in the toolbar) and the CURRENT verifying torrent will be skipped for hash check. (Taken from [here](https://github.com/superlukia/transmission-2.92_skiphashcheck#how-to-use))

## Notes

Alternative Web UI such as [endor/kettu](https://github.com/endor/kettu) and [Secretmapper/combustion](https://github.com/Secretmapper/combustion) are dropped. If you want them back or want me to include other Web UI like [killemov/Shift](https://github.com/killemov/Shift), please raise an issue.

Since this image is LinuxServer based, [Docker Mods](https://github.com/linuxserver/docker-mods) from [LinuxServer.io](https://github.com/linuxserver/docker-mods) are also available.

For further documentation, you can check out [linuxserver/transmission](https://hub.docker.com/r/linuxserver/transmission) and [docs.linuxserver.io](https://docs.linuxserver.io/)

## Credits

[blackyau/Transmission_SkipHashChek](https://github.com/blackyau/Transmission_SkipHashChek/)

[linuxserver/docker-transmission](https://github.com/linuxserver/docker-transmission)

[superlukia/transmission-2.92_skiphashcheck](https://github.com/superlukia/transmission-2.92_skiphashcheck)
