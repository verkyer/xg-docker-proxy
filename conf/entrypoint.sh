#!/bin/sh
set -e

# 如果找到模板，就用 envsubst 注入环境变量
if [ -f /usr/share/nginx/html/index.html.template ]; then
  envsubst '${VPS_HOST} ${VPS_PORT}' \
    < /usr/share/nginx/html/index.html.template \
    > /usr/share/nginx/html/index.html
fi

exec "$@"
