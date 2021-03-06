#!/bin/bash
CUSTOMERBASEDIR="/customer"
CUSTOMER=$1
CUSTOMERDIR="${CUSTOMERBASEDIR}/${CUSTOMER}"
DEPOTDIR="/depot"
INTRODIR="${CUSTOMERDIR}/logs/intro"
#SLEEP=$((3600 * 1))
SLEEP=600
MINDUR=60
MAXAGE=366

SQLITE="$(which sqlite3)"

test -r "$INTRODIR" || mkdir -p "$INTRODIR"

function create_database () {
    DBFILE="$1"
    test -r $DBFILE && return 1

    SQLCMD="CREATE TABLE IF NOT EXISTS introstats( \
	mountpoint TEXT NOT NULL DEFAULT 'unknown', \
	channel TEXT NOT NULL DEFAULT 'unknown', \
	ipaddress TEXT NOT NULL DEFAULT 'unknown', \
	start_datetime TEXT NOT NULL DEFAULT 'unknown', \
	start_date TEXT NOT NULL DEFAULT 'unknown', \
	start_day_txt TEXT NOT NULL DEFAULT 'unknown', \
	start_day_int INTEGER NOT NULL DEFAULT 666, \
	start_time TEXT NOT NULL DEFAULT 'unknown', \
	start_hour_txt TEXT NOT NULL DEFAULT 'unknown', \
	start_hour_int INTEGER NOT NULL DEFAULT 666, \
	played_sec INTEGER NOT NULL DEFAULT 0, \
	country TEXT NOT NULL DEFAULT 'unknown', \
	state TEXT NOT NULL DEFAULT 'unknown', \
	city TEXT NOT NULL DEFAULT 'unknown', \
	zip TEXT NOT NULL DEFAULT 'unknown', \
	latitude TEXT NOT NULL DEFAULT 'unknown', \
	longitude TEXT NOT NULL DEFAULT 'unknown' \
	);"
    echo "$SQLCMD" | $SQLITE "$DBFILE" > /dev/null 2>&1 && return 0
    return 1
}

function remove_empty_database () {
    DBFILE="$1"
    test -r "$DBFILE" || return 1
    SQLCMD="select count(ipaddress) from introstats;"
#    echo "$SQLCMD" | $SQLITE "$DBFILE"
    echo "$SQLCMD" | $SQLITE "$DBFILE" | grep -w '0' > /dev/null 
    if [ $? -eq 0 ]; then
	rm -f "$DBFILE"
    fi
    return 0
}

function do_sql() {
STATEMENT="$1"
while true; do
    echo "$STATEMENT" | $SQLITE $DB 2>/dev/null && break
done
}

while true; do
    for RAWINTROLOG in $DEPOTDIR/introlog.${CUSTOMER}.*; do
	test -r "$RAWINTROLOG" || continue
