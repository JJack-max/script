## 问题 #287（纠错后）

一家公司希望将其**基于 Windows 的应用程序**从本地迁移到 AWS 云。  
该应用程序包含三个层次：  
- **应用程序层**  
- **业务逻辑层**  
- **数据库层（使用 Microsoft SQL Server）**

公司希望继续使用 **SQL Server 的特定功能**，包括：  
- 本地备份  
- 数据质量服务（DQS）  

此外，公司需要在**各层之间共享文件**以进行处理。

解决方案架构师应如何设计架构以满足这些要求？

A. 在 Amazon EC2 实例上托管所有三个层。使用 Amazon FSx 文件网关在各层之间共享文件。  
B. 在 Amazon EC2 实例上托管所有三个层。使用 Amazon FSx for Windows 文件服务器在各层之间共享文件。  
C. 在 Amazon EC2 实例上托管应用程序层和业务层。在 Amazon RDS 上托管数据库层。使用 Amazon EFS 在层之间进行文件共享。  
D. 在 Amazon EC2 实例上托管应用程序层和业务层。在 Amazon RDS 上托管数据库层。使用预置 IOPS SSD（io2）Amazon EBS 卷在层之间进行文件共享。  

---

## 正确答案
**👉 B**

---

## 解析

### 考点
- **Windows 三层架构迁移**
- **SQL Server 高级/特定功能依赖**
- **跨层共享文件（SMB）**
- 托管 vs 自管理数据库取舍

---

### 为什么选 B

关键点在于 **SQL Server 的“特定功能”要求**：

- SQL Server **本地备份**
- **Data Quality Services（DQS）**
- 这些功能 **不被 Amazon RDS for SQL Server 支持**

👉 因此，**数据库层必须运行在 EC2 上的自管 SQL Server**

接下来是文件共享需求：

- Windows 应用 → 需要 **SMB 文件共享**
- 多层之间共享文件
- 原生、托管、无需额外复杂架构

✅ **Amazon FSx for Windows File Server**
- 原生 **SMB**
- 与 Windows / Active Directory 深度集成
- 托管、高可用、无需维护文件服务器
- 非混合云场景下的最佳选择

最终架构：
- 应用层：Windows EC2
- 业务层：Windows EC2
- 数据库层：Windows EC2 + SQL Server
- 文件共享：FSx for Windows File Server（SMB）

---

### 其他选项为什么错

**A. FSx 文件网关**
- ❌ 适用于 **混合云（on-prem ↔ AWS）**
- ❌ 本题是“迁移到 AWS”，不需要网关

**C. RDS + EFS**
- ❌ RDS for SQL Server **不支持 DQS / 本地备份**
- ❌ EFS 主要面向 Linux（NFS）
- ❌ Windows + EFS 支持受限，非推荐方案

**D. RDS + EBS**
- ❌ EBS 不能跨实例共享
- ❌ RDS 同样不支持所需 SQL Server 特性
- ❌ 架构不成立

---

## 一句话记忆
> **SQL Server 要用高级特性（DQS / 本地备份）→ 必须 EC2；Windows 跨层共享文件 → FSx for Windows**
