FROM nginx

MAINTAINER Alen Komic <akomic@gmail.com>

COPY config-and-run.sh www.foo.com.key www.foo.com.crt /

RUN ln -sf /dev/stdout /var/log/nginx/foo-access.log && \
	ln -sf /dev/stderr /var/log/nginx/foo-error.log

CMD /config-and-run.sh
