#!/bin/sh

./build.sh ; ./restart.sh -v ~/Documents/bt2-ui/indexes:/indexes -v ~/Documents/bt2-ui/gtf:/gtf -v ~/Documents/bt2-ui/data:/data
