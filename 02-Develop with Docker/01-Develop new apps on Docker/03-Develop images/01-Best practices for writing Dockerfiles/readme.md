## 书写Dockerfile最佳实践
Best practices for writing Dockerfiles

This document covers recommended best practices and methods for building efficient images.

Docker自动地构建镜像，通过阅读`Dockerfile`文件中的描述。它是一个文本文件，包含所有命令，按书写的顺序执行，用来构建一个给出的镜像。
Docker builds images automatically by reading the instructions from a `Dockerfile` -- a text file that contains all commands, in order, needed to build a given image. A `Dockerfile` adheres to a specific format and set of instructions which you can find at `[Dockerfile reference]()`.

Docker的镜像由只读的层组成，这些层代表了一个`Dockerfile`文件描述。这些层被堆叠起来，并且每一个取决于它的前一层。思考一下这个`Dockerfile`文件：

A Docker image consists of read-only layers each of which represents a `Dockerfile` instruction. The layers are stacked and each one is a delta of the changes from the previous layer. Consider this `Dockerfile`:
```
FROM ubuntu:15.04
COPY . /app
RUN make /app
CMD python /app/app.py
```

每一句描述，创建了一个层：
- 来自 创建来自于 ubuntu:15.04 Docker image的一个层
- 复制 从Docker client’s的当前目录复制文件到某个目录
- 运行 使用镜像构建应用
- 命令 构建应用时，需要在容器中执行的命令

Each instruction creates one layer:
- `FROM` creates a layer from the ubuntu:15.04 Docker image.
- `COPY` adds files from your Docker client’s current directory.
- `RUN` builds your application with make.
- `CMD` specifies what command to run within the container.

当你运行某镜像和生成某容器时，你添加一个新的可写的层（容器层）在底层的层的顶端。所有的在运行容器中的修改，比如写入新的文件、修改存在的文件以及删除文件，会写入到这个可写的容器层内
When you run an image and generate a container, you add a new writable layer (the “container layer”) on top of the underlying layers. All changes made to the running container, such as writing new files, modifying existing files, and deleting files, are written to this thin writable container layer.

获取更多的关于镜像层的内容（以及docker如何创建并存储镜像），查看[数据驱动]()。
For more on image layers (and how Docker builds and stores images), see About storage drivers.

#### 一般指南和建议
创建短暂性的容器
Create ephemeral containers
The image defined by your Dockerfile should generate containers that are as ephemeral as possible. By “ephemeral,” we mean that the container can be stopped and destroyed, then rebuilt and replaced with an absolute minimum set up and configuration.

Refer to Processes under The Twelve-factor App methodology to get a feel for the motivations of running containers in such a stateless fashion.

理解构建上下情境
Understand build context
When you issue a `docker build` command, the current working directory is called the build context. By default, the Dockerfile is assumed to be located here, but you can specify a different location with the file flag (-f). Regardless of where the Dockerfile actually lives, all recursive contents of files and directories in the current directory are sent to the Docker daemon as the build context.

使用标准输入写入
Pipe Dockerfile through stdin
Docker 17.05 added the ability to build images by piping `Dockerfile` through stdin with a local or remote build-context. In earlier versions, building an image with a Dockerfile from stdin did not send the build-context.

Docker 17.04 and lower
```
docker build -t foo -<<EOF
FROM busybox
RUN echo "hello world"
EOF
```
Docker 17.05 and higher (local build-context):
```
docker build -t foo . -f-<<EOF
FROM busybox
RUN echo "hello world"
COPY . /my-copied-files
EOF
```
Docker 17.05 and higher (remote build-context):
```
docker build -t foo https://github.com/thajeztah/pgadmin4-docker.git -f-<<EOF
FROM busybox
COPY LICENSE config_local.py /usr/local/lib/python2.7/site-packages/pgadmin4/
EOF
```

使用忽略文件排除
Exclude with .dockerignore
To exclude files not relevant to the build (without restructuring your source repository) use a `.dockerignore` file. This file supports exclusion patterns similar to `.gitignore` files. For information on creating one, see the `[.dockerignore]()` file.

使用多股进行构建
Use multi-stage builds
`[Multi-stage builds]()` (in Docker `17.05` or higher) allow you to drastically reduce the size of your final image, without struggling to reduce the number of intermediate layers and files.

