# Cloudflare Tunnel 视频系列脚本模板（中英文）

## 使用说明
- 每集包含: 视频标题、中英文讲解文案、操作步骤、示意图提示、字幕建议
- 可直接复制到你的脚本或提词器中
- 每集时长建议 5~10 分钟

---

## 第 1 集：Cloudflare Tunnel 入门 (Intro)
**标题:** Cloudflare Tunnel 入门 | Introduction to Cloudflare Tunnel

**中文讲解文案:**
```
大家好，欢迎来到本系列课程。今天我们来了解 Cloudflare Tunnel，它能帮助你安全地把本地服务映射到公网，而不用开端口或者配置复杂的路由。
```
**英文讲解文案:**
```
Hello everyone! Welcome to this series. Today, we will introduce Cloudflare Tunnel, which lets you expose local services to the internet securely without opening ports or configuring complex routing.
```
**操作步骤:**
- 无需操作，本集主要讲概念
**示意图提示:**
- 局域网和公网的箭头示意
- Tunnel 经过 Cloudflare 网络的流向
**字幕建议:**
- 中文和英文双字幕

---

## 第 2 集：注册 Cloudflare & 安装 Tunnel 客户端
**标题:** 安装 Cloudflare Tunnel 客户端 | Installing Cloudflare Tunnel Client

**中文讲解文案:**
```
首先，我们注册一个 Cloudflare 账号，并添加你的域名。然后我们下载 cloudflared 客户端，根据系统选择 Windows, Mac 或 Linux。
```
**英文讲解文案:**
```
First, sign up for a Cloudflare account and add your domain. Then, download the cloudflared client for your OS: Windows, Mac, or Linux.
```
**操作步骤:**
1. 打开 cloudflare.com 注册账号
2. 添加域名
3. 下载 cloudflared:
   - Windows: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation#windows
   - Mac: brew install cloudflared
   - Linux: wget ... / apt install cloudflared
**示意图提示:**
- 官网注册界面截图
- 安装命令截图
**字幕建议:**
- 重要命令加粗或高亮

---

## 第 3 集：快速创建第一个 Tunnel
**标题:** 创建第一个 Cloudflare Tunnel | Create Your First Cloudflare Tunnel

**中文讲解文案:**
```
现在我们来创建第一个 Tunnel。首先使用 cloudflared login 登录账号，然后创建 Tunnel 并绑定 DNS。
```
**英文讲解文案:**
```
Now, let's create your first tunnel. First, log in using cloudflared login, then create a tunnel and bind it to your DNS.
```
**操作步骤:**
1. `cloudflared login`
2. `cloudflared tunnel create mytunnel`
3. `cloudflared tunnel route dns mytunnel example.com`
4. `cloudflared tunnel run mytunnel`
**示意图提示:**
- 命令行操作演示
- 本地服务访问示例截图
**字幕建议:**
- 命令行输出用不同颜色标注

---

## 第 4 集：高级配置（多服务、多端口）
**标题:** 高级配置 Cloudflare Tunnel | Advanced Configuration

**中文讲解文案:**
```
我们可以使用 config.yml 管理多个 Tunnel，将不同子域名映射到不同本地端口，并设置自动启动。
```
**英文讲解文案:**
```
We can manage multiple tunnels with config.yml, mapping different subdomains to different local ports, and set tunnels to start automatically.
```
**操作步骤:**
1. 创建 config.yml
2. 配置多个 ingress 规则
3. Windows: `sc create cloudflared ...` 或 Linux: `systemctl enable cloudflared`
**示意图提示:**
- 配置文件示例截图
- 多服务映射图示
**字幕建议:**
- YAML 配置用等宽字体显示

---

## 第 5 集：安全与访问控制
**标题:** Cloudflare Tunnel 安全与访问控制 | Security & Access Control

**中文讲解文案:**
```
Cloudflare Tunnel 支持 Access Policy 和 Zero Trust，确保只有授权用户才能访问服务。
```
**英文讲解文案:**
```
Cloudflare Tunnel supports Access Policy and Zero Trust, ensuring only authorized users can access your services.
```
**操作步骤:**
1. 配置 Access Policy
2. 设置 HTTPS 自动加密
3. 验证访问控制
**示意图提示:**
- Access Policy 配置界面截图
- HTTPS 锁图标示意
**字幕建议:**
- 强调安全关键点

---

## 第 6 集：常见问题与故障排查
**标题:** Cloudflare Tunnel 常见问题 | Troubleshooting

**中文讲解文案:**
```
常见问题包括 TLS 错误、DNS 配置错误、Tunnel 无法连接等。我们将逐步排查。
```
**英文讲解文案:**
```
Common issues include TLS errors, DNS misconfiguration, and tunnel connection failures. We will troubleshoot step by step.
```
**操作步骤:**
1. 检查 cloudflared logs
2. 验证 DNS 配置
3. 检查防火墙/端口
**示意图提示:**
- 错误日志截图
- 排查流程图
**字幕建议:**
- 提供小贴士和快捷命令

---

## 第 7~8 集：实用案例演示
**标题:** Cloudflare Tunnel 实战案例 | Practical Examples

**中文讲解文案:**
```
通过 Cloudflare Tunnel 我们可以安全访问 NAS、HomeLab 或本地 Web 应用，无需端口映射。
```
**英文讲解文案:**
```
With Cloudflare Tunnel, we can securely access NAS, HomeLab, or local web apps without port forwarding.
```
**操作步骤:**
1. 配置内网服务
2. 配置 Tunnel 映射端口
3. 访问公网 URL
**示意图提示:**
- 内网服务到公网的流向示意图
- 实际访问演示截图
**字幕建议:**
- 每个服务单独标注 URL

---

**备注:**
- 每集中文与英文文案均可直接用于录制
- 命令行和配置文件截图可在录屏时直接录入
- 可在 VSCode 或 OBS 中显示提示文字与箭头

---

📌 **文件结束**

