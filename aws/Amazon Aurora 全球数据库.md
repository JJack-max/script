## 问题 #273（纠错后）

一家**快速发展的电子商务公司**目前在**单个 AWS 区域**运行其生产工作负载。  
解决方案架构师必须设计一个**跨多个 AWS 区域的灾难恢复（DR）策略**。

公司要求：
- **数据库在 DR 区域保持最新状态**
- **数据库复制延迟尽可能低**
- **DR 区域的其余基础设施以低流量运行**
- 在需要时**能够快速扩展**
- 具备**尽可能低的恢复时间目标（RTO）**

哪种解决方案可以满足这些要求？

A. 使用 **Pilot Light（灯塔）部署** 的 Amazon Aurora 全球数据库  
B. 使用 **Warm Standby（温备）部署** 的 Amazon Aurora 全球数据库  
C. 使用 **Pilot Light（灯塔）部署** 的 Amazon RDS Multi-AZ 数据库实例  
D. 使用 **Warm Standby（温备）部署** 的 Amazon RDS Multi-AZ 数据库实例  

---

## 正确答案
**👉 B**

---

## 解析

### 考点
- **跨区域灾难恢复（Multi-Region DR）**
- RTO（恢复时间目标）优先级
- Aurora Global Database 的能力
- DR 模式：Pilot Light vs Warm Standby

---

### 为什么选 B

#### 1️⃣ Aurora Global Database
- 原生 **跨区域复制**
- 复制延迟通常 **< 1 秒**
- DR 区域数据库始终保持**最新数据**
- 支持快速 **Region Failover**

👉 完美满足：
- “数据库在 DR 区域保持最新”
- “尽可能低的延迟”

---

#### 2️⃣ Warm Standby（温备）模式
- DR 区域：
  - 基础设施**已运行**
  - 但规模较小（低成本）
- 故障发生时：
  - **快速扩容**
  - 应用迅速接管流量
- **RTO 明显低于 Pilot Light**

👉 正好符合：
- “其余基础设施低流量运行”
- “需要时可快速扩展”
- “低 RTO”

---

### 其他选项为什么错

#### ❌ A. Aurora Global + Pilot Light
- Pilot Light：
  - 只保持**最小核心组件**
  - 大部分资源需灾难发生后再启动
- ❌ RTO 高于 Warm Standby
- 不满足“尽可能低的 RTO”

---

#### ❌ C / D. RDS Multi-AZ
- Multi-AZ 仅限：
  - **单一 Region 内**
- ❌ 不支持跨区域 DR
- 无法满足题目“不同 AWS 区域”的要求

---

## 一句话记忆
> **跨区域 + 低延迟数据库 + 低 RTO → Aurora Global Database + Warm Standby**

考试秒杀版：

> **DR 题只要看到“数据库要最新 + 低 RTO” → 直接选 Aurora Global + Warm Standby**