Because an image is built during the final stage of the build process, you can minimize image layers by `[leveraging build cache]()`.

For example, if your build contains several layers, you can order them from the less frequently changed (to ensure the build cache is reusable) to the more frequently changed:

- Install tools you need to build your application
- Install or update library dependencies
- Generate your application

A Dockerfile for a Go application could look like:
```
FROM golang:1.9.2-alpine3.6 AS build

# Install tools required for project
# Run `docker build --no-cache .` to update dependencies
RUN apk add --no-cache git
RUN go get github.com/golang/dep/cmd/dep

# List project dependencies with Gopkg.toml and Gopkg.lock
# These layers are only re-built when Gopkg files are updated
COPY Gopkg.lock Gopkg.toml /go/src/project/
WORKDIR /go/src/project/
# Install library dependencies
RUN dep ensure -vendor-only

# Copy the entire project and build it
# This layer is rebuilt when a file changes in the project directory
COPY . /go/src/project/
RUN go build -o /bin/project

# This results in a single layer image
FROM scratch
COPY --from=build /bin/project /bin/project
ENTRYPOINT ["/bin/project"]
CMD ["--help"]
```

移除非必需的包
Don’t install unnecessary packages
To reduce complexity, dependencies, file sizes, and build times, avoid installing extra or unnecessary packages just because they might be “nice to have.” For example, you don’t need to include a text editor in a database image.

去除重复的应用
Decouple applications
Each container should have only one concern. Decoupling applications into multiple containers makes it easier to scale horizontally and reuse containers. For instance, a web application stack might consist of three separate containers, each with its own unique image, to manage the web application, database, and an in-memory cache in a decoupled manner.

Limiting each container to one process is a good rule of thumb, but it is not a hard and fast rule. For example, not only can containers be spawned with an init process, some programs might spawn additional processes of their own accord. For instance, Celery can spawn multiple worker processes, and Apache can create one process per request.

Use your best judgment to keep containers as clean and modular as possible. If containers depend on each other, you can use Docker container networks to ensure that these containers can communicate.

最小化层的数量
Minimize the number of layers
In older versions of Docker, it was important that you minimized the number of layers in your images to ensure they were performant. The following features were added to reduce this limitation:

- In Docker 1.10 and higher, only the instructions RUN, COPY, ADD create layers. Other instructions create temporary intermediate images, and do not directly increase the size of the build.

- In Docker 17.05 and higher, you can do multi-stage builds and only copy the artifacts you need into the final image. This allows you to include tools and debug information in your intermediate build stages without increasing the size of the final image.

排序多行参数
Sort multi-line arguments
Whenever possible, ease later changes by sorting multi-line arguments alphanumerically. This helps to avoid duplication of packages and make the list much easier to update. This also makes PRs a lot easier to read and review. Adding a space before a backslash (\) helps as well.

Here’s an example from the buildpack-deps image:
```
RUN apt-get update && apt-get install -y \
  bzr \
  cvs \
  git \
  mercurial \
  subversion
```

#### 配置文件的指令
Dockerfile instructions
These recommendations are designed to help you create an efficient and maintainable `Dockerfile`.

来自
FROM
[Dockerfile reference for the FROM instruction]()

无论何时，只要可以，使用当前官方的仓库作为你的镜像的基础。我们建议使用Alpine镜像，因为它是严谨可控的并且在大小上较小，比完整的linux相比。
Whenever possible, use current official repositories as the basis for your images. We recommend the [Alpine image]() as it is tightly controlled and small in size (currently under 5 MB), while still being a full Linux distribution.

标签
LABEL

[Understanding object labels]()

你可以添加标签到你的镜像中，以便帮助工程组织镜像，记录授权信息，自动化辅助设备或者其他原因。
对于每个标签，添加新的一行，以`LABEL`开头，并且带一个或多个的键-值对。下面的几个例子显示不容的可接受的格式。注释内容也包含在里面，并以在一行内的形式出现。
You can add labels to your image to help organize images by project, record licensing information, to aid in automation, or for other reasons. For each label, add a line beginning with `LABEL` and with one or more key-value pairs. The following examples show the different acceptable formats. Explanatory comments are included inline.

带有空格的字符必须适应引号或者空格必须被避免编译。字符内的引号`"`也必须避免编译。
Strings with spaces must be quoted or the spaces must be escaped. Inner quote characters (`"`), must also be escaped.

