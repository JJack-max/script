# wechat_e2ee_gui_contacts.py
# 小程序风格本地端到端加密 GUI 工具
# - 支持联系人管理（保存姓名和 X25519 公钥到 contacts.json）
# - 支持生成/加载本地密钥对
# - 支持二维码导入公钥（从文件或剪贴板图片）
# - 输入明文→加密→复制密文到剪贴板
# - 粘贴密文→解密→聊天区显示

import tkinter as tk
from tkinter import ttk, filedialog, messagebox
from tkinter import scrolledtext
import json, os, base64, secrets, datetime, subprocess, string
import threading
import queue
import time
import hashlib
import py7zr
from cryptography.hazmat.primitives.asymmetric import x25519, ed25519
from cryptography.hazmat.primitives.kdf.hkdf import HKDF
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.ciphers.aead import ChaCha20Poly1305
from PIL import Image
import qrcode
import cv2
import numpy as np

KEY_DIR = '.'
CONTACTS_FILE = 'contacts.json'
USERS_FILE = 'users.json'
CHAT_FILE_TEMPLATE = '{username}.chats'

# Ciphertext marker for automatic detection
CIPHERTEXT_MARKER = 'E2EE:'

# Performance optimization constants
MAX_INITIAL_MESSAGES = 50  # Only load recent N messages initially
MAX_CACHED_CONTACTS = 10   # Maximum number of contacts to keep in memory
KEY_DERIVATION_CACHE_SIZE = 20  # Cache derived keys to avoid PBKDF2 recalculation

# Global caches for performance
_derived_key_cache = {}  # contact -> derived_key
_chat_cache = {}         # contact -> chat_data
_cache_access_time = {}  # contact -> last_access_time

def chat_file_path(username: str) -> str:
    return os.path.join(KEY_DIR, CHAT_FILE_TEMPLATE.format(username=username))

def b64(x: bytes) -> str:
    return base64.urlsafe_b64encode(x).decode('ascii')

def ub64(s: str) -> bytes:
    return base64.urlsafe_b64decode(s.encode('ascii'))

def is_ciphertext(text: str) -> bool:
    """检测文本是否为密文（基于标记）"""
    text = text.strip()
    return text.startswith(CIPHERTEXT_MARKER) and len(text) > len(CIPHERTEXT_MARKER)

def get_cached_derived_key(password: str, cache_key: str):
    """获取缓存的派生密钥，避免重复PBKDF2计算"""
    if cache_key in _derived_key_cache:
        return _derived_key_cache[cache_key]
    
    # 执行PBKDF2派生
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
    # 为每个用户生成一致的salt（基于用户名）
    salt = hashlib.sha256(cache_key.encode()).digest()[:16]
    
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=salt,
        iterations=100000,
    )
    key = kdf.derive(password.encode())
    
    # 缓存管理：如果缓存太大，移除最旧的条目
    if len(_derived_key_cache) >= KEY_DERIVATION_CACHE_SIZE:
        if _cache_access_time:
            oldest_key = min(_cache_access_time.items(), key=lambda x: x[1])[0]
            del _derived_key_cache[oldest_key]
            del _cache_access_time[oldest_key]
    
    _derived_key_cache[cache_key] = key
    _cache_access_time[cache_key] = time.time()
    
    return key

def clear_cache():
    """清理所有缓存"""
    global _derived_key_cache, _chat_cache, _cache_access_time
    _derived_key_cache.clear()
    _chat_cache.clear()
    _cache_access_time.clear()

def load_chats_lazy(username: str, password: str, contact_name: str | None = None):
    """延迟加载聊天记录 - 只加载指定联系人的记录"""
    cache_key = f"{username}_{contact_name}" if contact_name else username
    
    # 检查缓存
    if cache_key in _chat_cache:
        _cache_access_time[cache_key] = time.time()
        return _chat_cache[cache_key]
    
    path = chat_file_path(username)
    if not os.path.exists(path):
        return {}
    
    try:
        with open(path, 'rb') as f:
            raw = f.read()
        
        # 使用缓存的派生密钥
        derived_key_cache_key = f"chat_{username}_{password[:8]}"
        
        # 直接使用优化的解密函数
        data = decrypt_data_optimized(raw, password, derived_key_cache_key)
        if isinstance(data, dict):
            # 如果指定了联系人，只返回该联系人的数据
            if contact_name and contact_name in data:
                result = {contact_name: data[contact_name]}
            else:
                result = data
            
            # 缓存结果
            _chat_cache[cache_key] = result
            _cache_access_time[cache_key] = time.time()
            
            # 缓存管理
            if len(_chat_cache) > MAX_CACHED_CONTACTS:
                if _cache_access_time:
                    oldest_key = min(_cache_access_time.items(), key=lambda x: x[1])[0]
                    if oldest_key in _chat_cache:
                        del _chat_cache[oldest_key]
                    del _cache_access_time[oldest_key]
            
            return result
        return {}
    except Exception:
        return {}

def decrypt_data_optimized(encrypted_data, password, cache_key):
    """优化的数据解密函数，兼容两种加密方式"""
    from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
    import hashlib
    
    try:
        # 解析数据格式
        salt = encrypted_data[:16]
        nonce = encrypted_data[16:28]
        data = encrypted_data[28:]
        
        # 首先尝试使用数据中的salt（兼容旧格式）
        try:
            kdf = PBKDF2HMAC(
                algorithm=hashes.SHA256(),
                length=32,
                salt=salt,  # 使用数据中的真实salt
                iterations=100000,
            )
            key = kdf.derive(password.encode())
            
            aesgcm = AESGCM(key)
            decrypted_data = aesgcm.decrypt(nonce, data, None)
            return json.loads(decrypted_data.decode('utf-8'))
            
        except Exception:
            # 如果失败，尝试使用缓存的固定salt方式（新格式）
            key = get_cached_derived_key(password, cache_key)
            aesgcm = AESGCM(key)
            decrypted_data = aesgcm.decrypt(nonce, data, None)
            return json.loads(decrypted_data.decode('utf-8'))
            
    except Exception as e:
        return None

def decode_qr_with_opencv(image_path: str) -> str:
    """使用OpenCV解码二维码"""
    try:
        # 读取图像
        image = cv2.imread(image_path)
        if image is None:
            raise ValueError("无法读取图像文件")
        
        # 创建QR码检测器
        qr_detector = cv2.QRCodeDetector()
        
        # 检测和解码QR码
        data, bbox, straight_qrcode = qr_detector.detectAndDecode(image)
        
        if data:
            return data
        
        # 如果直接解码失败，尝试预处理图像
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        
        # 尝试不同的预处理方法
        preprocessing_methods = [
            lambda img: cv2.GaussianBlur(img, (5, 5), 0),  # 高斯模糊
            lambda img: cv2.adaptiveThreshold(img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2),  # 自适应阈值
            lambda img: cv2.morphologyEx(img, cv2.MORPH_CLOSE, np.ones((3,3), np.uint8))  # 形态学操作
        ]
        
        for method in preprocessing_methods:
            processed_img = method(gray)
            data, _, _ = qr_detector.detectAndDecode(processed_img)
            if data:
                return data
        
        raise ValueError("无法识别二维码")
        
    except Exception as e:
        raise ValueError(f"二维码解码失败: {str(e)}")

def _derive_key_from_password(password: str, salt: bytes, iterations: int = 100000) -> bytes:
    """从密码派生密钥的通用函数"""
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
    
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=salt,
        iterations=iterations,
    )
    return kdf.derive(password.encode())

def key_paths(username: str):
    return os.path.join(KEY_DIR, f'{username}.x25519.priv'), os.path.join(KEY_DIR, f'{username}.ed25519.priv')

def save_keys(username, x_priv, e_priv, password):
    from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    
    # 生成盐值
    salt = secrets.token_bytes(16)
    
    # 从密码派生密钥
    key = _derive_key_from_password(password, salt)
    
    # 加密私钥
    aesgcm = AESGCM(key)
    nonce = secrets.token_bytes(12)
    
    x_priv_bytes = x_priv.private_bytes(encoding=serialization.Encoding.Raw, format=serialization.PrivateFormat.Raw, encryption_algorithm=serialization.NoEncryption())
    e_priv_bytes = e_priv.private_bytes(encoding=serialization.Encoding.Raw, format=serialization.PrivateFormat.Raw, encryption_algorithm=serialization.NoEncryption())
    
    # 合并私钥数据
    combined_keys = x_priv_bytes + e_priv_bytes
    
    # 加密
    encrypted_data = aesgcm.encrypt(nonce, combined_keys, None)
    
    # 保存格式: [salt(16)][nonce(12)][encrypted_data]
    p1, p2 = key_paths(username)
    with open(p1, 'wb') as f: 
        f.write(salt + nonce + encrypted_data)
    # 删除旧的ed25519文件，现在合并存储
    if os.path.exists(p2):
        os.remove(p2)

