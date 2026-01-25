# MissBB Portrait Gallery

A responsive React application for showcasing female portrait photography, built with:
- React + TypeScript
- Material-UI (MUI)
- Vite

## Features
- Responsive design for mobile, tablet, and desktop
- Gallery view of models with brief descriptions
- Individual photo galleries for each model
- Video support in galleries (MP4, MOV, AVI, WEBM)
- Contact information display (LINE, Telegram)
- Smooth animations and transitions
- Mobile-friendly swipe gestures for image navigation
- Properly centered layout on all devices

## Development

### Prerequisites
- Node.js
- pnpm

### Installation
```bash
pnpm install
```

### Running the Development Server
```bash
pnpm dev
```

The application will be available at http://localhost:5173

### Building for Production
```bash
pnpm build
```

## Project Structure
- `src/components/` - React components
- `src/models/` - Data models and sample data
- `src/App.tsx` - Main application component
- `src/main.tsx` - Application entry point

## Optimizations

This application has been optimized for performance:
- Code splitting for faster initial loads
- Embedded translations to reduce HTTP requests
- Minimal dependencies
- Efficient component rendering
- Proper bundle chunking (React, MUI, i18next)

## Adding Videos to Galleries

To add videos to a model's gallery:
1. Add video URLs to the `videos` array in the model's data in `src/models/portraitData.ts`
2. Supported video formats: MP4, MOV, AVI, WEBM
3. Videos will automatically appear alongside photos in the gallery view

Example:
```typescript
{
  id: '1',
  name: 'Model Name',
  // ... other properties
  photos: [
    'https://example.com/image1.jpg',
    'https://example.com/image2.jpg'
  ],
  videos: [
    'https://example.com/video1.mp4',
    'https://example.com/video2.mov'
  ]
}
```

## Adding Contact Information

To add contact information (LINE, Telegram, etc.):
1. Update the contact QR codes in `src/App.tsx` in the [ContactInfo](file:///c:/Users/Bob/script/www.missbb.us/src/App.tsx#L59-L62) component
2. Replace the placeholder URLs with actual QR code image URLs
3. The contact information will appear when users scroll to the bottom of the page

Example:
```tsx
<ContactInfo 
  lineQrCode="https://your-website.com/qr-codes/line.png" 
  telegramQrCode="https://your-website.com/qr-codes/telegram.jpg" 
/>
```

## Deployment
This project is configured for deployment on Cloudflare Pages.

### Production CORS Configuration
When deploying to production, you need to configure CORS on your S3 bucket to allow requests from your domain:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
<CORSRule>
    <AllowedOrigin>https://girls.missbb.us</AllowedOrigin>
    <AllowedOrigin>http://localhost:5173</AllowedOrigin>
    <AllowedMethod>GET</AllowedMethod>
    <AllowedHeader>*</AllowedHeader>
</CORSRule>
</CORSConfiguration>
```

Alternatively, you can serve the QR code images from the same domain by placing them in the `public` folder and referencing them as:
```tsx
<ContactInfo 
  lineQrCode="/qr-codes/line.png" 
  telegramQrCode="/qr-codes/telegram.jpg" 
/>
```

### QR Code Display
The application displays QR codes in a simple dialog when users click on the contact buttons. It shows only the QR code image without attempting to parse or extract links from the QR code.

### Image Gallery Navigation
The image gallery supports multiple navigation methods:
- **Swipe Gestures**: Natural touch swipe on mobile devices (swipe left/right to navigate)
- **Navigation Buttons**: Click the arrow buttons on the sides
- **Keyboard**: Use left/right arrow keys on desktop
- **Image Counter**: Shows current position (e.g., 3/10)

The swipe gesture implementation provides a smooth, natural experience on mobile devices with proper touch handling and visual feedback.

### Layout
The application uses a responsive layout that works well on all device sizes:
- **Mobile**: Single column layout with full-width cards
- **Tablet**: Two-column layout
- **Desktop**: Three-column layout with proper centering
- **Large Screens**: Content is properly centered, not aligned to the right

# React + TypeScript + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Babel](https://babeljs.io/) (or [oxc](https://oxc.rs) when used in [rolldown-vite](https://vite.dev/guide/rolldown)) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## React Compiler

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type-aware lint rules:

```js
export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...

      // Remove tseslint.configs.recommended and replace with this
      tseslint.configs.recommendedTypeChecked,
      // Alternatively, use this for stricter rules
      tseslint.configs.strictTypeChecked,
      // Optionally, add this for stylistic rules
      tseslint.configs.stylisticTypeChecked,

      // Other configs...
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```

You can also install [eslint-plugin-react-x](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-x) and [eslint-plugin-react-dom](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-dom) for React-specific lint rules:

```js
// eslint.config.js
import reactX from 'eslint-plugin-react-x'
import reactDom from 'eslint-plugin-react-dom'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...
      // Enable lint rules for React
      reactX.configs['recommended-typescript'],
      // Enable lint rules for React DOM
      reactDom.configs.recommended,
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```