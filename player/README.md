# TikTok Style Video Player (PWA)

A mobile-optimized Progressive Web App (PWA) video player with vertical swipe navigation similar to TikTok, featuring autoplay videos and interactive elements.

## Features

1. **Vertical Swipe Navigation** - Swipe up/down to switch between videos like TikTok
2. **Autoplay Videos** - Videos automatically play when they come into view
3. **TikTok-Style UI** - Familiar interface with likes, comments, shares, and user info
4. **Responsive Design** - Works on mobile and desktop devices
5. **PWA Capabilities** - Installable on devices, works offline
6. **No External Dependencies** - Pure HTML, CSS, and JavaScript implementation

## How to Use

1. Open `index.html` in a browser
2. Videos will automatically load
3. **Swipe up** to go to the next video
4. **Swipe down** to go to the previous video
5. **Tap** on action buttons to interact with videos

## PWA Installation

This application can be installed on mobile devices as a Progressive Web App:

### Android (Chrome)
1. Open the app in Chrome browser
2. Tap the "Add to Home Screen" prompt or menu option
3. Confirm installation

### iOS (Safari)
1. Open the app in Safari browser
2. Tap the share button
3. Select "Add to Home Screen"

Once installed, the app can be used offline and will behave like a native application.

## User Interface

### Video Player
- Full-screen video playback
- Autoplay when in view
- Mobile-optimized with `playsinline` attribute

### Video Information
- Author information with avatar
- Video description
- Music information with spinning icon

### Action Buttons
- Like button (❤️)
- Comment button (💬)
- Share button (↗️)
- User avatar

## Technical Implementation

### Vertical Scrolling
- Uses CSS `scroll-snap-type: y mandatory` for smooth snapping
- `IntersectionObserver` API to detect when videos are in view
- Autoplays videos when 50% visible

### Video Playback
- HTML5 `<video>` element with native controls
- `playsinline` attribute for mobile optimization
- Autoplay handling with error catching

### PWA Features
- Web App Manifest for installability
- Service Worker for offline functionality
- Responsive design for all device sizes

### Responsive Design
- Flexbox layout for adaptive UI
- Media queries for mobile optimization
- Touch-friendly elements

## Customization

To add your own videos:
1. Modify the `playlist` array in `script.js`
2. Add objects with the following properties:
   - `id`: Unique identifier
   - `url`: Video file URL
   - `author`: Content creator name
   - `description`: Video description
   - `music`: Background music information
   - `likes`: Like count
   - `comments`: Comment count
   - `shares`: Share count

Example:
```javascript
{
    id: 1,
    url: "path/to/video.mp4",
    author: "Your Name",
    description: "Your video description",
    music: "Original Sound",
    likes: "10K",
    comments: "500",
    shares: "1K"
}
```

## Browser Support

- Chrome 60+
- Firefox 63+
- Safari 11+
- Edge 79+

## Mobile Considerations

- Designed for portrait orientation
- Touch-optimized interface
- Autoplay works on most mobile browsers
- Scroll snapping for smooth navigation