def load_keys(username, password):
    from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    
    p1, p2 = key_paths(username)
    if not os.path.exists(p1):
        return None
    
    try:
        with open(p1, 'rb') as f: 
            data = f.read()
        
        # 检查是否是新的加密格式
        if len(data) > 28:  # salt(16) + nonce(12) + min_encrypted_data
            # 新格式：加密存储
            salt = data[:16]
            nonce = data[16:28]
            encrypted_data = data[28:]
            
            # 从密码派生密钥
            key = _derive_key_from_password(password, salt)
            
            # 解密
            aesgcm = AESGCM(key)
            combined_keys = aesgcm.decrypt(nonce, encrypted_data, None)
            
            # 分离私钥
            x_priv_bytes = combined_keys[:32]
            e_priv_bytes = combined_keys[32:]
            
            return x25519.X25519PrivateKey.from_private_bytes(x_priv_bytes), ed25519.Ed25519PrivateKey.from_private_bytes(e_priv_bytes)
        else:
            # 旧格式：明文存储
            if os.path.exists(p2):
                with open(p2, 'rb') as f: e_priv_bytes = f.read()
                return x25519.X25519PrivateKey.from_private_bytes(data), ed25519.Ed25519PrivateKey.from_private_bytes(e_priv_bytes)
            else:
                return None
    except Exception:
        return None

def generate_and_save(username, password):
    x_priv = x25519.X25519PrivateKey.generate()
    e_priv = ed25519.Ed25519PrivateKey.generate()
    save_keys(username, x_priv, e_priv, password)
    return x_priv, e_priv

def derive_shared_key(priv_x, peer_x_pub_bytes):
    peer_pub = x25519.X25519PublicKey.from_public_bytes(peer_x_pub_bytes)
    shared = priv_x.exchange(peer_pub)
    hkdf = HKDF(algorithm=hashes.SHA256(), length=32, salt=None, info=b'wechat-e2ee-gui')
    return hkdf.derive(shared)

def encrypt_and_package(sender_x_priv, sender_e_priv, recipient_x_pub_bytes, plaintext: bytes, meta=None):
    key = derive_shared_key(sender_x_priv, recipient_x_pub_bytes)
    aead = ChaCha20Poly1305(key)
    nonce = secrets.token_bytes(12)
    ct = aead.encrypt(nonce, plaintext, None)
    sig = sender_e_priv.sign(nonce + ct)
    sender_x_pub = sender_x_priv.public_key().public_bytes(encoding=serialization.Encoding.Raw, format=serialization.PublicFormat.Raw)
    sender_e_pub = sender_e_priv.public_key().public_bytes(encoding=serialization.Encoding.Raw, format=serialization.PublicFormat.Raw)
    
    # 紧凑格式：直接拼接二进制数据，避免JSON开销
    # 格式: [x_pub(32)][e_pub(32)][nonce(12)][ct_len(2)][ct][sig(64)]
    ct_len = len(ct).to_bytes(2, 'big')
    compact_data = sender_x_pub + sender_e_pub + nonce + ct_len + ct + sig
    
    # 添加元数据（如果有）
    if meta:
        meta_bytes = json.dumps(meta, separators=(',', ':')).encode()
        meta_len = len(meta_bytes).to_bytes(2, 'big')
        compact_data = meta_len + meta_bytes + compact_data
    
    # 添加密文标记
    encoded_data = b64(compact_data)
    return CIPHERTEXT_MARKER + encoded_data

def unpack_and_decrypt(our_x_priv, package_b64: str):
    
    try:
        # 移除密文标记（如果存在）
        if package_b64.startswith(CIPHERTEXT_MARKER):
            package_b64 = package_b64[len(CIPHERTEXT_MARKER):]
        
        data = ub64(package_b64)
        
        # 检查是否有元数据
        meta = None
        if len(data) > 2:
            meta_len = int.from_bytes(data[:2], 'big')
            if meta_len > 0 and len(data) > 2 + meta_len:
                meta_bytes = data[2:2+meta_len]
                try:
                    meta = json.loads(meta_bytes.decode())
                except Exception:
                    pass  # 忽略元数据解析错误
                data = data[2+meta_len:]
        
        # 解析紧凑格式数据
        if len(data) < 142:  # 最小长度：32+32+12+2+16+64=142
            return {'ok': False, 'error': '数据格式错误：长度不足'}
        
        sender_x_pub = data[:32]
        sender_e_pub = data[32:64]
        nonce = data[64:76]
        ct_len = int.from_bytes(data[76:78], 'big')
        
        if 78 + ct_len + 64 > len(data):
            return {'ok': False, 'error': '数据格式错误：长度不匹配'}
        
        ct = data[78:78+ct_len]
        sig = data[78+ct_len:78+ct_len+64]
        
        # 验证签名
        try:
            ed25519.Ed25519PublicKey.from_public_bytes(sender_e_pub).verify(sig, nonce + ct)
        except Exception as e:
            return {'ok': False, 'error': f'签名验证失败: {str(e)}'}
        
        # 解密
        try:
            key = derive_shared_key(our_x_priv, sender_x_pub)
            pt = ChaCha20Poly1305(key).decrypt(nonce, ct, None)
            return {'ok': True, 'data': {'plaintext': pt.decode(), 'meta': meta}}
        except Exception as e:
            return {'ok': False, 'error': str(e)}
            
    except Exception as e:
        return {'ok': False, 'error': str(e)}

def encrypt_data(data, password):
    """加密数据"""
    from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    
    # 生成盐值
    salt = secrets.token_bytes(16)
    
    # 从密码派生密钥
    key = _derive_key_from_password(password, salt)
    
    # 加密数据
    aesgcm = AESGCM(key)
    nonce = secrets.token_bytes(12)
    
    json_data = json.dumps(data, ensure_ascii=False, separators=(',', ':'))
    encrypted_data = aesgcm.encrypt(nonce, json_data.encode('utf-8'), None)
    
    # 保存格式: [salt(16)][nonce(12)][encrypted_data]
    return salt + nonce + encrypted_data

def decrypt_data(encrypted_data, password):
    """解密数据"""
    from cryptography.hazmat.primitives.ciphers.aead import AESGCM
    
    try:
        # 解析数据
        salt = encrypted_data[:16]
        nonce = encrypted_data[16:28]
        data = encrypted_data[28:]
        
        # 从密码派生密钥
        key = _derive_key_from_password(password, salt)
        
        # 解密
        aesgcm = AESGCM(key)
        decrypted_data = aesgcm.decrypt(nonce, data, None)
        
        return json.loads(decrypted_data.decode('utf-8'))
    except Exception:
        return None

def _load_encrypted_json_file(file_path: str, password: str | None = None, file_type: str = "data") -> dict:
    """通用的加密JSON文件加载函数"""
    if not os.path.exists(file_path):
        return {}
    
    try:
        # 首先尝试作为二进制文件读取（加密格式）
        with open(file_path, 'rb') as f:
            data = f.read()
        
        # 检查是否是加密格式
        if len(data) > 28 and password:  # salt(16) + nonce(12) + min_encrypted_data
            decrypted = decrypt_data(data, password)
            if decrypted is not None:
                return decrypted
        
        # 尝试明文JSON格式（兼容旧版本）
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
            
    except Exception:
        return {}

def load_contacts(password=None):
    return _load_encrypted_json_file(CONTACTS_FILE, password, "contacts")

def _save_encrypted_json_file(file_path: str, data: dict, password: str | None = None, file_type: str = "data"):
    """通用的加密JSON文件保存函数"""
    try:
        if password:
            # 加密保存
            encrypted_data = encrypt_data(data, password)
            with open(file_path, 'wb') as f:
                f.write(encrypted_data)
        else:
            # 明文保存（兼容旧格式）
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
    except Exception:
        pass

def save_contacts(data, password=None):
    _save_encrypted_json_file(CONTACTS_FILE, data, password, "contacts")

def load_users(password=None):
    return _load_encrypted_json_file(USERS_FILE, password, "users")

def save_users(data, password=None):
    _save_encrypted_json_file(USERS_FILE, data, password, "users")

def load_chats(username: str, password: str):
    """加载聊天记录（按用户加密存储）"""
    path = chat_file_path(username)
    if not os.path.exists(path):
        return {}
    try:
        with open(path, 'rb') as f:
            raw = f.read()
        data = decrypt_data(raw, password)
        if isinstance(data, dict):
            return data
        return {}
    except Exception:
        return {}

def save_chats(username: str, password: str, chats: dict):
    """保存聊天记录（按用户加密存储）"""
    try:
        raw = encrypt_data(chats, password)
        with open(chat_file_path(username), 'wb') as f:
            f.write(raw)
    except Exception:
        pass

def generate_random_password(length: int = 20) -> str:
    """生成随机密码"""
    characters = string.ascii_letters + string.digits
    return ''.join(secrets.choice(characters) for _ in range(length))

