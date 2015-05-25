
$BACKEND_UPSTREAMS

server {
  listen $PORT default;
  server_name _;

  $BACKEND_LOCATIONS

  #if $DEFAULT_ROUTE
  location / {
    rewrite (.*) $DEFAULT_ROUTE\$1 last;
  }
  #end if
}
