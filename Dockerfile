# DESCRIPTION: HubiC daemon within a container
# BUILD:       docker build -t flem/rpi-hubic .
# RUN:         docker run -d \
#                         -v /etc/localtime:/etc/localtime:ro \
#                         -v /etc/timezone:/etc/timezone:ro \
#                         -v /path/to/datas:/hubiC
#                         -v /path/to/config:/root/.config/hubiC
#                         -e EMAIL=xxxxxxxx
#                         -e PASSWORD=xxxxxxxx
#                         flem/rpi-hubic


FROM debian:stretch
MAINTAINER Franck Lemoine <franck.lemoine@flem.fr>

# properly setup debian sources
ENV DEBIAN_FRONTEND=noninteractive

ENV HUBIC_VERSION=2.1.0
ENV HUBIC_VERSION_MINOR=53
ENV HUBIC_PACKAGE_URL=http://mir7.ovh.net/ovh-applications/hubic/hubiC-Linux/${HUBIC_VERSION}/hubiC-Linux-${HUBIC_VERSION}.${HUBIC_VERSION_MINOR}-linux.deb

RUN buildDeps=' \
		dbus \
		dbus-x11 \
		mono-runtime \
		libmono-sqlite4.0-cil \
		libmono-system-core4.0-cil \
		libmono-system-data4.0-cil \
		libmono-system-data-datasetextensions4.0-cil \
		libmono-system-drawing4.0-cil \
		libmono-system-runtime-serialization4.0-cil \
		libmono-system-xml-linq4.0-cil \
		ca-certificates-mono \
		wget \
		supervisor \
	' \
	set -x \
	&& apt-get -y update \
	&& apt-get -y upgrade \
	&& apt-get install -y --no-install-recommends $buildDeps \
	&& wget -O /tmp/hubiC.deb ${HUBIC_PACKAGE_URL} \
	&& dpkg -i /tmp/hubiC.deb \
	&& sed -ri ' \
		s!^#?[\t[:space:]]*(PARAMS=".*)"$!\1 --nofork"!g; \
		' /etc/default/dbus \
	&& apt-get clean autoclean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/* \
	&& mkdir /hubiC

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

VOLUME ["/root/.config/hubiC"]

ENTRYPOINT ["/docker-entrypoint.sh"]