def encrypt_file_with_7z(file_path: str) -> tuple:
    """使用py7zr加密文件，返回(加密文件路径, 密码)"""
    encrypted_path = None
    try:
        # 生成20位随机密码
        password = generate_random_password(20)
        
        # 获取用户Downloads目录
        downloads_dir = os.path.join(os.path.expanduser('~'), 'Downloads')
        
        # 确保Downloads目录存在
        if not os.path.exists(downloads_dir):
            os.makedirs(downloads_dir, exist_ok=True)
        
        # 生成加密文件名（不显示原文件名）
        encrypted_filename = f"encrypted_{secrets.token_hex(8)}.7z"
        encrypted_path = os.path.join(downloads_dir, encrypted_filename)
        
        # 使用py7zr创建加密的7z文件
        with py7zr.SevenZipFile(encrypted_path, 'w', password=password) as archive:
            # 获取原始文件名
            original_filename = os.path.basename(file_path)
            archive.write(file_path, original_filename)
        
        return encrypted_path, password
        
    except Exception as e:
        # 如果生成了部分文件但失败，清理临时文件
        if encrypted_path and os.path.exists(encrypted_path):
            try:
                os.remove(encrypted_path)
            except:
                pass
        raise Exception(f"文件加密失败: {str(e)}")

def decrypt_file_with_7z(encrypted_file_path: str, password: str) -> str:
    """使用py7zr解密文件，返回解密后的文件路径"""
    try:
        # 获取用户Downloads目录
        downloads_dir = os.path.join(os.path.expanduser('~'), 'Downloads')
        
        # 确保Downloads目录存在
        if not os.path.exists(downloads_dir):
            os.makedirs(downloads_dir, exist_ok=True)
        
        # 记录解密前的文件列表
        files_before = set()
        if os.path.exists(downloads_dir):
            files_before = set(os.listdir(downloads_dir))
        
        # 使用py7zr解密文件
        try:
            with py7zr.SevenZipFile(encrypted_file_path, 'r', password=password) as archive:
                archive.extractall(path=downloads_dir)
        except Exception as archive_error:
            # Check for specific py7zr error types by examining error message
            error_str = str(archive_error).lower()
            error_type = type(archive_error).__name__
            
            if "bad 7z file" in error_str or "not a 7z file" in error_str or "Bad7zFile" in error_type:
                raise Exception("文件格式错误，不是有效的7z文件")
            elif "password" in error_str and ("required" in error_str or "PasswordRequired" in error_type):
                raise Exception("需要密码才能解密此文件")
            elif "password" in error_str or "wrong" in error_str or "bad" in error_str:
                raise Exception("密码错误或文件损坏")
            else:
                raise Exception(f"解密失败: {str(archive_error)}")
        
        # 查找解密后的新文件或目录（改进检测逻辑）
        files_after = set(os.listdir(downloads_dir))
        new_items = files_after - files_before
        
        if new_items:
            # 查找最新的文件或目录
            newest_item = None
            newest_time = 0
            
            for item in new_items:
                item_path = os.path.join(downloads_dir, item)
                try:
                    mtime = os.path.getmtime(item_path)
                    if mtime > newest_time:
                        newest_time = mtime
                        newest_item = item_path
                except OSError:
                    # 如果无法获取修改时间，跳过
                    continue
            
            if newest_item:
                return newest_item
            else:
                # 如果没有找到最新项，返回第一个新项
                first_item = list(new_items)[0]
                return os.path.join(downloads_dir, first_item)
        else:
            raise Exception("解密完成，但未检测到新文件或目录")
            
    except Exception as e:
        # 如果是py7zr异常，传递原始错误信息
        if isinstance(e, Exception) and hasattr(e, 'args') and e.args:
            raise e
        else:
            raise Exception(f"文件解密失败: {str(e)}")

