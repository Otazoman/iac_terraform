# iac_terraform  
AWS and Azure and GoogleCloud and Terraform Develop Environment  
  
#Description  
It is a Docker container that combines AWS, Azure, GoogleCloud,   
and Terraform development environments into one.  

#Operating environment  
Ubuntu 20.04.2 LTS  
Docker version 19.03.13, build 4484c46d9d  

#Usage  
$ docker build . -t multicloud-ubuntu \  
--build-arg ruby_ver=3.0.0 \  
--build-arg python_ver=3.9.2 \  
--build-arg python_old_ver=3.8.8  
$ docker container run --name terraform-dev -h terraform-dev -it -d \  
 --mount type=bind,src=$(pwd)/terraform,dst=/root/terraform \  
 --restart=always \  
 -e TZ=Asia/Tokyo multicloud-ubuntu /bin/bash  
$ docker exec -it terraform-dev /bin/bash  

###Caution  
If you need to run the docker command with sudo, prefix it with sudo.
