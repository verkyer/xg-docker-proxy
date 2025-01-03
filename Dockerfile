# Dockerfile
# 使用 Tengine 2.5.2 作为基础镜像，已内置 mod_proxy_connect
FROM teddysun/tengine:2.5.2

# 我们需要 envsubst 来做环境变量注入
# teddysun/tengine:2.5.2 基于 debian:11 或 alpine，看其说明
# 如果是 debian/ubuntu 底层，一般可用 apt-get 安装 gettext
RUN apt-get update && apt-get install -y --no-install-recommends gettext-base \
    && rm -rf /var/lib/apt/lists/*

# 拷贝我们自己的配置文件到镜像里
COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY conf/entrypoint.sh /entrypoint.sh
COPY conf/index.html.template /usr/share/nginx/html/index.html.template

# 给 entrypoint.sh 执行权限
RUN chmod +x /entrypoint.sh

# 暴露80端口
EXPOSE 80

# 使用 entrypoint.sh 来做最后的模板渲染，然后启动 tengine
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