```
# 设置一个或多个个性化的标签
# Set one or more individual labels
LABEL com.example.version="0.0.1-beta"
LABEL vendor1="ACME Incorporated"
LABEL vendor2=ZENITH\ Incorporated
LABEL com.example.release-date="2015-02-12"
LABEL com.example.version.is-production=""
```

一个镜像可以有多个标签，在Docker 1.10之前，建议把所有标签组合在单个`LABEL`描述中,以防止创建时出现额外的层。现在已经不是必须的，但组合标签这一功能仍然支持。
An image can have more than one label. Prior to Docker 1.10, it was recommended to combine all labels into a single `LABEL` instruction, to prevent extra layers from being created. This is no longer necessary, but combining labels is still supported.
```
# Set multiple labels on one line
LABEL com.example.version="0.0.1-beta" com.example.release-date="2015-02-12"
```
查看[Understanding object labels]()，它是关于可接受标签的键与值得指南。若想了解关于查询标签的信息，参考这个项目，关于在[Managing labels on objects]()中使用过滤器。另外也可查看[LABEL]()在`Dockerfile reference`中。
See [Understanding object labels]() for guidelines about acceptable label keys and values. For information about querying labels, refer to the items related to filtering in [Managing labels on objects](). See also [LABEL]() in the Dockerfile reference.


运行
RUN
Dockerfile reference for the RUN instruction

Split long or complex RUN statements on multiple lines separated with backslashes to make your Dockerfile more readable, understandable, and maintainable.

下载
APT-GET
Probably the most common use-case for RUN is an application of apt-get. Because it installs packages, the RUN apt-get command has several gotchas to look out for.

Avoid RUN apt-get upgrade and dist-upgrade, as many of the “essential” packages from the parent images cannot upgrade inside an unprivileged container. If a package contained in the parent image is out-of-date, contact its maintainers. If you know there is a particular package, foo, that needs to be updated, use apt-get install -y foo to update automatically.

Always combine RUN apt-get update with apt-get install in the same RUN statement. For example:
```
    RUN apt-get update && apt-get install -y \
        package-bar \
        package-baz \
        package-foo
```

Using apt-get update alone in a RUN statement causes caching issues and subsequent apt-get install instructions fail. For example, say you have a Dockerfile:
```
 FROM ubuntu:14.04
    RUN apt-get update
    RUN apt-get install -y curl
```

After building the image, all layers are in the Docker cache. Suppose you later modify apt-get install by adding extra package:
```
   FROM ubuntu:14.04
    RUN apt-get update
    RUN apt-get install -y curl nginx
```
Docker sees the initial and modified instructions as identical and reuses the cache from previous steps. As a result the apt-get update is not executed because the build uses the cached version. Because the apt-get update is not run, your build can potentially get an outdated version of the curl and nginx packages.

Using RUN apt-get update && apt-get install -y ensures your Dockerfile installs the latest package versions with no further coding or manual intervention. This technique is known as “cache busting”. You can also achieve cache-busting by specifying a package version. This is known as version pinning, for example:
```
    RUN apt-get update && apt-get install -y \
        package-bar \
        package-baz \
        package-foo=1.3.*
```

Version pinning forces the build to retrieve a particular version regardless of what’s in the cache. This technique can also reduce failures due to unanticipated changes in required packages.



Below is a well-formed RUN instruction that demonstrates all the apt-get recommendations.
```
RUN apt-get update && apt-get install -y \
    aufs-tools \
    automake \
    build-essential \
    curl \
    dpkg-sig \
    libcap-dev \
    libsqlite3-dev \
    mercurial \
    reprepro \
    ruby1.9.1 \
    ruby1.9.1-dev \
    s3cmd=1.1.* \
 && rm -rf /var/lib/apt/lists/*

```

The s3cmd argument specifies a version 1.1.*. If the image previously used an older version, specifying the new one causes a cache bust of apt-get update and ensures the installation of the new version. Listing packages on each line can also prevent mistakes in package duplication.

In addition, when you clean up the apt cache by removing /var/lib/apt/lists it reduces the image size, since the apt cache is not stored in a layer. Since the RUN statement starts with apt-get update, the package cache is always refreshed prior to apt-get install.

Official Debian and Ubuntu images automatically run apt-get clean, so explicit invocation is not required.

