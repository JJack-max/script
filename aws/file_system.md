## 问题 #283（纠错后）

一家研究公司运行的实验由一个**模拟应用程序**和一个**可视化应用程序**共同支持。  
- 模拟应用程序运行在 **Linux** 上，每 5 分钟将结果数据输出到 **NFS 共享**。  
- 可视化应用程序是一个 **Windows 桌面应用程序**，用于显示模拟输出，并且需要一个 **SMB 文件系统**。  

公司目前维护 **两个独立的文件系统**，这导致数据重复和资源利用效率低下。  
公司需要将这些应用程序迁移到 **AWS**，并且 **不对任何应用程序代码进行更改**。

哪种解决方案可以满足这些要求？

A. 将两个应用程序迁移到 AWS Lambda。创建一个 Amazon S3 存储桶以在应用程序之间交换数据。  
B. 将两个应用程序迁移到 Amazon ECS。配置 Amazon FSx File Gateway 进行存储。  
C. 将模拟应用程序迁移到 Linux EC2 实例。将可视化应用程序迁移到 Windows EC2 实例。配置 Amazon SQS 在应用程序之间交换数据。  
D. 将模拟应用程序迁移到 Linux EC2 实例。将可视化应用程序迁移到 Windows EC2 实例。配置 Amazon FSx for NetApp ONTAP 进行存储。  

---

## 正确答案
**👉 D**

---

## 解析

### 考点
- 同一份数据同时支持 **NFS（Linux）** 和 **SMB（Windows）**
- **零代码修改**迁移
- 统一文件存储，避免数据重复
- AWS 原生托管文件系统选型

---

### 为什么选 D

**Amazon FSx for NetApp ONTAP** 是关键：

- ✅ **同时支持 NFS 和 SMB**
- ✅ Linux 和 Windows 可挂载同一个文件系统
- ✅ 应用程序无需修改代码（路径/协议保持一致）
- ✅ 企业级高性能、低延迟
- ✅ 消除双文件系统带来的数据复制问题

迁移架构：
- Linux EC2 → 挂载 FSx ONTAP（NFS）
- Windows EC2 → 挂载 FSx ONTAP（SMB）
- 两个应用 **直接共享同一份数据**

---

### 其他选项为什么错

**A. AWS Lambda + S3**
- ❌ Lambda 不适合桌面/模拟类应用
- ❌ S3 不是文件系统（无 NFS/SMB）
- ❌ 需要重构应用逻辑

**B. ECS + FSx File Gateway**
- ❌ File Gateway 是混合云方案，非纯 AWS 内部最优解
- ❌ 问题核心是 **统一 NFS + SMB 文件系统**，不是网关

**C. EC2 + SQS**
- ❌ SQS 是消息队列，不是文件系统
- ❌ 应用程序需要改写数据交换逻辑
- ❌ 不满足“无需代码更改”

---

## 一句话记忆
> **Linux 要 NFS，Windows 要 SMB，且不能改代码 → 直接选 FSx for NetApp ONTAP**
