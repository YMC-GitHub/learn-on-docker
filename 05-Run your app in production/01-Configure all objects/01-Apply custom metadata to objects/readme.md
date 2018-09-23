
#### 对象标签
Docker object labels

Labels are a mechanism for applying metadata to Docker objects, including:
- Images
- Containers
- Local daemons
- Volumes
- Networks
- Swarm nodes
- Swarm services

You can use labels to organize your images, record licensing information, annotate relationships between containers, volumes, and networks, or in any way that makes sense for your business or application.

#### 标签键值
Label keys and values
A label is a key-value pair, stored as a string. You can specify multiple labels for an object, but each key-value pair must be unique within an object. If the same key is given multiple values, the most-recently-written value overwrites all previous values.

#### 键的格式
Key format recommendations
A label key is the left-hand side of the key-value pair. Keys are alphanumeric strings which may contain periods (.) and hyphens (-). Most Docker users use images created by other organizations, and the following guidelines help to prevent inadvertent duplication of labels across objects, especially if you plan to use labels as a mechanism for automation.

- Authors of third-party tools should prefix each label key with the reverse DNS notation of a domain they own, such as com.example.some-label.

- Do not use a domain in your label key without the domain owner’s permission.

- The com.docker.*, io.docker.*, and org.dockerproject.* namespaces are reserved by Docker for internal use.

- Label keys should begin and end with a lower-case letter and should only contain lower-case alphanumeric characters, the period character (.), and the hyphen character (-). Consecutive periods or hyphens are not allowed.

- The period character (.) separates namespace “fields”. Label keys without namespaces are reserved for CLI use, allowing users of the CLI to interactively label Docker objects using shorter typing-friendly strings.

These guidelines are not currently enforced and additional guidelines may apply to specific use cases.

#### 键的方针
Value guidelines
Label values can contain any data type that can be represented as a string, including (but not limited to) JSON, XML, CSV, or YAML. The only requirement is that the value be serialized to a string first, using a mechanism specific to the type of structure. For instance, to serialize JSON into a string, you might use the JSON.stringify() JavaScript method.

Since Docker does not deserialize the value, you cannot treat a JSON or XML document as a nested structure when querying or filtering by label value unless you build this functionality into third-party tooling.

#### 管理标签
Manage labels on objects
Each type of object with support for labels has mechanisms for adding and managing them and using them as they relate to that type of object. These links provide a good place to start learning about how you can use labels in your Docker deployments.

Labels on images, containers, local daemons, volumes, and networks are static for the lifetime of the object. To change these labels you must recreate the object. Labels on swarm nodes and services can be updated dynamically.

- Images and containers
  - Adding labels to images
  - Overriding a container’s labels at runtime
  - Inspecting labels on images or containers
  - Filtering images by label
  - Filtering containers by label
- Local Docker daemons
  - Adding labels to a Docker daemon at runtime
  - Inspecting a Docker daemon’s labels
- Volumes
  - Adding labels to volumes
  - Inspecting a volume’s labels
  - Filtering volumes by label
- Networks
  - Adding labels to a network
  - Inspecting a network’s labels
  - Filtering networks by label
- Swarm nodes
  - Adding or updating a swarm node’s labels
  - Inspecting a swarm node’s labels
  - Filtering swarm nodes by label
- Swarm services
  - Adding labels when creating a swarm service
  - Updating a swarm service’s labels
  - Inspecting a swarm service’s labels
  - Filtering swarm services by label

Usage, user guide, labels, metadata, docker, documentation, examples, annotating