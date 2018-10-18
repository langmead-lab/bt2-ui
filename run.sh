#!/bin/sh

docker run --privileged --shm-size 30m --name bt2-ui --rm -p 3838:3838 -d $* benlangmead/bt2-ui
