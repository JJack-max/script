import base64
import hmac
import hashlib
import struct
import time

def generate_totp(secret, time_step=30, digits=6, algo=hashlib.sha1):
    """
    生成 TOTP 验证码
    :param secret: Base32 编码的密钥 (字符串)
    :param time_step: 时间步长 (秒)，默认 30s
    :param digits: 验证码位数，默认 6 位
    :param algo: 哈希算法，默认 SHA1
    :return: 生成的 TOTP 验证码 (字符串)
    """

    # 1. Base32 解码 secret
    key = base64.b32decode(secret, casefold=True)

    # 2. 当前时间戳 / 步长
    counter = int(time.time() // time_step)

    # 3. counter 转 8 字节
    msg = struct.pack(">Q", counter)

    # 4. 计算 HMAC
    hmac_hash = hmac.new(key, msg, algo).digest()

    # 5. 动态截断
    offset = hmac_hash[-1] & 0x0F
    binary = struct.unpack(">I", hmac_hash[offset:offset+4])[0] & 0x7FFFFFFF

    # 6. 取模，得到指定位数验证码
    otp = binary % (10 ** digits)
    return str(otp).zfill(digits)


# 示例使用
if __name__ == "__main__":
    secret = "JBSWY3DPEHPK3PXP"  # 这是 Base32 编码的密钥 (Google Authenticator QR 码里的 secret)
    code = generate_totp(secret)
    print("当前验证码:", code)
