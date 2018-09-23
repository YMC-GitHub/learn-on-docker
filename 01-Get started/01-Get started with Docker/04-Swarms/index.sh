##########
#建虚拟机
##########
docker-machine create --driver virtualbox myvm1
docker-machine create --driver virtualbox myvm2
docker-machine create --driver virtualbox myvm3

# 列虚拟机
docker-machine ls

# 设管理机
docker-machine ssh myvm1 "docker swarm init --advertise-addr $(docker-machine ip myvm1)"

# 设工作机
docker-machine ssh myvm2 "docker swarm join --token SWMTKN-1-2jhcfueglcmknowqnaus2gucxtsxeedga7jcw7wfpf7ocpo32q-bhh7fj430jk6t7z0oh6bxofjs 192.168.99.101:2377"
docker-machine ssh myvm3 "docker swarm join --token SWMTKN-1-2jhcfueglcmknowqnaus2gucxtsxeedga7jcw7wfpf7ocpo32q-bhh7fj430jk6t7z0oh6bxofjs 192.168.99.101:2377"

# 查看节点
docker-machine ssh myvm1 "docker node ls"

# 离开集群
# 工作机离开集群
#docker-machine ssh myvm2 "docker swarm leave"
#docker-machine ssh myvm3 "docker swarm leave"
# 管理机离开集群
#docker-machine ssh myvm1 "docker swarm leave"


# 连管理机
# eval $(docker-machine env myvm1)
# docker-machine ls
docker-machine ssh myvm1

##########
#下面的命令在管理机中运行
##########
# 登录仓库
docker login hub.c.163.com

# 部署应用
cd "/ymc/learn/01-Get started/01-Get started with Docker/04-Swarms/" && \
docker stack deploy -c docker-compose.yml --with-registry-auth getstartedlab

# 查看服务
docker service ls
docker stack ps --filter "desired-state=running" getstartedlab