# ssh 密钥文件登录错误

### 1.错误

```
 ssh -i C:\gen\sakura-test ubuntu@133.242.70.192
Bad permissions. Try removing permissions for user: BUILTIN\\Users (S-1-5-32-545) on file C:/gen/sakura-test.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Permissions for 'C:\\gen\\sakura-test' are too open.
It is required that your private key files are NOT accessible by others.
This private key will be ignored.
Load key "C:\\gen\\sakura-test": bad permissions
ubuntu@133.242.70.192: Permission denied (publickey).
```

### 2.解决方法

Open PowerShell as Administrator.

Run the following command to remove access from other users:

```
icacls "C:\gen\sakura-test" /inheritance:r
icacls "C:\gen\sakura-test" /grant:r "$($env:USERNAME):R"

```

---
