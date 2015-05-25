#!/bin/bash

set -eux

rebuild_config() {
  backend_list=`mktemp`
  backend_locations=`mktemp`

  for backend_data in `ls backends/*`; do
    # This is a unique backend! We need to setup http://server/backend and add all the units in the relation to the pool.
    backend_id=`cat $backend_data`
    if [ -z "$backend_id" ]; then
      juju-log "What happened? Where's the data? IT'S GONE JIM!"
      rm -f $backend_data
      continue
    fi

    export BACKEND=`basename $backend_data`

    if [ -z "$(relation-list -r $backend_id)" ]; then
      # Somehow we have a relation with no units, wat? Oh, it's probably been removed. We should clean up!
      rm -f $backend_data
      rm -f /etc/nginx/sites-enabled/$BACKEND || true
      continue
    fi

    echo "upstream $BACKEND {" >> $backend_list

    for unit in `relation-list -r $backend_id`; do
      # TIME TO SWIM!
      echo "  server $(relation-get -r $backend_id hostname $unit):$(relation-get -r $backend_id port $unit);" >> $backend_list
    done

    echo "}" >> $backend_list
    echo "" >> $backend_list

    if [ `config-get cache` == 'true' ]; then
      PROXY_CACHE=`cat tpl/cache.part.tpl`
    else
      PROXY_CACHE=""
    fi

    export PROXY_CACHE

    cheetah fill --env --stdout tpl/backend.tpl >> $backend_locations
    echo "" >> $backend_locations
  done

  if [ ! -z `config-get default-route` ]; then
    DEFAULT_ROUTE=`config-get default-route`
    if [ ${DEFAULT_ROUTE::1} != "/" ]; then
      DEFAULT_ROUTE="/$DEFAULT_ROUTE"
    fi
  else
    DEFAULT_ROUTE=""
  fi

  export DEFAULT_ROUTE
  export PORT=`config-get port`
  export BACKEND_UPSTREAMS=`cat $backend_list`
  export BACKEND_LOCATIONS=`cat $backend_locations`

  cheetah fill --env --stdout tpl/default.tpl > /etc/nginx/sites-enabled/default

  hooks/start
}
