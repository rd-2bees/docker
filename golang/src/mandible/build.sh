docker build -t 2beesadmin/mandible .

runme="
docker run --name mandible -d \
  -p 3000:3000 -p 8000:80 -p 8433:443 -p 8080:8080 \
  -e APP='asset.2bees.com' \
  -t 2beesadmin/mandible

docker exec -it mandible bash
"
