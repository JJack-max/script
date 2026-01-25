一、题目纠错（问题还原）

问题 #232

一家公司在 Amazon EC2 实例上为其客户运行演示桌面。
每个桌面都隔离在其自己的 VPC 中。

公司的运营团队需要在建立 RDP 或 SSH 访问桌面时收到通知。

哪种解决方案可以满足要求？

A. 配置 Amazon CloudWatch Application Insights，在检测到 RDP 或 SSH 访问时创建 AWS Systems Manager OpsItems。
B. 将 EC2 实例配置为具有附加了 AmazonSSMManagedInstanceCore 策略的 IAM 角色的 IAM 实例配置文件。
C. 将 VPC 流日志发布到 Amazon CloudWatch Logs，创建所需的指标过滤器，并创建一个 Amazon CloudWatch 指标警报，当警报处于 ALARM 状态时执行通知操作。
D. 配置一个 Amazon EventBridge 规则，监听类型为 EC2 实例状态更改通知 的事件，并将 Amazon SNS 主题作为目标，让运营团队订阅该主题。


二、正确答案 ✅

👉 C. 将 VPC 流日志发布到 Amazon CloudWatch Logs，并基于其创建告警通知

三、考点定位（这是在考什么）

这是一个典型的：

“如何监控 RDP / SSH 访问行为，并触发告警”

注意关键词：

RDP / SSH 访问

访问发生时通知

网络层行为

每个桌面在独立 VPC

👉 这本质是 网络流量监控问题，不是实例状态、不是运维自动化。


四、为什么 C 是正确的
1️⃣ RDP / SSH 属于网络连接行为

| 协议  | 端口       |
| --- | -------- |
| SSH | TCP 22   |
| RDP | TCP 3389 |

VPC Flow Logs 能做什么？

记录：

源 IP

目标 IP

端口

协议

ACCEPT / REJECT

覆盖：

ENI / 子网 / VPC 级别

与操作系统无关（关键点）

👉 只要有 RDP / SSH 连接建立，就一定会体现在 VPC Flow Logs 中。

2️⃣ CloudWatch Logs + Metric Filter + Alarm = 实时通知

完整链路：
```
RDP / SSH 连接
↓
VPC Flow Logs
↓
CloudWatch Logs
↓
Metric Filter（端口 22 / 3389）
↓
CloudWatch Alarm
↓
SNS / Ops 通知

```
✔ 实时
✔ 可扩展
✔ 跨 VPC
✔ 不依赖实例 OS
✔ AWS 官方推荐做法


五、逐项排错（考试最关键）
❌ A. CloudWatch Application Insights

错因：

Application Insights 用于：

应用性能

依赖关系

异常检测

❌ 无法检测 RDP / SSH 网络访问

OpsItems ≠ 访问告警

👉 方向完全不对


❌ B. AmazonSSMManagedInstanceCore

错因：

这是为了：

Session Manager

Patch / Run Command

❌ 不会自动感知 SSH / RDP 登录

❌ 没有通知机制

👉 这是权限配置题干扰项


❌ D. EC2 实例状态更改通知

错因：

只监听：

start

stop

terminate

reboot

❌ 与用户是否登录完全无关

👉 状态 ≠ 访问


六、一句话记忆法（考场用）

监控 SSH / RDP → 只想 VPC Flow Logs

或者更狠一点：

凡是“访问 / 端口 / 连接” → 网络日志（VPC Flow Logs）


七、延伸（真实生产中常见升级方案）

如果题目再高级一点，可能会出现：

VPC Flow Logs → S3 → Athena → Security Hub

或结合 AWS GuardDuty（但题目没给选项）