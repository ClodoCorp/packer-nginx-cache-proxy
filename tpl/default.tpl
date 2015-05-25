proxy_cache_path /mnt/ramdisk/proxy-cache levels=1:2 keys_zone=proxycache:50M max_size=1G inactive=2h;
proxy_temp_path /mnt/ramdisk/tmp-cache 1 2;

$BACKEND_UPSTREAMS

server {
  listen $PORT default;
  server_name _;

  $BACKEND_LOCATIONS

  #if $DEFAULT_ROUTE
  location / {
    rewrite ^ $DEFAULT_ROUTE/ redirect;
  }
  #end if
}
