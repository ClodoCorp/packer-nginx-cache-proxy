    proxy_cache proxycache;
    proxy_cache_key $scheme$host$request_method$request_uri;
    proxy_cache_valid any 30s;
    proxy_cache_use_stale updating;
