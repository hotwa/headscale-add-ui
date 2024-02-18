# Headscale Server with Angular UI

This project combines a Headscale server with an Angular-based UI, providing a user-friendly interface for managing your TailScale-compatible VPN network.

## Thanks

Special thanks to the following projects for their open-source contributions:

- [Headscale-webui](https://github.com/iFargle/headscale-webui) version: 0.1.4
- [Headscale](https://github.com/juanfont/headscale) version: v0.22.3
- [UI](https://github.com/NG-ZORRO/ng-zorro-antd) (NG-ZORRO) version: v15.0.3
- [BaseFramework](https://github.com/NG-ZORRO/ng-zorro-antd) (NG-ZORRO) version: 15.2.4

## Prerequisites

Before you begin, ensure you have met the following requirements:

- Docker and Docker Compose installed on your system.
- Basic knowledge of Docker and containerization.
- NGINX (optional) for reverse proxy setup.

## Installation

1. **Clone the Repository**

```shell
git clone https://github.com/YOUR_GITHUB/headscale-add-ui.git
cd headscale-add-ui
```

1. Add Submodule

```shell
git submodule add -b main https://github.com/simcu/headscale-ui.git headscale-ui/src
```

2. Install Docker Compose

Use the provided script to install the latest version of Docker Compose:

```shell
curl https://cdn.jsdelivr.net/gh/hotwa/headscale-add-ui@main/docker_compose_script.sh | bash
```

3. Build and Run Containers

Utilize the docker-compose.yml file in the project to build and run the containers:

```shell
docker-compose up -d
```

## Configuration

### NGINX Reverse Proxy

To access the Headscale-webui through your domain, configure NGINX as a reverse proxy. Update /etc/nginx/sites-available/default with the following configuration, replacing example.com with your domain:

```shell
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

server {
    listen 58080;
    listen [::]:58080;
    server_name example.com;
    location / {
        proxy_pass http://127.0.0.1:8080;
        ...
    }
    location /admin {
        proxy_pass http://127.0.0.1:5000/admin;
        ...
    }
}
```

## headscale config /etc/headscale/config.yaml

my reference:

```shell
server_url: https://hs.yourdomain.com     # you can use like http://hs.yourdomain.com:8080   
listen_addr: 0.0.0.0:8080    # be care use 0.0.0.0 to listen   
ip_prefixes:                         
  - 100.64.0.0/10
  - fd7a:115c:a1e0::/48
disable_check_updates: true  
dns_config:
  override_local_dns: false    
randomize_client_port: true  
```

## Usage

After installation and configuration, access the Headscale-webui through http://yourdomain:58080/admin to manage your VPN network.

## License

This project is licensed under the MIT License - see the LICENSE file for details.