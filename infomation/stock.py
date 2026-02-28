import yfinance as yf
import matplotlib.pyplot as plt

# 选择股票代码 AAPL
ticker = "AAPL"

# 下载 2025 全年历史日线数据
data = yf.download(ticker, start="2025-01-01", end="2026-01-31")

# 提取收盘价并绘图
plt.figure(figsize=(12, 6))
plt.plot(data.index, data['Close'], label='收盘价', color='blue')
plt.title('AAPL 2025 年股价折线图')
plt.xlabel("日期")
plt.ylabel("收盘价 (USD)")
plt.grid(True)
plt.legend()
plt.show()
