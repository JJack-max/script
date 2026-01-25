#!/usr/bin/env python3
import os
import json
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox
from pathlib import Path
import getpass
import sys

def get_script_dir():
    """Get the directory where the script is located"""
    return Path(__file__).parent.absolute()

def read_state_file(state_file):
    """Read previous input from state file"""
    last = {}
    if state_file.exists():
        try:
            with open(state_file, 'r', encoding='utf-8') as f:
                last = json.load(f)
        except:
            pass
    return last

def save_state_file(state_file, data):
    """Save current input to state file"""
    try:
        with open(state_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"Warning: Could not save state file: {e}")

def read_multiline_input(prompt, default=None):
    """Read multiline input from user"""
    print(f"{prompt} (多行输入，单独一行输入'end'结束，直接回车使用上次内容)")
    lines = []
    while True:
        try:
            line = input()
            if line.strip().lower() == 'end':
                break
            lines.append(line)
        except (EOFError, KeyboardInterrupt):
            break
    
    if not lines and default:
        return default
    return '\n'.join(lines)

def read_input(prompt, default=None, is_secure=False):
    """Read input from user with optional default value"""
    if default:
        display_prompt = f"{prompt} [默认: {default if not is_secure else '***'}]: "
    else:
        display_prompt = f"{prompt}: "
    
    try:
        if is_secure:
            user_input = getpass.getpass(display_prompt)
        else:
            user_input = input(display_prompt)
        
        if not user_input.strip() and default:
            return default
        return user_input
    except (EOFError, KeyboardInterrupt):
        print("\n操作已取消")
        sys.exit(1)

def save_file_dialog(initial_filename="elastic.p12"):
    """Show save file dialog and return selected path"""
    try:
        # Create a temporary root window (hidden)
        root = tk.Tk()
        root.withdraw()  # Hide the main window
        
        # Show save dialog
        file_path = filedialog.asksaveasfilename(
            title="请选择保存 p12 文件的位置",
            defaultextension=".p12",
            filetypes=[("PKCS#12 Files", "*.p12"), ("All Files", "*.*")],
            initialfile=initial_filename
        )
        
        root.destroy()
        return file_path
    except Exception as e:
        print(f"GUI dialog failed: {e}")
        # Fallback to console input
        return input("请输入保存路径 (包含文件名): ").strip()

def show_success_message(message):
    """Show success message"""
    try:
        root = tk.Tk()
        root.withdraw()
        messagebox.showinfo("保存成功", message)
        root.destroy()
    except:
        print(f"✅ {message}")

def main():
    print("Elastic P12 Certificate Merger - Python Version")
    print("=" * 50)
    
    # Setup file paths
    script_dir = get_script_dir()
    state_file = script_dir / 'merge_elastic_p12_his.json'
    crt_path = script_dir / 'elastic.crt'
    key_path = script_dir / 'elastic.key'
    p12_path = script_dir / 'elastic.p12'
    
    # Read previous input
    last = read_state_file(state_file)
    
    try:
        # Get certificate content
        crt_content = read_multiline_input(
            '请输入crt内容', 
            last.get('crt')
        )
        
        # Get key content
        key_content = read_multiline_input(
            '请输入key内容', 
            last.get('key')
        )
        
        # Get password
        password = read_input(
            '请输入p12密码', 
            last.get('pass'), 
            is_secure=True
        )
        
        # Save current input
        save_state_file(state_file, {
            'crt': crt_content,
            'key': key_content,
            'pass': password
        })
        
        # Write certificate and key files
        print("\n📄 Writing certificate and key files...")
        with open(crt_path, 'w', encoding='utf-8') as f:
            f.write(crt_content)
        
        with open(key_path, 'w', encoding='utf-8') as f:
            f.write(key_content)
        
        # Generate P12 file using OpenSSL
        print("🔐 Generating P12 file...")
        cmd = [
            'openssl', 'pkcs12', '-export',
            '-in', str(crt_path),
            '-inkey', str(key_path),
            '-out', str(p12_path),
            '-legacy',
            '-passout', f'pass:{password}'
        ]
        
        try:
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            print("✅ P12 file generated successfully!")
        except subprocess.CalledProcessError as e:
            print(f"❌ Error generating P12 file: {e}")
            print(f"Command output: {e.stderr}")
            return 1
        except FileNotFoundError:
            print("❌ Error: OpenSSL not found. Please ensure OpenSSL is installed and in PATH.")
            return 1
        
        # Show save dialog
        print("\n💾 Opening save dialog...")
        save_path = save_file_dialog("elastic.p12")
        
        if save_path:
            try:
                # Copy file to selected location
                import shutil
                shutil.copy2(p12_path, save_path)
                
                success_msg = f"p12 文件已保存到: {save_path}"
                show_success_message(success_msg)
                print(f"✅ {success_msg}")
                
            except Exception as e:
                print(f"❌ Error saving file: {e}")
                return 1
        else:
            print("⚠️ Save operation cancelled by user")
        
        # Cleanup temporary files
        try:
            for temp_file in [crt_path, key_path, p12_path]:
                if temp_file.exists():
                    temp_file.unlink()
        except Exception as e:
            print(f"Warning: Could not clean up temporary files: {e}")
        
        print("\n🎉 Operation completed successfully!")
        return 0
        
    except KeyboardInterrupt:
        print("\n\n⚠️ Operation cancelled by user")
        return 1
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        return 1

if __name__ == "__main__":
    sys.exit(main())