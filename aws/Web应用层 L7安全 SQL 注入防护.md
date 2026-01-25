## 问题 #340

一家媒体公司在 AWS 上托管其网站。  
该网站应用程序的架构包括：

- 一个 **位于 Application Load Balancer（ALB）后面的 Amazon EC2 实例集群**
- 一个 **托管在 Amazon Aurora 上的数据库**

公司的网络安全团队报告称：  
> **该应用程序易受 SQL 注入攻击。**

公司应该如何解决这个问题？

A. 在 ALB 前使用 **AWS WAF**，并将适当的 **Web ACL** 与 AWS WAF 关联。  
B. 创建一个 ALB 监听器规则，以固定响应 SQL 注入请求。  
C. 订阅 **AWS Shield Advanced** 以自动阻止所有 SQL 注入尝试。  
D. 设置 **Amazon Inspector** 以自动阻止所有 SQL 注入尝试。  

---

## 正确答案
**👉 A**

---

## 解析

### 考点
- **Web 应用层（L7）安全**
- **SQL Injection（OWASP Top 10）**
- **ALB + WAF 防护模式**
- AWS 各安全服务职责区分

---

### 为什么选 A

#### ✅ SQL 注入 = 典型 Web 应用层攻击

- SQL 注入发生在：
  - HTTP 请求内容
  - URL / Header / Body
- 属于 **L7（应用层）攻击**
- 需要 **理解请求内容** 才能防护

👉 **AWS WAF 正是为此设计的服务**

---

### 1️⃣ AWS WAF 能原生防护 SQL 注入

- AWS WAF 提供：
  - **托管规则（Managed Rules）**
  - 包含 **SQLi Rule Set**
- 可直接关联到：
  - Application Load Balancer
  - CloudFront
  - API Gateway

👉 **无需改代码即可防护**

---

### 2️⃣ 架构位置正确

```
Internet
↓
AWS WAF
↓
ALB
↓
EC2
↓
Aurora
```

- 在 **流量进入应用之前阻断攻击**
- 避免恶意请求到达 EC2 / 数据库

---

### 3️⃣ 符合 AWS 最佳实践

- Web 攻击 → **WAF**
- DDoS → Shield
- 漏洞扫描 → Inspector

👉 职责清晰、架构标准

---

## 其他选项为什么错

### ❌ B. ALB 监听器规则
- ALB 监听器：
  - 不能解析请求内容
  - 无法识别 SQL 注入 Payload
- ❌ 不具备 Web 防火墙能力

---

### ❌ C. AWS Shield Advanced
- Shield 主要防护：
  - L3 / L4 / 部分 L7 DDoS
- ❌ 不防 SQL 注入

---

### ❌ D. Amazon Inspector
- Inspector 用于：
  - 漏洞评估
  - 安全审计
- ❌ 不做实时请求拦截

---

## 一句话记忆
> **SQL 注入 = Web 应用层攻击 → ALB 前放 AWS WAF**

### 考试秒杀版
> **Web 攻击（SQLi / XSS）第一反应：AWS WAF**
