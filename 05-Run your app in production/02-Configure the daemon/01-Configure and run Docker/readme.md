## 配置和启动docker服务器daemon

Configure and troubleshoot the Docker daemon

After successfully installing and starting Docker, the dockerd daemon runs with its default configuration. This topic shows how to customize the configuration, start the daemon manually, and troubleshoot and debug the daemon if you run into issues.

#### 启动--使用操作系统工具
Start the daemon using operating system utilities
On a typical installation the Docker daemon is started by a system utility, not manually by a user. This makes it easier to automatically start Docker when the machine reboots.

The command to start Docker depends on your operating system. Check the correct page under [Install Docker](). To configure Docker to start automatically at system boot, see [Configure Docker to start on boot]().

#### 启动--使用命令手动启动
Start the daemon manually
If you don’t want to use a system utility to manage the Docker daemon, or just want to test things out, you can manually run it using the dockerd command. You may need to use `sudo`, depending on your operating system configuration.

When you start Docker this way, it runs in the foreground and sends its logs directly to your terminal.
```
$ dockerd

INFO[0000] +job init_networkdriver()
INFO[0000] +job serveapi(unix:///var/run/docker.sock)
INFO[0000] Listening for HTTP on unix (/var/run/docker.sock)
```
To stop Docker when you have started it manually, issue a `Ctrl+C` in your terminal.

#### 配置
Configure the Docker daemon


两种方式：
- 使用配置文件（推荐）
- 使用命令标识

There are two ways to configure the Docker daemon:

- Use a JSON configuration file. This is the preferred option, since it keeps all configurations in a single place.
- Use flags when starting dockerd.

或者使用两者方式结合，只用两种方式不存在相同的选项即可，不然不会启动并且打印错误信息。
You can use both of these options together as long as you don’t specify the same option both as a flag and in the JSON file. If that happens, the Docker daemon won’t start and prints an error message.

配置文件位置
To configure the Docker daemon using a JSON file, create a file at `/etc/docker/daemon.json` on Linux systems, or `C:\ProgramData\docker\config\daemon.json` on Windows.


配置文件内容
Here’s what the configuration file looks like:
```
{
  "debug": true,
  "tls": true,
  "tlscert": "/var/docker/server.pem",
  "tlskey": "/var/docker/serverkey.pem",
  "hosts": ["tcp://192.168.59.3:2376"]
}
```
With this configuration the Docker daemon runs in debug mode, uses TLS, and listens for traffic routed to `192.168.59.3` on port `2376`. You can learn what configuration options are available in the [dockerd reference docs]()

你另外可以使用命令标识手动地启动Docker daemon和配置它。这是有用的，在遇到出错提示时。
You can also start the Docker daemon manually and configure it using flags. This can be useful for troubleshooting problems.

Here’s an example of how to manually start the Docker daemon, using the same configurations as above:
```
dockerd --debug \
  --tls=true \
  --tlscert=/var/docker/server.pem \
  --tlskey=/var/docker/serverkey.pem \
  --host tcp://192.168.59.3:2376
```

You can learn what configuration options are available in the [dockerd reference docs](), or by running:
```
dockerd --help
```

许多特殊的配置选项是需要讨论的：
- 自动化启动容器
- 限制容器的资源
- 配置存储的驱动
- 容器安全

Many specific configuration options are discussed throughout the Docker documentation. Some places to go next include:

- Automatically start containers
- Limit a container’s resources
- Configure storage drivers
- Container security

#### 目录
Docker daemon directory

The Docker daemon persists all data in a single directory. This tracks everything related to Docker, including containers, images, volumes, service definition, and secrets.

默认目录
By default this directory is:

- `/var/lib/docker` on Linux.
- `C:\ProgramData\docker` on Windows.

指定目录
You can configure the Docker daemon to use a different directory, using the `data-root` configuration option.

Since the state of a Docker daemon is kept on this directory, make sure you use a dedicated directory for each daemon. If two daemons share the same directory, for example, an NFS share, you are going to experience errors that are difficult to troubleshoot.


#### 问题

Troubleshoot the daemon

You can enable debugging on the daemon to learn about the runtime activity of the daemon and to aid in troubleshooting. If the daemon is completely non-responsive, you can also force a full stack trace of all threads to be added to the daemon log by sending the `SIGUSR` signal to the Docker daemon.

- Troubleshoot conflicts between the daemon.json and startup scripts
- Out Of Memory Exceptions (OOME)

读取日志
Read the logs
The daemon logs may help you diagnose problems. The logs may be saved in one of a few locations, depending on the operating system configuration and the logging subsystem used:


开启调试模式
Enable debugging
There are two ways to enable debugging. The recommended approach is to set the debug key to true in the daemon.json file. This method works for every Docker platform.

- Edit the daemon.json file, which is usually located in /etc/docker/. You may need to create this file, if it does not yet exist. On macOS or Windows, do not edit the file directly. Instead, go to Preferences / Daemon / Advanced.

- If the file is empty, add the following:
```
{
  "debug": true
}
```

If the file already contains JSON, just add the key "debug": true, being careful to add a comma to the end of the line if it is not the last line before the closing bracket. Also verify that if the log-level key is set, it is set to either info or debug. info is the default, and possible values are debug, info, warn, error, fatal.

- Send a HUP signal to the daemon to cause it to reload its configuration. On Linux hosts, use the following command.
```
$ sudo kill -SIGHUP $(pidof dockerd)
```
On Windows hosts, restart Docker.

Instead of following this procedure, you can also stop the Docker daemon and restart it manually with the debug flag -D. However, this may result in Docker restarting with a different environment than the one the hosts’ startup scripts create, and this may make debugging more difficult.

堆栈日志记录
Force a stack trace to be logged

堆栈日志查看


查看是否运行
Check whether Docker is running
The operating-system independent way to check whether Docker is running is to ask Docker, using the docker info command.

You can also use operating system utilities, such as sudo systemctl is-active docker or sudo status docker or sudo service docker status, or checking the service status using Windows utilities.

Finally, you can check in the process list for the dockerd process, using commands like ps or top.
