## 开发最佳实践
Docker development best practices

The following development patterns have proven to be helpful for people building applications with Docker. If you have discovered something we should add, [let us know]().

#### 如何保持镜像小些
How to keep your images small

Small images are faster to pull over the network and faster to load into memory when starting containers or services. There are a few rules of thumb to keep image size small:

- 使用最基础的镜像
- 使用多个步骤构建
- 自定基础公共镜像
- 保持生产镜像简洁
- 给镜像打上好标签
- Start with an appropriate base image. For instance, if you need a JDK, consider basing your image on the official openjdk image, rather than starting with a generic ubuntu image and installing openjdk as part of the Dockerfile.

- Use multistage builds. For instance, you can use the maven image to build your Java application, then reset to the tomcat image and copy the Java artifacts into the correct location to deploy your app, all in the same Dockerfile. This means that your final image doesn’t include all of the libraries and dependencies pulled in by the build, but only the artifacts and the environment needed to run them.

  减少`RUN`命令的使用次数
  If you need to use a version of Docker that does not include multistage builds, try to reduce the number of layers in your image by minimizing the number of separate RUN commands in your Dockerfile. You can do this by consolidating multiple commands into a single RUN line and using your shell’s mechanisms to combine them together. Consider the following two fragments. The first creates two layers in the image, while the second only creates one.
```
RUN apt-get -y update
RUN apt-get install -y python
```
```
RUN apt-get -y update && apt-get install -y python
```

- If you have multiple images with a lot in common, consider creating your own base image with the shared components, and basing your unique images on that. Docker only needs to load the common layers once, and they are cached. This means that your derivative images use memory on the Docker host more efficiently and load more quickly.

- To keep your production image lean but allow for debugging, consider using the production image as the base image for the debug image. Additional testing or debugging tooling can be added on top of the production image.

- When building images, always tag them with useful tags which codify version information, intended destination (prod or test, for instance), stability, or other information that is useful when deploying the application in different environments. Do not rely on the automatically-created latest tag.

#### 如何保持数据持久
Where and how to persist application data

- Avoid storing application data in your container’s writable layer using `storage drivers`. This increases the size of your container and is less efficient from an I/O perspective than using volumes or bind mounts.

避免使用`storage drivers`存储应用数据在容器的可写层中。这会使你的容器变大，并且使用I/O的价值是低效的，与使用数据卷(volumes)或目录挂载（bind mounts）。

- Instead, store data using volumes.
作为替代，存储数据可使用数据卷。

- One case where it is appropriate to use bind mounts is during development, when you may want to mount your source directory or a binary you just built into your container. For production, use a volume instead, mounting it into the same location as you mounted a bind mount during development.

值得使用绑定挂载目录的一种情景是在开发的时候，当你想要挂载你的源码目录或者一个二进制文件到你所构建的那个容器时。在生产环境时，使用数据卷，挂载它到容器的相同位置就如在开发环境你挂载绑定目录一样。

- For production, use secrets to store sensitive application data used by services, and use configs for non-sensitive data such as configuration files. If you currently use standalone containers, consider migrating to use single-replica services, so that you can take advantage of these service-only features.

在生产环境，使用秘密文件保存服务用到的敏感的应用数据，使用配置保存非敏感的数据，比如配置文件。如果你正在使用独立的容器，可以考虑迁移到使用单一-重复服务，以便你可以利用单一-服务（service-only）的特性的优势。

#### 使用集群服务若可
Use swarm services when possible

- When possible, design your application with the ability to scale using swarm services.
如果可以，尽量使用集群服务的伸缩能力来设计你的应用。

- Even if you only need to run a single instance of your application, swarm services provide several advantages over standalone containers. A service’s configuration is declarative, and Docker is always working to keep the desired and actual state in sync.
尽管你仅仅需要运行你的应用的一个单一实例，但集群服务提供一些优势相比于独立的容器。某一服务的配置是声明的，并且Docker总是工作者以便保持设计与实际状态同步。

