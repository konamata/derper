# Tailscale Derp Server

Although tailscale derp supports automatic SSL certificate generation, it is not always convenient. This repository uses [NginxProxyManager](https://github.com/NginxProxyManager/nginx-proxy-manager)(NPM) as a reverse proxy for derp, Which provides a more convenient and flexible way to configure SSL.

With NPM, you can use the DNS-01 challenge to obtain an SSL certificate or even upload the SSL certificate manually. This is extremely convenient in countries where certain HTTP-01 challenge are blocked.

##  TL;DR

1. Modify the port configuration in `docker-compose.yaml` as desired.

  ```yaml
  version: '3'
  services:
    npm:
      image: 'jc21/nginx-proxy-manager:latest'
      restart: unless-stopped
      volumes:
        - ./data:/data
        - ./letsencrypt:/etc/letsencrypt
      ports:
        - '127.0.0.1:81:81'
        - '233:443'
    derp:
      build: .
      restart: always
      ports:
        - "3478:3478/udp"
      volumes:
        - "/var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock"
  ```

2. Start with `docker compse`

  ```shell
  docker compose up -d	
  ```

3. Login to NPM WebUI

To log in to NPM using SSH local forwarding and access it at [http://127.0.0.1:8881](http://127.0.0.1:8881/), you can use the following command:

 ```
 ssh -L 8881:localhost:81 user@yourhost
 ```

 Replace `user@example.com` with your SSH username and server address. Once you establish the SSH connection, you can access NPM in your browser by navigating to [http://127.0.0.1:8881](http://127.0.0.1:8881/).

 As for the default username and password, you mentioned using `admin@example.com` as the username and `changeme` as the password. Please make sure to change the password to a secure one after logging in for the first time to ensure the security of your NPM installation.

4. Setup SSL and Proxy

NPM provides a user-friendly interface that simplifies the process of setting up a reverse proxy and SSL. You can find detailed instructions on how to configure it in the documentation available at [doc](https://nginxproxymanager.com/guide/). By the way, **please ensure that the proxy is set to point to http://derp:80**.


# With Headscale

As [derp example](https://github.com/juanfont/headscale/blob/main/derp-example.yaml) in Headscale repo:

```yaml
regions:
  900:
    regionid: 900
    regioncode: custom
    regionname: My Region
    nodes:
      - name: 900a
        regionid: 900
        hostname: myderp.mydomain.no
        ipv4: 123.123.123.123
        ipv6: "2604:a880:400:d1::828:b001"
        stunport: 3478
        stunonly: false
        derpport: 233
```
