import base64
import jwt
import uuid
import datetime
import json
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend

def get_anser_private_key():
    private_key_str = """MIIEpAIBAAKCAQEA2AXAXV8ZFx7VQ7FOgG/ogFo+JSXZlrJkwmBKNEYNxSEcYZvN5C0VqtEIF8PY93F2t1sYQQv7cd4Wz1XKtpXTDPBakqPXxlnRZGOGS6yd8+zJ2cI+ec/icuWQPoKDDMLJSjqiV9++ldgb5+p//QWZtnU4/ngO3ZVnut+7o65+C6OmyLqdSbInIbQbhW96BOa9tlrw38PfmncWsJYauMnN6mMirMJSAJnczIokvPv9McQWkr0e6Tfl/WZq/ZPGk/hdFxYGD9BOxKFpRkBLFPdWlhxlwty2fRdAbJWI0yBObEqAWCpUCDPH7tzv/SIhYjDveptZAnixblpC3D09h+iuLwIDAQABAoIBAQCcJoQnuk87rDkCho81Pi91YEYduh9v1CILc2kQIjdf8JBAakxJDOHlqNXNv+785pKm9X0xv8SRSbV5SA2RL/nwF2mRKEgYA+LdSyfPWcaPhPFfrA5XJRMOdKxw0wyB0+eG9Z1WIdD1JdL+MD82Ga9D+bYqE4TDXXUu2v0a004fgGZ8757gnbjIH3PR/LptCq3jjaA7lK3YQtJEFGSoDhJABEkrN9oaKGxtZHnyvaA0img+XyPMTBBqy8uA6G1aRtF1FE9CrIT9UGcsj1TtcTuAi6rV5oKk4zFrQ1FvDAQ4UMiLvsTBGrFPUFJ2zhQScAWZn22F286Nsw58a5Bj4TyxAoGBAPybYgO22YRvyDd0CT96WkVfc3MIAeklo8g1NK33xttJQilOzeS9L7iEpRjDA4wSsFYzm0AUYdPvvWMPR4jpKu00OnIhaqFTVI3ocQkdIFCGnymwaDZAYS0M3wmb9svCeLzutvJfYQVnkoOdsx2uAu5QfC9gDVu2dEsty5taq5iXAoGBANrskZXT0dtbILbr1W2ofGIKqFTpkcjSD6N1i9Hse20zYK4Phav0RXZO1tqvpE76gAaNtOZBB2THALrH2Wq8zVHRvUa29aPKxVWvNigS4Vs0teMnI7FxcCyeWIN4x5AYgKPxKF9R/DjQnPVpAEXGWOEKRrlVgOOMBUQZ4mdQlnIpAoGAN11nEiFVc218mIraLAuJFYNiLmgm4w7Y4tymeyq/bviTg7I99lBw0SRhexfjAyRleb8928Gb33PAMqH6r8tLGUpFNRaV5F37Pk8f1zuHBZ8760s6zAk4Q0N67wQ8B1TMWbyIZH77KNAWkLpTs8Gb6tfBIDERPHS08HVNFvO8gGkCgYEArJhdntXEWT/a5tu/BBkVFuZ4F5mdScnyclg1x2a9WDZtPk0WgZ6vNLqrQPXAgFOVo5UMzYrvHVCXDqqIilIXPS4yHxIXTu6J7SeZdraL3LANxewRg89/NG4SMnSCQORQZu+1eJDWXKR7Wi9R+7CIWcMURwFWAA9gB3SwvesW8SECgYA2E7S0rx4lPLM+C8zoREbDw6un4s8VDJHf5EXNmyJZVQEUG95H5phb6wDBMlcHVGW0EE6Mbajn35XOzG8H8+IuwJGS8EThjRwNlOCPETQ0srkrCmGV/8vYbInChdxj38T4RvbJ1lWlc6qobe9aMfoZu2RNUToMQWZWPHb72NSbjw=="""
    key_bytes = base64.b64decode(private_key_str)
    private_key = serialization.load_der_private_key(
        key_bytes,
        password=None,
        backend=default_backend()
    )
    return private_key

# 从 body.txt 读取 body 内容
with open("body.txt", "r", encoding="utf-8") as f:
    body_data = json.load(f)

# 生成 JWT
now = datetime.datetime.utcnow()
claims = {
    "sub": "anser",
    "jti": str(uuid.uuid4()),
    "iat": now,
    "exp": now + datetime.timedelta(seconds=300),
    "body": body_data
}

headers = {
    "alg": "RS512",
    "typ": "JWT"
}

token = jwt.encode(
    payload=claims,
    key=get_anser_private_key(),
    algorithm="RS512",
    headers=headers
)

print(token)
