# fileupload-nginx
==================
## pointlook/webserver
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs",
etc/nginx/conf.d", "/var/log/nginx", "/var/upload", "/home/www" ]


```
mkdir `pwd`/log `pwd`/upload 
docker run --name webserver -d \
  -v `pwd`/log:/var/log/nginx \
  -v `pwd`/upload:/var/upload \
  -p 3000:3000 -p 8000:80 -p 8433:443 \
  -e APP='message.2bees.com' \
  -t pointlook/webserver

docker exec -it webserver bash
```
