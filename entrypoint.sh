#!/bin/bash

# password section
if [ -n "$UPDATEPASSWORD" ]; then
    sed -i "s/ADMINPASS/$UPDATEPASSWORD/g" /etc/lighttpd/lighttpd-plain.user
fi


mkdir -p /dev/shm/html
cp /var/www/html/*.php /dev/shm/html/ 
chown -R www-data /dev/shm/html/
#bash
lighttpd -D -f /etc/lighttpd/lighttpd.conf

exit
