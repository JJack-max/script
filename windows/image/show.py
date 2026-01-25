import tkinter as tk
from PIL import Image, ImageTk
import glob
import sys
import os
import subprocess


def launch_window(file_path):
    """
    启动独立 Python 进程显示图片，带右键关闭菜单
    """
    python_exe = sys.executable
    # 构建 Python 脚本字符串
    script = f"""
import tkinter as tk
from PIL import Image, ImageTk

root = tk.Tk()
root.overrideredirect(True)
root.attributes('-topmost', True)

img = Image.open(r"{file_path}")
tk_img = ImageTk.PhotoImage(img)
label = tk.Label(root, image=tk_img)
label.pack()
root.geometry(f"{{img.width}}x{{img.height}}")

# 拖动逻辑
def start_move(event):
    root.x_offset = event.x
    root.y_offset = event.y

def on_move(event):
    x = event.x_root - root.x_offset
    y = event.y_root - root.y_offset
    root.geometry(f"+{{x}}+{{y}}")

root.bind("<Button-1>", start_move)
root.bind("<B1-Motion>", on_move)
label.bind("<Button-1>", start_move)
label.bind("<B1-Motion>", on_move)

# 右键弹出菜单
menu = tk.Menu(root, tearoff=0)
menu.add_command(label="关闭", command=root.destroy)

def show_menu(event):
    menu.post(event.x_root, event.y_root)

root.bind("<Button-3>", show_menu)
label.bind("<Button-3>", show_menu)

root.mainloop()
"""
    subprocess.Popen([python_exe, "-c", script])


def main():
    if len(sys.argv) < 2:
        print("用法: python show.py <图片路径或通配符>")
        sys.exit(1)

    paths = sys.argv[1:]
    files = []

    for p in paths:
        files.extend(glob.glob(p))

    if not files:
        print("未找到匹配的图片")
        sys.exit(1)

    for f in files:
        if os.path.isfile(f):
            launch_window(f)


if __name__ == "__main__":
    main()
