
# 📘 `git-crypt` 使用指南

> 安全地加密 Git 仓库中的敏感文件，支持 GPG 多用户解密。

---

## 📦 安装（Windows 用户）

建议使用 [Scoop](https://scoop.sh) 安装：

```powershell
scoop install git-crypt
```

---

## 🚀 初始化仓库加密

```bash
git-crypt init
```

该命令会在仓库中生成 `.git-crypt` 文件夹，并准备好用于加密的密钥信息。

---

## 🔐 设置加密文件（编辑 `.gitattributes`）

添加你希望加密的文件路径。例如：

```gitattributes
file/private filter=git-crypt diff=git-crypt
**/private     filter=git-crypt diff=git-crypt
```

然后提交：

```bash
git add .gitattributes
git commit -m "Add git-crypt attributes"
```

---

## 🔒 添加加密文件（触发加密）

```bash
git add file/private
git commit -m "Add encrypted file"
```

---

## 🔓 解锁仓库（解密文件）

```bash
git-crypt unlock
```

确保你本地有对应的 GPG 私钥。

---

## 👥 添加 GPG 用户（允许其他人解密）

```bash
git-crypt add-gpg-user ABCDEFG123456789
```

用户需将其 GPG 公钥（如 `.asc` 文件）提交给你。

---

## 👤 移除 GPG 用户权限（不完全）

手动删除 `.git-crypt/keys/default/0/<FINGERPRINT>.gpg` 并提交：

```bash
rm .git-crypt/keys/default/0/XXXXXXXX.gpg
git add .git-crypt/keys
git commit -m "Remove GPG user"
```

⚠️ 若彻底吊销访问，请执行重新初始化（见下方）。

---

## 💥 彻底吊销用户（重新初始化）

```bash
git-crypt unlock
git rm -r --cached .git-crypt
rm -rf .git-crypt

git-crypt init
git-crypt add-gpg-user 你的新GPG-ID
git add .
git commit -m "Reinitialize git-crypt with updated GPG users"
```

---

## 🧪 检查加密状态

```bash
git-crypt status
```

---

## 🧼 常见问题：加密无效？

可能是文件在 `.gitattributes` 生效前已提交明文。处理方法：

```bash
git rm --cached file/private
git add file/private
git commit -m "Re-add with encryption"
```

---

## 👀 查看文件是否已加密

```bash
git show HEAD:file/private | head
hexdump -C file/private | head
```

如果看到二进制乱码，说明加密成功。
