## 容器

#### 章节系列
Welcome! We are excited that you want to learn Docker. The Docker Get Started Tutorial teaches you how to:

- 1 Set up your Docker environment 
- 2 Build an image and run it as one container(on this page)
- 3 Scale your app to run multiple containers
- 4 Distribute your app across a cluster
- 5 Stack services by adding a backend database
- 6 Deploy your app to production

#### 环境准备
- Install Docker version 1.13 or higher.
- Read the orientation in Part 1.
- Give your environment a quick test run to make sure you’re all set up:
```
$ docker run hello-world
```

#### 章节介绍
It’s time to begin building an app the Docker way. We start at the bottom of the hierarchy of such an app, which is a container, which we cover on this page. Above this level is a service, which defines how containers behave in production, covered in Part 3. Finally, at the top level is the stack, defining the interactions of all the services, covered in Part 5.

- Stack
- Services
- Container (you are here)


#### 新的开发环境
In the past, if you were to start writing a `Python` app, your first order of business was to install a `Python` runtime onto your machine. But, that creates a situation where the environment on your machine needs to be perfect for your app to run as expected, and also needs to match your production environment.

With Docker, you can just grab a portable `Python` runtime as an image, no installation necessary. Then, your build can include the base Python image right alongside your app code, ensuring that your app, its dependencies, and the runtime, all travel together.

These portable images are defined by something called a `Dockerfile`.

#### 创建镜像
`Dockerfile` defines what goes on in the environment inside your container. Access to resources like networking interfaces and disk drives is virtualized inside this environment, which is isolated from the rest of your system, so you need to map ports to the outside world, and be specific about what files you want to “copy in” to that environment. However, after doing that, you can expect that the build of your app defined in this Dockerfile behaves exactly the same wherever it runs.

Create an empty directory. Change directories (`cd`) into the new directory, create a file called `Dockerfile`, copy-and-paste the following content into that file, and save it. Take note of the comments that explain each statement in your new Dockerfile.

This Dockerfile refers to a couple of files we haven’t created yet, namely `app.py` and `requirements.txt`. Let’s create those next.

#### 编写代码
创建2个文件，`requirements.txt` 和 `app.py`。把他们放到与`Dockerfile`相同的目录。这就是我们的整个应用，正如你所看到的，它非常简单。当上面的`Dockerfile`文件被构建成镜像时，`app.py` 和 `requirements.txt`也在镜像内，因为`Dockerfile`文件的`ADD` 命令。并且`app.py`的输出可以通过HTTP被访问，由于`EXPOSE`命令。
Create two more files, `requirements.txt` and `app.py`, and put them in the same folder with the `Dockerfile`. This completes our app, which as you can see is quite simple. When the above `Dockerfile` is built into an image, `app.py` and `requirements.txt` is present because of that `Dockerfile`’s `ADD` command, and the output from `app.py` is accessible over HTTP thanks to the `EXPOSE` command.

Now we see that `pip install -r requirements.txt` installs the Flask and Redis libraries for Python, and the app prints the environment variable `NAME`, as well as the output of a call to `socket.gethostname()`. Finally, because Redis isn’t running (as we’ve only installed the Python library, and not Redis itself), we should expect that the attempt to use it here fails and produces the error message.

注意：访问主机名字，在容器内，返回的是容器编号，它就像是一个可执行文件的进程编号。
Note: Accessing the name of the host when inside a container retrieves the container ID, which is like the process ID for a running executable.

仅此而已！你不需要Python或者任何requirements.txt所记载的依赖在你的系统中，亦或构建或者安装以及运行镜像在你的系统上。
That’s it! You don’t need Python or anything in requirements.txt on your system, nor does building or running this image install them on your system. It doesn’t seem like you’ve really set up an environment with Python and Flask, but you have.

#### 构建应用
We are ready to build the app. Make sure you are still at the top level of your new directory. Here’s what ls should show:
```
# 列出文件
$ ls
```

Now run the build command. This creates a Docker image, which we’re going to tag using -t so it has a friendly name.

```
# 创建镜像
# -t is --tag for short
$ docker build --tag friendlyhello .

```

Where is your built image? It’s in your machine’s local Docker image registry:

```
# 查看镜像
$ docker image ls
```

Proxy servers can block connections to your web app once it’s up and running. If you are behind a proxy server, add the following lines to your Dockerfile, using the `ENV` command to specify the host and port for your proxy servers:
```
# 设代理服务器
# Set proxy server, replace host:port with values for your servers
ENV http_proxy host:port
ENV https_proxy host:port
```

DNS misconfigurations can generate problems with `pip`. You need to set your own `DNS` server address to make pip work properly. You might want to change the DNS settings of the Docker daemon. You can edit (or create) the configuration file at `/etc/docker/daemon.json` with the `dns` key, as following:
```
# 设域名服务器
{
  "dns": ["your_dns_address", "8.8.8.8"]
}
```
In the example above, the first element of the list is the address of your DNS server. The second item is the Google’s DNS which can be used when the first one is not available.

