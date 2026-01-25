# p12 导出 key crt

from cryptography.hazmat.primitives.serialization import pkcs12, Encoding, PrivateFormat, NoEncryption
from cryptography.hazmat.primitives import serialization

# 文件路径和密码
p12_file = "jnb-test.payeelink.com.P12"
password = b"2794"

# 读取 p12 文件
with open(p12_file, "rb") as f:
    p12_data = f.read()

# 加载 p12 内容
private_key, cert, additional_certs = pkcs12.load_key_and_certificates(p12_data, password)

# 检查是否成功加载
if private_key is None:
    raise ValueError("无法从 P12 文件中提取私钥")
if cert is None:
    raise ValueError("无法从 P12 文件中提取证书")

# 导出私钥
with open("jnb-test.payeelink.com.key", "wb") as f:
    f.write(private_key.private_bytes(
        encoding=Encoding.PEM,
        format=PrivateFormat.TraditionalOpenSSL,
        encryption_algorithm=NoEncryption()
    ))

# 导出证书
with open("jnb-test.payeelink.com.crt", "wb") as f:
    f.write(cert.public_bytes(Encoding.PEM))

# （可选）导出 CA 证书链
if additional_certs:
    with open("jnb-test.payeelink.com-ca.crt", "wb") as f:
        for c in additional_certs:
            f.write(c.public_bytes(Encoding.PEM))

print("导出完成！")
