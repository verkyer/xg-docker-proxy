# Dockerfile at project root

# ----------------------------------------------------
# 1) Builder stage: 编译带 proxy_connect_module 的 Nginx
# ----------------------------------------------------
FROM alpine:3.18 AS builder

RUN apk add --no-cache \
    gcc g++ make openssl-dev pcre-dev zlib-dev linux-headers \
    curl git perl-dev libtool autoconf automake

ENV NGINX_VERSION="1.24.0"
ENV PC_MODULE_REPO="https://github.com/chobits/ngx_http_proxy_connect_module.git"

WORKDIR /tmp/build

# 1.1 下载 Nginx 源码
RUN curl -SL "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -o nginx.tar.gz \
    && tar xzf nginx.tar.gz

# 1.2 克隆 proxy_connect_module 源码
RUN git clone "${PC_MODULE_REPO}"

# 1.3 进入 Nginx 源码目录并编译
WORKDIR /tmp/build/nginx-${NGINX_VERSION}
RUN ./configure \
    --prefix=/etc/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --sbin-path=/usr/sbin/nginx \
    --add-module=../ngx_http_proxy_connect_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_gzip_static_module \
    && make && make install

# ----------------------------------------------------
# 2) Final stage: 复制编译产物 + 配置
# ----------------------------------------------------
FROM alpine:3.18

# 安装 gettext (envsubst)
RUN apk add --no-cache libintl && \
    apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing gettext

# 拷贝编译好的 Nginx
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx

# 创建必要的目录并调整权限
RUN mkdir -p /var/log/nginx /var/run/nginx \
    && addgroup -S nginx && adduser -S -G nginx nginx

# 拷贝本地 conf/ 文件夹里的配置到容器
COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY conf/entrypoint.sh /entrypoint.sh
COPY conf/index.html.template /usr/share/nginx/html/index.html.template

# 给 entrypoint.sh 执行权限
RUN chmod +x /entrypoint.sh

EXPOSE 80

USER nginx

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