Before proceeding, save `daemon.json` and restart the docker service.
```
#重启软件服务
$ sudo service docker restart
```
Once fixed, retry to run the `build` command.
```
# 重建镜像
# -t is --tag for short
$ docker build -t friendlyhello .
```

#### 运行应用

Run the app, mapping your machine’s port 4000 to the container’s published port 80 using -p:
```
# 指定端口映射
# -p is --publish for short
$ docker run --publish 4000:80 friendlyhello
```

#### 浏览应用
You should see a message that Python is serving your app at `http://0.0.0.0:80`. But that message is coming from inside the container, which doesn’t know you mapped port 80 of that container to 4000, making the correct URL `http://localhost:4000`.

Go to that URL in a web browser to see the display content served up on a web page.


Note: If you are `using Docker Toolbox on Windows 7`, use the Docker Machine IP instead of localhost. For example, `http://192.168.99.100:4000/`. To find the IP address, use the command docker-machine ip.

You can also use the `curl` command in a shell to view the same content.
```
$ curl http://localhost:4000

# using Docker Toolbox on Windows 7
$ curl http://192.168.99.100:4000/
```

This port remapping of 4000:80 demonstrates the difference between `EXPOSE` within the Dockerfile and what the publish value is set to when running docker run -p. In later steps, map port 4000 on the host to port 80 in the container and use `http://localhost`.

#### 退出应用
Hit `CTRL+C` in your terminal to quit.

- On Windows, explicitly stop the container

On Windows systems, `CTRL+C` does not stop the container. So, first type `CTRL+C` to get the prompt back (or open another shell), then type `docker container ls` to list the running containers, followed by `docker container stop <Container NAME or ID>` to stop the container. Otherwise, you get an error response from the daemon when you try to re-run the container in the next step.
```
# 后台运行
docker run -d -p 4000:80 friendlyhello

# 列出容器
$ docker container ls

# 停止容器
docker container stop 1fa4ab2cf395
```

#### 分享镜像
一旦构建，随地时用
To demonstrate the portability of what we just created, let’s upload our built image and run it somewhere else. After all, you need to know how to push to registries when you want to deploy containers to production.
镜像仓库，收集镜像
A registry is a collection of repositories, and a repository is a collection of images—sort of like a GitHub repository, except the code is already built. An account on a registry can create many repositories. The docker CLI uses Docker’s public registry by default.

仓库公私，自行选择
Note: We use Docker’s public registry here just because it’s free and pre-configured, but there are many public ones to choose from, and you can even set up your own private registry using Docker Trusted Registry.

#### 登录仓库
If you don’t have a Docker account, sign up for one at `hub.docker.com`. Make note of your username.

Log in to the Docker public registry on your local machine.
```
# 登录docker官方仓库hub.docker.com
$ docker login

# 登录163私有仓库hub.c.163.com
$ docker login hub.c.163.com
# 账号：hualei03042013@163.com
# 密码：

# 登录本地私有仓库 192.168.99.100:5000
$ docker login 192.168.99.100:5000
```

#### 镜像打标
The notation for associating a local image with a repository on a registry is `username/repository:tag`. The tag is optional, but recommended, since it is the mechanism that registries use to give Docker images a version. Give the repository and tag meaningful names for the context, such as get-started:part2. This puts the image in the get-started repository and tag it as part2.

Now, put it all together to tag the image. Run docker tag image with your username, repository, and tag names so that the image uploads to your desired destination. The syntax of the command is:
```
# 镜像命名规范--仓库域名/用户名字/镜像名字：标签名字
$ docker tag friendlyhello gordon/get-started:part2

$ docker tag friendlyhello  hub.c.163.com/yemiancheng/friendlyhello:part-2
```

Run docker image ls to see your newly tagged image.
```
# 列出镜像
$ docker image ls
```

#### 发布镜像
Upload your tagged image to the repository:
```
# 发到docker官方仓库hub.docker.com
$ docker push username/repository:tag

# 发到163私有仓库hub.c.163.com
$ docker push hub.c.163.com/yemiancheng/friendlyhello:part-2
```
Once complete, the results of this upload are publicly available. If you log in to Docker Hub, you see the new image there, with its pull command.

#### 下拉镜像
From now on, you can use docker run and run your app on any machine with this command:
```
# 下拉镜像+运行镜像+创建容器+启动容器
$ docker run -p 4000:80 username/repository:tag


```
If the image isn’t available locally on the machine, Docker pulls it from the repository.

No matter where docker run executes, it pulls your image, along with Python and all the dependencies from requirements.txt, and runs your code. It all travels together in a neat little package, and you don’t need to install anything on the host machine for Docker to run it.

#### 问题集锦
```
问题：Error response from daemon: Get https://hub.c.163.com/v2/: unauthorized: authentication required
分析：可能时账户密码不正确
解决：
参考：https://www.cnblogs.com/dadream/p/7798201.html
```
#### 结论
That’s all for this page. In the next section, we learn how to scale our application by running this container in a service.