- Networks and volumes can be connected and disconnected from swarm services, and Docker handles redeploying the individual service containers in a non-disruptive way. Standalone containers need to be manually stopped, removed, and recreated to accommodate configuration changes.
网络和数据卷可以从集群服务连接和断开，并且Docker处理重新部署个别的服务容器以非破坏的的方式。
独立容器需要手动停止。移除和重新创建以便适应配置文件的改变。

- Several features, such as the ability to store secrets and configs, are only available to services rather than standalone containers. These features allow you to keep your images as generic as possible and to avoid storing sensitive data within the Docker images or containers themselves.
不同的特性，比如存储秘密和配置的能力，仅仅在服务中有效，与独立容器相比。这些特性允许你保存你镜像尽可能的正常，以及避免存储敏感数据在镜像和容器中。

- Let `docker stack deploy` handle any image pulls for you, instead of using `docker pull`. This way, your deployment doesn’t try to pull from nodes that are down. Also, when new nodes are added to the swarm, images are pulled automatically.
使用`docker stack deploy`处理下拉给你的任一镜像，替代使用`docker pull`。这种方式，你的部署不会尝试下拉关闭的节点。另外，当新的节点添加到该集群时，镜像会自动地下拉。


There are limitations around sharing data amongst nodes of a swarm service. If you use Docker for AWS or Docker for Azure, you can use the Cloudstor plugin to share data amongst your swarm service nodes. You can also write your application data into a separate database which supports simultaneous updates.
这里有一些限制，在集群服务职工的不同节点共享数据时。如果你使用 `Docker for AWS`或者 `Docker for Azure`，你可以使用Cloudstor插件在集群服务职工的不同节点共享数据。另外，你可以写你的应用数据到一个分布式数据库中，该数据库支持同时更新。

#### 使用持续集成部署

Use CI/CD for testing and deployment
使用CI/CD 在测试环境和部署环境中。

- When you check a change into source control or create a pull request, use Docker Cloud or another CI/CD pipeline to automatically build and tag a Docker image and test it. Docker Cloud can also deploy tested apps straight into production.
当你检查源码是否改变或创建一个下拉请求时，使用Docker Cloud 或者其他的CI/CD pipeline管道线，以便自动构建和给镜像打上标签，并且进行测试。Docker Cloud还可以部署测试过后的应用直接到产品环境。

- Take this even further with Docker EE by requiring your development, testing, and security teams to sign images before they can be deployed into production. This way, you can be sure that before an image is deployed into production, it has been tested and signed off by, for instance, development, quality, and security teams.

在你的开发、测试和安全性团队中，使用Docker EE是进阶的一步，以便签名镜像在他们可以被部署到产品之前。这种方式,你可以确认，在镜像被部署到生产环境前，它是否已经被测试以及签名过。比如，开发，质量检查，以及安全团队。

#### 开发生产环境异同
Differences in development and production environments

开发
使用绑定挂载以便给予你的容器访问你的代码的权限
使用`Docker for Mac` or `Docker for Windows`
不必担心时间的不同
Development
- Use `bind mounts` to give your container access to your source code.
- Use `Docker for Mac` or `Docker for Windows`.
- Don’t worry about time drift.

生产
使用数据卷存储容器数据
如果可能,使用Docker EE，在userns mapping下有更好的容器进程与主机进程的位置对照
总是运行一个NTP客户端在Docker主机和在每一个容器进程中，并同步他们到相同的NTP服务器。如果你使用集群服务，另外需确定每个Docker节点同步他们的时钟到相同的时间点在容器中。
Production
- Use `volumes` to store container data.
- Use `Docker EE` if possible, with `userns mapping` for greater isolation of Docker processes from host processes.
- Always run an NTP client on the Docker host and within each container process and sync them all to the same NTP server. If you use swarm services, also ensure that each Docker node syncs its clocks to the same time source as the containers.