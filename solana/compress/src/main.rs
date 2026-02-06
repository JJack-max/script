use aes::Aes256;
use base64::{engine::general_purpose, Engine as _};
use cbc::{Decryptor, Encryptor};
use cipher::{block_padding::Pkcs7, BlockDecryptMut, BlockEncryptMut, KeyIvInit};
use clap::Parser;
use rand::Rng;
use std::fs;
use std::path::Path;
use std::process::Command;
use uuid::Uuid;

#[derive(Parser)]
#[command(name = "compress")]
#[command(version = "2.0")]
#[command(about = "Simple & secure file compression tool")]
#[command(long_about = "
Compress & encrypt files with a single command:
  compress -c <file>           -> Encrypt & compress file/folder
  compress -x <archive> <key>  -> Decrypt & decompress archive
")]
struct Cli {
    /// Compress and encrypt mode
    #[arg(short = 'c', long = "compress", value_name = "FILE")]
    compress_mode: Option<String>,

    /// Extract and decrypt mode
    #[arg(short = 'x', long = "extract", value_name = "ARCHIVE")]
    extract_mode: Option<String>,

    /// Keyfile path (for extract mode)
    #[arg(short, long, value_name = "PATH")]
    keyfile: Option<String>,
}

/// keyfile 格式 (v2):
/// v2:base64(16_bytes_iv + encrypted_password)
///
/// 将 IV 嵌入到加密数据前面，keyfile 保存单个字符串

/// 生成强密码
fn generate_password(length: usize) -> String {
    const CHARSET: &[u8] =
        b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=";
    let mut rng = rand::thread_rng();

    (0..length)
        .map(|_| {
            let idx = rng.gen_range(0..CHARSET.len());
            CHARSET[idx] as char
        })
        .collect()
}

/// 生成随机 IV
fn generate_iv() -> [u8; 16] {
    let mut iv = [0u8; 16];
    let mut rng = rand::thread_rng();
    rng.fill(&mut iv);
    iv
}

/// 获取本地主密钥（基于用户主目录）
fn get_local_master_key() -> Result<[u8; 32], Box<dyn std::error::Error>> {
    use sha2::{Digest, Sha256};

    let home = std::env::var("HOME")
        .or_else(|_| std::env::var("USERPROFILE")) // Windows fallback
        .unwrap_or_else(|_| "/tmp".to_string());

    let mut hasher = Sha256::new();
    hasher.update(home.as_bytes());
    hasher.update(b"compress-local-key-v2"); // Version salt
    let result = hasher.finalize();

    let mut key = [0u8; 32];
    key.copy_from_slice(&result[..32]);
    Ok(key)
}

/// 从密码和盐派生密钥 (简单的 PBKDF2 实现) - 保留用于向后兼容参考
#[allow(dead_code)]
fn derive_key(password: &str, salt: &[u8]) -> [u8; 32] {
    use hmac::{Hmac, Mac};
    use sha2::Sha256;

    type HmacSha256 = Hmac<Sha256>;

    let mut result = [0u8; 32];
    let mut u = [0u8; 32];
    let mut prev = [0u8; 32];

    // First iteration with counter = 1 (big-endian)
    let mut mac = HmacSha256::new_from_slice(password.as_bytes()).expect("HMAC key size valid");
    mac.update(salt);
    mac.update(&[0u8, 0u8, 0u8, 1u8]); // counter = 1
    let first_out = mac.finalize().into_bytes();
    u.copy_from_slice(&first_out);
    prev.copy_from_slice(&u);

    // Remaining iterations (100_000 total, so 99_999 more)
    for _ in 1..100_000 {
        let mut mac = HmacSha256::new_from_slice(password.as_bytes()).expect("HMAC key size valid");
        mac.update(&prev);
        let out = mac.finalize().into_bytes();
        for j in 0..32 {
            u[j] ^= out[j];
        }
        prev.copy_from_slice(&out);
    }

    result.copy_from_slice(&u);
    result
}

/// 用本地主密钥自动加密密码并返回 keyfile 字符串
/// 格式: v2:base64(iv + encrypted_password)
fn auto_encrypt_password(password: &str) -> Result<String, Box<dyn std::error::Error>> {
    let local_key = get_local_master_key()?;
    let iv = generate_iv();

    let encryptor = Encryptor::<Aes256>::new((&local_key).into(), (&iv).into());
    let mut buffer = [0u8; 256];
    let pos = password.len();
    buffer[..pos].copy_from_slice(password.as_bytes());
    let encrypted = encryptor
        .encrypt_padded_mut::<Pkcs7>(&mut buffer, pos)
        .map_err(|_| "加密失败: 填充错误")?;

    // 合并 IV + encrypted_password
    let mut combined = Vec::new();
    combined.extend_from_slice(&iv);
    combined.extend_from_slice(encrypted);

    // 格式: v2:base64(...)
    Ok(format!(
        "v2:{}",
        general_purpose::STANDARD.encode(&combined)
    ))
}
/// 从 keyfile 字符串解密密码
/// 格式: v2:base64(iv + encrypted_password)
fn decrypt_password(keyfile_content: &str) -> Result<String, Box<dyn std::error::Error>> {
    if !keyfile_content.starts_with("v2:") {
        return Err("不支持的 keyfile 格式".into());
    }

    let encoded_data = &keyfile_content[3..]; // Skip "v2:"
    let combined = general_purpose::STANDARD.decode(encoded_data)?;

    if combined.len() < 16 {
        return Err("加密数据损坏: 长度不足".into());
    }

    // 提取 IV (前 16 字节) 和加密数据 (剩余部分)
    let (iv_slice, encrypted_slice) = combined.split_at(16);
    let iv: [u8; 16] = iv_slice.try_into()?;

    // 使用本地主密钥解密
    let local_key = get_local_master_key()?;
    let decryptor = Decryptor::<Aes256>::new((&local_key).into(), (&iv).into());
    let mut buffer = encrypted_slice.to_vec();
    let decrypted = decryptor
        .decrypt_padded_mut::<Pkcs7>(&mut buffer)
        .map_err(|_| "解密失败: 此 keyfile 可能在不同的机器上生成")?;

    Ok(String::from_utf8(decrypted.to_vec())?)
}

