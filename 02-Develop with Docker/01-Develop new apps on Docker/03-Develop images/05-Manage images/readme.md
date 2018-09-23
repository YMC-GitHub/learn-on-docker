## 管理镜像
The easiest way to make your images available for use by others inside or outside your organization is to use a Docker registry, such as [Docker Hub](), [Docker Trusted Registry](), or by running your own [private registry]().

#### Docker Hub
Docker Hub
[Docker Hub]() is a public registry managed by Docker, Inc. It centralizes information about organizations, user accounts, and images. It includes a web UI, authentication and authorization using organizations, CLI and API access using commands such as `docker login`, `docker pull`, and `docker push`, comments, stars, search, and more. Docker Hub is also integrated into [Docker Store](), which is a marketplace that allows you to buy and sell entitlements to non-free images.

#### Docker Registry
Docker Registry
The Docker Registry is a component of Docker’s ecosystem. A registry is a storage and content delivery system, holding named Docker images, available in different tagged versions. For example, the image distribution/registry, with tags 2.0 and latest. Users interact with a registry by using `docker push` and pull commands such as `docker pull myregistry.com/stevvooe/batman:voice`.

Docker Hub is an instance of a Docker Registry.

#### Docker Trusted Registry
Docker Trusted Registry
Docker Trusted Registry is part of Docker Enterprise Edition, and is a private, secure Docker registry which includes features such as image signing and content trust, role-based access controls, and other Enterprise-grade features.

#### Content Trust
Content Trust
When transferring data among networked systems, trust is a central concern. In particular, when communicating over an untrusted medium such as the internet, it is critical to ensure the integrity and publisher of all of the data a system operates on. You use Docker to push and pull images (data) to a registry. Content trust gives you the ability to both verify the integrity and the publisher of all the data received from a registry over any channel.

See Content trust for information about configuring and using this feature on Docker clients.




