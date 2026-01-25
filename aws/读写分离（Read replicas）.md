## 问题 #381

一家制造公司托管了一个 **包含 PostgreSQL 数据库的三层 Web 应用程序**。

当前架构与问题点：

- PostgreSQL 数据库：
  - 存储 **文档的元数据**
  - 元数据中包含 **关键术语**，用于审计与报告
- 文档本体存储在 **Amazon S3**
- 使用场景：
  - 文档 **写入次数少**
  - **读取和更新频繁**
- 报告（审计）流程：
  - 需要运行 **几个小时**
  - 使用 **复杂的关系型查询**
  - 在运行期间：
    - **必须阻止文档修改**
    - **必须阻止新增文档**
- 目标：
  - **加快报告过程**
  - **对应用程序代码进行最少修改**

哪种解决方案最符合这些要求？

A. 使用 Amazon DocumentDB（MongoDB 兼容），通过只读副本生成报告  
B. 使用 Amazon Aurora PostgreSQL，并通过 Aurora 副本生成报告  
C. 使用 Amazon RDS for PostgreSQL Multi-AZ，并在次级节点上运行报告  
D. 使用 Amazon DynamoDB 存储文档元数据，并通过自动扩展读取容量生成报告  

---

## 正确答案
**👉 B**

---

## 解析

### 考点
- 读写分离（Read replicas）
- 报告 / 审计型长时间查询
- PostgreSQL 兼容性
- **最少代码改动**

---

## 为什么选 B

### ✅ Aurora PostgreSQL + Aurora Replica = 报告加速标准解法

**Amazon Aurora PostgreSQL 是最适合该场景的选择：**

1. **完全兼容 PostgreSQL**
2. 支持多个 **Aurora 只读副本**
3. 只需最少修改（连接切换）
4. 专门为 **高并发读 + 报告查询** 优化

---

### 1️⃣ 关系型查询 + PostgreSQL 兼容性

- 题目明确指出：
  - 使用 PostgreSQL
  - 依赖复杂关系型查询
- Aurora PostgreSQL：
  - **SQL 语法完全兼容**
  - 无需重写查询逻辑

👉 **代码改动最小**

---

### 2️⃣ 使用 Aurora Replica 承载报告负载

- 报告流程特点：
  - 长时间
  - 重读查询
- 将报告查询：
  - 全部指向 **Aurora Replica**
- 主实例：
  - 专注处理在线事务（OLTP）
  - 避免被报告拖慢

👉 **显著提升整体性能**

---

### 3️⃣ 满足“阻止写入”的审计要求

- 在报告期间：
  - 可暂停主库写入
  - 或通过应用层控制写入
- Aurora Replica：
  - 使用共享存储
  - **读性能远高于传统 RDS Read Replica**

👉 非常适合审计 / 报告型场景

---

## 其他选项为什么错

### ❌ A. Amazon DocumentDB
- DocumentDB 是：
  - **NoSQL / 文档型数据库**
- 现有系统：
  - PostgreSQL
  - 关系型查询
- ❌ 需要大量代码与数据模型重构
- ❌ 违背“最少代码修改”

---

### ❌ C. RDS for PostgreSQL Multi-AZ
- Multi-AZ 的次级节点：
  - **仅用于故障转移**
  - ❌ **不能用于读查询**
- 报告查询仍会打到主节点
- ❌ 无法解决性能问题

---

### ❌ D. Amazon DynamoDB
- DynamoDB：
  - NoSQL
  - 不支持复杂关系查询
- ❌ 完全不适合审计 / 报告 SQL
- ❌ 架构改动最大

---

## 一句话记忆
> **PostgreSQL 报告 / 审计加速 → Aurora PostgreSQL + Aurora Replica**

### 考试秒杀版
> **长时间读查询 + 最少改代码：直接把报告打到 Aurora 只读副本**
