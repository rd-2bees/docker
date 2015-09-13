docker build -t 2beesadmin/owncloud .

runme="
docker run --name owncloud -d \
  -v `pwd`/log:/var/log/nginx \
  -v `pwd`/upload:/var/upload \
  -v `pwd`/www:/home/www \
  -p 3000:3000 -p 8080:8080 \
  -e APP='asset.2bees.com' \
  -t 2beesadmin/owncloud

docker exec -it owncloud bash
"
