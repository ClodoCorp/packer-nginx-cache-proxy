  location /$BACKEND/ {
    set \$no_cache "";

    if (\$request_method !~ ^(GET|HEAD)\$) {
      set \$no_cache "1";
    }

    if (\$no_cache = "1") {
      add_header Set-Cookie "_mcnc=1; Max-Age=30; Path=/";
      add_header X-Microcachable "0";
    }

    if (\$http_cookie ~* "_mcnc") {
      set \$no_cache "1";
    }

    proxy_no_cache \$no_cache;
    proxy_cache_bypass \$no_cache;

    rewrite ^/${BACKEND}(/?.*)$ \$1 break;
    proxy_pass  http://$BACKEND/;
    $PROXY_CACHE

    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

    proxy_max_temp_file_size 1M;
  }
