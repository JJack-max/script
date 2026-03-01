---
title: "How to Deploy a Self-Hosted Headscale Server"
date: 2026-02-27T20:10:00+08:00
tags: ["headscale", "tailscale", "docker", "self-hosted"]
draft: false
---

## Introduction

Headscale is an open-source, self-hosted implementation of the Tailscale control server. It allows you to create a secure, private network between your devices, without relying on the public Tailscale service. This guide will walk you through the process of deploying your own Headscale server using Docker and Docker Compose.

## Prerequisites

Before you begin, you will need:

*   A server with a public IP address (e.g., a VPS from any cloud provider).
*   A domain name pointing to your server's IP address.
*   Docker and Docker Compose installed on your server.

## Deployment using Docker

We will use Docker Compose to deploy Headscale. Here is a `docker-compose.yml` file to get you started:

```yaml
version: '3.7'

services:
  headscale:
    image: headscale/headscale:latest
    container_name: headscale
    restart: unless-stopped
    volumes:
      - ./config:/etc/headscale/
      - ./data:/var/lib/headscale/
    ports:
      - "8080:8080"
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv6.conf.all.forwarding=1

  caddy:
    image: caddy:latest
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
  caddy_config:
```

### Configuration

1.  **Create a `config` directory and a `config.yaml` file inside it.**

    ```bash
    mkdir config
    touch config/config.yaml
    ```

    Here is a basic configuration to get you started. **Make sure to replace `your_domain.com` with your actual domain name.**

    ```yaml
    server_url: https://your_domain.com
    listen_addr: 0.0.0.0:8080
    metrics_listen_addr: 0.0.0.0:9090
    grpc_listen_addr: 0.0.0.0:50443
    ip_prefixes:
      - 100.64.0.0/10
    db_type: sqlite3
    db_path: /var/lib/headscale/db.sqlite
    ```

2.  **Create a `Caddyfile` for the reverse proxy.**

    ```bash
    touch Caddyfile
    ```

    Add the following content to the `Caddyfile`. **Again, replace `your_domain.com` with your domain.**

    ```
    your_domain.com {
        reverse_proxy headscale:8080
    }
    ```

3.  **Start the services.**

    ```bash
    docker-compose up -d
    ```

## Connecting Clients

1.  **Create a user.**

    ```bash
    docker-compose exec headscale headscale users create myuser
    ```

2.  **Create a pre-authenticated key.**

    ```bash
    docker-compose exec headscale headscale preauthkeys create --reusable --expiration 24h --user myuser
    ```

3.  **Connect a client.**

    On your client machine, run the following command, replacing `your_domain.com` with your domain and `<preauth_key>` with the key you just generated:

    ```bash
    tailscale up --login-server https://your_domain.com --authkey <preauth_key>
    ```

You have now successfully deployed your own Headscale server!
