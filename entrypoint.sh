#!/bin/bash
CFGDIR="/etc/lighttpd"
PASSWORDFILE=$CFGDIR/lighttpd-plain.user
CONFIGFILE=$CFGDIR/lighttpd.conf

# password section
echo "admin:$CUSTOMERPASSWORD_ADMIN" > $PASSWORDFILE
for CUSTOMER in "$@"; do
    echo $CUSTOMER:$(eval echo \$CUSTOMERPASSWORD_$CUSTOMER) >> $PASSWORDFILE
    echo "auth.require = ( \"/customer/$CUSTOMER\" => (\"method\"  => \"digest\",\"realm\"   => \"You are entering the $CUSTOMER sector!\",\"require\" => \"user=$CUSTOMER\" ))" >> CONFIGFILE=$CFGDIR/lighttpd.conf
done

lighttpd -D -f /etc/lighttpd/lighttpd.conf

exit
