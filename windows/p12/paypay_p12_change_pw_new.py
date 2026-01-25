#!/usr/bin/env python3
import os
import sys
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox
from pathlib import Path
import getpass
import zipfile
import shutil
import argparse

def get_script_dir():
    """Get the directory where the script is located"""
    return Path(__file__).parent.absolute()

def convert_to_absolute_path(file_path, script_dir):
    """Convert relative path to absolute path"""
    path_obj = Path(file_path)
    if path_obj.is_absolute():
        return str(path_obj)
    else:
        return str(script_dir / file_path)

def secure_input(prompt):
    """Secure password input"""
    try:
        return getpass.getpass(f"{prompt}: ")
    except (EOFError, KeyboardInterrupt):
        print("\n操作已取消")
        sys.exit(1)

def show_save_dialog(title, file_types, initial_filename):
    """Show save file dialog"""
    try:
        root = tk.Tk()
        root.withdraw()  # Hide the main window
        
        file_path = filedialog.asksaveasfilename(
            title=title,
            filetypes=file_types,
            initialfile=initial_filename
        )
        
        root.destroy()
        return file_path
    except Exception as e:
        print(f"GUI dialog failed: {e}")
        # Fallback to console input
        return input(f"请输入保存路径 (包含文件名): ").strip()

def show_success_message(message):
    """Show success message"""
    try:
        root = tk.Tk()
        root.withdraw()
        messagebox.showinfo("保存成功", message)
        root.destroy()
    except:
        print(f"✅ {message}")

def run_openssl_command(cmd, step_name):
    """Run OpenSSL command with error handling"""
    try:
        print(f"🔧 Executing: {' '.join(cmd)}")
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        print(f"✅ {step_name} completed successfully!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error in {step_name}: {e}")
        if e.stderr:
            print(f"Error details: {e.stderr}")
        return False
    except FileNotFoundError:
        print(f"❌ Error: Command not found. Please ensure OpenSSL is installed and in PATH.")
        return False

def run_keytool_command(cmd, step_name):
    """Run keytool command with error handling"""
    try:
        print(f"🔧 Executing: {' '.join(cmd)}")
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        print(f"✅ {step_name} completed successfully!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Error in {step_name}: {e}")
        if e.stderr:
            print(f"Error details: {e.stderr}")
        print("请确保 Java 和 keytool 已正确安装并在 PATH 中")
        return False
    except FileNotFoundError:
        print(f"❌ Error: keytool not found. Please ensure Java is installed and keytool is in PATH.")
        return False

