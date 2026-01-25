from paddleocr import PaddleOCR

# OCR 初始化
ocr = PaddleOCR(lang="japan")  # 日语模型

# 图片路径
img_path = r"C:\Users\zhengchang.wang\script\windows\OCR\demo.png"

# OCR 识别
result = ocr.ocr(img_path)

# 打印结果
for line in result[0]:
    print(line[1][0])
