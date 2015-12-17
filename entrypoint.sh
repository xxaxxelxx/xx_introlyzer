#!/bin/bash
CFGDIR="/etc/lighttpd"
PASSWORDFILE=$CFGDIR/lighttpd-plain.user
CONFIGFILE=$CFGDIR/lighttpd.conf

# password section
echo "admin:$CUSTOMERPASSWORD_admin" > $PASSWORDFILE
CONFIGSTRING="\"/admin\" => (\"method\"  => \"digest\",\"realm\"   => \"You are entering the admin sector. Authenticate yourself to the skynet.\",\"require\" => \"user=admin\" )"
USERSTRING="user=admin"
test -d /customer/admin/ || mkdir -p /customer/admin/
cp index.admin.html /customer/admin/index.html
for CUSTOMER in "$@"; do
    echo $CUSTOMER:$(eval echo \$CUSTOMERPASSWORD_$CUSTOMER) >> $PASSWORDFILE
    CONFIGSTRING="\"/$CUSTOMER\" => (\"method\"  => \"digest\",\"realm\"   => \"You are entering the $CUSTOMER sector. Authenticate yourself to the skynet.\",\"require\" => \"user=admin|user=$CUSTOMER\" ),$CONFIGSTRING"
    test -r /customer/$CUSTOMER/index.html || cp index.customer.html /customer/$CUSTOMER/index.html
    sed -i "s/CUSTOMER/$CUSTOMER/g" /customer/$CUSTOMER/index.html
    USERSTRING="$USERSTRING|user=$CUSTOMER"
done

cat "$CONFIGFILE" | grep '^auth.require' > /dev/null
if [ $? -ne 0 ]; then
    CONFIGSTRING="\"/index.php\" => (\"method\"  => \"digest\",\"realm\"   => \"Authenticate yourself to the skynet.\",\"require\" => \"$USERSTRING\" ),$CONFIGSTRING"
    echo "auth.require = ( $CONFIGSTRING )" >> $CONFIGFILE
fi

cp index.php /customer/

lighttpd -D -f /etc/lighttpd/lighttpd.conf
#bash
exit
