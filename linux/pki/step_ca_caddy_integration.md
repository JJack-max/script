# Step CA + Caddy 完整集成配置文档

## 1. 环境要求
- Step CA 0.28.4 及以上
- Caddy 2.x
- Linux / macOS / Windows
- 根证书和 CA 配置文件 `ca.json`

---

## 2. Step CA 初始化

1. 初始化 CA
```bash
step ca init
```
- 填写 CA 名称、DNS 名称、监听端口
- 生成 `ca.json`、根证书和私钥

2. 编辑 `ca.json` 添加 ACME Provisioner
```json
{
    "type": "ACME",
    "name": "acme",
    "claims": {
        "maxTLSCertDuration": "8760h",
        "domains": ["*.*"],
        "disableRenewal": false
    }
}
```

3. 启动 CA
```bash
step-ca ca.json
```
- 默认监听 443 端口，可用 `--address` 指定其他端口

---

## 3. 配置 Caddy 使用 Step CA

1. 下载 Step CA 根证书
```bash
step ca root root_ca.crt
```
2. 配置 Caddyfile
```caddyfile
example.com {
    tls {
        ca https://127.0.0.1:443/acme/acme/directory
        issuer acme {
            email admin@example.com
        }
    }

    reverse_proxy localhost:8080
}
```
- `ca` 指向本地 Step CA ACME 目录
- `issuer acme` 使用 ACME 协议签发证书

3. 启动 Caddy
```bash
caddy run --config /path/to/Caddyfile
```

---

## 4. 自动续签与证书轮换
- Caddy 会自动使用 ACME 与 Step CA 通信
- 建议 Step CA 配置 **短期证书**（例如 90 天）
- Caddy 自动续签证书时会向 ACME provisioner 请求新证书

---

## 5. 注意事项
1. **Step CA 数据库清空**后，Caddy 使用的证书仍有效，只要根证书没改。
2. **域名白名单**一定要配置，避免滥用 ACME provisioner。
3. 使用 **allowWildcard** 时注意 DNS 验证是否正确。
4. 生产环境建议启用 **TLS + mTLS** 对内部服务安全。

---

## 6. 推荐目录结构
```
/etc/step-ca/
  ca.json
  db.sqlite (或其他数据库)
  certs/
    root_ca.crt
    root_ca_key.pem
/etc/caddy/
  Caddyfile
  certs/
    root_ca.crt
```

---

## 7. 参考文档
- [Step CA 官方文档](https://smallstep.com/docs/step-ca)
- [Caddy 官方 ACME 配置](https://caddyserver.com/docs/caddyfile/directives/tls)
- [Step CA ACME Provisioner](https://smallstep.com/docs/step-ca/provisioners/acme)

