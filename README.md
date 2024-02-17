# a headscale server with a angular UI

## Thanks 

[headscale-webui](https://github.com/iFargle/headscale-webui) version: 0.1.4 

[Headscale](https://github.com/juanfont/headscale) version: v0.22.3 

[UI](https://github.com/NG-ZORRO/ng-zorro-antd) version: v15.0.3

[BaseFramework](https://github.com/NG-ZORRO/ng-zorro-antd) version: 15.2.4

## add submodule

```shell
git submodule add -b main https://github.com/simcu/headscale-ui.git headscale-ui/src
```

### Submodules Commit ID

- **Headscale UI** - Commit ID: `10fbd02ee445728395eea37ed894c450a4a9a2ab`

## Usage

headscale-webui 0.1.4 not support headscale v0.23.0-alpha4, api maybe change, like mkey:hash is newer. (Compatibility with headscale v0.22.1 and v0.22.3)

## Config

### nginx /etc/nginx/sites-available/default

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
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection $connection_upgrade;
                proxy_set_header Host $server_name;
                proxy_buffering off;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $http_x_forwarded-proto;
                add_header Strict-Transport-Security "max-age=15552000; includeSubDomains" always;
        }
        location /admin {
                proxy_pass http://127.0.0.1:5000/admin;
                proxy_http_version 1.1;
                proxy_set_header Host $server_name;
                proxy_buffering off;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
                        auth_basic "Administrator's Area";
                        auth_basic_user_file /etc/nginx/htpasswd;
        }
}
```

## headscale config /etc/headscale/config.yaml

```shell
server_url: https://hs.yourdomain.com        
listen_addr: 0.0.0.0:8080      
ip_prefixes:                         
  - 100.64.0.0/10
  - fd7a:115c:a1e0::/48
disable_check_updates: true  
dns_config:
  override_local_dns: false    
randomize_client_port: true  
```