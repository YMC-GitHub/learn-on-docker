## 集群

#### 章节系列
Welcome! We are excited that you want to learn Docker. The Docker Get Started Tutorial teaches you how to:

- 1 Set up your Docker environment 
- 2 Build an image and run it as one container
- 3 Scale your app to run multiple containers
- 4 Distribute your app across a cluster(on this page)
- 5 Stack services by adding a backend database
- 6 Deploy your app to production

#### 环境准备
- Install Docker version 1.13 or higher.

- Get Docker Compose as described in Part 3 prerequisites.

- Get Docker Machine, which is pre-installed with Docker for Mac and Docker for Windows, but on Linux systems you need to install it directly. On pre Windows 10 systems without Hyper-V, as well as Windows 10 Home, use Docker Toolbox.

- Read the orientation in Part 1.

- Learn how to create containers in Part 2.

- Make sure you have published the friendlyhello image you created by pushing it to a registry. We use that shared image here.

- Be sure your image works as a deployed container. Run this command, slotting in your info for username, repo, and tag: docker run -p 80:80 username/repo:tag, then visit http://localhost/.
```
$ docker tag friendlyhello 192.168.99.100:5000/friendlyhello

# 由于国内政策原因访问不了国外docker官网仓库，可选用163公司的私人仓库
# 修改标签
$ docker tag friendlyhello hub.c.163.com/yemiancheng/:part-2
# 登录仓库
$ docker login hub.c.163.com
# 账号：hualei03042013@163.com
# 密码：

# 上传镜像
$ docker push hub.c.163.com/yemiancheng/friendlyhello:part-2
# 参考文献：https://www.163yun.com/help/documents/68510213955833856
```

- Have a copy of your docker-compose.yml from Part 3 handy.


#### 章节介绍
In part 3, you took an app you wrote in part 2, and defined how it should run in production by turning it into a service, scaling it up 5x in the process.
多个机器，多个容器
Here in part 4, you deploy this application onto a cluster, running it on multiple machines. Multi-container, multi-machine applications are made possible by joining multiple machines into a “Dockerized” cluster called a swarm.


#### 关于集群
一组机器，运行容器，组成一簇。
什么是集群？
如何去运行？
有哪些机器？
A swarm is a group of machines that are running Docker and joined into a cluster. After that has happened, you continue to run the Docker commands you’re used to, but now they are executed on a cluster by a swarm manager. The machines in a swarm can be physical or virtual. After joining a swarm, they are referred to as nodes.

集群管理者可以使用不同的策略去运行容器。
Swarm managers can use several strategies to run containers, such as “emptiest node” -- which fills the least utilized machines with containers. Or “global”, which ensures that each machine gets exactly one instance of the specified container. You instruct the swarm manager to use these strategies in the Compose file, just like the one you have already been using.

集群管理者是唯一的机器，该机器能够执行命令或者认证其他机器作为机器工作机器。集群工作机器仅仅是提供性能（capacity），它无法告诉其他机器该做什么不该做什么。
Swarm managers are the only machines in a swarm that can execute your commands, or authorize other machines to join the swarm as workers. Workers are just there to provide capacity and do not have the authority to tell any other machine what it can and cannot do.

开启集群模式，作为集群管理者，在当前机器上、在集群层面上执行命令。
Up until now, you have been using Docker in a single-host mode on your local machine. But Docker also can be switched into swarm mode, and that’s what enables the use of swarms. Enabling swarm mode instantly makes the current machine a swarm manager. From then on, Docker runs the commands you execute on the swarm you’re managing, rather than just on the current machine.

#### 搭建集群
集群由不同的节点组成，这些节点可以是物理机器，也可以是虚拟机器。
A swarm is made up of multiple nodes, which can be either physical or virtual machines. The basic concept is simple enough: run `docker swarm init` to enable swarm mode and make your current machine a swarm manager, then run `docker swarm join` on other machines to have them join the swarm as workers. Choose a tab below to see how this plays out in various contexts. We use VMs to quickly create a two-machine cluster and turn it into a swarm.

