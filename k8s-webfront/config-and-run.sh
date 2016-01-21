#!/bin/bash

mkdir -p /var/nginx/assets_cache
mkdir -p /tmp/nginx

chown -R nginx. /var/nginx /tmp/nginx

cat <<'EOF'> /etc/nginx/conf.d/default.conf
client_max_body_size 200m;
proxy_cache_path    /var/nginx/assets_cache levels=1:2        keys_zone=assets:90m inactive=24h max_size=90m;
proxy_temp_path /tmp/nginx;

upstream MYAPP {
	server MYAPP:80;
}

server {
        listen  80;
        server_name www.foo.com foo.com;
        access_log      off;
        rewrite ^(.*)$ https://www.foo.com$1 redirect;
}

server {
        listen       443 ssl;
        server_name  www.foo.com foo.com;
	error_log       /var/log/nginx/foo-error.log;
	root html;
        ssl on;
        ssl_certificate      /www.foo.com.crt;
        ssl_certificate_key  /www.foo.com.key;
	ssl_protocols        TLSv1 TLSv1.1 TLSv1.2;


        gzip             on;
        gzip_min_length  50;
        gzip_proxied     any;
        gzip_types       text/plain text/css text/xml application/xml application/x-javascript application/javascript text/javascript application/js image/png image/jpeg image/gif image/x-icon;

        location / {
                access_log      /var/log/nginx/foo-access.log main;
                try_files $uri @heroku_ssl;
        }


        location @assets_cache {
		access_log      /var/log/nginx/foo-access.log main;
                #expires 1h;
                proxy_cache     assets;
                proxy_cache_key "$request_uri";
                proxy_cache_valid       200 302 60m;
                proxy_cache_use_stale   error timeout invalid_header;
                proxy_ignore_headers "Cache-Control";
                proxy_ignore_headers "Expires";
                proxy_ignore_headers "X-Accel-Expires";

                proxy_connect_timeout      120;
                proxy_send_timeout         120;
                proxy_read_timeout         90;
                proxy_buffer_size          4k;
                proxy_buffers              4 32k;
                proxy_busy_buffers_size    64k;
                proxy_temp_file_write_size 64k;

                proxy_set_header  X-Real-IP  $remote_addr;
                proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header  Host $host;
                #proxy_set_header  X_FORWARDED_PROTO https;
                proxy_redirect    off;
                proxy_max_temp_file_size 0;
                proxy_pass http://MYAPP;
        }

        location @heroku_ssl {
		access_log      /var/log/nginx/foo-access.log main;
                proxy_set_header  X-Real-IP  $remote_addr;
                proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header  Host $host;
                #proxy_set_header  X_FORWARDED_PROTO https;
                proxy_redirect    off;
                proxy_max_temp_file_size 0;
                proxy_pass http://MYAPP;
        }

}
EOF

cat /etc/nginx/conf.d/default.conf
exec nginx -g "daemon off;"
