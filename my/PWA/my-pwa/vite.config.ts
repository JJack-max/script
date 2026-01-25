import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';

// https://vitejs.dev/config/
export default defineConfig({
  server: {
    host: '0.0.0.0',
    port: 5173
  },
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      devOptions: {
        enabled: true
      },
      manifest: {
        name: 'My PWA App',
        short_name: 'MyPWA',
        description: 'My Progressive Web App',
        theme_color: '#ffffff',
        icons: [
          {
            src: 'src/assets/logo.png',
            sizes: '192x192',
            type: 'image/png'
          },
          {
            src: 'src/assets/logo.png',
            sizes: '512x512',
            type: 'image/png'
          }
        ]
      }
    })
  ],
});