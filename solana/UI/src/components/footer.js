import React from 'react'

import Script from 'dangerous-html/react'

import './footer.css'

const Footer = (props) => {
  return (
    <div className="footer-container1">
      <div className="footer-container2">
        <div className="footer-container3">
          <Script
            html={`<style>
        @keyframes footer-glow-pulse {0%,100% {opacity: 0.3;
transform: translateX(-50%) scale(1);}
50% {opacity: 0.5;
transform: translateX(-50%) scale(1.1);}}@keyframes footer-logo-glow {0%,100% {box-shadow: 0 0 20px
        color-mix(in srgb, var(--color-primary) 20%, transparent);}
50% {box-shadow: 0 0 30px
          color-mix(in srgb, var(--color-primary) 40%, transparent),
        0 0 40px color-mix(in srgb, var(--color-primary) 20%, transparent);}}@keyframes footer-status-pulse {0%,100% {opacity: 1;
transform: scale(1);}
50% {opacity: 0.6;
transform: scale(1.2);}}
        </style> `}
          ></Script>
        </div>
      </div>
      <div className="footer-container4">
        <div className="footer-container5">
          <Script
            html={`<style>
@media (prefers-reduced-motion: reduce) {
.footer-glow-effect, .footer-logo-icon, .footer-status-dot, .footer-badge, .footer-nav-link, .footer-social-link, .footer-link-arrow {
  animation: none;
  transition: none;
}
}
</style>`}
          ></Script>
        </div>
      </div>
      <div className="footer-container6">
        <div className="footer-container7">
          <Script
            html={`<script defer data-name="footer-interactions">
(function(){
  // Enhanced footer interactions with tech-savvy animations

  // Staggered fade-in animation for nav items
  const observerOptions = {
    threshold: 0.1,
    rootMargin: "0px 0px -50px 0px",
  }

  const footerObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        const navColumns = entry.target.querySelectorAll(".footer-nav-column")
        navColumns.forEach((column, index) => {
          setTimeout(() => {
            column.style.opacity = "1"
            column.style.transform = "translateY(0)"
          }, index * 100)
        })

        footerObserver.unobserve(entry.target)
      }
    })
  }, observerOptions)

  // Initialize animations
  const footerNavGrid = document.querySelector(".footer-nav-grid")
  if (footerNavGrid) {
    const navColumns = footerNavGrid.querySelectorAll(".footer-nav-column")
    navColumns.forEach((column) => {
      column.style.opacity = "0"
      column.style.transform = "translateY(20px)"
      column.style.transition = "opacity 0.6s ease-out, transform 0.6s ease-out"
    })

    footerObserver.observe(footerNavGrid)
  }

  // Glowing cursor effect on hover
  const footerContainer = document.getElementById("footer")
  if (footerContainer) {
    let glowElement = null

    footerContainer.addEventListener("mousemove", (e) => {
      if (!glowElement) {
        glowElement = document.createElement("div")
        glowElement.style.cssText = \`
        position: absolute;
        width: 300px;
        height: 300px;
        border-radius: 50%;
        background: radial-gradient(circle, 
          color-mix(in srgb, var(--color-primary) 8%, transparent),
          transparent 70%);
        pointer-events: none;
        z-index: 2;
        transition: opacity 0.3s ease;
        opacity: 0;
      \`
        footerContainer.appendChild(glowElement)
      }

      const rect = footerContainer.getBoundingClientRect()
      const x = e.clientX - rect.left
      const y = e.clientY - rect.top

      glowElement.style.left = x - 150 + "px"
      glowElement.style.top = y - 150 + "px"
      glowElement.style.opacity = "1"
    })

    footerContainer.addEventListener("mouseleave", () => {
      if (glowElement) {
        glowElement.style.opacity = "0"
      }
    })
  }

  // Animate security badges on scroll
  const badges = document.querySelectorAll(".footer-badge")
  if (badges.length > 0) {
    const badgeObserver = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry, index) => {
          if (entry.isIntersecting) {
            setTimeout(() => {
              entry.target.style.opacity = "1"
              entry.target.style.transform = "translateX(0)"
            }, index * 150)
            badgeObserver.unobserve(entry.target)
          }
        })
      },
      { threshold: 0.3 }
    )

    badges.forEach((badge) => {
      badge.style.opacity = "0"
      badge.style.transform = "translateX(-20px)"
      badge.style.transition = "opacity 0.5s ease-out, transform 0.5s ease-out"
      badgeObserver.observe(badge)
    })
  }

  // Social link ripple effect
  const socialLinks = document.querySelectorAll(".footer-social-link")
  socialLinks.forEach((link) => {
    link.addEventListener("click", (e) => {
      const ripple = document.createElement("span")
      const rect = link.getBoundingClientRect()
      const size = Math.max(rect.width, rect.height)
      const x = e.clientX - rect.left - size / 2
      const y = e.clientY - rect.top - size / 2

      ripple.style.cssText = \`
      position: absolute;
      width: \${size}px;
      height: \${size}px;
      left: \${x}px;
      top: \${y}px;
      background: color-mix(in srgb, var(--color-primary) 30%, transparent);
      border-radius: 50%;
      transform: scale(0);
      animation: footer-ripple 0.6s ease-out;
      pointer-events: none;
      z-index: 1;
    \`

      link.appendChild(ripple)

      setTimeout(() => {
        ripple.remove()
      }, 600)
    })
  })

  // Add ripple animation
  const style = document.createElement("style")
  style.textContent = \`
  @keyframes footer-ripple {
    to {
      transform: scale(2);
      opacity: 0;
    }
  }
\`
  document.head.appendChild(style)
})()
</script>`}
          ></Script>
        </div>
      </div>
      <footer id="footer" className="footer-container">
        <div className="footer-glow-effect"></div>
        <div className="footer-grid-pattern"></div>
        <div className="footer-content">
          <div className="footer-brand">
            <div className="footer-logo-wrapper">
              <div className="footer-logo-icon">
                <svg
                  width="32"
                  xmlns="http://www.w3.org/2000/svg"
                  height="32"
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
              <h2 className="footer-brand-name">SolanaVault</h2>
            </div>
            <p className="footer-brand-tagline">安全的多链钱包管理解决方案</p>
            <p className="footer-brand-description">
              {' '}
              支持多网络、多钱包，为您的数字资产提供企业级安全保护
              <span
                dangerouslySetInnerHTML={{
                  __html: ' ',
                }}
              />
            </p>
            <div className="footer-security-badges">
              <div className="footer-badge">
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
                <span>端到端加密</span>
              </div>
              <div className="footer-badge">
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
                    <rect x="16" y="16" rx="1" width="6" height="6"></rect>
                    <rect x="2" y="16" rx="1" width="6" height="6"></rect>
                    <rect x="9" y="2" rx="1" width="6" height="6"></rect>
                    <path d="M5 16v-3a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v3m-7-4V8"></path>
                  </g>
                </svg>
                <span>多链支持</span>
              </div>
            </div>
          </div>
          <div className="footer-nav-grid">
            <div className="footer-nav-column">
              <h3 className="footer-nav-title">产品</h3>
              <ul className="footer-nav-list">
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">移动钱包</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">多网络管理</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">资产追踪</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">安全功能</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
              </ul>
            </div>
            <div className="footer-nav-column">
              <h3 className="footer-nav-title">资源</h3>
              <ul className="footer-nav-list">
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">开发文档</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">API 参考</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">安全指南</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">常见问题</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
              </ul>
            </div>
            <div className="footer-nav-column">
              <h3 className="footer-nav-title">公司</h3>
              <ul className="footer-nav-list">
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">关于我们</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">团队介绍</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">招聘职位</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">联系我们</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
              </ul>
            </div>
            <div className="footer-nav-column">
              <h3 className="footer-nav-title">法律条款</h3>
              <ul className="footer-nav-list">
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">隐私政策</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">服务条款</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">Cookie 政策</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
                <li className="footer-nav-item">
                  <a href="/">
                    <div className="footer-nav-link">
                      <span className="footer-link-text">合规声明</span>
                      <span className="footer-link-arrow"></span>
                    </div>
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>
        <div className="footer-bottom">
          <div className="footer-bottom-content">
            <div className="footer-bottom-left">
              <p className="footer-copyright">© 2025 SolanaVault. 版权所有</p>
              <div className="footer-tech-indicator">
                <span className="footer-status-dot"></span>
                <span className="footer-status-text">系统运行正常</span>
              </div>
            </div>
            <div className="footer-social-links">
              <a href="#">
                <div aria-label="GitHub" className="footer-social-link">
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
                      <path d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5c.08-1.25-.27-2.48-1-3.5c.28-1.15.28-2.35 0-3.5c0 0-1 0-3 1.5c-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.4 5.4 0 0 0 4 9c0 3.5 3 5.5 6 5.5c-.39.49-.68 1.05-.85 1.65S8.93 17.38 9 18v4"></path>
                      <path d="M9 18c-4.51 2-5-2-7-2"></path>
                    </g>
                  </svg>
                </div>
              </a>
              <a href="#">
                <div aria-label="Twitter" className="footer-social-link">
                  <svg
                    width="20"
                    xmlns="http://www.w3.org/2000/svg"
                    height="20"
                    viewBox="0 0 24 24"
                  >
                    <path
                      d="M22 4s-.7 2.1-2 3.4c1.6 10-9.4 17.3-18 11.6c2.2.1 4.4-.6 6-2C3 15.5.5 9.6 3 5c2.2 2.6 5.6 4.1 9 4c-.9-4.2 4-6.6 7-3.8c1.1 0 3-1.2 3-1.2"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    ></path>
                  </svg>
                </div>
              </a>
              <a href="#">
                <div aria-label="Email" className="footer-social-link">
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
                      <path d="m22 7l-8.991 5.727a2 2 0 0 1-2.009 0L2 7"></path>
                      <rect x="2" y="4" rx="2" width="20" height="16"></rect>
                    </g>
                  </svg>
                </div>
              </a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}

export default Footer