cp -f "$RAWINTROLOG" $DEPOTDIR/introtest/

	FILE_BASE="intro.$CUSTOMER"
	FILE_SQLCMD_SUFF="sql"
	FILE_SQLITE_SUFF="ite"
	FILE_CSV_SUFF="csv.txt"

	find $INTRODIR -type f -mtime +${MAXAGE} -iname "introlog*" -exec rm {} \;


	cat "$RAWINTROLOG" | ( \
	    C_IP=""; C_DUR=""; C_MOUNT=""
	    while read LINE; do
		echo "$LINE" | grep "$TSTAMPLOG" > /dev/null || continue
	    	C_IP=$(echo "$LINE" | awk '{print $1}')
	    	C_DUR=$(echo "${LINE##*\ }")
	    	C_MOUNT=$(echo "$LINE" | awk '{print $7}' | sed 's|^/||')
	    	C_CHANNEL=$(echo "$C_MOUNT" | sed 's|\..*||')
	    	C_TIME=$(echo "$LINE" | awk '{print $4}' | sed 's|\[||')
	    	if [ "x$C_IP" == "x" ]; then continue; fi
	    	if [ "x$C_DUR" == "x" ]; then continue; fi
	    	[[ $C_DUR =~ ^[-+]?[0-9]+$ ]]; if [ $? -ne 0 ]; then continue; fi
	    	if [ "x$C_MOUNT" == "x" ]; then continue; fi
	    	if [ "x$C_TIME" == "x" ]; then continue; fi
	    	A_TIME=($(echo "$C_TIME" | sed 's|\/|\ |g' | sed 's|\:|\ |g'))
	    	C_T_YEAR=${A_TIME[2]}
	    	C_T_MONTH=${A_TIME[1]}
	    	C_T_DAY=${A_TIME[0]}
#	    	C_T_DAY_INT=${A_TIME[0]#0*}
	    	C_T_HOUR=${A_TIME[3]}
#	    	C_T_HOUR_INT=${A_TIME[3]#0*}
	    	C_T_MIN=${A_TIME[4]}
	    	C_T_SEC=${A_TIME[5]}
	    	C_T_EPOCH=$(date -d "${C_T_MONTH} ${C_T_DAY} ${C_T_HOUR}:${C_T_MIN}:${C_T_SEC} ${C_T_YEAR} UTC" +%s)
	    	C_T_E_STOP="$C_T_EPOCH"
	    	C_T_E_START=$(($C_T_EPOCH - $C_DUR))
	    	C_T_STOP="$(date -d @${C_T_E_STOP} '+%Y-%m-%d %H:%M:%S')"
	    	C_T_START="$(date -d @${C_T_E_START} '+%Y-%m-%d %H:%M:%S')"
	    	C_T_START_DATE="$(date -d @${C_T_E_START} '+%Y-%m-%d')"
	    	C_T_START_TIME="$(date -d @${C_T_E_START} '+%H:%M:%S')"
		C_T_START_HOUR="$(date -d @${C_T_E_START} +%H)"
		C_T_START_HOUR_INT="${C_T_START_HOUR#0*}"
		C_T_START_DAY="$(date -d @${C_T_E_START} +%d)"
		C_T_START_DAY_INT="${C_T_START_DAY#0*}"
		C_T_START_YEAR="$(date -d @${C_T_E_START} +%Y)"
		C_T_START_MONTH="$(date -d @${C_T_E_START} +%m)"
		QUOTE="\'"
	    	OIFS=$IFS;IFS=$'\,';A_GEO=($(geoiplookup $C_IP | grep 'City' | sed 's|^.*\:||' | sed 's|\x27||g' 2>/dev/null));IFS=$OIFS
		C_GEO_COUNTRY="$(echo "${A_GEO[0]}" | sed 's|^\ ||')"
		C_GEO_STATE="$(echo "${A_GEO[2]}" | sed 's|^\ ||')"
		C_GEO_CITY="$(echo "${A_GEO[3]}" | sed 's|^\ ||')"
		C_GEO_ZIP="$(echo "${A_GEO[4]}" | sed 's|^\ ||')"
		C_GEO_LAT="$(echo "${A_GEO[5]}" | sed 's|^\ ||')"
		C_GEO_LON="$(echo "${A_GEO[6]}" | sed 's|^\ ||')"

		CSVSTRING="${C_MOUNT},${C_CHANNEL},${C_IP},${C_T_START},${C_T_START_DATE},${C_T_START_TIME},${C_T_START_HOUR},${C_DUR},${C_GEO_COUNTRY},${C_GEO_STATE},${C_GEO_CITY},${C_GEO_ZIP},${C_GEO_LAT},${C_GEO_LON}\r"
		SQLSTRING="INSERT INTO introstats ( mountpoint,channel,ipaddress,start_datetime,start_date,start_day_txt,start_day_int,start_time,start_hour_txt,start_hour_int,played_sec,country,state,city,zip,latitude,longitude ) VALUES ('${C_MOUNT}','${C_CHANNEL}','${C_IP}','${C_T_START}','${C_T_START_DATE}','${C_T_START_DAY}','${C_T_START_DAY_INT}','${C_T_START_TIME}','${C_T_START_HOUR}','${C_T_START_HOUR_INT}',${C_DUR},'${C_GEO_COUNTRY}','${C_GEO_STATE}','${C_GEO_CITY}','${C_GEO_ZIP}','${C_GEO_LAT}','${C_GEO_LON}');"

#		# UTF-8 OUT ####################################################################################################
		echo -e "$CSVSTRING" | iconv -f ascii -t utf-8 -c >> $DEPOTDIR/${FILE_BASE}.${C_T_START_YEAR}-${C_T_START_MONTH}-${C_T_START_DAY}.${FILE_CSV_SUFF}
		echo -e "$SQLSTRING" | iconv -f ascii -t utf-8 -c >> $DEPOTDIR/${FILE_BASE}.${C_T_START_YEAR}-${C_T_START_MONTH}.${FILE_SQLCMD_SUFF}
	    done
	)
	rm -f "$RAWINTROLOG"
    done
    for PREINTROLOG in $DEPOTDIR/${FILE_BASE}.*.${FILE_CSV_SUFF}; do
	test -r "$PREINTROLOG" || continue
	cat "$PREINTROLOG" >> "$INTRODIR/$(basename $PREINTROLOG)"
	if [ $? -eq 0 ]; then
	    rm -f "$PREINTROLOG"
	fi
    done
    for PREINTROLOG in $DEPOTDIR/${FILE_BASE}.*.${FILE_SQLCMD_SUFF}; do
	test -r "$PREINTROLOG" || continue
	test -r "$INTRODIR/$(basename $PREINTROLOG)${FILE_SQLITE_SUFF}" || create_database "$INTRODIR/$(basename $PREINTROLOG)${FILE_SQLITE_SUFF}"
	SQLLOOP=0
	while [ $SQLLOOP -lt 10 ]; do
	    cat "$PREINTROLOG" | $SQLITE "$INTRODIR/$(basename $PREINTROLOG)${FILE_SQLITE_SUFF}" 2>/dev/null 
	    if [ $? -eq 0 ]; then
		rm -f "$PREINTROLOG"
		break
	    fi
	    SQLLOOP=$(( $SQLLOOP + 1 ))
	    sleep 1
	done
    done
    sleep $SLEEP
done
exit