class App:
    def __init__(self, root):
        self.root = root
        self.root.title('端到端加密聊天工具')
        self.root.geometry('800x600')
        
        # 初始化变量
        self.username = None
        self.password = None
        self.x_priv = None
        self.e_priv = None
        self.contacts = {}
        self.users = {}
        self.chats = {}  # { contact_name: [ {direction, plaintext, ciphertext, timestamp} ] }
        
        # 性能优化相关变量
        self.loaded_contacts = set()  # 已加载的联系人
        self.message_cache = {}       # 消息缓存
        self.is_loading = False       # 加载状态
        self.background_queue = queue.Queue()  # 后台任务队列
        self.current_displayed_messages = 0    # 当前显示的消息数
        
        # 创建界面
        self.create_widgets()
        
        # 设置样式
        style = ttk.Style()
        style.theme_use('clam')
        
        # 启动后台处理线程
        self.start_background_worker()

    def start_background_worker(self):
        """启动后台工作线程处理异步任务"""
        def background_worker():
            while True:
                try:
                    # 从队列获取任务
                    task = self.background_queue.get(timeout=1)
                    if task is None:  # 终止信号
                        break
                    
                    task_type = task.get('type')
                    if task_type == 'load_user':
                        self._background_load_user(task['username'], task['password'])
                    elif task_type == 'load_contact_chats':
                        self._background_load_contact_chats(task['contact'])
                    elif task_type == 'save_chats':
                        self._background_save_chats(task['data'])
                    
                    self.background_queue.task_done()
                except queue.Empty:
                    continue
                except Exception:
                    pass
        
        # 启动后台线程
        self.worker_thread = threading.Thread(target=background_worker, daemon=True)
        self.worker_thread.start()

    def _background_load_user(self, username, password):
        """后台加载用户数据"""
        try:
            # 在后台线程中执行耗时操作
            keys = load_keys(username, password)
            if keys:
                contacts = load_contacts(password)
                
                # 更新UI（在主线程中）
                self.root.after(0, self._finish_load_user, username, password, keys, contacts)
            else:
                self.root.after(0, lambda: messagebox.showerror('错误', '密码错误或密钥文件损坏'))
        except Exception as e:
            self.root.after(0, lambda: messagebox.showerror('错误', f'加载用户失败: {str(e)}'))
        finally:
            self.root.after(0, lambda: setattr(self, 'is_loading', False))

    def _finish_load_user(self, username, password, keys, contacts):
        """在主线程中完成用户加载"""
        self.x_priv, self.e_priv = keys
        self.username = username
        self.password = password
        self.contacts = contacts
        
        # 更新UI
        self.combo_contacts['values'] = list(self.contacts.keys())
        if self.contacts:
            self.combo_contacts.set(list(self.contacts.keys())[0])
        
        self.update_users_display()
        messagebox.showinfo('成功', f'用户 {username} 加载成功')
        
        # 清理缓存并重新加载
        clear_cache()
        self.loaded_contacts.clear()

    def _background_load_contact_chats(self, contact):
        """后台加载联系人聊天记录"""
        if not self.username or not self.password:
            return
        
        try:
            # 使用延迟加载
            chats = load_chats_lazy(self.username, self.password, contact)
            
            # 更新内存数据
            if contact in chats:
                if contact not in self.chats:
                    self.chats[contact] = []
                self.chats[contact] = chats[contact]
                self.loaded_contacts.add(contact)
            
            # 在主线程中更新UI
            self.root.after(0, self.refresh_chat_view_optimized)
            
        except Exception:
            pass

    def _background_save_chats(self, data):
        """后台保存聊天记录"""
        if not self.username or not self.password:
            return
        
        try:
            save_chats(self.username, self.password, data)
        except Exception:
            pass

    def create_widgets(self):
        """创建界面组件"""
        # 用户选择区域
        frm_user = ttk.LabelFrame(self.root, text='用户')
        frm_user.pack(fill='x', padx=8, pady=4)
        
        ttk.Label(frm_user, text='用户名:').pack(side='left', padx=4)
        self.entry_username = ttk.Entry(frm_user, width=20)
        self.entry_username.pack(side='left', padx=4)
        
        ttk.Label(frm_user, text='密码:').pack(side='left', padx=4)
        self.entry_password = ttk.Entry(frm_user, show='*', width=20)
        self.entry_password.pack(side='left', padx=4)
        self.entry_password.bind('<Return>', self.load_user)
        
        ttk.Button(frm_user, text='加载用户', command=self.load_user).pack(side='left', padx=4)
        ttk.Button(frm_user, text='新建用户', command=self.create_new_user).pack(side='left', padx=4)
        ttk.Button(frm_user, text='删除用户', command=self.delete_user).pack(side='left', padx=4)
        ttk.Button(frm_user, text='生成我的二维码', command=self.show_my_qr).pack(side='left', padx=4)
        
        # 显示已存在的用户（延迟加载，避免密码问题）
        self.users_label = ttk.Label(frm_user, text='点击"加载用户"查看已存在用户', foreground='gray')
        self.users_label.pack(side='left', padx=8)
        
        # 联系人选择区域
        frm_contact = ttk.LabelFrame(self.root, text='联系人')
        frm_contact.pack(fill='x', padx=8, pady=4)
        
        ttk.Label(frm_contact, text='选择联系人:').pack(side='left', padx=4)
        self.combo_contacts = ttk.Combobox(frm_contact, values=list(self.contacts.keys()), state='readonly')
        self.combo_contacts.pack(side='left', padx=4)
        self.combo_contacts.bind('<<ComboboxSelected>>', self.on_contact_changed)
        
        ttk.Button(frm_contact, text='添加联系人', command=self.add_contact).pack(side='left', padx=4)
        ttk.Button(frm_contact, text='删除联系人', command=self.del_contact).pack(side='left', padx=4)
        ttk.Button(frm_contact, text='扫描二维码', command=self.import_qr).pack(side='left', padx=4)
        ttk.Button(frm_contact, text='查看公钥', command=self.show_contact_key).pack(side='left', padx=4)
        
        # 聊天记录区域
        frm_chat = ttk.LabelFrame(self.root, text='聊天记录')
        frm_chat.pack(fill='both', expand=True, padx=8, pady=4)
        
        self.chat = scrolledtext.ScrolledText(frm_chat, state='disabled', width=80, height=15)
        self.chat.pack(fill='both', expand=True)

        # 消息输入区域
        frm_compose = ttk.LabelFrame(self.root, text='发送消息')
        frm_compose.pack(fill='x', padx=8, pady=4)
        
        # 输入框
        frm_input = ttk.Frame(frm_compose)
        frm_input.pack(fill='x', padx=4, pady=2)
        self.message_entry = tk.Text(frm_input, height=5, wrap='word')
        self.message_entry.pack(side='left', fill='x', expand=True, padx=(0, 4))
        # 绑定Ctrl+Enter快捷键
        self.message_entry.bind('<Control-Return>', lambda e: self.handle_chat())
        
        # 按钮区域
        frm_buttons = ttk.Frame(frm_compose)
        frm_buttons.pack(fill='x', padx=4, pady=2)
        ttk.Button(frm_buttons, text='聊天', command=self.handle_chat).pack(side='left', padx=(0, 4))
        ttk.Button(frm_buttons, text='加密文件', command=self.encrypt_file_with_7z).pack(side='left', padx=4)
        ttk.Button(frm_buttons, text='解密文件', command=self.decrypt_file_with_7z).pack(side='left', padx=4)
        ttk.Button(frm_buttons, text='清空输入', command=self.clear_inputs).pack(side='left', padx=4)

    def create_new_user(self):
        """创建新用户"""
        name = self.entry_username.get().strip()
        if not name:
            messagebox.showwarning('提示', '请输入用户名')
            return
        
        password = self.entry_password.get().strip()
        if not password:
            messagebox.showwarning('提示', '请输入密码')
            return
        
        confirm_password = simple_input(self.root, '请确认密码:')
        if password != confirm_password:
            messagebox.showerror('错误', '密码不匹配')
            return
        
        # 检查用户是否已存在
        p1, p2 = key_paths(name)
        if os.path.exists(p1):
            messagebox.showerror('错误', '用户已存在，请使用"加载用户"功能')
            return
        
        # 生成密钥
        try:
            self.x_priv, self.e_priv = generate_and_save(name, password)
            self.username = name
            self.password = password
            
            # 初始化加密的联系人数据
            self.contacts = {}
            save_contacts(self.contacts, password)
            
            # 保存用户信息
            self.users[name] = {
                'created': str(datetime.datetime.now()),
                'has_keys': True
            }
            save_users(self.users, password)
            
            # 更新UI
            self.combo_contacts['values'] = list(self.contacts.keys())
            self.update_users_display()
            
            messagebox.showinfo('成功', f'用户 {name} 创建成功')
        except Exception as e:
            messagebox.showerror('错误', f'创建用户失败: {str(e)}')

    def load_user(self, event=None):
        """加载用户"""
        name = self.entry_username.get().strip()
        if not name:
            messagebox.showwarning('提示', '请输入用户名')
            return
        
        password = self.entry_password.get().strip()
        if not password:
            messagebox.showwarning('提示', '请输入密码')
            return
        
        try:
            # 首先尝试加载用户列表
            self.users = load_users(password)
            
            # 检查用户是否存在
            p1, p2 = key_paths(name)
            if not os.path.exists(p1):
                messagebox.showerror('错误', f'用户 {name} 不存在，请先创建用户')
                return
            
            # 加载密钥
            keys = load_keys(name, password)
            if not keys:
                messagebox.showerror('错误', '密码错误或密钥文件损坏')
                return
            
            self.x_priv, self.e_priv = keys
            self.username = name
            self.password = password
            
            # 加载加密的联系人数据
            try:
                self.contacts = load_contacts(password)
            except Exception:
                self.contacts = {}

            # 加载该用户的聊天记录
            try:
                self.chats = load_chats(self.username, self.password)
            except Exception:
                self.chats = {}
            
            # 更新联系人UI
            self.combo_contacts['values'] = list(self.contacts.keys())
            if self.contacts:
                self.combo_contacts.set(list(self.contacts.keys())[0])
                # 切换后刷新聊天区
                self.refresh_chat_view()
            
            # 更新用户信息
            if name not in self.users:
                self.users[name] = {
                    'created': str(datetime.datetime.now()),
                    'has_keys': True
                }
                save_users(self.users, password)
            
            # 更新用户显示
            self.update_users_display()
            
            messagebox.showinfo('成功', f'用户 {name} 加载成功')
            
        except Exception as e:
            messagebox.showerror('错误', f'加载用户失败: {str(e)}')

    def update_users_display(self):
        """更新用户显示"""
        if self.users:
            users_text = ', '.join(list(self.users.keys())[:5])  # 显示前5个用户
            if len(self.users) > 5:
                users_text += f'... (共{len(self.users)}个)'
            self.users_label.config(text=f'已存在用户: {users_text}')
        else:
            self.users_label.config(text='暂无用户')

    def delete_user(self):
        """删除用户"""
        name = self.entry_username.get().strip()
        if not name:
            messagebox.showwarning('提示', '请输入要删除的用户名')
            return
        
        # 要求输入密码确认
        password = simple_input(self.root, '请输入密码确认删除:')
        if not password:
            return
        
        # 验证密码
        try:
            keys = load_keys(name, password)
            if not keys:
                messagebox.showerror('错误', '密码错误，无法删除用户')
                return
        except Exception:
            messagebox.showerror('错误', '密码验证失败')
            return
        
        if not messagebox.askyesno('确认', f'确定要删除用户 {name} 吗？\n这将删除所有密钥、联系人信息、聊天记录和二维码文件！'):
            return
        
        try:
            # 删除密钥文件
            p1, p2 = key_paths(name)
            if os.path.exists(p1):
                os.remove(p1)
            if os.path.exists(p2):
                os.remove(p2)
            
            # 删除聊天记录文件
            chat_file = chat_file_path(name)
            if os.path.exists(chat_file):
                os.remove(chat_file)
            
            # 删除二维码文件
            qr_file = f"{name}_qr.png"
            if os.path.exists(qr_file):
                os.remove(qr_file)
            
            # 删除联系人二维码文件（如果存在）
            for contact_name in list(self.contacts.keys()):
                contact_qr_file = f"{contact_name}_contact_qr.png"
                if os.path.exists(contact_qr_file):
                    os.remove(contact_qr_file)
            
            # 删除用户信息
            if name in self.users:
                del self.users[name]
                if self.password:
                    save_users(self.users, self.password)
            
            # 删除联系人信息
            if name in self.contacts:
                del self.contacts[name]
                if self.password:
                    save_contacts(self.contacts, self.password)
            
            # 如果删除的是当前用户，清理当前状态
            if self.username == name:
                self.username = None
                self.x_priv = None
                self.e_priv = None
                self.password = None
                self.contacts = {}
                self.chats = {}
                self.entry_username.delete(0, 'end')
                self.entry_password.delete(0, 'end')
                self.combo_contacts['values'] = []
                self.combo_contacts.set('')
                self.chat['state'] = 'normal'
                self.chat.delete('1.0', 'end')
                self.chat['state'] = 'disabled'
            
            # 检查是否还有其他用户，如果没有则删除全局文件
            remaining_users = load_users(password)
            if not remaining_users:
                # 删除全局文件
                if os.path.exists(USERS_FILE):
                    os.remove(USERS_FILE)
                if os.path.exists(CONTACTS_FILE):
                    os.remove(CONTACTS_FILE)
                self.users = {}
                self.contacts = {}
            
            self.update_users_display()
            messagebox.showinfo('成功', f'用户 {name} 已删除')
        except Exception as e:
            messagebox.showerror('错误', f'删除用户失败: {str(e)}')

    def migrate_old_data(self, old_contacts, old_users):
        """迁移旧版本数据到加密格式"""
        try:
            # 创建默认用户来存储旧数据
            default_password = "default_password_123"
            default_user = "migrated_user"
            
            # 保存用户信息
            self.users[default_user] = {
                'created': str(datetime.datetime.now()),
                'has_keys': False,
                'migrated': True
            }
            save_users(self.users, default_password)
            
            # 保存联系人信息
            if old_contacts:
                save_contacts(old_contacts, default_password)
            
            # 删除旧文件
            if os.path.exists(CONTACTS_FILE):
                os.remove(CONTACTS_FILE)
            if os.path.exists(USERS_FILE):
                os.remove(USERS_FILE)
            
            # 更新UI
            self.update_users_display()
            
            messagebox.showinfo('迁移完成', f'数据已迁移到用户: {default_user}\n密码: {default_password}\n请及时修改密码！')
            
        except Exception as e:
            messagebox.showerror('迁移失败', f'数据迁移失败: {str(e)}')

    def show_my_qr(self):
        """显示我的二维码"""
        if not self.username or not self.x_priv or not self.e_priv:
            messagebox.showwarning('提示', '请先加载用户')
            return
        
        try:
            # 生成二维码
            qr_data = {
                'name': self.username,
                'key': b64(self.x_priv.public_key().public_bytes(serialization.Encoding.Raw, serialization.PublicFormat.Raw))
            }
            qr_json = json.dumps(qr_data, ensure_ascii=False)
            
            # 保存二维码
            path = f"{self.username}_qr.png"
            qr = qrcode.QRCode(version=1, box_size=10, border=5)
            qr.add_data(qr_json)
            qr.make(fit=True)
            img = qr.make_image(fill_color="black", back_color="white")
            with open(path, 'wb') as f:
                img.save(f, 'PNG')
            
            # 复制二维码到剪贴板
            self.copy_image_to_clipboard(img)
            
            # 显示二维码
            messagebox.showinfo('成功', f'已生成 {self.username} 的二维码: {path}\n二维码已复制到剪贴板！')
        except Exception as e:
            messagebox.showerror('错误', f'生成二维码失败: {str(e)}')

    def add_contact(self):
        """添加联系人"""
        if not self.username or not self.password:
            messagebox.showwarning('提示', '请先加载用户')
            return
            
        name = simple_input(self.root, '请输入联系人名称:')
        if not name:
            return
        
        if name in self.contacts:
            messagebox.showerror('错误', '联系人已存在')
            return
        
        key = simple_input(self.root, '请输入联系人公钥:')
        if not key:
            return
        
        try:
            # 验证公钥格式
            ub64(key)
            self.contacts[name] = key
            save_contacts(self.contacts, self.password)
            self.combo_contacts['values'] = list(self.contacts.keys())
            self.combo_contacts.set(name)
            messagebox.showinfo('成功', f'联系人 {name} 添加成功')
        except Exception as e:
            messagebox.showerror('错误', f'添加联系人失败: {str(e)}')

    def del_contact(self):
        """删除联系人"""
        if not self.username or not self.password:
            messagebox.showwarning('提示', '请先加载用户')
            return
            
        if not self.combo_contacts.get():
            messagebox.showwarning('提示', '请选择要删除的联系人')
            return
        
        contact_name = self.combo_contacts.get()
        if not messagebox.askyesno('确认', f'确定要删除联系人 {contact_name} 吗？'):
            return
        
        try:
            del self.contacts[contact_name]
            save_contacts(self.contacts, self.password)
            self.combo_contacts['values'] = list(self.contacts.keys())
            self.combo_contacts.set('')
            messagebox.showinfo('成功', f'联系人 {contact_name} 删除成功')
        except Exception as e:
            messagebox.showerror('错误', f'删除联系人失败: {str(e)}')

    def import_qr(self):
        """导入二维码"""
        if not self.username or not self.password:
            messagebox.showwarning('提示', '请先加载用户')
            return
            
        try:
            path = filedialog.askopenfilename(title='选择二维码图片', filetypes=[('图片文件', '*.png *.jpg *.jpeg'), ('所有文件', '*.*')])
            if not path:
                return
            
            # 使用OpenCV解码二维码
            qr_text = decode_qr_with_opencv(path)
            
            # 解析JSON
            try:
                qr_data = json.loads(qr_text)
                name = qr_data.get('name')
                key = qr_data.get('key')
                
                if name and key:
                    self.contacts[name] = key
                    save_contacts(self.contacts, self.password)
                    self.combo_contacts['values'] = list(self.contacts.keys())
                    messagebox.showinfo('成功', f'已导入联系人 {name}')
                else:
                    messagebox.showerror('错误', '二维码格式不正确')
            except json.JSONDecodeError:
                messagebox.showerror('错误', '二维码格式不正确')
                
        except Exception as e:
            messagebox.showerror('错误', f'导入二维码失败: {str(e)}')

    def show_contact_key(self):
        """显示联系人公钥"""
        if not self.username or not self.password:
            messagebox.showwarning('提示', '请先加载用户')
            return
            
        if not self.combo_contacts.get():
            messagebox.showwarning('提示', '请选择联系人')
            return
        
        contact_name = self.combo_contacts.get()
        key = self.contacts[contact_name]
        
        # 创建新窗口显示公钥
        top = tk.Toplevel(self.root)
        top.title(f'{contact_name} 的公钥')
        top.geometry('600x200')
        
        # 计算居中位置
        x = self.root.winfo_x() + (self.root.winfo_width() - 600) // 2
        y = self.root.winfo_y() + (self.root.winfo_height() - 200) // 2
        top.geometry(f'600x200+{x}+{y}')
        
        # 设置窗口属性
        top.transient(self.root)
        top.grab_set()
        
        ttk.Label(top, text=f'{contact_name} 的公钥:').pack(pady=10)
        text_widget = scrolledtext.ScrolledText(top, height=8, width=70)
        text_widget.pack(padx=10, pady=5)
        text_widget.insert('1.0', key)
        text_widget['state'] = 'disabled'
        
        ttk.Button(top, text='复制公钥', command=lambda: self.copy_to_clipboard(key)).pack(pady=5)
        ttk.Button(top, text='关闭', command=top.destroy).pack(pady=5)

    def generate_contact_qr(self, name, key_b64):
        contact_info = {
            'name': name,
            'public_key': key_b64
        }
        qr_data = json.dumps(contact_info, separators=(',', ':'))
        img = qrcode.make(qr_data)
        path = f'{name}_contact_qr.png'
        with open(path, 'wb') as f:
            img.save(f, 'PNG')
        
        # 复制二维码到剪贴板
        self.copy_image_to_clipboard(img)
        
        os.startfile(path)
        messagebox.showinfo('成功', f'已生成 {name} 的二维码: {path}\n二维码已复制到剪贴板！')

    def handle_chat(self):
        """智能聊天处理：自动识别内容类型并处理"""
        if not self.username or not self.x_priv:
            messagebox.showwarning('提示', '请先加载用户')
            return
            
        content = self.message_entry.get('1.0', 'end-1c').strip()
        if not content:
            messagebox.showwarning('提示', '请输入内容')
            return
        
        # 自动检测内容类型
        if is_ciphertext(content):
            # 处理密文（解密）
            self._handle_ciphertext_content(content)
        else:
            # 处理明文（加密）
            self._handle_plaintext_content(content)
    
    def _handle_plaintext_content(self, plaintext):
        """处理明文内容（加密）"""
        if not self.combo_contacts.get():
            messagebox.showwarning('提示', '请选择联系人')
            return
        
        try:
            rec_key = self.contacts[self.combo_contacts.get()]
            pkg = encrypt_and_package(self.x_priv, self.e_priv, ub64(rec_key), plaintext.encode(), meta={'from': self.username})
            
            # 显示消息（明文在上，密文在下）
            self.append_chat_with_copy(f'ME -> {self.combo_contacts.get()}:', plaintext, pkg)
            
            # 清空输入框
            self.clear_inputs()
            
        except Exception as e:
            messagebox.showerror('错误', f'加密发送失败: {str(e)}')
    
    def _handle_ciphertext_content(self, ciphertext):
        """处理密文内容（解密）"""
        try:
            # 执行解密操作
            res = unpack_and_decrypt(self.x_priv, ciphertext)
            
            if res['ok']:
                plaintext = res['data']['plaintext']
                # 获取发送者信息
                sender = res['data']['meta'].get('from', 'Unknown') if res['data'].get('meta') else 'Unknown'
                
                # 显示接收到的消息
                self.append_chat_with_copy(f'{sender} -> ME:', plaintext, ciphertext)
                self.clear_inputs()
            else:
                error_msg = res.get('error', '未知错误')
                messagebox.showerror('解密失败', error_msg)
        except Exception as e:
            import traceback
            traceback.print_exc()
            messagebox.showerror('错误', f'解密失败: {str(e)}')

    def handle_plaintext(self):
        """处理明文输入"""
        if not self.username or not self.x_priv:
            messagebox.showwarning('提示', '请先加载用户')
            return
            
        plaintext = self.message_entry.get('1.0', 'end-1c').strip()
        if not plaintext:
            messagebox.showwarning('提示', '请输入明文')
            return
        
        if not self.combo_contacts.get():
            messagebox.showwarning('提示', '请选择联系人')
            return
        
        try:
            rec_key = self.contacts[self.combo_contacts.get()]
            pkg = encrypt_and_package(self.x_priv, self.e_priv, ub64(rec_key), plaintext.encode(), meta={'from': self.username})
            
            # 显示消息（明文在上，密文在下）
            self.append_chat_with_copy(f'ME -> {self.combo_contacts.get()}:', plaintext, pkg)
            
            # 清空输入框
            self.clear_inputs()
            
            # messagebox.showinfo('成功', '消息发送成功！')
        except Exception as e:
            messagebox.showerror('错误', f'发送失败: {str(e)}')

    def handle_ciphertext(self):
        """处理密文输入"""
        if not self.username or not self.x_priv:
            messagebox.showwarning('提示', '请先加载用户')
            return
            
        ciphertext = self.message_entry.get('1.0', 'end-1c').strip()
        if not ciphertext:
            messagebox.showwarning('提示', '请输入密文')
            return
        
        print(f"开始解密，密文长度: {len(ciphertext)} 字符")
        print(f"密文前50字符: {ciphertext[:50]}")
        
        try:
            # 执行解密操作
            res = unpack_and_decrypt(self.x_priv, ciphertext)
            print(f"解密结果: {res}")
            
            if res['ok']:
                plaintext = res['data']['plaintext']
                # 获取发送者信息
                sender = res['data']['meta'].get('from', 'Unknown') if res['data'].get('meta') else 'Unknown'
                
                # 显示接收到的消息
                self.append_chat_with_copy(f'{sender} -> ME:', plaintext, ciphertext)
                self.clear_inputs()
                # messagebox.showinfo('成功', '消息接收成功！')
            else:
                error_msg = res.get('error', '未知错误')
                print(f"解密失败: {error_msg}")
                messagebox.showerror('失败', error_msg)
        except Exception as e:
            print(f"解密异常: {str(e)}")
            import traceback
            traceback.print_exc()
            messagebox.showerror('错误', str(e))

    def append_chat_with_copy(self, header, plaintext, ciphertext):
        """添加带复制按钮的聊天记录（使用tk.Message显示，突出明文）"""
        self.chat['state'] = 'normal'
        
        # 添加时间戳
        timestamp = datetime.datetime.now().strftime('%H:%M:%S')
        self.chat.insert('end', f'[{timestamp}] {header}\n')
        
        # 创建消息容器框架
        message_frame = tk.Frame(self.chat, bg='white', relief='solid', bd=1)
        
        # 判断消息方向来设置样式
        is_outgoing = header.startswith('ME ->')
        if is_outgoing:
            # 发送消息样式（蓝色背景）
            bg_color = '#4A90E2'
            fg_color = 'white'
            message_frame.configure(bg=bg_color)
        else:
            # 接收消息样式（浅灰背景）
            bg_color = '#F5F5F5'
            fg_color = 'black'
            message_frame.configure(bg=bg_color)
        
        # 使用tk.Label显示明文（突出显示，全宽度，真正左对齐，自动换行）
        plaintext_msg = tk.Label(
            message_frame,
            text=f"{plaintext}",
            bg=bg_color,
            fg=fg_color,
            font=('Arial', 11, 'bold'),  # 加粗突出明文
            relief='flat',
            justify='left',  # 文本左对齐
            anchor='w',  # 标签内容左对齐
            wraplength=600  # 设置固定宽度进行换行
        )
        plaintext_msg.pack(fill='x', padx=8, pady=5, anchor='nw')  # 包装左上对齐
        
        # 密文显示框架
        cipher_frame = tk.Frame(message_frame, bg=bg_color)
        cipher_frame.pack(fill='x', padx=8, pady=2)
        
        # 密文缩略显示（全宽度，真正左对齐，自动换行）
        cipher_preview = ciphertext[:50] + '...' if len(ciphertext) > 50 else ciphertext
        cipher_msg = tk.Label(
            cipher_frame,
            text=f"🔒 {cipher_preview}",
            bg=bg_color,
            fg=fg_color if is_outgoing else '#666666',
            font=('Arial', 9),
            relief='flat',
            justify='left',  # 文本左对齐
            anchor='w',  # 标签内容左对齐
            wraplength=450  # 设置较小宽度留空间给复制按钮
        )
        cipher_msg.pack(side='left', fill='x', expand=True, anchor='nw')  # 包装左上对齐
        
        # 复制按钮
        copy_button = tk.Button(
            cipher_frame,
            text='📋',
            command=lambda: self.copy_to_clipboard_with_notification(ciphertext),
            font=('Arial', 8, 'normal'),
            relief='raised',
            bg='#28a745' if is_outgoing else '#4A90E2',
            fg='white',
            bd=1,
            padx=2,
            pady=2,
            cursor='hand2'
        )
        copy_button.pack(side='right', padx=5)
        
        # 将消息框架嵌入到聊天区域（全宽度）
        self.chat.window_create('end', window=message_frame, stretch=True)  # stretch=True让窗口拉伸
        self.chat.insert('end', '\n\n')  # 消息间距
        
        self.chat['state'] = 'disabled'
        self.chat.see('end')

        # 追加到内存聊天记录（优化版）
        contact = None
        direction = 'unknown'
        
        if '->' in header:
            try:
                if header.startswith('ME -> '):
                    contact = header.split('ME -> ')[1].rstrip(':')
                    direction = 'out'
                elif header.endswith(' -> ME:'):
                    contact = header.split(' -> ME:')[0]
                    direction = 'in'
            except Exception:
                pass

        if self.username and self.password and contact:
            if contact not in self.chats:
                self.chats[contact] = []
            
            # 添加新消息
            new_message = {
                'direction': direction,
                'plaintext': plaintext,
                'ciphertext': ciphertext,
                'timestamp': datetime.datetime.now().isoformat(timespec='seconds')
            }
            self.chats[contact].append(new_message)
            
            # 确保该联系人已加载
            self.loaded_contacts.add(contact)
            
            # 异步保存（避免阻塞UI）
            task = {
                'type': 'save_chats',
                'data': self.chats.copy()
            }
            self.background_queue.put(task)

    def refresh_chat_view_optimized(self):
        """优化的聊天记录刷新（分页加载）"""
        self.chat['state'] = 'normal'
        contact = self.combo_contacts.get()
        if not contact:
            self.chat.delete('1.0', 'end')
            self.chat['state'] = 'disabled'
            return
        
        # 如果该联系人的数据未加载，异步加载
        if contact not in self.loaded_contacts:
            self.chat.delete('1.0', 'end')
            self.chat.insert('1.0', f'正在加载 {contact} 的聊天记录...')
            self.chat['state'] = 'disabled'
            
            # 异步加载联系人数据
            task = {
                'type': 'load_contact_chats',
                'contact': contact
            }
            self.background_queue.put(task)
            return
        
        # 显示已加载的数据（分页显示）
        history = self.chats.get(contact, [])
        
        # 只显示最近的N条消息
        recent_history = history[-MAX_INITIAL_MESSAGES:] if len(history) > MAX_INITIAL_MESSAGES else history
        
        self.chat.delete('1.0', 'end')
        
        # 如果有更多历史记录，显示加载更多的按钮
        if len(history) > MAX_INITIAL_MESSAGES:
            load_more_btn = tk.Button(
                self.chat,
                text=f'↑ 加载更多 ({len(history) - MAX_INITIAL_MESSAGES} 条更早的消息)',
                command=lambda: self.load_more_messages(contact),
                relief='flat',
                bg='#e8e8e8',
                cursor='hand2'
            )
            self.chat.window_create('1.0', window=load_more_btn)
            self.chat.insert('end', '\n\n')
        
        # 渲染消息（优化版）
        for item in recent_history:
            self.render_message_optimized(item, contact)
        
        self.chat['state'] = 'disabled'
        self.chat.see('end')
        self.current_displayed_messages = len(recent_history)

    def render_message_optimized(self, item, contact):
        """优化的消息渲染（使用tk.Message显示）"""
        # 判断消息方向
        if item['direction'] == 'out':
            header = f"ME -> {contact}:"
        elif item['direction'] == 'in':
            header = f"{contact} -> ME:"
        else:
            header = f"{contact}:"
        
        # 渲染时间戳
        timestamp = item.get('timestamp', '')
        self.chat.insert('end', f"[{timestamp}] {header}\n")
        
        # 创建消息容器框架
        message_frame = tk.Frame(self.chat, bg='white', relief='solid', bd=1)
        
        # 判断消息方向来设置样式
        is_outgoing = item['direction'] == 'out'
        if is_outgoing:
            # 发送消息样式（蓝色背景）
            bg_color = '#4A90E2'
            fg_color = 'white'
            message_frame.configure(bg=bg_color)
        else:
            # 接收消息样式（浅灰背景）
            bg_color = '#F5F5F5'
            fg_color = 'black'
            message_frame.configure(bg=bg_color)
        
        # 使用tk.Label显示明文（突出显示，全宽度，真正左对齐，自动换行）
        plaintext_msg = tk.Label(
            message_frame,
            text=f"{item['plaintext']}",
            bg=bg_color,
            fg=fg_color,
            font=('Arial', 11, 'bold'),  # 加粗突出明文
            relief='flat',
            justify='left',  # 文本左对齐
            anchor='w',  # 标签内容左对齐
            wraplength=600  # 设置固定宽度进行换行
        )
        plaintext_msg.pack(fill='x', padx=8, pady=5, anchor='nw')  # 包装左上对齐
        
        # 密文显示框架
        cipher_frame = tk.Frame(message_frame, bg=bg_color)
        cipher_frame.pack(fill='x', padx=8, pady=2)
        
        # 密文缩略显示（全宽度，真正左对齐）
        cipher_preview = item['ciphertext'][:50] + '...' if len(item['ciphertext']) > 50 else item['ciphertext']
        cipher_msg = tk.Label(
            cipher_frame,
            text=f"🔒 {cipher_preview}",
            bg=bg_color,
            fg=fg_color if is_outgoing else '#666666',
            font=('Arial', 9),
            relief='flat',
            justify='left',  # 文本左对齐
            anchor='w',  # 标签内容左对齐
            wraplength=0  # 自动换行
        )
        cipher_msg.pack(side='left', fill='x', expand=True, anchor='nw')  # 包装左上对齐
        
        # 复制按钮
        copy_button = tk.Button(
            cipher_frame,
            text='📋',
            command=lambda c=item['ciphertext']: self.copy_to_clipboard_with_notification(c),
            font=('Arial', 8, 'normal'),
            relief='raised',
            bg='#28a745' if is_outgoing else '#4A90E2',
            fg='white',
            bd=1,
            padx=2,
            pady=2,
            cursor='hand2'
        )
        copy_button.pack(side='right', padx=5)
        
        # 将消息框架嵌入到聊天区域
        self.chat.window_create('end', window=message_frame)
        self.chat.insert('end', '\n\n')  # 消息间距

    def load_more_messages(self, contact):
        """加载更多历史消息"""
        if contact not in self.chats:
            return
        
        history = self.chats[contact]
        if len(history) <= self.current_displayed_messages:
            return
        
        # 计算需要加载的消息数量
        remaining = len(history) - self.current_displayed_messages
        load_count = min(remaining, MAX_INITIAL_MESSAGES)
        
        # 获取需要加载的消息
        start_index = len(history) - self.current_displayed_messages - load_count
        end_index = len(history) - self.current_displayed_messages
        messages_to_load = history[start_index:end_index]
        
        # 在当前内容顶部插入新消息
        self.chat['state'] = 'normal'
        
        # 保存当前内容
        current_content = self.chat.get('1.0', 'end')
        
        # 清空并重新渲染
        self.chat.delete('1.0', 'end')
        
        # 添加新的消息
        for item in messages_to_load:
            self.render_message_optimized(item, contact)
        
        # 添加分隔线
        self.chat.insert('end', '=' * 50 + ' 以上是更早的消息 ' + '=' * 50 + '\n\n')
        
        # 添加原有内容
        self.chat.insert('end', current_content)
        
        self.chat['state'] = 'disabled'
        self.current_displayed_messages += load_count

    def refresh_chat_view(self):
        """刷新聊天记录显示"""
        self.refresh_chat_view_optimized()

    def on_contact_changed(self, event=None):
        """联系人切换事件（优化版）"""
        self.refresh_chat_view_optimized()

    def copy_to_clipboard(self, text):
        """复制文本到剪贴板"""
        self.root.clipboard_clear()
        self.root.clipboard_append(text)
        # 不显示弹窗，让用户体验更流畅
    
    def copy_to_clipboard_with_notification(self, text):
        """复制文本到剪贴板并显示成功通知"""
        self.root.clipboard_clear()
        self.root.clipboard_append(text)
        self.show_copy_success_notification()
    
    def show_copy_success_notification(self):
        """显示复制成功的弹窗通知"""
        # 创建弹窗
        notification = tk.Toplevel(self.root)
        notification.title('复制成功')
        notification.geometry('200x80')
        notification.resizable(False, False)
        
        # 计算居中位置
        x = self.root.winfo_x() + self.root.winfo_width() // 2 - 100
        y = self.root.winfo_y() + self.root.winfo_height() // 2 - 40
        notification.geometry(f'200x80+{x}+{y}')
        
        # 设置窗口属性
        notification.transient(self.root)
        notification.configure(bg='#E8F5E8')
        
        # 添加成功图标和文字
        success_frame = tk.Frame(notification, bg='#E8F5E8')
        success_frame.pack(expand=True, fill='both', padx=10, pady=10)
        
        success_label = tk.Label(
            success_frame,
            text='✅ 密文复制成功！',
            font=('Arial', 12, 'bold'),
            bg='#E8F5E8',
            fg='#2E8B57'
        )
        success_label.pack(expand=True)
        
        # 自动关闭弹窗
        notification.after(1500, notification.destroy)

    def copy_image_to_clipboard(self, img):
        """复制PIL图像到剪贴板"""
        try:
            import io
            import subprocess
            import sys
            
            # 尝试使用win32clipboard（Windows上最佳选择）
            try:
                import win32clipboard
                
                # 将PIL图像转换为BMP格式的字节数据
                output = io.BytesIO()
                img.save(output, format='BMP')
                data = output.getvalue()[14:]  # BMP文件头是14字节，剪贴板不需要
                output.close()
                
                # 打开剪贴板并复制图像
                win32clipboard.OpenClipboard()
                win32clipboard.EmptyClipboard()
                win32clipboard.SetClipboardData(win32clipboard.CF_DIB, data)
                win32clipboard.CloseClipboard()
                
                print("二维码已复制到剪贴板（使用win32clipboard）")
                return True
                
            except ImportError:
                print("win32clipboard不可用，尝试其他方法")
                
                # 方法2：尝试使用tkinter的内置clipboard（仅支持文本）
                try:
                    # 保存临时文件路径到剪贴板
                    temp_path = "temp_qr.png"
                    img.save(temp_path, 'PNG')
                    file_path = os.path.abspath(temp_path)
                    self.root.clipboard_clear()
                    self.root.clipboard_append(file_path)
                    print(f"二维码文件路径已复制到剪贴板: {file_path}")
                    messagebox.showinfo('提示', 
                        f'二维码已保存为临时文件\n'
                        f'文件路径已复制到剪贴板: {file_path}\n\n'
                        f'建议安装 pywin32 包以获得更好的剪贴板支持:\n'
                        f'pip install pywin32')
                    return True
                except Exception as e:
                    print(f"使用tkinter剪贴板失败: {e}")
                
                # 方法3：如果是Windows系统，尝试使用PowerShell
                if sys.platform == "win32":
                    try:
                        temp_path = "temp_qr.png"
                        img.save(temp_path, 'PNG')
                        
                        # 使用PowerShell复制图像到剪贴板
                        ps_script = f'''
                        Add-Type -AssemblyName System.Windows.Forms
                        $img = [System.Drawing.Image]::FromFile("{os.path.abspath(temp_path)}")
                        [System.Windows.Forms.Clipboard]::SetImage($img)
                        $img.Dispose()
                        '''
                        
                        result = subprocess.run(
                            ["powershell", "-Command", ps_script], 
                            capture_output=True, 
                            text=True, 
                            timeout=10
                        )
                        
                        if result.returncode == 0:
                            print("二维码已复制到剪贴板（使用PowerShell）")
                            return True
                        else:
                            print(f"PowerShell复制失败: {result.stderr}")
                            
                    except Exception as e:
                        print(f"PowerShell方法失败: {e}")
                
                # 最后的fallback：只提示用户手动复制
                print("所有剪贴板方法都失败，提示用户手动复制")
                messagebox.showinfo('提示', 
                    '无法直接复制图像到剪贴板。\n\n'
                    '解决方案：\n'
                    '1. 安装 pywin32 包：pip install pywin32\n'
                    '2. 或者从生成的PNG文件中手动复制二维码图片')
                return False
                
        except Exception as e:
            print(f"复制图像到剪贴板失败: {e}")
            messagebox.showinfo('提示', 
                f'复制图像到剪贴板时发生错误: {str(e)}\n\n'
                f'请从生成的文件中手动复制二维码图片。')
            return False

    def clear_inputs(self):
        """清空输入框"""
        self.message_entry.delete('1.0', 'end')
    
    def encrypt_file_with_7z(self):
        """使用7z加密文件（带进度指示）"""
        # 选择文件
        file_path = filedialog.askopenfilename(
            title='选择要加密的文件',
            filetypes=[('所有文件', '*.*')]
        )
        
        if not file_path:
            return
        
        # 检查文件大小
        try:
            file_size = os.path.getsize(file_path)
            size_mb = file_size / (1024 * 1024)
            
            # 如果文件大于10MB，显示进度条
            if size_mb > 10:
                self._encrypt_file_with_progress(file_path, file_size)
            else:
                self._encrypt_file_directly(file_path)
        except Exception as e:
            messagebox.showerror('错误', f'无法读取文件信息: {str(e)}')
    
    def _encrypt_file_directly(self, file_path):
        """直接加密文件（小文件）"""
        try:
            # 使用7z加密文件
            encrypted_path, password = encrypt_file_with_7z(file_path)
            
            # 在输入框显示密码
            self.message_entry.delete('1.0', 'end')
            self.message_entry.insert('1.0', f'解压密码是 {password}')
            
            # 打开Downloads文件夹并聚焦到加密文件
            subprocess.Popen(['explorer', '/select,', encrypted_path])
            
            messagebox.showinfo('成功', f'文件加密成功！\n\n加密文件: {os.path.basename(encrypted_path)}\n保存位置: Downloads文件夹\n解压密码: {password}\n\n密码已显示在输入框中。')
            
        except Exception as e:
            messagebox.showerror('错误', f'文件加密失败: {str(e)}')
    
    def _encrypt_file_with_progress(self, file_path, file_size):
        """带进度条的文件加密（大文件）"""
        # 创建进度对话框
        progress_window = tk.Toplevel(self.root)
        progress_window.title('加密进度')
        progress_window.geometry('400x150')
        progress_window.resizable(False, False)
        
        # 居中显示
        x = self.root.winfo_x() + (self.root.winfo_width() - 400) // 2
        y = self.root.winfo_y() + (self.root.winfo_height() - 150) // 2
        progress_window.geometry(f'400x150+{x}+{y}')
        
        progress_window.transient(self.root)
        progress_window.grab_set()
        
        # 进度标签
        progress_label = tk.Label(progress_window, text=f'正在加密文件: {os.path.basename(file_path)}')
        progress_label.pack(pady=10)
        
        # 进度条
        progress_var = tk.DoubleVar()
        progress_bar = ttk.Progressbar(progress_window, variable=progress_var, maximum=100)
        progress_bar.pack(pady=10, padx=20, fill='x')
        
        # 状态标签
        status_label = tk.Label(progress_window, text='准备中...')
        status_label.pack(pady=5)
        
        # 取消按钮
        cancel_flag = {'cancelled': False}
        def cancel_operation():
            cancel_flag['cancelled'] = True
            progress_window.destroy()
        
        cancel_button = ttk.Button(progress_window, text='取消', command=cancel_operation)
        cancel_button.pack(pady=10)
        
        # 在后台线程中执行加密
        def encrypt_thread():
            try:
                if cancel_flag['cancelled']:
                    return
                
                # 更新状态
                self.root.after(0, lambda: status_label.config(text='正在加密...'))
                self.root.after(0, lambda: progress_var.set(20))
                
                # 执行加密
                encrypted_path, password = encrypt_file_with_7z(file_path)
                
                if cancel_flag['cancelled']:
                    # 清理临时文件
                    try:
                        if os.path.exists(encrypted_path):
                            os.remove(encrypted_path)
                    except:
                        pass
                    return
                
                # 加密完成
                self.root.after(0, lambda: progress_var.set(100))
                self.root.after(0, lambda: status_label.config(text='加密完成！'))
                
                # 在主线程中更新UI
                def finish_encryption():
                    try:
                        progress_window.destroy()
                        
                        # 在输入框显示密码
                        self.message_entry.delete('1.0', 'end')
                        self.message_entry.insert('1.0', f'解压密码是 {password}')
                        
                        # 打开Downloads文件夹并聚焦到加密文件
                        subprocess.Popen(['explorer', '/select,', encrypted_path])
                        
                        messagebox.showinfo('成功', f'文件加密成功！\n\n加密文件: {os.path.basename(encrypted_path)}\n保存位置: Downloads文件夹\n解压密码: {password}\n\n密码已显示在输入框中。')
                    except Exception as e:
                        messagebox.showerror('错误', f'完成加密后处理失败: {str(e)}')
                
                self.root.after(0, finish_encryption)
                
            except Exception as e:
                # 错误处理
                def show_error():
                    try:
                        progress_window.destroy()
                    except:
                        pass
                    messagebox.showerror('错误', f'文件加密失败: {str(e)}')
                
                self.root.after(0, show_error)
        
        # 启动加密线程
        encrypt_thread_obj = threading.Thread(target=encrypt_thread, daemon=True)
        encrypt_thread_obj.start()
    
    def decrypt_file_with_7z(self):
        """使用7z解密文件（带进度指示）"""
        # 选择加密文件
        file_path = filedialog.askopenfilename(
            title='选择要解密的文件',
            filetypes=[('7-Zip文件', '*.7z'), ('所有文件', '*.*')]
        )
        
        if not file_path:
            return
        
        # 提示输入密码
        password = simple_input(self.root, '请输入解密密码:')
        if not password:
            return
        
        # 检查文件大小
        try:
            file_size = os.path.getsize(file_path)
            size_mb = file_size / (1024 * 1024)
            
            # 如果文件大于5MB，显示进度条
            if size_mb > 5:
                self._decrypt_file_with_progress(file_path, password, file_size)
            else:
                self._decrypt_file_directly(file_path, password)
        except Exception as e:
            messagebox.showerror('错误', f'无法读取文件信息: {str(e)}')
    
    def _decrypt_file_directly(self, file_path, password):
        """直接解密文件（小文件）"""
        try:
            # 使用7z解密文件
            decrypted_file_path = decrypt_file_with_7z(file_path, password)
            
            print(f"解密后文件路径: {decrypted_file_path}")
            
            # 打开Downloads文件夹并聚焦到解密文件
            subprocess.Popen(['explorer', '/select,', decrypted_file_path])
            
            messagebox.showinfo('成功', f'文件解密成功！\n\n解密文件: {os.path.basename(decrypted_file_path)}\n保存位置: Downloads文件夹')
            
        except Exception as e:
            messagebox.showerror('错误', f'文件解密失败: {str(e)}')
    
    def _decrypt_file_with_progress(self, file_path, password, file_size):
        """带进度条的文件解密（大文件）"""
        # 创建进度对话框
        progress_window = tk.Toplevel(self.root)
        progress_window.title('解密进度')
        progress_window.geometry('400x150')
        progress_window.resizable(False, False)
        
        # 居中显示
        x = self.root.winfo_x() + (self.root.winfo_width() - 400) // 2
        y = self.root.winfo_y() + (self.root.winfo_height() - 150) // 2
        progress_window.geometry(f'400x150+{x}+{y}')
        
        progress_window.transient(self.root)
        progress_window.grab_set()
        
        # 进度标签
        progress_label = tk.Label(progress_window, text=f'正在解密文件: {os.path.basename(file_path)}')
        progress_label.pack(pady=10)
        
        # 进度条
        progress_var = tk.DoubleVar()
        progress_bar = ttk.Progressbar(progress_window, variable=progress_var, maximum=100)
        progress_bar.pack(pady=10, padx=20, fill='x')
        
        # 状态标签
        status_label = tk.Label(progress_window, text='准备中...')
        status_label.pack(pady=5)
        
        # 取消按钮
        cancel_flag = {'cancelled': False}
        def cancel_operation():
            cancel_flag['cancelled'] = True
            progress_window.destroy()
        
        cancel_button = ttk.Button(progress_window, text='取消', command=cancel_operation)
        cancel_button.pack(pady=10)
        
        # 在后台线程中执行解密
        def decrypt_thread():
            try:
                if cancel_flag['cancelled']:
                    return
                
                # 更新状态
                self.root.after(0, lambda: status_label.config(text='正在解密...'))
                self.root.after(0, lambda: progress_var.set(20))
                
                # 执行解密
                decrypted_file_path = decrypt_file_with_7z(file_path, password)
                
                if cancel_flag['cancelled']:
                    return
                
                # 解密完成
                self.root.after(0, lambda: progress_var.set(100))
                self.root.after(0, lambda: status_label.config(text='解密完成！'))
                
                # 在主线程中更新UI
                def finish_decryption():
                    try:
                        progress_window.destroy()
                        
                        print(f"解密后文件路径: {decrypted_file_path}")
                        
                        # 打开Downloads文件夹并聚焦到解密文件
                        subprocess.Popen(['explorer', '/select,', decrypted_file_path])
                        
                        messagebox.showinfo('成功', f'文件解密成功！\n\n解密文件: {os.path.basename(decrypted_file_path)}\n保存位置: Downloads文件夹')
                    except Exception as e:
                        messagebox.showerror('错误', f'完成解密后处理失败: {str(e)}')
                
                self.root.after(0, finish_decryption)
                
            except Exception as e:
                # 错误处理
                def show_error():
                    try:
                        progress_window.destroy()
                    except:
                        pass
                    messagebox.showerror('错误', f'文件解密失败: {str(e)}')
                
                self.root.after(0, show_error)
        
        # 启动解密线程
        decrypt_thread_obj = threading.Thread(target=decrypt_thread, daemon=True)
        decrypt_thread_obj.start()

