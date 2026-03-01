---
title: "Exposing Self-Hosted Services with Cloudflare Tunnel"
date: 2026-02-27T10:00:00+08:00
tags: ["cloudflare", "tunnel", "networking", "self-hosted"]
draft: false
---

## Introduction

Cloudflare Tunnel provides a secure way to connect your local services to the internet without opening up firewall ports or having a public IP address. It creates a secure, outbound-only connection between your service and the Cloudflare network.

This guide will walk you through setting up a Cloudflare Tunnel to expose a local web service.

## Prerequisites

*   A Cloudflare account.
*   A domain added to your Cloudflare account.
*   `cloudflared` daemon installed on your server where the service is running.

## Steps to Create a Tunnel

1.  **Login to Cloudflare:**
    Authenticate `cloudflared` with your Cloudflare account.
    ```bash
    cloudflared tunnel login
    ```

2.  **Create a Tunnel:**
    Give your tunnel a name. For example, `my-app`.
    ```bash
    cloudflared tunnel create my-app
    ```
    This will generate a credentials file for the tunnel in your `~/.cloudflared/` directory.

3.  **Create a Configuration File:**
    Create a `config.yml` file for your tunnel. This is where you define the services to be exposed.
    ```yaml
    tunnel: my-app
    credentials-file: /root/.cloudflared/YOUR_TUNNEL_ID.json

    ingress:
      - hostname: my-app.your-domain.com
        service: http://localhost:8080
      - service: http_status:404
    ```
    Replace `YOUR_TUNNEL_ID.json` with the file from the previous step and `my-app.your-domain.com` with your desired subdomain.

4.  **Route DNS for the Tunnel:**
    Tell Cloudflare to route traffic for the new subdomain to your tunnel.
    ```bash
    cloudflared tunnel route dns my-app my-app.your-domain.com
    ```

5.  **Run the Tunnel:**
    You can run the tunnel as a service to ensure it's always active.
    ```bash
    cloudflared service install
    cloudflared service start
    ```
    Alternatively, you can run it directly from the command line with your configuration file.
    ```bash
    cloudflared tunnel --config /path/to/your/config.yml run
    ```

Your local service is now securely exposed to the internet via Cloudflare Tunnel!