装虚拟机
VMS ON YOUR LOCAL MACHINE (MAC, LINUX, WINDOWS 7 AND 8)
You need a hypervisor that can create virtual machines (VMs), so `install Oracle VirtualBox for your machine’s OS`.

Note: If you are on a Windows system that has Hyper-V installed, such as Windows 10, there is no need to install VirtualBox and you should use Hyper-V instead. View the instructions for Hyper-V systems by clicking the Hyper-V tab above. If you are using Docker Toolbox, you should already have VirtualBox installed as part of it, so you are good to go.

建虚拟机
Now, create a couple of VMs using docker-machine, using the VirtualBox driver:
```
$ docker-machine create --driver virtualbox myvm1
$ docker-machine create --driver virtualbox myvm2
$ docker-machine create --driver virtualbox myvm3
```

列虚拟机
You now have two VMs created, named myvm1 and myvm2.

Use this command to list the machines and get their IP addresses.
```
$ docker-machine ls
```

设管理机
The first machine acts as the manager, which executes management commands and authenticates workers to join the swarm, and the second is a worker.

You can send commands to your VMs using docker-machine ssh. Instruct myvm1 to become a swarm manager with docker swarm init and look for output like this:
```
# 获取地址
$ docker-machine ip myvm1
# 设管理机
$ docker-machine ssh myvm1 "docker swarm init --advertise-addr <myvm1 ip>"

# 或者
$ docker-machine ssh myvm1 "docker swarm init --advertise-addr $(docker-machine ip myvm1)"

Swarm initialized: current node (iz4u2rdl65inynh8azfan9fsu) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-2jhcfueglcmknowqnaus2gucxtsxeedga7jcw7wfp
f7ocpo32q-bhh7fj430jk6t7z0oh6bxofjs 192.168.99.100:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow
 the instructions.
```

Ports 2377 and 2376

Always run `docker swarm init` and `docker swarm join` with port 2377 (the swarm management port), or no port at all and let it take the default.

The machine IP addresses returned by `docker-machine ls` include port 2376, which is the Docker daemon port. Do not use this port or you may experience errors.

- Having trouble using SSH? Try the --native-ssh flag

Docker Machine has the option to let you use your own system’s SSH, if for some reason you’re having trouble sending commands to your Swarm manager. Just specify the --native-ssh flag when invoking the ssh command:
```
docker-machine --native-ssh ssh myvm1 ...
```

设工作机
As you can see, the response to `docker swarm init`contains a pre-configured `docker swarm join` command for you to run on any nodes you want to add. Copy this command, and send it to myvm2 via `docker-machine ssh` to have myvm2 join your new swarm as a worker:
```
# 设工作机
$ docker-machine ssh myvm2 "docker swarm join --token SWMTKN-1-2jhcfueglcmknowqnaus2gucxtsxeedga7jcw7wfpf7ocpo32q-bhh7fj430jk6t7z0oh6bxofjs 192.168.99.100:2377"
```


查看节点
Run docker node ls on the manager to view the nodes in this swarm:
```
# 查看节点
$ docker-machine ssh myvm1 "docker node ls"
```


离开集群
- Leaving a swarm

If you want to start over, you can run `docker swarm leave` from each node.
```
# 工作机离开集群
$ docker-machine ssh myvm2 "docker swarm leave"

# 管理机离开集群
$ docker-machine ssh myvm1 "docker swarm leave"
```

#### 在集群簇上部署应用
The hard part is over. Now you just repeat the process you used in part 3 to deploy on your new swarm. Just remember that only swarm managers like myvm1 execute Docker commands; workers are just for capacity.

