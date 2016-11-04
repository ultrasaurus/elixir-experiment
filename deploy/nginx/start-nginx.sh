#!/bin/bash -eu

# make an entry in hosts file
echo "$HOST_ADDRESS parent" >> /etc/hosts

# startng nginx
service nginx start

# this runs forever so we can see the log output
tail -f /var/log/nginx/error.log