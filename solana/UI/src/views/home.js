import React from 'react'

import Script from 'dangerous-html/react'
import { Helmet } from 'react-helmet'

import Navigation from '../components/navigation'
import Footer from '../components/footer'
import './home.css'

const Home = (props) => {
  return (
    <div className="home-container10">
      <Helmet>
        <title>Plush High Level Gerbil</title>
        <meta property="og:title" content="Plush High Level Gerbil" />
      </Helmet>
      <Navigation></Navigation>
      <div className="home-container11">
        <div className="home-container12">
          <Script
            html={`<style>
        @keyframes pulse-glow {0%,100% {box-shadow: 0 0 20px
        color-mix(in srgb, var(--color-accent) 30%, transparent);}
50% {box-shadow: 0 0 30px
        color-mix(in srgb, var(--color-accent) 50%, transparent);}}@keyframes pulse-dot {0%,100% {opacity: 1;}
50% {opacity: 0.3;}}
        </style> `}
          ></Script>
        </div>
      </div>
      <div className="home-container13">
        <div className="home-container14">
          <Script
            html={`<style>
#hero {
  position: relative;
  background: var(--color-surface);
  overflow: hidden;
}
#hero::before {
  content: "";
  position: absolute;
  inset: 0;
  background: radial-gradient(
        circle at 20% 50%,
        color-mix(in srgb, var(--color-primary) 8%, transparent) 0%,
        transparent 50%
      ),
      radial-gradient(
        circle at 80% 20%,
        color-mix(in srgb, var(--color-accent) 6%, transparent) 0%,
        transparent 50%
      );
  z-index: 1;
}
@media (prefers-reduced-motion: reduce) {
.wallet-card, .add-wallet-action, .logo-mark {
  animation: none;
  transition: none;
}
}
#dashboard {
  padding: var(--section-gap) var(--spacing-3xl);
  background: var(--color-surface);
  position: relative;
}
@media (max-width: 479px) {
#dashboard {
  padding: var(--section-gap) var(--spacing-lg);
}
}
#network-overview {
  padding: var(--section-gap) var(--spacing-3xl);
  background: var(--color-surface);
}
@media (max-width: 767px) {
#network-overview {
  padding: var(--section-gap) var(--spacing-lg);
}
}
#add-wallet-prompt {
  padding: var(--section-gap) var(--spacing-3xl);
  background: var(--color-surface);
}
@media (max-width: 479px) {
#add-wallet-prompt {
  padding: var(--section-gap) var(--spacing-lg);
}
}
#security-password {
  padding: var(--section-gap) var(--spacing-3xl);
  background: var(--color-surface);
}
@media (max-width: 479px) {
#security-password {
  padding: var(--section-gap) var(--spacing-lg);
}
}
@media (prefers-reduced-motion: reduce) {
.strength-fill, .toggle-slider, .toggle-slider::before {
  transition: none;
}
.strip-icon {
  animation: none;
}
}
#wallet-options {
  padding: var(--section-gap) var(--spacing-3xl);
  background: var(--color-surface);
}
@media (max-width: 767px) {
#wallet-options {
  padding: var(--section-gap) var(--spacing-lg);
}
}
@media (prefers-reduced-motion: reduce) {
.wallet-detail {
  transition: none;
}
}
#tips-actions {
  padding: var(--section-gap) var(--spacing-3xl);
  background: var(--color-surface);
}
@media (max-width: 479px) {
#tips-actions {
  padding: var(--section-gap) var(--spacing-lg);
}
}
@media (prefers-reduced-motion: reduce) {
.action-card {
  transition: none;
}
}
</style>`}
          ></Script>
        </div>
      </div>
      <div className="home-container15">
        <div className="home-container16">
          <Script
            html={`<script defer data-name="wallet-interactions">
(function(){
  const walletCards = document.querySelectorAll(
    ".wallet-card, .wallet-section .wallet-row"
  )
  const networkTiles = document.querySelectorAll(".network-tile")
  const copyButtons = document.querySelectorAll(".copy-btn, .copy-address-btn")
  const passwordInput = document.getElementById("new-password")
  const strengthFill = document.querySelector(".strength-fill")
  const strengthLevel = document.querySelector(".strength-level")
  const entropyValue = document.querySelector(".entropy-value")
  const toggleVisibility = document.querySelector(".toggle-visibility")
  const pasteButtons = document.querySelectorAll(".paste-btn")

  // Network tile selection
  networkTiles.forEach((tile) => {
    tile.addEventListener("click", () => {
      networkTiles.forEach((t) => t.setAttribute("aria-pressed", "false"))
      tile.setAttribute("aria-pressed", "true")
    })
  })

  // Copy address functionality
  copyButtons.forEach((btn) => {
    btn.addEventListener("click", (e) => {
      e.stopPropagation()
      const originalHTML = btn.innerHTML
      btn.innerHTML =
        '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 6L9 17l-5-5"/></svg>'

      setTimeout(() => {
        btn.innerHTML = originalHTML
      }, 1500)
    })
  })

  // Password strength calculator
  if (passwordInput && strengthFill && strengthLevel && entropyValue) {
    passwordInput.addEventListener("input", (e) => {
      const password = e.target.value
      const length = password.length

      let strength = 0
      let strengthText = "弱"
      let entropy = 0

      if (length === 0) {
        strengthText = "未输入"
      } else if (length < 8) {
        strength = 20
        strengthText = "太弱"
        entropy = length * 4
      } else if (length < 12) {
        strength = 40
        strengthText = "弱"
        entropy = length * 5
      } else if (length < 16) {
        strength = 60
        strengthText = "中等"
        entropy = length * 6
      } else {
        strength = 80
        strengthText = "强"
        entropy = length * 7
      }

      if (/[A-Z]/.test(password)) entropy += 10
      if (/[a-z]/.test(password)) entropy += 10
      if (/[0-9]/.test(password)) entropy += 10
      if (/[^A-Za-z0-9]/.test(password)) entropy += 15

      if (
        strength >= 80 &&
        /[A-Z]/.test(password) &&
        /[a-z]/.test(password) &&
        /[0-9]/.test(password) &&
        /[^A-Za-z0-9]/.test(password)
      ) {
        strength = 100
        strengthText = "非常强"
      }

      strengthFill.style.width = strength + "%"
      strengthLevel.textContent = strengthText
      entropyValue.textContent = Math.round(entropy) + " bits"

      if (strength < 40) {
        strengthFill.style.background = "var(--color-accent-900)"
      } else if (strength < 80) {
        strengthFill.style.background = "var(--color-secondary)"
      } else {
        strengthFill.style.background = "var(--color-accent)"
      }
    })
  }

  // Toggle password visibility
  if (toggleVisibility) {
    toggleVisibility.addEventListener("click", () => {
      const input = document.getElementById("new-password")
      if (input.type === "password") {
        input.type = "text"
      } else {
        input.type = "password"
      }
    })
  }

  // Paste functionality
  pasteButtons.forEach((btn) => {
    btn.addEventListener("click", async () => {
      try {
        const text = await navigator.clipboard.readText()
        const input =
          btn.previousElementSibling || btn.parentElement.querySelector("input")
        if (input) {
          input.value = text
          input.focus()
        }
      } catch (err) {
        console.log("Clipboard access denied")
      }
    })
  })

  // Wallet card keyboard navigation
  walletCards.forEach((card) => {
    card.addEventListener("keydown", (e) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault()
        card.click()
      }
    })
  })

  // Network tile keyboard navigation
  networkTiles.forEach((tile) => {
    tile.addEventListener("keydown", (e) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault()
        tile.click()
      }
    })
  })
})()
</script>`}
          ></Script>
        </div>
      </div>
      <section id="hero" role="region" aria-label="Wallet security hero">
        <div className="hero-container">
          <div className="hero-content-pane">
            <div className="content-backplate">
              <div className="logo-mark">
                <svg
                  width="48"
                  xmlns="http://www.w3.org/2000/svg"
                  height="48"
                  viewBox="0 0 24 24"
                >
                  <g
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  >
                    <rect x="16" y="16" rx="1" width="6" height="6"></rect>
                    <rect x="2" y="16" rx="1" width="6" height="6"></rect>
                    <rect x="9" y="2" rx="1" width="6" height="6"></rect>
                    <path d="M5 16v-3a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v3m-7-4V8"></path>
                  </g>
                </svg>
              </div>
              <h1 className="hero-headline">
                SolanaVault — 未来级 Solana 钱包
              </h1>
              <p className="hero-subhead">
                护航您的数字资产，瞬间进入多网多钱包视图
              </p>
              <p className="hero-body">
                {' '}
                创建访问密码，解锁所有钱包；每一次验证，都是对安全与效率的承诺。军规级加密与本地密码守护，结合直观的网络指示——为熟悉技术的用户打造的专业级数字资产入口。
                <span
                  dangerouslySetInnerHTML={{
                    __html: ' ',
                  }}
                />
              </p>
              <div className="hero-actions">
                <button
                  aria-label="Create access password"
                  className="btn-primary btn btn-lg"
                >
                  {' '}
                  创建密码
                  <span
                    dangerouslySetInnerHTML={{
                      __html: ' ',
                    }}
                  />
                </button>
                <p className="microcopy">一次密码，直达所有钱包</p>
              </div>
            </div>
          </div>
          <div className="wallet-stack-pane">
            <div
              role="button"
              tabindex="0"
              aria-label="Mainnet wallet ending in 4xZ9"
              className="wallet-card"
            >
              <div className="mainnet-badge network-badge">
                <span className="badge-pulse"></span>
                <span>
                  {' '}
                  Mainnet
                  <span
                    dangerouslySetInnerHTML={{
                      __html: ' ',
                    }}
                  />
                </span>
              </div>
              <div className="wallet-address">
                <span>7k...4xZ9</span>
              </div>
              <div className="wallet-balance">
                <span>124.89 SOL</span>
              </div>
              <div className="scanline-overlay"></div>
            </div>
            <div
              role="button"
              tabindex="0"
              aria-label="Devnet wallet ending in 7mK2"
              className="wallet-card"
            >
              <div className="devnet-badge network-badge">
                <span className="badge-pulse"></span>
                <span>
                  {' '}
                  Devnet
                  <span
                    dangerouslySetInnerHTML={{
                      __html: ' ',
                    }}
                  />
                </span>
              </div>
              <div className="wallet-address">
                <span>9x...7mK2</span>
              </div>
              <div className="wallet-balance">
                <span>2,450.10 SOL</span>
              </div>
              <div className="scanline-overlay"></div>
            </div>
            <button aria-label="Add new wallet" className="add-wallet-action">
              <svg
                width="28"
                xmlns="http://www.w3.org/2000/svg"
                height="28"
                viewBox="0 0 24 24"
              >
                <path
                  d="M5 12h14m-7-7v14"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                ></path>
              </svg>
            </button>
          </div>
        </div>
      </section>
      <section id="dashboard" role="region" aria-label="Wallet dashboard">
        <div className="dashboard-container">
          <div className="section-header">
            <h2 className="section-title">钱包一览</h2>
            <p className="section-subtitle">
              直观横向卡片式展示，快速浏览网络与地址预览
            </p>
          </div>
          <div role="list" className="wallet-strip">
            <div
              role="button"
              tabindex="0"
              aria-label="Add wallet"
              className="wallet-add"
            >
              <div className="add-content">
                <svg
                  width="32"
                  xmlns="http://www.w3.org/2000/svg"
                  height="32"
                  viewBox="0 0 24 24"
                >
                  <path
                    d="M5 12h14m-7-7v14"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  ></path>
                </svg>
                <span>添加钱包</span>
              </div>
            </div>
            <div role="listitem" className="wallet-card">
              <div className="card-header">
                <div className="mainnet-badge network-badge">
                  <span className="badge-dot"></span>
                  <span>
                    {' '}
                    Mainnet
                    <span
                      dangerouslySetInnerHTML={{
                        __html: ' ',
                      }}
                    />
                  </span>
                </div>
                <button aria-label="Copy address" className="copy-btn">
                  <svg
                    width="16"
                    xmlns="http://www.w3.org/2000/svg"
                    height="16"
                    viewBox="0 0 24 24"
                  >
                    <g
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <rect
                        x="8"
                        y="8"
                        rx="2"
                        ry="2"
                        width="14"
                        height="14"
                      ></rect>
                      <path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"></path>
                    </g>
                  </svg>
                </button>
              </div>
              <div className="wallet-name">
                <span>主钱包</span>
              </div>
              <div className="wallet-address">
                <span>7kH9...4xZ9</span>
              </div>
              <div className="wallet-balance-display">
                <div className="balance-amount">
                  <span>124.89 SOL</span>
                </div>
                <div className="balance-fiat">
                  <span>≈ $12,489.00</span>
                </div>
              </div>
              <div className="card-texture"></div>
            </div>
            <div role="listitem" className="wallet-card">
              <div className="card-header">
                <div className="devnet-badge network-badge">
                  <span className="badge-dot"></span>
                  <span>
                    {' '}
                    Devnet
                    <span
                      dangerouslySetInnerHTML={{
                        __html: ' ',
                      }}
                    />
                  </span>
                </div>
                <button aria-label="Copy address" className="copy-btn">
                  <svg
                    width="16"
                    xmlns="http://www.w3.org/2000/svg"
                    height="16"
                    viewBox="0 0 24 24"
                  >
                    <g
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <rect
                        x="8"
                        y="8"
                        rx="2"
                        ry="2"
                        width="14"
                        height="14"
                      ></rect>
                      <path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"></path>
                    </g>
                  </svg>
                </button>
              </div>
              <div className="wallet-name">
                <span>测试钱包</span>
              </div>
              <div className="wallet-address">
                <span>9xT2...7mK2</span>
              </div>
              <div className="wallet-balance-display">
                <div className="balance-amount">
                  <span>2,450.10 SOL</span>
                </div>
                <div className="balance-fiat">
                  <span>测试网络</span>
                </div>
              </div>
              <div className="card-texture"></div>
            </div>
            <div role="listitem" className="wallet-card">
              <div className="card-header">
                <div className="testnet-badge network-badge">
                  <span className="badge-dot"></span>
                  <span>
                    {' '}
                    Testnet
                    <span
                      dangerouslySetInnerHTML={{
                        __html: ' ',
                      }}
                    />
                  </span>
                </div>
                <button aria-label="Copy address" className="copy-btn">
                  <svg
                    width="16"
                    xmlns="http://www.w3.org/2000/svg"
                    height="16"
                    viewBox="0 0 24 24"
                  >
                    <g
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <rect
                        x="8"
                        y="8"
                        rx="2"
                        ry="2"
                        width="14"
                        height="14"
                      ></rect>
                      <path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"></path>
                    </g>
                  </svg>
                </button>
              </div>
              <div className="wallet-name">
                <span>开发钱包</span>
              </div>
              <div className="wallet-address">
                <span>3pL8...9nQ4</span>
              </div>
              <div className="wallet-balance-display">
                <div className="balance-amount">
                  <span>856.24 SOL</span>
                </div>
                <div className="balance-fiat">
                  <span>测试网络</span>
                </div>
              </div>
              <div className="card-texture"></div>
            </div>
            <div role="listitem" className="wallet-card">
              <div className="card-header">
                <div className="custom-badge network-badge">
                  <span className="badge-dot"></span>
                  <span>
                    {' '}
                    Custom
                    <span
                      dangerouslySetInnerHTML={{
                        __html: ' ',
                      }}
                    />
                  </span>
                </div>
                <button aria-label="Copy address" className="copy-btn">
                  <svg
                    width="16"
                    xmlns="http://www.w3.org/2000/svg"
                    height="16"
                    viewBox="0 0 24 24"
                  >
                    <g
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <rect
                        x="8"
                        y="8"
                        rx="2"
                        ry="2"
                        width="14"
                        height="14"
                      ></rect>
                      <path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"></path>
                    </g>
                  </svg>
                </button>
              </div>
              <div className="wallet-name">
                <span>自定义网络</span>
              </div>
              <div className="wallet-address">
                <span>5qW1...3rP8</span>
              </div>
              <div className="wallet-balance-display">
                <div className="balance-amount">
                  <span>45.67 SOL</span>
                </div>
                <div className="balance-fiat">
                  <span>自定义 RPC</span>
                </div>
              </div>
              <div className="card-texture"></div>
            </div>
          </div>
        </div>
      </section>
      <section
        id="network-overview"
        role="region"
        aria-label="Network overview"
      >
        <div className="network-overview">
          <div className="featured-panel">
            <div className="panel-header">
              <h2 className="panel-title">网络概览</h2>
              <div className="network-status">
                <span className="status-indicator active"></span>
                <span className="status-text">全部在线</span>
              </div>
            </div>
            <div className="metrics-row">
              <div className="metric-card">
                <div className="metric-label">
                  <span>活跃网络</span>
                </div>
                <div className="metric-value">
                  <span>4</span>
                </div>
              </div>
              <div className="metric-card">
                <div className="metric-label">
                  <span>总钱包数</span>
                </div>
                <div className="metric-value">
                  <span>4</span>
                </div>
              </div>
              <div className="metric-card">
                <div className="metric-label">
                  <span>平均延迟</span>
                </div>
                <div className="metric-value">
                  <span>~45ms</span>
                </div>
              </div>
            </div>
            <div className="alerts-strip">
              <div className="alert-item">
                <svg
                  width="18"
                  xmlns="http://www.w3.org/2000/svg"
                  height="18"
                  viewBox="0 0 24 24"
                >
                  <path
                    d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  ></path>
                </svg>
                <span>所有网络健康运行</span>
              </div>
            </div>
            <div className="topology-teaser">
              <h3 className="teaser-title">实时网络状态</h3>
              <div className="network-grid">
                <div className="network-node mainnet-node">
                  <div className="node-icon"></div>
                  <div className="node-info">
                    <div className="node-name">
                      <span>Mainnet</span>
                    </div>
                    <div className="node-status">
                      <span>在线 · 42ms</span>
                    </div>
                  </div>
                </div>
                <div className="network-node devnet-node">
                  <div className="node-icon"></div>
                  <div className="node-info">
                    <div className="node-name">
                      <span>Devnet</span>
                    </div>
                    <div className="node-status">
                      <span>在线 · 38ms</span>
                    </div>
                  </div>
                </div>
                <div className="network-node testnet-node">
                  <div className="node-icon"></div>
                  <div className="node-info">
                    <div className="node-name">
                      <span>Testnet</span>
                    </div>
                    <div className="node-status">
                      <span>在线 · 51ms</span>
                    </div>
                  </div>
                </div>
                <div className="network-node custom-node">
                  <div className="node-icon"></div>
                  <div className="node-info">
                    <div className="node-name">
                      <span>Custom</span>
                    </div>
                    <div className="node-status">
                      <span>在线 · 67ms</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div role="region" aria-label="Quick actions" className="wallet-list">
            <div className="filter-bar">
              <h3 className="filter-title">按网络筛选</h3>
            </div>
            <div
              role="button"
              tabindex="0"
              aria-label="Mainnet wallet"
              aria-expanded="false"
              className="wallet-row"
            >
              <div className="row-badge mainnet-badge">
                <span>M</span>
              </div>
              <div className="row-info">
                <div className="row-network">
                  <span>Mainnet</span>
                </div>
                <div className="row-address">
                  <span>7kH9...4xZ9</span>
                </div>
              </div>
              <div className="row-balance">
                <span>124.89</span>
              </div>
            </div>
            <div
              role="button"
              tabindex="0"
              aria-label="Devnet wallet"
              aria-expanded="false"
              className="wallet-row"
            >
              <div className="row-badge devnet-badge">
                <span>D</span>
              </div>
              <div className="row-info">
                <div className="row-network">
                  <span>Devnet</span>
                </div>
                <div className="row-address">
                  <span>9xT2...7mK2</span>
                </div>
              </div>
              <div className="row-balance">
                <span>2,450.10</span>
              </div>
            </div>
            <div
              role="button"
              tabindex="0"
              aria-label="Testnet wallet"
              aria-expanded="false"
              className="wallet-row"
            >
              <div className="row-badge testnet-badge">
                <span>T</span>
              </div>
              <div className="row-info">
                <div className="row-network">
                  <span>Testnet</span>
                </div>
                <div className="row-address">
                  <span>3pL8...9nQ4</span>
                </div>
              </div>
              <div className="row-balance">
                <span>856.24</span>
              </div>
            </div>
            <div
              role="button"
              tabindex="0"
              aria-label="Custom network wallet"
              aria-expanded="false"
              className="wallet-row"
            >
              <div className="row-badge custom-badge">
                <span>C</span>
              </div>
              <div className="row-info">
                <div className="row-network">
                  <span>Custom</span>
                </div>
                <div className="row-address">
                  <span>5qW1...3rP8</span>
                </div>
              </div>
              <div className="row-balance">
                <span>45.67</span>
              </div>
            </div>
          </div>
        </div>
      </section>
      <section
        id="add-wallet-prompt"
        role="region"
        aria-label="Add wallet wizard"
      >
        <div className="add-wallet-container">
          <div
            role="region"
            aria-labelledby="add-wallet-steps"
            className="stepper-panel"
          >
            <h3 id="add-wallet-steps" className="stepper-title">
              添加钱包流程
            </h3>
            <div className="step-list">
              <div className="step-item active">
                <div className="step-number">
                  <span>1</span>
                </div>
                <div className="step-content">
                  <div className="step-title">
                    <span>选择网络</span>
                  </div>
                  <div className="step-desc">
                    <span>连接未来的价值通道</span>
                  </div>
                </div>
              </div>
              <div className="step-item">
                <div className="step-number">
                  <span>2</span>
                </div>
                <div className="step-content">
                  <div className="step-title">
                    <span>输入地址</span>
                  </div>
                  <div className="step-desc">
                    <span>安全验证与格式检查</span>
                  </div>
                </div>
              </div>
              <div className="step-item">
                <div className="step-number">
                  <span>3</span>
                </div>
                <div className="step-content">
                  <div className="step-title">
                    <span>确认添加</span>
                  </div>
                  <div className="step-desc">
                    <span>完成钱包配置</span>
                  </div>
                </div>
              </div>
            </div>
            <button
              aria-label="Cancel add wallet"
              className="btn btn-sm cancel-btn btn-outline"
            >
              {' '}
              取消
              <span
                dangerouslySetInnerHTML={{
                  __html: ' ',
                }}
              />
            </button>
          </div>
          <div className="form-rail">
            <div
              role="form"
              aria-labelledby="add-wallet-title"
              className="form-card"
            >
              <h2 id="add-wallet-title" className="form-title">
                选择网络
              </h2>
              <p className="form-subtitle">
                {' '}
                请选择您要添加的钱包网络。我们支持多链并实时验证网络兼容性。
                <span
                  dangerouslySetInnerHTML={{
                    __html: ' ',
                  }}
                />
              </p>
              <div className="network-tiles">
                <button aria-pressed="false" className="network-tile">
                  <div className="home-tile-icon1"></div>
                  <div className="home-tile-name1">
                    <span>Mainnet</span>
                  </div>
                  <div className="home-tile-status1">
                    <span>主网</span>
                  </div>
                </button>
                <button aria-pressed="false" className="network-tile">
                  <div className="home-tile-icon2"></div>
                  <div className="home-tile-name2">
                    <span>Devnet</span>
                  </div>
                  <div className="home-tile-status2">
                    <span>开发网</span>
                  </div>
                </button>
                <button aria-pressed="false" className="network-tile">
                  <div className="home-tile-icon3"></div>
                  <div className="home-tile-name3">
                    <span>Testnet</span>
                  </div>
                  <div className="home-tile-status3">
                    <span>测试网</span>
                  </div>
                </button>
                <button aria-pressed="false" className="network-tile">
                  <div className="home-tile-icon4"></div>
                  <div className="home-tile-name4">
                    <span>Custom</span>
                  </div>
                  <div className="home-tile-status4">
                    <span>自定义</span>
                  </div>
                </button>
              </div>
              <div className="address-input-group">
                <label htmlFor="wallet-address" className="input-label">
                  钱包地址
                </label>
                <div className="input-wrapper">
                  <input
                    type="text"
                    id="wallet-address"
                    placeholder="粘贴或输入钱包地址"
                    aria-describedby="address-help"
                    className="address-input"
                  />
                  <button className="btn-primary btn btn-sm paste-btn">
                    粘贴
                  </button>
                </div>
                <div id="address-help" className="input-help">
                  <span>
                    {' '}
                    地址将经过实时格式校验与只读安全检测
                    <span
                      dangerouslySetInnerHTML={{
                        __html: ' ',
                      }}
                    />
                  </span>
                </div>
              </div>
              <div className="form-actions">
                <button className="btn-primary btn btn-lg">确认并添加</button>
              </div>
            </div>
          </div>
        </div>
      </section>
      <section
        id="security-password"
        role="region"
        aria-label="Security and password creation"
      >
        <div className="security-container">
          <div className="info-rail">
            <div className="info-content">
              <h2 className="info-title">创建主密码</h2>
              <p className="info-subtitle">你的链上安全基石</p>
              <p className="info-body">
                {' '}
                为手机端 SolanaVault
                设置一个强密码，用于加密本地密钥与授权每次访问。推荐使用 12
                位以上、含大小写字母、数字与符号的组合。
                <span
                  dangerouslySetInnerHTML={{
                    __html: ' ',
                  }}
                />
              </p>
              <div className="info-features">
                <div className="feature-item">
                  <svg
                    width="20"
                    xmlns="http://www.w3.org/2000/svg"
                    height="20"
                    viewBox="0 0 24 24"
                  >
                    <g
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <rect
                        x="3"
                        y="11"
                        rx="2"
                        ry="2"
                        width="18"
                        height="11"
                      ></rect>
                      <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                    </g>
                  </svg>
                  <span>本地加密，私钥永不上传</span>
                </div>
                <div className="feature-item">
                  <svg
                    width="20"
                    xmlns="http://www.w3.org/2000/svg"
                    height="20"
                    viewBox="0 0 24 24"
                  >
                    <path
                      d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    ></path>
                  </svg>
                  <span>银行级防护标准</span>
                </div>
                <div className="feature-item">
                  <svg
                    width="20"
                    xmlns="http://www.w3.org/2000/svg"
                    height="20"
                    viewBox="0 0 24 24"
                  >
                    <path
                      d="M20 6L9 17l-5-5"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    ></path>
                  </svg>
                  <span>实时熵评估与强度指示</span>
                </div>
              </div>
              <div className="security-note">
                <p>
                  {' '}
                  SolanaVault
                  遵循行业最佳加密实践并通过定期安全审计。密码与密钥永不离开设备。
                  <span
                    dangerouslySetInnerHTML={{
                      __html: ' ',
                    }}
                  />
                </p>
              </div>
            </div>
          </div>
          <div className="password-card">
            <div className="card-inner">
              <h3 className="card-title">设置访问密码</h3>
              <div className="password-input-group">
                <label htmlFor="new-password" className="input-label">
                  创建密码
                </label>
                <div className="password-wrapper">
                  <input
                    type="password"
                    id="new-password"
                    placeholder="至少 12 位，含大小写、数字、符号"
                    autoComplete="new-password"
                    aria-describedby="password-strength"
                    className="password-input"
                  />
                  <button
                    aria-label="Toggle password visibility"
                    className="toggle-visibility"
                  >
                    <svg
                      width="18"
                      xmlns="http://www.w3.org/2000/svg"
                      height="18"
                      viewBox="0 0 24 24"
                    >
                      <g
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <path d="M2.062 12.348a1 1 0 0 1 0-.696a10.75 10.75 0 0 1 19.876 0a1 1 0 0 1 0 .696a10.75 10.75 0 0 1-19.876 0"></path>
                        <circle r="3" cx="12" cy="12"></circle>
                      </g>
                    </svg>
                  </button>
                </div>
                <div
                  id="password-strength"
                  aria-live="polite"
                  className="strength-meter"
                >
                  <div className="strength-bar">
                    <div className="strength-fill"></div>
                  </div>
                  <div className="strength-text">
                    <span>
                      {' '}
                      密码强度：
                      <span
                        dangerouslySetInnerHTML={{
                          __html: ' ',
                        }}
                      />
                    </span>
                    <span className="strength-level">未输入</span>
                  </div>
                </div>
              </div>
              <div className="password-input-group">
                <label htmlFor="confirm-password" className="input-label">
                  确认密码
                </label>
                <input
                  type="password"
                  id="confirm-password"
                  placeholder="再次输入密码"
                  autoComplete="new-password"
                  className="password-input"
                />
              </div>
              <div className="biometric-toggle">
                <label className="toggle-label">
                  <input type="checkbox" className="home-toggle-input" />
                  <span className="home-toggle-slider"></span>
                  <span className="home-toggle-text">
                    启用生物识别（指纹/面容）
                  </span>
                </label>
              </div>
              <div className="entropy-readout">
                <div className="entropy-label">
                  <span>熵值：</span>
                </div>
                <code className="entropy-value">0 bits</code>
              </div>
              <button className="btn-primary btn submit-btn btn-lg">
                {' '}
                创建密码并继续
                <span
                  dangerouslySetInnerHTML={{
                    __html: ' ',
                  }}
                />
              </button>
            </div>
          </div>
          <div className="tertiary-strip">
            <div className="strip-icon">
              <svg
                width="24"
                xmlns="http://www.w3.org/2000/svg"
                height="24"
                viewBox="0 0 24 24"
              >
                <path
                  d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                ></path>
              </svg>
            </div>
            <div className="strip-text">
              <span>安全</span>
            </div>
          </div>
        </div>
      </section>
      <section
        id="wallet-options"
        role="region"
        aria-label="Wallet management options"
      >
        <div className="wallet-section">
          <div className="wallet-feed">
            <div className="feed-header">
              <h2 className="feed-title">钱包管理</h2>
              <button
                aria-label="Add wallet"
                className="btn-primary btn add-wallet btn-sm"
              >
                <svg
                  width="18"
                  xmlns="http://www.w3.org/2000/svg"
                  height="18"
                  viewBox="0 0 24 24"
                >
                  <path
                    d="M5 12h14m-7-7v14"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  ></path>
                </svg>
                <span>
                  {' '}
                  添加
                  <span
                    dangerouslySetInnerHTML={{
                      __html: ' ',
                    }}
                  />
                </span>
              </button>
            </div>
            <div
              role="button"
              tabindex="0"
              aria-label="Mainnet wallet details"
              className="wallet-row"
            >
              <div className="row-left">
                <div className="mainnet-badge network-badge-pill">
                  <span className="badge-glow"></span>
                  <span>
                    {' '}
                    Mainnet
                    <span
                      dangerouslySetInnerHTML={{
                        __html: ' ',
                      }}
                    />
                  </span>
                </div>
                <div className="row-details">
                  <div className="wallet-label">
                    <span>主钱包</span>
                  </div>
                  <div className="wallet-address-short">
                    <span>7kH9...4xZ9</span>
                  </div>
                </div>
              </div>
              <div className="row-right">
                <div className="balance-primary">
                  <span>124.89 SOL</span>
                </div>
                <div className="balance-secondary">
                  <span>$12,489.00</span>
                </div>
              </div>
            </div>
            <div
              role="button"
              tabindex="0"
              aria-label="Devnet wallet details"
              className="wallet-row"
            >
              <div className="row-left">
                <div className="network-badge-pill devnet-badge">
                  <span className="badge-glow"></span>
                  <span>
                    {' '}
                    Devnet
                    <span
                      dangerouslySetInnerHTML={{
                        __html: ' ',
                      }}
                    />
                  </span>
                </div>
                <div className="row-details">
                  <div className="wallet-label">
                    <span>测试钱包</span>
                  </div>
                  <div className="wallet-address-short">
                    <span>9xT2...7mK2</span>
                  </div>
                </div>
              </div>
              <div className="row-right">
                <div className="balance-primary">
                  <span>2,450.10 SOL</span>
                </div>
                <div className="balance-secondary">
                  <span>测试网络</span>
                </div>
              </div>
            </div>
            <div
              role="button"
              tabindex="0"
              aria-label="Testnet wallet details"
              className="wallet-row"
            >
              <div className="row-left">
                <div className="testnet-badge network-badge-pill">
                  <span className="badge-glow"></span>
                  <span>
                    {' '}
                    Testnet
                    <span
                      dangerouslySetInnerHTML={{
                        __html: ' ',
                      }}
                    />
                  </span>
                </div>
                <div className="row-details">
                  <div className="wallet-label">
                    <span>开发钱包</span>
                  </div>
                  <div className="wallet-address-short">
                    <span>3pL8...9nQ4</span>
                  </div>
                </div>
              </div>
              <div className="row-right">
                <div className="balance-primary">
                  <span>856.24 SOL</span>
                </div>
                <div className="balance-secondary">
                  <span>测试网络</span>
                </div>
              </div>
            </div>
            <div
              role="button"
              tabindex="0"
              aria-label="Custom network wallet details"
              className="wallet-row"
            >
              <div className="row-left">
                <div className="custom-badge network-badge-pill">
                  <span className="badge-glow"></span>
                  <span>
                    {' '}
                    Custom
                    <span
                      dangerouslySetInnerHTML={{
                        __html: ' ',
                      }}
                    />
                  </span>
                </div>
                <div className="row-details">
                  <div className="wallet-label">
                    <span>自定义网络</span>
                  </div>
                  <div className="wallet-address-short">
                    <span>5qW1...3rP8</span>
                  </div>
                </div>
              </div>
              <div className="row-right">
                <div className="balance-primary">
                  <span>45.67 SOL</span>
                </div>
                <div className="balance-secondary">
                  <span>自定义 RPC</span>
                </div>
              </div>
            </div>
          </div>
          <div className="wallet-detail">
            <div className="detail-header">
              <h3 className="detail-title">钱包详情</h3>
              <button aria-label="Close detail panel" className="close-detail">
                <svg
                  width="20"
                  xmlns="http://www.w3.org/2000/svg"
                  height="20"
                  viewBox="0 0 24 24"
                >
                  <path
                    d="M18 6L6 18M6 6l12 12"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  ></path>
                </svg>
              </button>
            </div>
            <div className="detail-content">
              <div className="detail-section">
                <div className="detail-label">
                  <span>网络</span>
                </div>
                <div className="detail-value network-value">
                  <div className="mainnet-badge network-badge-pill">
                    <span className="badge-glow"></span>
                    <span>
                      {' '}
                      Mainnet
                      <span
                        dangerouslySetInnerHTML={{
                          __html: ' ',
                        }}
                      />
                    </span>
                  </div>
                </div>
              </div>
              <div className="detail-section">
                <div className="detail-label">
                  <span>完整地址</span>
                </div>
                <div className="detail-value address-value">
                  <code>7kH9p2xQ...tR3mK4xZ9</code>
                  <button
                    aria-label="Copy full address"
                    className="copy-address-btn"
                  >
                    <svg
                      width="16"
                      xmlns="http://www.w3.org/2000/svg"
                      height="16"
                      viewBox="0 0 24 24"
                    >
                      <g
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <rect
                          x="8"
                          y="8"
                          rx="2"
                          ry="2"
                          width="14"
                          height="14"
                        ></rect>
                        <path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"></path>
                      </g>
                    </svg>
                  </button>
                </div>
              </div>
              <div className="detail-section balance-section">
                <div className="detail-label">
                  <span>当前余额</span>
                </div>
                <div className="balance-display">
                  <div className="balance-main">
                    <span>124.89 SOL</span>
                  </div>
                  <div className="balance-fiat">
                    <span>≈ $12,489.00 USD</span>
                  </div>
                </div>
              </div>
              <div className="detail-actions">
                <button className="btn-primary btn">查看交易</button>
                <button className="btn btn-outline">导出视图</button>
              </div>
            </div>
          </div>
        </div>
      </section>
      <section id="tips-actions" aria-labelledby="tips-title">
        <div className="tips-container">
          <aside className="tips-rail">
            <h2 id="tips-title" className="tips-main-title">
              快速入门提示
            </h2>
            <div className="priority-card tip-card">
              <div className="tip-icon">
                <svg
                  width="24"
                  xmlns="http://www.w3.org/2000/svg"
                  height="24"
                  viewBox="0 0 24 24"
                >
                  <g
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  >
                    <rect
                      x="3"
                      y="11"
                      rx="2"
                      ry="2"
                      width="18"
                      height="11"
                    ></rect>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                  </g>
                </svg>
              </div>
              <h3 className="tip-title">创建强密码</h3>
              <p className="tip-body">
                {' '}
                这是您进入所有钱包与网络的单一通行证。建议使用 12
                字以上、含字母数字与符号的组合并存放于可信密码管理器中。
                <span
                  dangerouslySetInnerHTML={{
                    __html: ' ',
                  }}
                />
              </p>
            </div>
            <div className="tip-card">
              <div className="tip-icon">
                <svg
                  width="24"
                  xmlns="http://www.w3.org/2000/svg"
                  height="24"
                  viewBox="0 0 24 24"
                >
                  <path
                    d="M5 12h14m-7-7v14"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  ></path>
                </svg>
              </div>
              <h3 className="tip-title">添加钱包小贴士</h3>
              <p className="tip-body">
                {' '}
                点击&quot;+&quot;，选择目标网络，粘贴或扫描您的钱包地址。系统会即时验证地址格式并在列表中以网络徽章明确标识。
                <span
                  dangerouslySetInnerHTML={{
                    __html: ' ',
                  }}
                />
              </p>
            </div>
            <div className="tip-card">
              <div className="tip-icon">
                <svg
                  width="24"
                  xmlns="http://www.w3.org/2000/svg"
                  height="24"
                  viewBox="0 0 24 24"
                >
                  <g
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  >
                    <path d="M2.062 12.348a1 1 0 0 1 0-.696a10.75 10.75 0 0 1 19.876 0a1 1 0 0 1 0 .696a10.75 10.75 0 0 1-19.876 0"></path>
                    <circle r="3" cx="12" cy="12"></circle>
                  </g>
                </svg>
              </div>
              <h3 className="tip-title">余额速览</h3>
              <p className="tip-body">
                {' '}
                在主页面长条卡片上即可查看每个钱包的网络与实时余额。点击卡片进入详情页，可查看交易历史与多网络余额汇总。
                <span
                  dangerouslySetInnerHTML={{
                    __html: ' ',
                  }}
                />
              </p>
            </div>
            <div className="tip-card">
              <div className="tip-icon">
                <svg
                  width="24"
                  xmlns="http://www.w3.org/2000/svg"
                  height="24"
                  viewBox="0 0 24 24"
                >
                  <g
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  >
                    <rect x="16" y="16" rx="1" width="6" height="6"></rect>
                    <rect x="2" y="16" rx="1" width="6" height="6"></rect>
                    <rect x="9" y="2" rx="1" width="6" height="6"></rect>
                    <path d="M5 16v-3a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v3m-7-4V8"></path>
                  </g>
                </svg>
              </div>
              <h3 className="tip-title">多网络导航</h3>
              <p className="tip-body">
                {' '}
                切换网络时，界面会高亮当前网络与相应资产数值。若网络不匹配，系统会弹出安全提醒并建议核对地址。
                <span
                  dangerouslySetInnerHTML={{
                    __html: ' ',
                  }}
                />
              </p>
            </div>
          </aside>
          <div
            role="region"
            aria-label="Quick actions"
            className="actions-rail"
          >
            <h3 className="actions-title">快速操作</h3>
            <div className="action-cards">
              <button className="primary-action action-card">
                <div className="home-action-icon1">
                  <svg
                    width="28"
                    xmlns="http://www.w3.org/2000/svg"
                    height="28"
                    viewBox="0 0 24 24"
                  >
                    <path
                      d="M5 12h14m-7-7v14"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    ></path>
                  </svg>
                </div>
                <div className="home-action-content1">
                  <div className="action-title">
                    <span>添加钱包</span>
                  </div>
                  <div className="action-desc">
                    <span>快速导入新网络地址</span>
                  </div>
                </div>
              </button>
              <button className="action-card">
                <div className="home-action-icon2">
                  <svg
                    width="28"
                    xmlns="http://www.w3.org/2000/svg"
                    height="28"
                    viewBox="0 0 24 24"
                  >
                    <g
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <path d="M9.671 4.136a2.34 2.34 0 0 1 4.659 0a2.34 2.34 0 0 0 3.319 1.915a2.34 2.34 0 0 1 2.33 4.033a2.34 2.34 0 0 0 0 3.831a2.34 2.34 0 0 1-2.33 4.033a2.34 2.34 0 0 0-3.319 1.915a2.34 2.34 0 0 1-4.659 0a2.34 2.34 0 0 0-3.32-1.915a2.34 2.34 0 0 1-2.33-4.033a2.34 2.34 0 0 0 0-3.831A2.34 2.34 0 0 1 6.35 6.051a2.34 2.34 0 0 0 3.319-1.915"></path>
                      <circle r="3" cx="12" cy="12"></circle>
                    </g>
                  </svg>
                </div>
                <div className="home-action-content2">
                  <div className="action-title">
                    <span>安全设置</span>
                  </div>
                  <div className="action-desc">
                    <span>管理密码与生物识别</span>
                  </div>
                </div>
              </button>
              <button className="action-card">
                <div className="home-action-icon3">
                  <svg
                    width="28"
                    xmlns="http://www.w3.org/2000/svg"
                    height="28"
                    viewBox="0 0 24 24"
                  >
                    <g
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <rect x="16" y="16" rx="1" width="6" height="6"></rect>
                      <rect x="2" y="16" rx="1" width="6" height="6"></rect>
                      <rect x="9" y="2" rx="1" width="6" height="6"></rect>
                      <path d="M5 16v-3a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v3m-7-4V8"></path>
                    </g>
                  </svg>
                </div>
                <div className="home-action-content3">
                  <div className="action-title">
                    <span>网络状态</span>
                  </div>
                  <div className="action-desc">
                    <span>查看所有网络健康度</span>
                  </div>
                </div>
              </button>
              <button className="action-card">
                <div className="home-action-icon4">
                  <svg
                    width="28"
                    xmlns="http://www.w3.org/2000/svg"
                    height="28"
                    viewBox="0 0 24 24"
                  >
                    <path
                      d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    ></path>
                  </svg>
                </div>
                <div className="home-action-content4">
                  <div className="action-title">
                    <span>备份恢复</span>
                  </div>
                  <div className="action-desc">
                    <span>导出与恢复钱包配置</span>
                  </div>
                </div>
              </button>
            </div>
            <div className="security-checklist">
              <h4 className="checklist-title">安全检查清单</h4>
              <ul className="checklist-items">
                <li className="checklist-item">
                  <svg
                    width="18"
                    xmlns="http://www.w3.org/2000/svg"
                    height="18"
                    viewBox="0 0 24 24"
                  >
                    <path
                      d="M20 6L9 17l-5-5"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    ></path>
                  </svg>
                  <span>创建强密码</span>
                </li>
                <li className="checklist-item">
                  <svg
                    width="18"
                    xmlns="http://www.w3.org/2000/svg"
                    height="18"
                    viewBox="0 0 24 24"
                  >
                    <path
                      d="M20 6L9 17l-5-5"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    ></path>
                  </svg>
                  <span>启用生物识别</span>
                </li>
                <li className="pending checklist-item">
                  <svg
                    width="18"
                    xmlns="http://www.w3.org/2000/svg"
                    height="18"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      r="10"
                      cx="12"
                      cy="12"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    ></circle>
                  </svg>
                  <span>添加首个钱包</span>
                </li>
                <li className="pending checklist-item">
                  <svg
                    width="18"
                    xmlns="http://www.w3.org/2000/svg"
                    height="18"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      r="10"
                      cx="12"
                      cy="12"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    ></circle>
                  </svg>
                  <span>完成备份流程</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>
      <Footer></Footer>
      <a href="https://play.teleporthq.io/signup">
        <div aria-label="Sign up to TeleportHQ" className="home-container24">
          <svg
            width="24"
            height="24"
            viewBox="0 0 19 21"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            className="home-icon98"
          >
            <path
              d="M9.1017 4.64355H2.17867C0.711684 4.64355 -0.477539 5.79975 -0.477539 7.22599V13.9567C-0.477539 15.3829 0.711684 16.5391 2.17867 16.5391H9.1017C10.5687 16.5391 11.7579 15.3829 11.7579 13.9567V7.22599C11.7579 5.79975 10.5687 4.64355 9.1017 4.64355Z"
              fill="#B23ADE"
            ></path>
            <path
              d="M10.9733 12.7878C14.4208 12.7878 17.2156 10.0706 17.2156 6.71886C17.2156 3.3671 14.4208 0.649963 10.9733 0.649963C7.52573 0.649963 4.73096 3.3671 4.73096 6.71886C4.73096 10.0706 7.52573 12.7878 10.9733 12.7878Z"
              fill="#FF5C5C"
            ></path>
            <path
              d="M17.7373 13.3654C19.1497 14.1588 19.1497 15.4634 17.7373 16.2493L10.0865 20.5387C8.67402 21.332 7.51855 20.6836 7.51855 19.0968V10.5141C7.51855 8.92916 8.67402 8.2807 10.0865 9.07221L17.7373 13.3654Z"
              fill="#2874DE"
            ></path>
          </svg>
          <span className="home-text223">Built in TeleportHQ</span>
        </div>
      </a>
    </div>
  )
}

export default Home
