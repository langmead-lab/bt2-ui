#!/bin/sh

CID=`docker ps | grep shiny | awk '{ print $1 }'`
docker kill $CID && sleep 1; docker run --privileged --name bt2-ui --rm -p 3838:3838 -d $* benlangmead/bt2-ui