#### 连管理机
So far, you’ve been wrapping Docker commands in `docker-machine ssh` to talk to the VMs. Another option is to run `docker-machine env <machine>` to get and run a command that configures your current shell to talk to the Docker daemon on the VM. This method works better for the next step because it allows you to use your local docker-compose.yml file to deploy the app “remotely” without having to copy it anywhere.

- 方式1
```
$ docker-machine ssh myvm1 "docker swarm leave"
```
- 方式2
```
$ docker-machine ssh myvm1
# run you cmd
$ echo hello
```
- 方式3


获取配置
Type `docker-machine env myvm1`, then copy-paste and run the command provided as the last line of the output to configure your shell to talk to myvm1, the swarm manager.
```
$ docker-machine env myvm1
```
The commands to configure your shell differ depending on whether you are Mac, Linux, or Windows, so examples of each are shown on the tabs below.
Run `docker-machine env myvm1` to get the command to configure your shell to talk to myvm1.

进行连接
Run the given command to configure your shell to talk to myvm1.
```
$ eval $(docker-machine env myvm1)
```

查看结果
Run `docker-machine ls` to verify that myvm1 is now the active machine, as indicated by the asterisk next to it.

#### 在管理机上部署应用
Now that you have myvm1, you can use its powers as a swarm manager to deploy your app by using the same 

切换目录
You are connected to `myvm1` by means of the `docker-machine` shell configuration, and you still have access to the files on your local host. Make sure you are in the same directory as before, which includes the `docker-compose.yml` file you created in part 3.
```
$ cd "/f/docker/learn/01-Get started/01-Get started with Docker/03-services"
```
部署应用
`docker stack deploy` command you used in part 3 to myvm1, and your local copy of `docker-compose.yml.`. This command may take a few seconds to complete and the deployment takes some time to be 
available.
Just like before, run the following command to deploy the app on myvm1.
```
$ docker stack deploy -c docker-compose.yml getstartedlab

# 方式2
$ docker-machine ssh myvm1
$ cd "/ymc/learn/01-Get started/01-Get started with Docker/04-Swarms"
$ docker stack deploy -c docker-compose.yml getstartedlab

# 方式3
$ docker-machine ssh myvm1 "cd \"/ymc/learn/01-Get started/01-Get started with Docker/04-Swarms/\" && docker stack deploy -c docker-compose.yml getstartedlab"
```
And that’s it, the app is deployed on a swarm cluster!

查看结果
Use the`docker service ps <service_name>` command on a swarm manager to verify that all services have been redeployed.
```
# 查看服务
$ docker service ls
# 查看进程
$ docker service ps getstartedlab_web
```



私有镜像
Note: If your image is stored on a private registry instead of Docker Hub, you need to be logged in using docker login <your-registry> and then you need to add the --with-registry-auth flag to the above command. For example:
```
# docker tag friendlyhello 192.168.99.100:5000

# 登录仓库
$ docker login registry.example.com

$ docker stack deploy --with-registry-auth -c docker-compose.yml getstartedlab
```

查看进程
Now you can use the same docker commands you used in part 3. Only this time notice that the services (and associated containers) have been distributed between both myvm1 and myvm2.
```
$ docker stack ps getstartedlab
```

连虚拟机
- Connecting to VMs with `docker-machine env` and `docker-machine ssh`

```
# 方式1
$ docker-machine ssh myvm2
```

To set your shell to talk to a different machine like  `myvm2`, simply re-run `docker-machine env` in the same or a different shell, then run the given command to point to myvm2. This is always specific to the current shell. If you change to an unconfigured shell or open a new one, you need to re-run the commands. Use `docker-machine ls` to list machines, see what state they are in, get IP addresses, and find out which one, if any, you are connected to. To learn more, see the Docker Machine getting started topics.
```
# 方式2
# 列出机器
$ docker-machine ls

# 获取配置
$ docker-machine env myvm2

# 获取环境
$ eval $(docker-machine env myvm2)
```

