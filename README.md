# Tailscale Derp Server

Although Tailscale DERP supports automatic SSL certificate generation, it is not always convenient. This setup uses NginxProxyManager [NginxProxyManager](https://github.com/NginxProxyManager/nginx-proxy-manager) (NPM) as a reverse proxy for DERP, which provides a more convenient and flexible way to configure SSL.

With NPM, you can use the DNS-01 challenge to obtain an SSL certificate or even upload the SSL certificate manually. This is extremely convenient in countries where certain HTTP-01 challenges are blocked.

##  TL;DR

1. Modify the port configuration in `docker-compose.yaml` as desired.

  ```yaml
  version: '3'
  services:
    npm:
      image: jc21/nginx-proxy-manager:latest
      container_name: nginx-proxy-manager
      restart: unless-stopped
      ports:
        - 80:80
        - 81:81
        - 443:443
      volumes:
        - ./data:/data
        - ./letsencrypt:/etc/letsencrypt
      networks:
        npm: null
    derper:
      build: .
      restart: always
      container_name: derper
      hostname: derp.latte.ltd
      ports:
        - 3439:3439/udp
      volumes:
        - /var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock
      networks:
        npm: null
  networks:
    npm:
      name: npm
  ```

2. Start with `docker compose`

  ```shell
  docker compose up -d	
  ```

# With Headscale

As [derp example](https://github.com/juanfont/headscale/blob/main/derp-example.yaml) in Headscale repo:

```yaml
regions:
  901:
    regionid: 901
    regioncode: ist
    regionname: Istanbul
    nodes:
      - name: 901a
        regionid: 901
        hostname: derp.latte.ltd
        ipv4: 46.31.77.160
        ipv6: ""
        stunport: 3439
        stunonly: false
        derpport: 443
```
