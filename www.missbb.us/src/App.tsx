import { useState, useEffect } from 'react';
import { Container, Box } from '@mui/material';
import PortraitCard from './components/PortraitCard';
import Gallery from './components/Gallery';
import ContactInfo from './components/ContactInfo';
import { portraitData } from './models/portraitData';
import type { Portrait } from './models/Portrait';
import './App.css';

// Helper function to determine the correct QR code URL based on environment
const getQrCodeUrl = (filename: string) => {
  // In development, use the proxy path
  if (import.meta.env.DEV) {
    return `/s3/${filename}`;
  }
  // In production, use the direct S3 URL
  return `https://s3.missbb.us/${filename}`;
};

function App() {
  const [selectedPortrait, setSelectedPortrait] = useState<Portrait | null>(null);
  const [scrollPosition, setScrollPosition] = useState(0);
  const [showContactInfo, setShowContactInfo] = useState(false);
  const [isAtBottom, setIsAtBottom] = useState(false);
  const [contactDialogOpen, setContactDialogOpen] = useState(false);

  // Initialize state from URL on first load
  useEffect(() => {
    const path = window.location.pathname;
    const portraitId = path.split('/')[2];

    if (path.startsWith('/gallery/') && portraitId) {
      const portrait = portraitData.find(p => p.id === portraitId) || null;
      if (portrait) {
        setSelectedPortrait(portrait);
      }
    }
  }, []);

  // Handle portrait selection with proper URL navigation
  const handlePortraitClick = (portrait: Portrait) => {
    // Save current scroll position
    setScrollPosition(window.scrollY);

    // Update URL without page refresh
    window.history.pushState(
      { portraitId: portrait.id, scrollPosition: window.scrollY },
      '',
      `/gallery/${portrait.id}`
    );

    // Set selected portrait
    setSelectedPortrait(portrait);
  };

  // Handle back to gallery with proper URL navigation
  const handleBackToGallery = () => {
    // Update URL without page refresh
    window.history.pushState(
      { portraitId: null, scrollPosition },
      '',
      '/'
    );

    // Clear selected portrait
    setSelectedPortrait(null);

    // Restore scroll position
    setTimeout(() => {
      window.scrollTo(0, scrollPosition);
    }, 0);
  };

  // Handle browser back/forward buttons
  useEffect(() => {
    const handlePopState = (event: PopStateEvent) => {
      if (event.state) {
        // Restore scroll position if available
        if (event.state.scrollPosition !== undefined) {
          setScrollPosition(event.state.scrollPosition);
        }

        // Handle portrait selection
        if (event.state.portraitId) {
          const portrait = portraitData.find(p => p.id === event.state.portraitId) || null;
          setSelectedPortrait(portrait);
          // Scroll to top for gallery view
          setTimeout(() => {
            window.scrollTo(0, 0);
          }, 0);
        } else {
          // Back to main gallery
          setSelectedPortrait(null);
          // Restore scroll position
          setTimeout(() => {
            window.scrollTo(0, event.state.scrollPosition || 0);
          }, 0);
        }
      } else {
        // Handle initial load or unknown state
        const path = window.location.pathname;
        const portraitId = path.split('/')[2];

        if (path.startsWith('/gallery/') && portraitId) {
          const portrait = portraitData.find(p => p.id === portraitId) || null;
          setSelectedPortrait(portrait);
          // Scroll to top for gallery view
          setTimeout(() => {
            window.scrollTo(0, 0);
          }, 0);
        } else {
          setSelectedPortrait(null);
          // Restore scroll position
          setTimeout(() => {
            window.scrollTo(0, scrollPosition);
          }, 0);
        }
      }
    };

    window.addEventListener('popstate', handlePopState);
    return () => {
      window.removeEventListener('popstate', handlePopState);
    };
  }, [scrollPosition]);

  // Check scroll position to show contact info on scroll
  useEffect(() => {
    let timeoutId: ReturnType<typeof setTimeout>;

    const handleScroll = () => {
      // Clear any existing timeout
      if (timeoutId) {
        clearTimeout(timeoutId);
      }

      // Show contact info when user scrolls (unless dialog is open)
      if (!contactDialogOpen) {
        setShowContactInfo(true);
      }

      // Check if user is at bottom of page
      const scrollTop = window.scrollY;
      const windowHeight = window.innerHeight;
      const documentHeight = document.documentElement.scrollHeight;

      // Check if near bottom (within 100px)
      if (scrollTop + windowHeight >= documentHeight - 100) {
        setIsAtBottom(true);
      } else {
        setIsAtBottom(false);
        // Hide contact info after 2 seconds of inactivity (unless at bottom or dialog is open)
        if (!contactDialogOpen) {
          timeoutId = setTimeout(() => {
            setShowContactInfo(false);
          }, 2000);
        }
      }
    };

    window.addEventListener('scroll', handleScroll);
    return () => {
      window.removeEventListener('scroll', handleScroll);
      if (timeoutId) {
        clearTimeout(timeoutId);
      }
    };
  }, [contactDialogOpen]);

  // Handle when contact dialog opens
  const handleContactDialogOpen = () => {
    setContactDialogOpen(true);
    setShowContactInfo(true);
  };

  // Handle when contact dialog closes
  const handleContactDialogClose = () => {
    setContactDialogOpen(false);
  };

  return (
    <div className="App">
      <Container maxWidth="lg" sx={{ py: 0.5 }}>
        {selectedPortrait ? (
          <Gallery portrait={selectedPortrait} onBack={handleBackToGallery} />
        ) : (
          <Box sx={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'center', gap: 0.5 }}>
            {portraitData.map((portrait) => (
              <PortraitCard
                key={portrait.id}
                portrait={portrait}
                onClick={() => handlePortraitClick(portrait)}
              />
            ))}
          </Box>
        )}
      </Container>

      {/* Contact Information - Appears on scroll and hides after inactivity */}
      {(showContactInfo || isAtBottom || contactDialogOpen) && (
        <ContactInfo
          lineQrCode={getQrCodeUrl('line.png')}
          telegramQrCode={getQrCodeUrl('telegram.png')}
          onDialogOpen={handleContactDialogOpen}
          onDialogClose={handleContactDialogClose}
        />
      )}
    </div>
  );
}

export default App;