def simple_input(root, prompt):
    top = tk.Toplevel(root)
    top.title(prompt)
    top.geometry('300x120')
    top.resizable(False, False)
    
    # 计算居中位置
    x = root.winfo_x() + (root.winfo_width() - 300) // 2
    y = root.winfo_y() + (root.winfo_height() - 120) // 2
    top.geometry(f'300x120+{x}+{y}')
    
    top.transient(root)
    top.grab_set()
    
    tk.Label(top, text=prompt).pack(padx=8, pady=4)
    e = tk.Entry(top, width=40)
    e.pack(padx=8, pady=4)
    e.focus_set()
    
    val = {}
    def ok():
        val['text'] = e.get().strip()
        top.destroy()
    
    def on_enter(event):
        ok()
    
    e.bind('<Return>', on_enter)
    top.bind('<Escape>', lambda e: top.destroy())
    
    btn_frame = tk.Frame(top)
    btn_frame.pack(pady=4)
    ttk.Button(btn_frame, text='确定', command=ok).pack(side='left', padx=4)
    ttk.Button(btn_frame, text='取消', command=top.destroy).pack(side='left', padx=4)
    
    top.wait_window()
    return val.get('text')

if __name__ == '__main__':
    root = tk.Tk()
    App(root)
    root.mainloop()
