import React from 'react'

import Script from 'dangerous-html/react'

import './navigation.css'

const Navigation = (props) => {
  return (
    <div className="navigation-container1">
      <div className="navigation-container2">
        <div className="navigation-container3">
          <Script
            html={`<style>
        @keyframes navigationGlowPulse {0%,100% {opacity: 0.4;
transform: scaleX(1);}
50% {opacity: 0.8;
transform: scaleX(1.02);}}@keyframes navigationScanline {0% {left: -100%;}
100% {left: 200%;}}@keyframes navigationLogoShine {0%,100% {transform: translateX(-100%) rotate(45deg);}
50% {transform: translateX(100%) rotate(45deg);}}
        </style> `}
          ></Script>
        </div>
      </div>
      <div className="navigation-container4">
        <div className="navigation-container5">
          <Script
            html={`<style>
@media (prefers-reduced-motion: reduce) {
.navigation-wrapper::before, .navigation-scanline, .navigation-logo-icon::before {
  animation: none;
}
.navigation-link, .navigation-toggle, .navigation-menu {
  transition-duration: 0.01ms;
}
}
</style>`}
          ></Script>
        </div>
      </div>
      <div className="navigation-container6">
        <div className="navigation-container7">
          <Script
            html={`<script defer data-name="navigation">
(function(){
  const navigationToggle = document.getElementById("navigationToggle")
  const navigationMenu = document.getElementById("navigationMenu")

  if (navigationToggle && navigationMenu) {
    navigationToggle.addEventListener("click", () => {
      const isExpanded =
        navigationToggle.getAttribute("aria-expanded") === "true"

      navigationToggle.setAttribute("aria-expanded", !isExpanded)
      navigationMenu.classList.toggle("navigation-menu-open")

      // Prevent body scroll when menu is open
      if (!isExpanded) {
        document.body.style.overflow = "hidden"
      } else {
        document.body.style.overflow = ""
      }
    })

    // Close menu when clicking outside
    document.addEventListener("click", (event) => {
      const isClickInside =
        navigationToggle.contains(event.target) ||
        navigationMenu.contains(event.target)

      if (
        !isClickInside &&
        navigationMenu.classList.contains("navigation-menu-open")
      ) {
        navigationToggle.setAttribute("aria-expanded", "false")
        navigationMenu.classList.remove("navigation-menu-open")
        document.body.style.overflow = ""
      }
    })

    // Close menu when pressing Escape key
    document.addEventListener("keydown", (event) => {
      if (
        event.key === "Escape" &&
        navigationMenu.classList.contains("navigation-menu-open")
      ) {
        navigationToggle.setAttribute("aria-expanded", "false")
        navigationMenu.classList.remove("navigation-menu-open")
        document.body.style.overflow = ""
        navigationToggle.focus()
      }
    })

    // Close menu on window resize if above mobile breakpoint
    let resizeTimer
    window.addEventListener("resize", () => {
      clearTimeout(resizeTimer)
      resizeTimer = setTimeout(() => {
        if (
          window.innerWidth > 991 &&
          navigationMenu.classList.contains("navigation-menu-open")
        ) {
          navigationToggle.setAttribute("aria-expanded", "false")
          navigationMenu.classList.remove("navigation-menu-open")
          document.body.style.overflow = ""
        }
      }, 250)
    })

    // Handle navigation link clicks on mobile
    const navLinks = navigationMenu.querySelectorAll(".navigation-link")
    navLinks.forEach((link) => {
      link.addEventListener("click", () => {
        if (window.innerWidth <= 991) {
          navigationToggle.setAttribute("aria-expanded", "false")
          navigationMenu.classList.remove("navigation-menu-open")
          document.body.style.overflow = ""
        }
      })
    })
  }
})()
</script>`}
          ></Script>
        </div>
      </div>
      <nav id="mainNavigation" className="navigation-wrapper">
        <div className="navigation-container">
          <a href="/">
            <div aria-label="SolanaVault 首页" className="navigation-logo">
              <div className="navigation-logo-icon">
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
                    <path d="M19 7V4a1 1 0 0 0-1-1H5a2 2 0 0 0 0 4h15a1 1 0 0 1 1 1v4h-3a2 2 0 0 0 0 4h3a1 1 0 0 0 1-1v-2a1 1 0 0 0-1-1"></path>
                    <path d="M3 5v14a2 2 0 0 0 2 2h15a1 1 0 0 0 1-1v-4"></path>
                  </g>
                </svg>
              </div>
              <span className="navigation-logo-text">SolanaVault</span>
            </div>
          </a>
          <button
            id="navigationToggle"
            aria-label="切换菜单"
            aria-controls="navigationMenu"
            aria-expanded="false"
            className="navigation-toggle"
          >
            <span className="navigation-navigation-toggle-icon1">
              <svg
                width="24"
                xmlns="http://www.w3.org/2000/svg"
                height="24"
                viewBox="0 0 24 24"
              >
                <path
                  d="M4 5h16M4 12h16M4 19h16"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                ></path>
              </svg>
            </span>
            <span className="navigation-navigation-toggle-icon2">
              <svg
                width="24"
                xmlns="http://www.w3.org/2000/svg"
                height="24"
                viewBox="0 0 24 24"
              >
                <path
                  d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1zm-5.5-3.5l-5 5m0-5l5 5"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                ></path>
              </svg>
            </span>
          </button>
          <div id="navigationMenu" className="navigation-menu">
            <ul className="navigation-list">
              <li className="navigation-item">
                <a href="#features">
                  <div className="navigation-link">
                    <span className="navigation-link-text">功能特性</span>
                    <span className="navigation-link-glow"></span>
                  </div>
                </a>
              </li>
              <li className="navigation-item">
                <a href="#security">
                  <div className="navigation-link">
                    <span className="navigation-link-text">安全保障</span>
                    <span className="navigation-link-glow"></span>
                  </div>
                </a>
              </li>
              <li className="navigation-item">
                <a href="#networks">
                  <div className="navigation-link">
                    <span className="navigation-link-text">支持网络</span>
                    <span className="navigation-link-glow"></span>
                  </div>
                </a>
              </li>
              <li className="navigation-item">
                <a href="#download">
                  <div className="navigation-link">
                    <span className="navigation-link-text">下载应用</span>
                    <span className="navigation-link-glow"></span>
                  </div>
                </a>
              </li>
            </ul>
            <div className="navigation-actions">
              <a href="#login">
                <div className="btn navigation-cta-secondary btn-outline">
                  <span>
                    {' '}
                    登录
                    <span
                      dangerouslySetInnerHTML={{
                        __html: ' ',
                      }}
                    />
                  </span>
                </div>
              </a>
              <a href="#start">
                <div className="btn-primary navigation-cta-primary btn">
                  <span>
                    {' '}
                    开始使用
                    <span
                      dangerouslySetInnerHTML={{
                        __html: ' ',
                      }}
                    />
                  </span>
                </div>
              </a>
            </div>
          </div>
        </div>
        <div aria-hidden="true" className="navigation-scanline"></div>
      </nav>
    </div>
  )
}

export default Navigation
