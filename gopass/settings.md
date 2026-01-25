# gopass & gpg 常用命令手册

## 一、GPG 密钥管理

- **列出所有密钥**

  ```sh
  gpg --list-keys
  ```

- **生成新密钥**

  ```sh
  gpg --full-generate-key
  ```

- **导出私钥**

  ```sh
  gpg --export-secret-keys -a <密钥ID> > my-private-key.asc
  ```

- **导出公钥**

  ```sh
  gpg --armor --export <用户名或密钥ID> > public-key.asc
  ```

- **导入私钥/公钥**

  ```sh
  gpg --import path\to\privatekey.asc
  gpg --import path\to\publickey.asc
  ```

- **删除私钥/公钥**
  ```sh
  gpg --batch --yes --delete-secret-keys <密钥ID>
  gpg --batch --yes --delete-keys <密钥ID>
  ```

---

## 二、gopass 密码库管理

- **初始化密码库**

  ```sh
  gopass init --path <密码库路径> <GPG-ID>
  ```

- **克隆远程密码库**

  ```sh
  gopass clone <git仓库地址> <本地目录>
  ```

  > 提示：使用 `gopass clone` 时，不需要执行 `gopass init`，克隆命令会自动完成初始化。

- **初始化团队密码库**

  ```sh
  gopass init --store <store名> --path <本地路径> <GPG-ID>

  > 提示：`--path` 不是必须参数，不加时会自动在主库目录的 `.gopass/stores/<store名>` 下生成默认文件夹。
  ```

- **同步密码库**

  ```
  gopass sync
  ```
