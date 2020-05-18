#!/bin/sh

conf_path=/aria2/conf
conf_copy_path=/aria2/conf-copy
data_path=/aria2/data
cache_path=/aria2/cache
cache_copy_path=/aria2/cache-copy

if [ ! -f $conf_path/aria2.conf ]; then
	cp $conf_copy_path/aria2.conf $conf_path/aria2.conf
    if [ -n "$RPC_SECRET" ]; then
        printf '\nrpc-secret=%s\n' ${RPC_SECRET} >> $conf_path/aria2.conf
    fi
fi

if [ ! -f $cache_path/dht.dat ]; then
	cp $cache_copy_path/dht.dat $cache_path/dht.dat
fi

if [ ! -f $cache_path/dht6.dat ]; then
	cp $cache_copy_path/dht6.dat $cache_path/dht6.dat
fi

touch $conf_path/aria2.session

if [[ -n "$ARIA2RPCPORT" ]]; then
    echo "Changing rpc request port to $ARIA2RPCPORT"
    sed -i "s/6800/${ARIA2RPCPORT}/g" /usr/local/www/ariang/js/aria-ng*.js
fi

userid="$(id -u)" # 65534 - nobody, 0 - root
groupid="$(id -g)"

if [[ -n "$PUID" && -n  "$PGID" ]]; then
    echo "Running as user $PUID:$PGID"
    userid=$PUID
    groupid=$PGID
fi

chown -R $userid:$groupid $conf_path
chown -R $userid:$groupid $data_path
chown -R $userid:$groupid $cache_path

caddy -quiet -conf /usr/local/caddy/Caddyfile &
su-exec $userid:$groupid aria2c --conf-path="$conf_path/aria2.conf"
