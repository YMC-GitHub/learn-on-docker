## 部署

#### 章节系列
Welcome! We are excited that you want to learn Docker. The Docker Get Started Tutorial teaches you how to:

- 1 Set up your Docker environment 
- 2 Build an image and run it as one container
- 3 Scale your app to run multiple containers
- 4 Distribute your app across a cluster
- 5 Stack services by adding a backend database
- 6 Deploy your app to production(on this page)

#### 环境准备
- Install Docker.
- Get Docker Compose as described in Part 3 prerequisites.
- Get Docker Machine as described in Part 4 prerequisites.
- Read the orientation in Part 1.
- Learn how to create containers in Part 2.

- Make sure you have published the friendlyhello image you created by pushing it to a registry. We use that shared image here.

- Be sure your image works as a deployed container. Run this command, slotting in your info for username, repo, and tag: docker run -p 80:80 username/repo:tag, then visit http://localhost/.

- Have the final version of docker-compose.yml from Part 5 handy.


#### 章节介绍
You’ve been editing the same Compose file for this entire tutorial. Well, we have good news. That Compose file works just as well in production as it does on your machine. Here, We go through some options for running your Dockerized application.

#### 选择版本
Choose an option
- Docker Community Edition
- Docker Enterprise Edition
- Docker Enterprise Edition

#### 选择某云
If you’re okay with using `Docker Community Edition` in production, you can use Docker Cloud to help manage your app on popular service providers such as `Amazon Web Services`(亚马逊), `DigitalOcean`(大西洋), and `Microsoft Azure`.

To set up and deploy:

- Connect Docker Cloud with your preferred provider, granting Docker Cloud permission to automatically provision and “Dockerize” VMs for you.
- Use Docker Cloud to create your computing resources and create your swarm.
- Deploy your app.

Note: We do not link into the Docker Cloud documentation here; be sure to come back to this page after completing each step.

#### 连接
Connect Docker Cloud
You can run Docker Cloud in `standard mode` or in `Swarm mode`.

If you are running Docker Cloud in standard mode, follow instructions below to link your service provider to Docker Cloud.

- `Amazon Web Services` setup guide
- `DigitalOcean` setup guide
- `Microsoft Azure` setup guide
- `Packet` setup guide
- `SoftLayer` setup guide
- Use the Docker Cloud Agent to bring your own host

If you are running in `Swarm mode` (recommended for Amazon Web Services or Microsoft Azure), then skip to the next section on how to `[create your swarm]()`.

#### 创建集群
Ready to create a swarm?

- If you’re on Amazon Web Services (AWS) you can `[automatically create a swarm on AWS]()`.

- If you are on Microsoft Azure, you can automatically create a swarm on Azure.

- Otherwise, create your nodes in the Docker Cloud UI, and run the `docker swarm init` and `docker swarm join` commands you learned in part 4 over `SSH via Docker Cloud`. Finally, `enable Swarm Mode` by clicking the toggle at the top of the screen, and register the  swarm you just created.

Note: If you are Using the Docker Cloud Agent to Bring your Own Host, this provider does not support swarm mode. You can register your own existing swarms with Docker Cloud.

#### 部署集群

在云上部署你的应用
Deploy your app on a cloud provider

- 1 Connect to your swarm via Docker Cloud. There are a couple of different ways to connect:

    - From the Docker Cloud web interface in Swarm mode, select Swarms at the top of the page, click the swarm you want to connect to, and copy-paste the given command into a command line terminal.

- 2 Run `docker stack deploy -c docker-compose.yml getstartedlab` to deploy the app on the cloud hosted swarm.
```
 docker stack deploy -c docker-compose.yml getstartedlab
```
Your app is now running on your cloud provider.


#### 回顾
From here you can do everything you learned about in previous parts of the tutorial.

- Scale the app by changing the `docker-compose.yml` file and redeploy on-the-fly with the `docker stack deploy` command.

- Change the app behavior by editing code, then rebuild, and push the new image. (To do this, follow the same steps you took earlier to build the app and publish the image).

You can tear down the stack with `docker stack rm`. For example:
```
$ docker stack rm getstartedlab
```
与部署集群在本地虚拟机器上的情况不同，你的集群或者任一应用部署在云上能够继续运行，无视你师父关闭本地的主机。
Unlike the scenario where you were running the swarm on local Docker machine VMs, your swarm and any apps deployed on it continue to run on cloud servers regardless of whether you shut down your local host.

#### 进阶
You’ve taken a full-stack, dev-to-deploy tour of the entire Docker platform.

There is much more to the Docker platform than what was covered here, but you have a good idea of the basics of containers, images, services, swarms, stacks, scaling, load-balancing, volumes, and placement constraints.

Want to go deeper? Here are some resources we recommend:

- Samples: Our samples include multiple examples of popular software running in containers, and some good labs that teach best practices.
- User Guide: The user guide has several examples that explain networking and storage in greater depth than was covered here.
- Admin Guide: Covers how to manage a Dockerized production environment.
- Training: Official Docker courses that offer in-person instruction and virtual classroom environments.
- Blog: Covers what’s going on with Docker lately.
