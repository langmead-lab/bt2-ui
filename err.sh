CID=`docker ps | grep shiny | awk '{ print $1 }'`
docker logs $CID
