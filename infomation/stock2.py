import backtrader as bt
import yfinance as yf
import pandas as pd

# 下载数据
data = yf.download("AAPL", start="2025-01-01", end="2026-01-01")

# 确保列名是字符串
data.columns = [col[0] if isinstance(
    col, tuple) else col for col in data.columns]

# 只保留必要列
data = data[['Open', 'High', 'Low', 'Close', 'Volume']]

# 转换为 Backtrader 数据源
data_bt = bt.feeds.PandasData(dataname=data)

# 简单策略


class SmaCross(bt.Strategy):
    def __init__(self):
        self.sma1 = bt.indicators.SimpleMovingAverage(
            self.data.close, period=20)
        self.sma2 = bt.indicators.SimpleMovingAverage(
            self.data.close, period=50)

    def next(self):
        if self.sma1[0] > self.sma2[0] and not self.position:
            self.buy(size=10)
        elif self.sma1[0] < self.sma2[0] and self.position:
            self.close()


# Cerebro 回测
cerebro = bt.Cerebro()
cerebro.addstrategy(SmaCross)
cerebro.adddata(data_bt)
cerebro.broker.setcash(100000)
cerebro.run()
cerebro.plot()
