docker build -t 2beesadmin/webserver .

runme="
docker run --name webserver -d \
  -v `pwd`/log:/var/log/nginx \
  -v `pwd`/upload:/var/upload \
  -v `pwd`/www:/home/www \
  -p 3000:3000 -p 8000:80 -p 8433:443 \
  -e APP='asset.2bees.com' \
  -t 2beesadmin/webserver

docker exec -it webserver bash
"