管道
USING PIPES
Some RUN commands depend on the ability to pipe the output of one command into another, using the pipe character (|), as in the following example:
```

RUN wget -O - https://some.site | wc -l > /number
```
Docker executes these commands using the /bin/sh -c interpreter, which only evaluates the exit code of the last operation in the pipe to determine success. In the example above this build step succeeds and produces a new image so long as the wc -l command succeeds, even if the wget command fails.

If you want the command to fail due to an error at any stage in the pipe, prepend set -o pipefail && to ensure that an unexpected error prevents the build from inadvertently succeeding. For example:
```
RUN set -o pipefail && wget -O - https://some.site | wc -l > /number
```

- Not all shells support the -o pipefail option.

In such cases (such as the dash shell, which is the default shell on Debian-based images), consider using the exec form of RUN to explicitly choose a shell that does support the pipefail option. For example:
```
RUN ["/bin/bash", "-c", "set -o pipefail && wget -O - https://some.site | wc -l > /number"]

```

命令
CMD
Dockerfile reference for the CMD instruction

The CMD instruction should be used to run the software contained by your image, along with any arguments. CMD should almost always be used in the form of CMD [“executable”, “param1”, “param2”…]. Thus, if the image is for a service, such as Apache and Rails, you would run something like CMD ["apache2","-DFOREGROUND"]. Indeed, this form of the instruction is recommended for any service-based image.

In most other cases, CMD should be given an interactive shell, such as bash, python and perl. For example, CMD ["perl", "-de0"], CMD ["python"], or CMD [“php”, “-a”]. Using this form means that when you execute something like docker run -it python, you’ll get dropped into a usable shell, ready to go. CMD should rarely be used in the manner of CMD [“param”, “param”] in conjunction with ENTRYPOINT, unless you and your expected users are already quite familiar with how ENTRYPOINT works.

暴露
EXPOSE
Dockerfile reference for the EXPOSE instruction

The EXPOSE instruction indicates the ports on which a container listens for connections. Consequently, you should use the common, traditional port for your application. For example, an image containing the Apache web server would use EXPOSE 80, while an image containing MongoDB would use EXPOSE 27017 and so on.

For external access, your users can execute docker run with a flag indicating how to map the specified port to the port of their choice. For container linking, Docker provides environment variables for the path from the recipient container back to the source (ie, MYSQL_PORT_3306_TCP).

环境


添加

复制

入口命令
ENTRYPOINT
[Dockerfile reference for the ENTRYPOINT instruction]()

The best use for `ENTRYPOINT` is to set the image’s main command, allowing that image to be run as though it was that command (and then use `CMD` as the default flags).

Let’s start with an example of an image for the command line tool s3cmd:
```
ENTRYPOINT ["s3cmd"]
CMD ["--help"]
```
Now the image can be run like this to show the command’s help:
```
$ docker run s3cmd
```
Or using the right parameters to execute a command:
```
$ docker run s3cmd ls s3://mybucket
```

This is useful because the image name can double as a reference to the binary as shown in the command above.

The ENTRYPOINT instruction can also be used in combination with a helper script, allowing it to function in a similar way to the command above, even when starting the tool may require more than one step.

For example, the Postgres Official Image uses the following script as its ENTRYPOINT:
```
#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
    chown -R postgres "$PGDATA"

    if [ -z "$(ls -A "$PGDATA")" ]; then
        gosu postgres initdb
    fi

    exec gosu postgres "$@"
fi

exec "$@"
```


- Configure app as PID 1

This script uses the exec Bash command so that the final running application becomes the container’s PID 1. This allows the application to receive any Unix signals sent to the container. For more, see the ENTRYPOINT reference.

The helper script is copied into the container and run via ENTRYPOINT on container start:
```
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["postgres"]
```

This script allows the user to interact with Postgres in several ways.

It can simply start Postgres:
```
$ docker run postgres
```
Or, it can be used to run Postgres and pass parameters to the server:
```
$ docker run postgres postgres --help
```

Lastly, it could also be used to start a totally different tool, such as Bash:
```
$ docker run --rm -it postgres bash
```


数据卷
VOLUME

[Dockerfile reference for the VOLUME instruction]()

