FROM ubuntu

RUN apt-get update && \
    apt-get install nginx -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN touch /var/log/nginx/error.log

ADD nginx.conf /etc/nginx/sites-enabled/default
ADD start-nginx.sh /start-nginx.sh

CMD /start-nginx.sh