def cleanup_files(*files):
    """Clean up temporary files"""
    for file_path in files:
        try:
            if Path(file_path).exists():
                Path(file_path).unlink()
        except Exception as e:
            print(f"Warning: Could not clean up {file_path}: {e}")

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='PayPay P12 Certificate Password Changer - Python Version')
    parser.add_argument('origin_p12_file', help='Original P12 file path')
    
    try:
        args = parser.parse_args()
    except SystemExit:
        print("Usage: python paypay_p12_change_pw_new.py <origin_p12_file>")
        return 1
    
    print("PayPay P12 Certificate Password Changer - Python Version")
    print("=" * 60)
    
    # Setup paths
    script_dir = get_script_dir()
    origin_p12_file_full = convert_to_absolute_path(args.origin_p12_file, script_dir)
    
    # Check if original P12 file exists
    if not Path(origin_p12_file_full).exists():
        print(f"❌ Error: Original P12 file not found: {origin_p12_file_full}")
        return 1
    
    # Interactive password input
    print(f"\n📄 Original P12 file: {origin_p12_file_full}")
    origin_p12_password = secure_input('请输入原始 p12 文件密码')
    new_p12_password = secure_input('请输入新 p12 文件密码（JKS 密码同此）')
    jks_password = new_p12_password  # Same password for JKS
    
    # Setup temporary file paths
    pem_file = script_dir / 'tmp.pem'
    p12_file = script_dir / 'tmp.p12'
    jks_file = script_dir / 'tmp.jks'
    zip_file = script_dir / 'tmp.zip'
    
    print(f"\n📄 PEM 目标文件: {pem_file}")
    print(f"📄 新 P12 文件: {p12_file}")
    print(f"📄 JKS 目标文件: {jks_file}")
    
    # Clean up old files
    cleanup_files(pem_file, p12_file, jks_file, zip_file)
    
    try:
        # Step 1: P12 -> PEM
        print("\n📦 Step 1: Converting .p12 -> .pem")
        cmd1 = [
            'openssl', 'pkcs12',
            '-in', origin_p12_file_full,
            '-nodes',
            '-out', str(pem_file),
            '-legacy',
            '-password', f'pass:{origin_p12_password}'
        ]
        
        if not run_openssl_command(cmd1, "P12 to PEM conversion"):
            return 1
        
        # Step 2: PEM -> New P12
        print("\n🔁 Step 2: Creating new .p12 from .pem")
        cmd2 = [
            'openssl', 'pkcs12',
            '-export',
            '-in', str(pem_file),
            '-out', str(p12_file),
            '-keypbe', 'PBE-SHA1-3DES',
            '-certpbe', 'PBE-SHA1-3DES',
            '-macalg', 'sha1',
            '-iter', '2048',
            '-passout', f'pass:{new_p12_password}'
        ]
        
        if not run_openssl_command(cmd2, "PEM to new P12 conversion"):
            return 1
        
        # Step 3: P12 -> JKS
        print("\n🔐 Step 3: Creating .jks from .p12")
        cmd3 = [
            'keytool',
            '-importkeystore',
            '-srckeystore', str(p12_file),
            '-srcstoretype', 'PKCS12',
            '-srcstorepass', new_p12_password,
            '-deststoretype', 'JKS',
            '-destkeystore', str(jks_file),
            '-deststorepass', jks_password,
            '-noprompt'
        ]
        
        if not run_keytool_command(cmd3, "P12 to JKS conversion"):
            return 1
        
        print(f"\n✅ All done. Final JKS file: {jks_file}")
        
        # Create ZIP file
        print("\n📦 Creating ZIP package...")
        try:
            with zipfile.ZipFile(zip_file, 'w', zipfile.ZIP_DEFLATED) as zipf:
                for file_path in [pem_file, p12_file, jks_file]:
                    if Path(file_path).exists():
                        zipf.write(file_path, Path(file_path).name)
                    else:
                        print(f"⚠️ Warning: File {file_path} not found, skipping...")
            
            print(f"✅ ZIP package created: {zip_file}")
        except Exception as e:
            print(f"❌ Error creating ZIP file: {e}")
            return 1
        
        # Show save dialog
        print("\n💾 Opening save dialog...")
        save_path = show_save_dialog(
            "请选择保存 zip 文件的位置",
            [("ZIP 文件", "*.zip"), ("All Files", "*.*")],
            "tmp.zip"
        )
        
        if save_path:
            try:
                shutil.copy2(zip_file, save_path)
                success_msg = f"zip 文件已保存到: {save_path}"
                show_success_message(success_msg)
                print(f"✅ {success_msg}")
            except Exception as e:
                print(f"❌ Error saving file: {e}")
                return 1
        else:
            print("⚠️ Save operation cancelled by user")
        
        # Final cleanup
        cleanup_files(pem_file, p12_file, jks_file, zip_file)
        
        print("\n🎉 Operation completed successfully!")
        return 0
        
    except KeyboardInterrupt:
        print("\n\n⚠️ Operation cancelled by user")
        cleanup_files(pem_file, p12_file, jks_file, zip_file)
        return 1
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        cleanup_files(pem_file, p12_file, jks_file, zip_file)
        return 1

if __name__ == "__main__":
    sys.exit(main())