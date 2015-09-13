docker build -t 2beesadmin/ubuntu .

runme="
docker run --name ubuntu -d \
     -t pointlook/ubuntu

docker exec -it ubuntu bash
"
