#!/bin/sh
set -e

# 如果存在我们的模板文件，就把其中的 $VPS_HOST / $VPS_PORT 注入到 index.html
if [ -f /usr/share/nginx/html/index.html.template ]; then
  envsubst '${VPS_HOST} ${VPS_PORT}' \
    < /usr/share/nginx/html/index.html.template \
    > /usr/share/nginx/html/index.html
fi

exec "$@"
