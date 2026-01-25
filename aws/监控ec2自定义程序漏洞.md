## 问题 #315

一家公夜曾遭受一次**漏洞攻击**，影响了其本地数据中心中运行的多个应用程序。  
攻击者利用了**服务器上运行的自定义应用程序中的漏洞**。

公司现在正在将这些应用程序迁移到 **Amazon EC2 实例** 上运行，并希望：

- **自动扫描 EC2 实例上的漏洞**
- **生成并发送详细的漏洞报告**
- 使用 **AWS 原生、安全、自动化** 的方式

哪种解决方案可以满足这些要求？

A. 部署 AWS Shield 扫描 EC2 实例中的漏洞。创建一个 AWS Lambda 函数，将任何发现记录到 AWS CloudTrail。  
B. 部署 Amazon Macie 和 AWS Lambda 函数扫描 EC2 实例中的漏洞。将任何发现记录到 AWS CloudTrail。  
C. 启用 Amazon GuardDuty。将 GuardDuty 代理部署到 EC2 实例。配置一个 AWS Lambda 函数，以自动生成和分发详细说明发现的报告。  
D. 启用 **Amazon Inspector**。将 Amazon Inspector 代理部署到 EC2 实例。配置一个 AWS Lambda 函数，以自动生成和分发详细说明发现的报告。

---

## 正确答案
**👉 D**

---

## 解析

### 考点
- **EC2 漏洞扫描**
- **主机级安全评估**
- **自动化安全报告**
- AWS 原生安全服务选型

---

### 为什么选 D

**Amazon Inspector 正是为这个场景设计的：**

#### 1️⃣ 专门用于漏洞扫描
- **Amazon Inspector**
  - 自动扫描 EC2 实例
  - 识别：
    - 操作系统漏洞
    - 已知 CVE
    - 不安全配置
    - 暴露风险
- 完全符合题目中的“漏洞扫描”要求

#### 2️⃣ 支持代理模式
- 在 EC2 实例上安装 **Inspector Agent**
- 可进行更深入、主机级别的安全分析

#### 3️⃣ 报告与自动化
- Inspector 会生成 **详细的安全发现**
- 通过：
  - EventBridge
  - Lambda
- 可自动生成并分发**详细漏洞报告**

👉 完整满足：
- 自动扫描
- EC2 主机级漏洞
- 详细报告
- 云原生、低运维

---

### 其他选项为什么错

#### ❌ A. AWS Shield
- Shield 用于：
  - **DDoS 防护**
- ❌ 不做漏洞扫描
- ❌ 不分析应用或主机漏洞

---

#### ❌ B. Amazon Macie
- Macie 用于：
  - **S3 中的敏感数据发现**
- ❌ 不扫描 EC2
- ❌ 不做漏洞分析

---

#### ❌ C. Amazon GuardDuty
- GuardDuty 用于：
  - 威胁检测
  - 异常行为分析
  - 日志驱动的安全告警
- ❌ **不是漏洞扫描工具**
- ❌ 无需也不支持安装 agent

---

## 一句话记忆
> **EC2 漏洞扫描 = Amazon Inspector**

考试秒杀版：

> **题目出现“漏洞扫描 + EC2” → 不要犹豫，直接选 Amazon Inspector**