Alternatively, you can wrap Docker commands in the form of `docker-machine ssh <machine> "<command>"`, which logs directly into the VM but doesn’t give you immediate access to files on your local host.
```
# 方式3
$ docker-machine ssh  myvm2 "echo hello"
```

On Mac and Linux, you can use `docker-machine scp <file> <machine>:~` to copy files across machines, but Windows users need a Linux terminal emulator like Git Bash for this to 
```
# 方式4
# docker-machine scp <file> <machine>:~
```

# 访问集群
You can access your app from the IP address of either myvm1 or myvm2.

查看地址，并访问地址
The network you created is shared between them and load-balancing. Run `docker-machine ls` to get your VMs’ IP addresses and visit either of them on a browser, hitting refresh (or just curl them).


There are five possible container IDs all cycling by randomly, demonstrating the load-balancing.
```
# 列出堆叠
$ docker stack ls

# 查看服务
$ docker stack services getstartedlab

# 查看进程
$ docker stack ps --filter "desired-state=running" getstartedlab
# 或者
$ docker stack ps getstartedlab | grep "Running"
# 或者
$ docker service ps --filter "desired-state=running" getstartedlab

```

The reason both IP addresses work is that nodes in a swarm participate in an ingress routing mesh. This ensures that a service deployed at a certain port within your swarm always has that port reserved to itself, no matter what node is actually running the container. Here’s a diagram of how a routing mesh for a service called my-web published at port 8080 on a three-node swarm would look.

暴露端口
- Having connectivity trouble?
Keep in mind that to use the ingress network in the swarm, you need to have the following ports open between the swarm nodes before you enable swarm mode:

Port 7946 TCP/UDP for container network discovery.
Port 4789 UDP for the container ingress network.

#### 集成伸缩

From here you can do everything you learned about in parts 2 and 3.


Scale the app by changing the `docker-compose.yml` file.
```
# 修改配置
replicas: 8

# 重新部署
$ cd "/ymc/learn/01-Get started/01-Get started with Docker/04-Swarms/" && \
$ docker stack deploy -c docker-compose.yml --with-registry-auth getstartedlab

# 或者
docker service scale getstartedlab_web=8
```

改变应用行为，通过编辑代码，然后重建，发布镜像。
Change the app behavior by editing code, then rebuild, and push the new image. (To do this, follow the same steps you took earlier to build the app and publish the image).
此时，简单再次运行命令`docker stack deploy`,即可发布。
In either case, simply run `docker stack deploy` again to deploy these changes.


你可以添加任意机器，物理的亦或是虚拟的，到集群。使用相同的命令`docker swarm join` ,像在myvm2上一样使用。性能会被添加到你的集群上。之后仅运行`docker stack deploy`，你的应用会利用新资源的优势。
You can join any machine, physical or virtual, to this swarm, using the same `docker swarm join` command you used on myvm2, and capacity is added to your cluster. Just run `docker stack deploy` afterwards, and your app can take advantage of the new resources.

#### 清除重启

移除堆栈
You can tear down the stack with docker stack rm. For example:
```
$ docker stack rm getstartedlab
```

保留集群还是删掉集群？
- Keep the swarm or remove it?

At some point later, you can remove this swarm if you want to with `docker-machine ssh myvm2 "docker swarm leave"` on the worker and `docker-machine ssh myvm1 "docker swarm leave --force"` on the manager, but you need this swarm for part 5, so keep it around for now.

工作机离开集群：
```
$ docker-machine ssh myvm2 "docker swarm leave"
```
管理机离开集群：
```
$ docker-machine ssh myvm1 "docker swarm leave --force"
```

删除配置
Unsetting docker-machine shell variable settings
你可以删除`docker-machine`的环境变量，在你当前的shell命令中。
You can unset the `docker-machine` environment variables in your current shell with the given command.

