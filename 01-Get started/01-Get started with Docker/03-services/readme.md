## 服务

#### 章节系列
Welcome! We are excited that you want to learn Docker. The Docker Get Started Tutorial teaches you how to:

- 1 Set up your Docker environment 
- 2 Build an image and run it as one container
- 3 Scale your app to run multiple containers(on this page)
- 4 Distribute your app across a cluster
- 5 Stack services by adding a backend database
- 6 Deploy your app to production

#### 环境准备
- Install Docker version 1.13 or higher.

- Get Docker Compose. On Docker for Mac and Docker for Windows it’s pre-installed, so you’re good-to-go. On Linux systems you need to install it directly. On pre Windows 10 systems without Hyper-V, use Docker Toolbox.

- Read the orientation in Part 1.

- Learn how to create containers in Part 2.

- Make sure you have published the friendlyhello image you created by pushing it to a registry. We use that shared image here.

- Be sure your image works as a deployed container. Run this command, slotting in your info for username, repo, and tag: 
`docker run -p 4000:80 username/repo:tag`, then visit http://localhost:4000/.


#### 章节介绍
In part 3, we scale our application and enable load-balancing. To do this, we must go one level up in the hierarchy of a distributed application: the service.

- Stack
- Services (you are here)
- Container (covered in part 2)


#### 关于服务
应用与服务
In a distributed application, different pieces of the app are called “services.” For example, if you imagine a video sharing site, it probably includes a service for storing application data in a database, a service for video transcoding in the background after a user uploads something, a service for the front-end, and so on.

容器与服务
Services are really just “containers in production.” A service only runs one image, but it codifies the way that image runs—what ports it should use, how many replicas of the container should run so the service has the capacity it needs, and so on. Scaling a service changes the number of container instances running that piece of software, assigning more computing resources to the service in the process.

定运及伸缩
Luckily it’s very easy to define, run, and scale services with the Docker platform -- just write a `docker-compose.yml` file.

#### 定义服务
A `docker-compose.yml` file is a YAML file that defines how Docker containers should behave `in production`.

存放位置：
Save this file as `docker-compose.yml` wherever you want. Be sure you have pushed the image you created in Part 2 to a registry, and update this .yml by replacing username/repo:tag with your image details.

文件内容：
This `docker-compose.yml` file tells Docker to do the following:

- Pull the image we uploaded in step 2 from the registry.

- Run 5 instances of that image as a service called web, limiting each one to use, at most, 10% of the CPU (across all cores), and 50MB of RAM.

- Immediately restart containers if one fails.

- Map port 4000 on the host to web’s port 80.

- Instruct web’s containers to share port 80 via a load-balanced network called webnet. (Internally, the containers themselves publish to web’s port 80 at an ephemeral port.)

- Define the webnet network with the default settings (which is a load-balanced overlay network).

#### 运行应用

运行你的负载均衡应用
Run your new load-balanced app

创建集群
Before we can use the `docker stack deploy` command we first run:
```
# 创建集群
$ docker swarm init
```
Note: We get into the meaning of that command in part 4. If you don’t run `docker swarm init` you get an error that “this node is not a swarm manager.”

运行应用
Now let’s run it. You need to give your app a name. Here, it is set to getstartedlab:
```
# 切换目录
$ cd "/ymc/learn/01-Get started/01-Get started with Docker/03-services"
# 运行应用
$ docker stack deploy -c docker-compose.yml getstartedlab

```
Our single service stack is running 5 container instances of our deployed image on one host. Let’s investigate.

列出服务
Get the service ID for the one service in our application:
```
# 列出服务
$ docker service ls
```

查看输出
Look for output for the web service, prepended with your app name. If you named it the same as shown in this example, the name is `getstartedlab_web`. The service ID is listed as well, along with the number of replicas, image name, and exposed ports.

查看进程
A single container running in a service is called a `task`. Tasks are given unique IDs that numerically increment, up to the number of replicas you defined in `docker-compose.yml`. List the tasks for your service:
```
# 查看进程
$ docker service ps getstartedlab_web
```

Tasks also show up if you just list all the containers on your system, though that is not filtered by service:
```
# -q is --quiet for short
$ docker container ls --quiet
```

浏览应用
You can run `curl -4 http://localhost:4000` several times in a row, or go to that URL in your browser and hit refresh a few times.
```
# 在某主机上(物理机win7》虚拟机boot2docker=宿主机boot2docker》某主机=虚拟机|物理机)
$ curl -4 http://localhost:4000

# 在物理机上-win7
$ curl -4 192.168.99.100:4000
```

Either way, the container ID changes, demonstrating the load-balancing; with each request, one of the 5 tasks is chosen, in a round-robin fashion, to respond. The container IDs match your output from the previous command 
(`docker container ls -q`).

- 在win10上使用？
- Running Windows 10?

Windows 10 PowerShell should already have curl available, but if not you can grab a Linux terminal emulator like Git BASH, or download wget for Windows which is very similar.

- 减少响应时间？
- Slow response times?

Depending on your environment’s networking configuration, it may take up to 30 seconds for the containers to respond to HTTP requests. This is not indicative of Docker or swarm performance, but rather an unmet Redis dependency that we address later in the tutorial. For now, the visitor counter isn’t working for the same reason; we haven’t yet added a service to persist data.

#### 伸缩应用
修改配置+重启服务
You can scale the app by changing the `replicas` value in `docker-compose.yml`, saving the change, and re-running the `docker stack deploy` command:
```
# 修改配置
replicas: 3
# 重启服务
$ docker stack deploy -c docker-compose.yml getstartedlab

#或者
$ docker service scale getstartedlab_web=3
```
Docker performs an in-place update, no need to tear the stack down first or kill any containers.

查看服务
Now, re-run `docker container ls -q` to see the deployed instances reconfigured. If you scaled up the replicas, more tasks, and hence, more containers, are started.
```
# 查看服务
$ docker container ls --quiet
```

#### 关闭
关闭应用
Take the app down with `docker stack rm`:
```
# 移除堆叠
$ docker stack rm getstartedlab
```

关闭集群
Take down the swarm.
```
# 关闭集群
$ docker swarm leave --force
```

#### 常用命令
```
##########
#创建
##########
# 列出堆叠
# List stacks or apps
docker stack ls
# 运行堆叠
# Run the specified Compose file
docker stack deploy -c <composefile> <appname>  

##########
#查看
##########
# 列出服务
# List running services associated with an app
docker service ls
# 列出进程
# List tasks associated with an app
docker service ps <service>

# 堆叠详情
# Inspect task or container
docker inspect <task or container>
# 列出容器
# List container IDs
docker container ls -q

##########
#删除
##########
# 移除堆叠
# Tear down an application
docker stack rm <appname>
# 删除集群
# Take down a single node swarm from the manager
docker swarm leave --force
```


#### 回顾
It’s as easy as that to stand up and scale your app with Docker. You’ve taken a huge step towards learning how to run containers in production. Up next, you learn how to run this app as a bonafide swarm on a cluster of Docker machines.