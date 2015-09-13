docker build -t 2beesadmin/goreceive .

runme="
docker run --name goreceive -d \
  -p 3000:3000 -p 8000:80 \
  -e APP='asset.2bees.com' \
  -t 2beesadmin/goreceive

docker exec -it goreceive bash
"
