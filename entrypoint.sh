#!/bin/bash
<<<<<<< HEAD

set -e
#set -x

wget http://www.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz > /dev/null 2>&1
if [ $? -eq 0 ]; then
    test -r GeoLiteCity.dat && mv -f GeoLiteCity.dat GeoLiteCity.dat.old
    test -r GeoLiteCity.dat.gz && gunzip -f GeoLiteCity.dat.gz > /dev/null
    if [ $? -eq 0 ]; then
	mv -f GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat
    fi
fi

./introlyzer.sh $@

bash
=======
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
>>>>>>> 85240ecf05cee9bac4867a5f5905447fb6436366
exit
