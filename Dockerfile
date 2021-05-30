FROM debian:stretch-slim

ENV	OPENRESTY_VERSION=1.15.8.3 \
	BUILD_DEPS="libreadline6-dev libncurses5-dev libpcre3-dev libssl-dev zlib1g-dev make build-essential wget git" \
	WSPROXY_ADDR="172.17.0.1:23" \
	WSPROXY_CONN_DATA=""

RUN	apt-get update && apt-get dist-upgrade -y && apt-get install -y ${BUILD_DEPS} libssl1.1 \
	&& \
	mkdir -p /tmp/build && \
	cd /tmp/build && \
	wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz && \
	tar xfz openresty-${OPENRESTY_VERSION}.tar.gz && \
	cd /tmp/build/openresty-${OPENRESTY_VERSION} && \
	./configure \
		--with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2' \
		--with-ld-opt='-Wl,-z,relro -Wl,-z,now' \
		--with-http_stub_status_module \
		--with-http_realip_module \
		--with-http_auth_request_module \
		--with-http_slice_module \
		--with-threads \
		--with-http_addition_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_secure_link_module \
		--with-http_sub_module \
		--with-stream_ssl_module \
		--with-pcre-jit \
		--with-ipv6 \
		--with-http_v2_module \
		--prefix=/usr/share/nginx \
		--sbin-path=/usr/sbin/nginx \
		--conf-path=/etc/nginx/nginx.conf \
		--http-log-path=/var/log/nginx/access.log \
		--error-log-path=/var/log/nginx/error.log \
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
	make && make install && \
	mkdir -p /app/lib && \
	git clone https://github.com/toxicfrog/vstruct/ /app/lib/vstruct && \
	apt-get purge -y ${BUILD_DEPS} && \
	apt-get autoremove -y && \
	apt-get autoclean && \
	rm -rf /tmp/build && \
	ln -sf /dev/stdout /var/log/nginx/access.log && \
	ln -sf /dev/stderr /var/log/nginx/error.log

COPY	wsproxy.lua /app/wsproxy.lua
COPY	nginx.conf /etc/nginx/nginx.conf

EXPOSE	80
CMD	["nginx", "-g", "daemon off;"]
