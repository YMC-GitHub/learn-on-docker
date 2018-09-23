## 

#### 章节系列
Welcome! We are excited that you want to learn Docker. The Docker Get Started Tutorial teaches you how to:

- 1 Set up your Docker environment (on this page)
- 2 Build an image and run it as one container
- 3 Scale your app to run multiple containers
- 4 Distribute your app across a cluster
- 5 Stack services by adding a backend database
- 6 Deploy your app to production

#### 基础概念
Docker is a platform for developers and sysadmins to develop, deploy, and run applications with containers. The use of Linux containers to deploy applications is called containerization. Containers are not new, but their use for easily deploying applications is.

Containerization is increasingly popular because containers are:

- Flexible: Even the most complex applications can be containerized.
- Lightweight: Containers leverage and share the host kernel.
- Interchangeable: You can deploy updates and upgrades on-the-fly.
- Portable: You can build locally, deploy to the cloud, and run anywhere.
- Scalable: You can increase and automatically distribute container replicas.
- Stackable: You can stack services vertically and on-the-fly.

#### #容器和镜像

什么是镜像
 An image is an executable package that includes everything needed to run an application--the code, a runtime, libraries, environment variables, and configuration files.

什么是容器
A container is a runtime instance of an image--what the image becomes in memory when executed (that is, an image with state, or a user process). You can see a list of your running containers with the command, docker ps, just as you would in Linux.
他们何关系


#### #容器和虚机
什么是容器？
A container runs natively on Linux and shares the kernel of the host machine with other containers. It runs a discrete process, taking no more memory than any other executable, making it lightweight.
什么是虚机？
By contrast, a virtual machine (VM) runs a full-blown “guest” operating system with virtual access to host resources through a hypervisor. In general, VMs provide an environment with more resources than most applications need.
他们何关系

#### 准备环境
Install a [maintained version]() of Docker Community Edition (CE) or Enterprise Edition (EE) on a [supported platform]().

For full Kubernetes Integration:
- Kubernetes on Docker for Mac is available in 17.12 Edge (mac45) or 17.12 Stable (mac46) and higher.
- Kubernetes on Docker for Windows is available in 18.02 Edge (win50) and higher edge channels only.

[Install Docker]()

#### 测试版本
Test Docker version
查看版本
Run `docker --version` and ensure that you have a supported version of Docker:
```
$ docker --version
```

查看详情
Run `docker info` or (`docker version` without --) to view even more details about your docker installation:
```
$ docker version
# 或者
$ docker info
```

权限错误
To avoid permission errors (and the use of sudo), add your user to the `docker` group. `[Read more]()`.


#### 测试安装
Test Docker installation

运行镜像：查找镜像+下拉镜像+启动镜像
Test that your installation works by running the simple Docker image, hello-world:
```
$ docker run hello-world
```

列出镜像
List the hello-world image that was downloaded to your machine:
```
$ docker image ls
# 或者
$ docker images
```
列出容器
List the hello-world container (spawned by the image) which exits after displaying its message. If it were still running, you would not need the --all option:
```
$ docker container ls --all
```

注明：不同的版本，命令可能不一样。
#### 结论
Containerization makes CI/CD seamless. For example:

- applications have no system dependencies
- updates can be pushed to any part of a distributed application
- resource density can be optimized.
- With Docker, scaling your application is a matter of spinning up new executables, not running heavy VM hosts.