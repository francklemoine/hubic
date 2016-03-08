# HubiC

This Docker image aims to synchronize local datas to a [HubiC](https://hubic.com/) data store.
It is based on the official HubiC binaries.


A Dockerfile is also available for the __Raspberry Pi__
(Automated builds fail since Docker Hub currently doesn't support ARM platforms).
You can grab that image or build it yourself from Github.

## Links

- arm (raspberry PI)
  - [GitHub](https://github.com/francklemoine/rpi-hubic)
  - [Docker Hub](https://hub.docker.com/r/flem/rpi-hubic)

- x86_64
  - [GitHub](https://github.com/francklemoine/hubic)
  - [Docker Hub](https://hub.docker.com/r/flem/hubic)


## Usage

```
docker run -d \
           -v /etc/localtime:/etc/localtime:ro \
           -v /etc/timezone:/etc/timezone:ro \
           -v /path/to/datas:/hubiC
           -v /path/to/config:/root/.config/hubiC
           -e EMAIL=xxxxxxxx
           -e PASSWORD=xxxxxxxx
           flem/rpi-hubic
```