On Mac or Linux the command is:
```
$ eval $(docker-machine env -u)
```
On Windows the command is:
```
  & "C:\Program Files\Docker\Docker\Resources\bin\docker-machine.exe" env -u | Invoke-Expression

```

断开连接
清除配置将断开连接shell。
This disconnects the shell from docker-machine created virtual machines, and allows you to continue working in the same shell, now using native docker commands (for example, on Docker for Mac or Docker for Windows). To learn more, see the Machine topic on unsetting environment variables.

重启机器
Restarting Docker machines

If you shut down your local host, Docker machines stops running.You can check the status of machines by running `docker-machine ls`.
查看状态
```
$ docker-machine ls
```
启动机器
To restart a machine that’s stopped, run:
```
# docker-machine start <machine-name>
$ docker-machine start myvm1
$ docker-machine start myvm2
```

#### 常用命令
```
# 建虚拟机
# Create a VM (Mac, Win7, Linux)
$ docker-machine create --driver virtualbox myvm1 
# Win10
$ docker-machine create -d hyperv --hyperv-virtual-switch "myswitch" myvm1 

# 获取配置
# View basic information about your node
docker-machine env myvm1                

# 连虚拟机 + 列出节点
# List the nodes in your swarm
docker-machine ssh myvm1 "docker node ls"         
# 连虚拟机 + 查看节点详情
# Inspect a node
docker-machine ssh myvm1 "docker node inspect <node ID>"        

# 连虚拟机 + 查看加入令牌
# View join token
docker-machine ssh myvm1 "docker swarm join-token -q worker"   


# 连虚拟机
# Open an SSH session with the VM; type "exit" to end
docker-machine ssh myvm1   
# 列出节点
# View nodes in swarm (while logged on to manager)
docker node ls                

# 连虚拟机（连工作机） + 离开集群
# Make the worker leave the swarm
docker-machine ssh myvm2 "docker swarm leave"  

# 连虚拟机（连管理机） + 删除集群
# Make master leave, kill swarm
docker-machine ssh myvm1 "docker swarm leave -f" 


# 列虚拟机
# list VMs, asterisk shows which VM this shell is talking to
docker-machine ls 
# 启动机器
 # Start a VM that is currently not running
docker-machine start myvm1           
# 获取配置
# show environment variables and command for myvm1
docker-machine env myvm1      
# 连虚拟机
# Mac command to connect shell to myvm1
eval $(docker-machine env myvm1)         
# Windows command to connect shell to myvm1
& "C:\Program Files\Docker\Docker\Resources\bin\docker-machine.exe" env myvm1 | Invoke-Expression   

# 部署应用+ 使用本地文件
# Deploy an app; command shell must be set to talk to manager (myvm1), uses local Compose file
docker stack deploy -c <file> <app>  

# 拷贝文件
# Copy file to node's home dir (only required if you use ssh to connect to manager and deploy the app)
docker-machine scp docker-compose.yml myvm1:~ 
# 部署应用
# Deploy an app using ssh (you must have first copied the Compose file to myvm1)
docker-machine ssh myvm1 "docker stack deploy -c <file> <app>"  

# 断开连接
# Disconnect shell from VMs, use native docker
eval $(docker-machine env -u)     

# 关掉机器
# Stop all running VMs
docker-machine stop $(docker-machine ls -q)       
# 删虚机器
# Delete all VMs and their disk images        
docker-machine rm $(docker-machine ls -q) 
```
#### 问题集锦
```
问题：could not be accessed on a registry to record its digest.
解决：
参考：https://q.cnblogs.com/q/104776/
```

#### 结论
In part 4 you learned what a swarm is, how nodes in swarms can be managers or workers, created a swarm, and deployed an application on it. You saw that the core Docker commands didn’t change from part 3, they just had to be targeted to run on a swarm master. You also saw the power of Docker’s networking in action, which kept load-balancing requests across containers, even though they were running on different machines. Finally, you learned how to iterate and scale your app on a cluster.