FROM debian:bookworm-slim

ENV	OPENRESTY_VERSION=1.25.3.1 \
	BUILD_DEPS="libreadline6-dev libncurses5-dev libpcre3-dev libssl-dev zlib1g-dev make build-essential wget git libssl3" \
	WSPROXY_ADDR="172.17.0.1:23" \
	WSPROXY_CONN_DATA=""

RUN	apt-get update && apt-get install -y ${BUILD_DEPS}
RUN mkdir -p /tmp/build && \
	cd /tmp/build && \
	wget -c https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz && \
	tar xfz openresty-${OPENRESTY_VERSION}.tar.gz && \
	cd /tmp/build/openresty-${OPENRESTY_VERSION} && \
	./configure \
		--with-threads \
		--with-http_v2_module \
		--prefix=/usr/share/nginx \
		--sbin-path=/usr/sbin/nginx \
		--conf-path=/etc/nginx/nginx.conf \
		--http-log-path=/dev/stdout \
		--error-log-path=/dev/stderr \
		--lock-path=/var/lock/nginx.lock \
		--pid-path=/run/nginx.pid \
		--http-client-body-temp-path=/tmp/body \
		--http-fastcgi-temp-path=/tmp/fastcgi \
		--http-proxy-temp-path=/tmp/proxy \
		--http-scgi-temp-path=/tmp/scgi \
		--http-uwsgi-temp-path=/tmp/uwsgi \
		--user=www-data \
		--group=www-data \
	&& \
	make && make install clean
RUN mkdir -p /app/lib && \
	git clone https://github.com/toxicfrog/vstruct/ /app/lib/vstruct && \
	rm -rf /tmp/build

COPY	wsproxy.lua /app/wsproxy.lua
COPY	nginx.conf /etc/nginx/nginx.conf

EXPOSE	80
CMD	["nginx", "-g", "daemon off;"]
