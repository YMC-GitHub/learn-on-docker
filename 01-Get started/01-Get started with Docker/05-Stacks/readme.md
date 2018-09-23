## 堆叠

#### 章节系列
Welcome! We are excited that you want to learn Docker. The Docker Get Started Tutorial teaches you how to:

- 1 Set up your Docker environment 
- 2 Build an image and run it as one container
- 3 Scale your app to run multiple containers
- 4 Distribute your app across a cluster
- 5 Stack services by adding a backend database(on this page)
- 6 Deploy your app to production

#### 环境准备
- Install Docker version 1.13 or higher.

- Get Docker Compose as described in Part 3 prerequisites.

- Get Docker Machine, which is pre-installed with Docker for Mac and Docker for Windows, but on Linux systems you need to install it directly. On pre Windows 10 systems without Hyper-V, as well as Windows 10 Home, use Docker Toolbox.

- Read the orientation in Part 1.

- Learn how to create containers in Part 2.

- Make sure you have published the friendlyhello image you created by pushing it to a registry. We use that shared image here.

- Be sure your image works as a deployed container. Run this command, slotting in your info for username, repo, and tag: docker run -p 80:80 username/repo:tag, then visit http://localhost/.

- Have a copy of your docker-compose.yml from Part 3 handy.

- Make sure that the machines you set up in part 4 are running and ready. Run docker-machine ls to verify this. If the machines are stopped, run docker-machine start myvm1 to boot the manager, followed by docker-machine start myvm2 to boot the worker.

- Have the swarm you created in part 4 running and ready. Run docker-machine ssh myvm1 "docker node ls" to verify this. If the swarm is up, both nodes report a ready status. If not, reinitialize the swarm and join the worker as described in Set up your swarm.


#### 章节介绍
In part 4, you learned how to set up a swarm, which is a cluster of machines running Docker, and deployed an application to it, with containers running in concert on multiple machines.


您将到达分布式应用程序层次结构的顶部：堆叠。一个堆叠是一组相关的服务，他们共享依赖，并可以将其协调和缩放到一起。单个堆栈能够定义和协调整个应用程序的功能（然而，非常复杂的应用会使用多个堆叠）。
Here in part 5, you reach the top of the hierarchy of distributed applications: the stack. A stack is a group of interrelated services that share dependencies, and can be orchestrated and scaled together. A single stack is capable of defining and coordinating the functionality of an entire application (though very complex applications may want to use multiple stacks).

好消息是，你已经接触过堆叠的技术，在第3章节中。当时你创建docker-compose.yml，使用`docker stack deploy`进行部署。但是那是个单个服务堆叠并且运行在单个主机上，它一般不应用在产品环境中。在本章节，你可以使用你所学的，关联多个服务，并运行在多个机器上。
Some good news is, you have technically been working with stacks since part 3, when you created a Compose file and used docker stack deploy. But that was a single service stack running on a single host, which is not usually what takes place in production. Here, you can take what you’ve learned, make multiple services relate to each other, and run them on multiple machines.

You’re doing great, this is the home stretch!

#### 添加服务并且重启
It’s easy to add services to our `docker-compose.yml` file. First, let’s add a free visualizer service that lets us look at how our swarm is scheduling containers.

编辑配置文件
Open up `docker-compose.yml` in an editor and replace its contents with the following. Be sure to replace username/repo:tag with your image details.

The only thing new here is the peer service to web, named visualizer. Notice two new things here: a `volumes` key, giving the visualizer access to the host’s socket file for Docker, and a `placement` key, ensuring that this service only ever runs on a swarm manager -- never a worker. That’s because this container, built from an open source project created by Docker, displays Docker services running on a swarm in a diagram.

We talk more about placement constraints and volumes in a moment.

确保连管理机
Make sure your shell is configured to talk to myvm1 (full examples are here).

Run `docker-machine ls` to list machines and make sure you are connected to myvm1, as indicated by an asterisk next to it.
```
# 查看当前连接的机器
$ docker-machine ls
# 或者
$ docker-machine active
```

If needed, re-run `docker-machine env myvm1`, then run the given command to configure the shell.
On Mac or Linux the command is:
```
eval $(docker-machine env myvm1)
```
On Windows the command is:

```
& "C:\Program Files\Docker\Docker\Resources\bin\docker-machine.exe" env myvm1 | Invoke-Expression
```

重新运行应用
Re-run the `docker stack deploy` command on the manager, and whatever services need updating are updated:
```
# 切换目录
# cd "/ymc/learn/01-Get started/01-Get started with Docker/05-Stacks"

# 部署堆叠
$ docker stack deploy -c docker-compose.yml getstartedlab
```

查看相应服务
Take a look at the visualizer.

