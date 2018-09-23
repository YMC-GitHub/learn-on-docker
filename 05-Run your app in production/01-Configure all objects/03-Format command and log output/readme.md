
## 格式化命令与日志输出
Docker uses Go templates which you can use to manipulate the output format of certain commands and log drivers.

Docker provides a set of basic functions to manipulate template elements. All of these examples use the `docker inspect` command, but many other CLI commands have a `--format` flag, and many of the CLI command references include examples of customizing the output format.

join
join concatenates a list of strings to create a single string. It puts a separator between each element in the list.
```
docker inspect --format '{{join .Args " , "}}' container
```

json
json encodes an element as a json string.
```
docker inspect --format '{{json .Mounts}}' container
```


lower
lower transforms a string into its lowercase representation.
```
docker inspect --format "{{lower .Name}}" container
```


split
split slices a string into a list of strings separated by a separator.
```
docker inspect --format '{{split .Image ":"}}'
```

title
title capitalizes the first character of a string.
```
docker inspect --format "{{title .Name}}" container
```


upper
upper transforms a string into its uppercase representation.
```
docker inspect --format "{{upper .Name}}" container
```

println
println prints each value on a new line.
```
docker inspect --format='{{range .NetworkSettings.Networks}}{{println .IPAddress}}{{end}}' container
```


#### 标签
format, formatting, output, templates, log