/// 获取 7z 可执行文件路径
fn get_7z_path() -> Result<String, Box<dyn std::error::Error>> {
    // 1. 检查程序目录下的 assets/7zz (development/source build)
    let exe_path = std::env::current_exe()?;
    let exe_dir = exe_path.parent().ok_or("无法获取程序目录")?;
    let local_7z = exe_dir.join("assets").join("7zz");

    if local_7z.exists() {
        return Ok(local_7z.to_string_lossy().to_string());
    }

    // 2. 检查 Debian 包标准安装路径
    let deb_7z = Path::new("/usr/local/share/compress/assets/7zz");
    if deb_7z.exists() {
        return Ok(deb_7z.to_string_lossy().to_string());
    }

    // 3. 检查系统 PATH 中的 7z
    if Command::new("7z").arg("-h").output().is_ok() {
        return Ok("7z".to_string());
    }

    Err("未找到 7z 可执行文件".into())
}

/// 压缩并加密文件
fn compress_file(input_path: &str) -> Result<(), Box<dyn std::error::Error>> {
    let path = Path::new(input_path);
    if !path.exists() {
        return Err(format!("文件/文件夹不存在: {}", input_path).into());
    }

    // 生成随机密码
    let file_password = generate_password(32);

    // 生成 UUID 作为输出文件名
    let uuid_name = Uuid::new_v4().to_string();
    let archive_name = format!("{}.7z", uuid_name);
    let keyfile_name = format!("{}.key", uuid_name);

    // 创建 keyfile - 自动用本地主密钥加密
    // keyfile 格式: v2:base64(iv + encrypted_password)
    let keyfile_content = auto_encrypt_password(&file_password)?;
    fs::write(&keyfile_name, &keyfile_content)?;

    // 执行 7z 压缩
    let seven_zip = get_7z_path()?;
    println!("🔐 正在加密压缩: {}", input_path);

    let mut cmd = Command::new(&seven_zip);
    cmd.args([
        "a",
        "-t7z",
        "-mx9",
        &format!("-p{}", file_password),
        "-mhe=on",
        &archive_name,
        input_path,
    ]);

    let output = cmd.output()?;

    if !output.status.success() {
        eprintln!("错误: {}", String::from_utf8_lossy(&output.stderr));
        return Err("压缩失败".into());
    }

    println!("\n✅ 压缩加密完成！\n");
    println!("📦 存档文件: {}", archive_name);
    println!("🔑 密钥文件: {}\n", keyfile_name);
    println!(
        "📋 解压：compress -x {} -k {}\n",
        archive_name, keyfile_name
    );

    Ok(())
}

/// 解压并解密文件
fn decompress_file(
    archive_path: &str,
    keyfile_path: &str,
) -> Result<(), Box<dyn std::error::Error>> {
    // 验证文件存在
    if !Path::new(archive_path).exists() {
        return Err(format!("存档文件不存在: {}", archive_path).into());
    }

    if !Path::new(keyfile_path).exists() {
        return Err(format!("密钥文件不存在: {}", keyfile_path).into());
    }

    // 读取 keyfile 并解密密码
    // keyfile 格式: v2:base64(iv + encrypted_password)
    let keyfile_content = fs::read_to_string(keyfile_path)?;
    let file_password = decrypt_password(&keyfile_content)?;

    // 执行解压到当前目录
    println!("🔓 正在解密解压: {}", archive_path);

    let seven_zip = get_7z_path()?;
    let mut cmd = Command::new(&seven_zip);
    let password_arg = format!("-p{}", file_password);

    cmd.args(["x", "-o.", "-y", &password_arg, archive_path]);

    // 移除stdin，避免7z等待输入
    cmd.stdin(std::process::Stdio::null());

    let output = cmd.output()?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        let stdout = String::from_utf8_lossy(&output.stdout);
        eprintln!("7z stderr: {}", stderr);
        eprintln!("7z stdout: {}", stdout);
        return Err("解压失败".into());
    }

    println!("\n✅ 解压解密完成！\n");
    println!("📁 文件已解压到当前目录\n");

    Ok(())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();

    // 压缩模式
    if let Some(input) = cli.compress_mode {
        compress_file(&input)?;
        return Ok(());
    }

    // 解压模式
    if let Some(archive) = cli.extract_mode {
        let keyfile = cli.keyfile.ok_or("需要提供密钥文件路径 (-k/--keyfile)")?;
        decompress_file(&archive, &keyfile)?;
        return Ok(());
    }

    // 如果都没有指定，打印帮助
    println!("📦 Compress - 简单安全的文件压缩工具\n");
    println!("用法:");
    println!("  压缩加密:     compress -c <文件或文件夹>");
    println!("  解压解密:     compress -x <存档文件> -k <密钥文件>\n");
    println!("示例:");
    println!("  compress -c myfile.txt");
    println!("  compress -x myfile.7z -k myfile.key");

    Ok(())
}