`VOLUME`描述应该用来暴露任一 被你的docker容器创建的 数据库贮存区域，配置文件贮存，或者文件/目录。强烈建议使用`VOLUME`，给那些任一易变的或者用户-可用的 镜像部分。
The `VOLUME` instruction should be used to expose any database storage area, configuration storage, or files/folders created by your docker container. You are strongly encouraged to use `VOLUME` for any mutable and/or user-serviceable parts of your image.

USER
[Dockerfile reference for the USER instruction]()

如果一个服务 在没有特权时 可以运行，使用`USER`改变为非root用户。创建用户和群组在`Dockerfile`文件内，比如`RUN groupadd -r postgres && useradd --no-log-init -r -g postgres postgres`。
If a service can run without privileges, use `USER` to change to a non-root user. Start by creating the user and group in the `Dockerfile` with something like `RUN groupadd -r postgres && useradd --no-log-init -r -g postgres postgres`.

看重一个明确的用户标识/群组标识
- Consider an explicit UID/GID

Users and groups in an image are assigned a non-deterministic UID/GID in that the “next” UID/GID is assigned regardless of image rebuilds. So, if it’s critical, you should assign an explicit UID/GID.

Due to an unresolved bug in the Go archive/tar package’s handling of sparse files, attempting to create a user with a significantly large UID inside a Docker container can lead to disk exhaustion because /var/log/faillog in the container layer is filled with NULL (\0) characters. A workaround is to pass the --no-log-init flag to useradd. The Debian/Ubuntu adduser wrapper does not support this flag.


Avoid installing or using `sudo` as it has unpredictable TTY and signal-forwarding behavior that can cause problems. If you absolutely need functionality similar to `sudo`, such as initializing the daemon as root but running it as non-root), consider using `“gosu”`.

最后，为了减少层数以及复杂性，避免频繁地切换`USER`。
Lastly, to reduce layers and complexity, avoid switching `USER` back and forth frequently.

WORKDIR
[Dockerfile reference for the WORKDIR instruction]()

为了清晰和可读，你应该一直使用绝对路径，给你的`WORKDIR`。另外，你应该使用`WORKDIR`代替增生的描述，比如`RUN cd … &&`做某事，这种描述很难读，易触发问题。
For clarity and reliability, you should always use absolute paths for your `WORKDIR`. Also, you should use `WORKDIR` instead of proliferating instructions like RUN cd … && do-something, which are hard to read, troubleshoot, and maintain.

ONBUILD
[Dockerfile reference for the ONBUILD instruction]()

`ONBUILD`这个命令在 当前`Dockerfile`构建完成 之后执行。`ONBUILD`执行在任一的子镜像中，这些子镜像来源于`FROM`的当前镜像。可以这么认为，`ONBUILD`命令作为一句指令，父`Dockerfile`给子`Dockerfile`的指令。
An `ONBUILD` command executes after the current Dockerfile build completes. `ONBUILD` executes in any child image derived `FROM` the current image. Think of the `ONBUILD` command as an instruction the parent Dockerfile gives to the child Dockerfile.

一个镜像构建，执行`ONBUILD`命令，在任一子`Dockerfile`命令之前。
A Docker build executes `ONBUILD` commands before any command in a child `Dockerfile`.

`ONBUILD` 是很有用的，对于构建那些 来自`FROM`于某一给出的镜像的 镜像。比如，你想要使用`ONBUILD`，为某一语言堆叠镜像。
`ONBUILD` is useful for images that are going to be built `FROM` a given image. For example, you would use `ONBUILD` for a language stack image that builds arbitrary user software written in that language within the Dockerfile, as you can see in Ruby’s `ONBUILD` variants.

构建来自`ONBUILD` 的镜像应该给出一个分离的标签，比如ruby:1.9-onbuild 或者 ruby:2.0-onbuild。
Images built from ONBUILD should get a separate tag, for example: ruby:1.9-onbuild or ruby:2.0-onbuild.

Be careful when putting ADD or COPY in ONBUILD. The “onbuild” image fails catastrophically if the new build’s context is missing the resource being added. Adding a separate tag, as recommended above, helps mitigate this by allowing the Dockerfile author to make a choice.
#### 官方仓库的示例

Examples for Official Repositories
These Official Repositories have exemplary Dockerfiles:
- Go
- Perl
- Hy
- Ruby

#### 其他额外资源
Additional resources:

- Dockerfile Reference
- More about Base Images
- More about Automated Builds
- Guidelines for Creating Official Repositories