You saw in the Compose file that visualizer runs on port 8080. Get the IP address of one of your nodes by running `docker-machine ls`. Go to either IP address at port 8080 and you can see the visualizer running:
The single copy of visualizer is running on the manager as you expect, and the 5 instances of web are spread out across the swarm. 

You can corroborate this visualization by running `docker stack ps <stack>`:
```
# 列出堆叠
$ docker stack ls

# 查看服务
$ docker stack services getstartedlab

# 查看进程
$ docker stack ps getstartedlab
# 或者
$ docker stack ps --filter "desired-state=running" getstartedlab
# 或者
$ docker stack ps getstartedlab | grep "Running"
# 或者
$ docker service ps --filter "desired-state=running" getstartedlab

# 备注：用浏览器访问该地址时，360se10.0页面显示不全，google版本 69.0.3493.3正常显示。
```


这个visualizer是个单独的服务，它可以运行在任一应用，那些应用引入它在堆叠中。他没有依赖任一其他服务。现在一起创建一个服务，它包含一个依赖：Redis服务提供某一访问者的计数。
The visualizer is a standalone service that can run in any app that includes it in the stack. It doesn’t depend on anything else. Now let’s create a service that does have a dependency: the Redis service that provides a visitor counter.

```
# 编辑配置文件

# 确保连管理机
$ docker-machine ls
$ docker-machine env myvm1
$ eval $(docker-machine env myvm1)

# 重新运行应用
$ docker stack deploy -c docker-compose.yml getstartedlab

# 查看相应服务
$ docker-machine ls
$ docker stack ps getstartedlab
```

#### 添数据库存储数据
Let’s go through the same workflow once more to add a Redis database for storing app data.

编辑配置文件
Save this new `docker-compose.yml` file, which finally adds a `Redis` service. Be sure to replace username/repo:tag with your image details.

`Redis` has an official image in the Docker library and has been granted the short image name of just `redis`, so no username/repo notation here. The Redis port, 6379, has been pre-configured by Redis to be exposed from the container to the host, and here in our Compose file we expose it from the host to the world, so you can actually enter the IP for any of your nodes into Redis Desktop Manager and manage this Redis instance, if you so choose.

Most importantly, there are a couple of things in the `redis` specification that make data persist between deployments of this stack:
- `redis` always runs on the manager, so it’s always using the same filesystem.
- `redis` accesses an arbitrary directory in the host’s file system as `/data` inside the container, which is where Redis stores data.

Together, this is creating a “source of truth” in your host’s physical filesystem for the Redis data. Without this, Redis would store its data in `/data` inside the container’s filesystem, which would get wiped out if that container were ever redeployed.

This source of truth has two components:

- The placement constraint you put on the Redis service, ensuring that it always uses the same host.
- The volume you created that lets the container access `./data` (on the host) as `/data` (inside the Redis container). While containers come and go, the files stored on `./data` on the specified host persists, enabling continuity.

You are ready to deploy your new Redis-using stack.

创建数据目录
Create a `./data` directory on the manager:
```
$ docker-machine ssh myvm1 "mkdir ./data"
```

确保连管理机
Make sure your shell is configured to talk to myvm1 (full examples are here).
```
$ docker-machine ls

$ docker-machine env myvm1
# On Mac or Linux the command is:
$ eval $(docker-machine env myvm1)
# On Windows
& "C:\Program Files\Docker\Docker\Resources\bin\docker-machine.exe" env myvm1 | Invoke-Expression

```

重新运行应用
Run docker stack deploy one more time.
```
$ docker stack deploy -c docker-compose.1.yml getstartedlab
```
查看相应服务
Run docker service ls to verify that the three services are running as expected.
```
$ docker service ls
```
check the web page at one of your nodes, such as `http://192.168.99.101`, and take a look at the results of the visitor counter, which is now live and storing information on Redis.


Also, check the visualizer at port 8080 on either node’s IP address, and notice see the redis service running along with the web and visualizer services.

```
# 编辑配置文件

# 创建数据目录
$ docker-machine ssh myvm1 "mkdir ./data"

# 确保连管理机
$ docker-machine ls
$ docker-machine env myvm1
$ eval $(docker-machine env myvm1)

# 重新运行应用
$ docker stack deploy -c docker-compose.1.yml getstartedlab

# 查看相应服务
$ docker-machine ls
$ docker stack ps getstartedlab
```

#### 回顾
You learned that stacks are inter-related services all running in concert, and that -- surprise! -- you’ve been using stacks since part three of this tutorial. You learned that to add more services to your stack, you insert them in your Compose file. Finally, you learned that by using a combination of placement constraints and volumes you can create a permanent home for persisting data, so that your app’s data survives when the container is torn down and redeployed.