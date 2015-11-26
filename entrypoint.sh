#!/bin/bash
CFGDIR="/etc/lighttpd"
PASSWORDFILE=$CFGDIR/lighttpd-plain.user
CONFIGFILE=$CFGDIR/lighttpd.conf

# password section
echo "admin:$CUSTOMERPASSWORD_ADMIN" > $PASSWORDFILE
CONFIGSTRING=""
for CUSTOMER in "$@"; do
    echo $CUSTOMER:$(eval echo \$CUSTOMERPASSWORD_$CUSTOMER) >> $PASSWORDFILE
    if [ "x$CONFIGSTRING" != "x" ]; then
	CONFIGSTRING="\"/customer/$CUSTOMER\" => (\"method\"  => \"digest\",\"realm\"   => \"You are entering the $CUSTOMER sector!\",\"require\" => \"user=$CUSTOMER\" ),$CONFIGSTRING"
    else
	CONFIGSTRING="\"/customer/$CUSTOMER\" => (\"method\"  => \"digest\",\"realm\"   => \"You are entering the $CUSTOMER sector!\",\"require\" => \"user=$CUSTOMER\" )"
    fi
    cp index.html /customer/$CUSTOMER/
done
    echo "auth.require = ( $CONFIGSTRING )" >> $CONFIGFILE

#lighttpd -D -f /etc/lighttpd/lighttpd.conf
bash
exit
