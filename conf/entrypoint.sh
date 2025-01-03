#!/bin/sh
set -e

# 如果找到 index.html.template，就用 envsubst 替换为 index.html
if [ -f /usr/share/nginx/html/index.html.template ]; then
  envsubst '${VPS_HOST} ${VPS_PORT}' \
    < /usr/share/nginx/html/index.html.template \
    > /usr/share/nginx/html/index.html
fi

exec "$@"
