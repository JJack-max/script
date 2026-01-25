import React, { useState, useEffect } from 'react';
import { Box, IconButton, Typography } from '@mui/material';

interface ImageModalProps {
    media: string[];
    initialIndex: number;
    onClose: () => void;
    isVideoUrl: (url: string) => boolean;
}

const ImageModal: React.FC<ImageModalProps> = ({ media, initialIndex, onClose, isVideoUrl }) => {
    const [currentIndex, setCurrentIndex] = useState(initialIndex);
    const [offset, setOffset] = useState(0);
    const [isDragging, setIsDragging] = useState(false);
    const [startX, setStartX] = useState(0);

    const currentMedia = media[currentIndex];

    // Handle keyboard navigation
    useEffect(() => {
        const handleKeyDown = (e: KeyboardEvent) => {
            if (e.key === 'Escape') {
                onClose();
            } else if (e.key === 'ArrowLeft') {
                goToPrev();
            } else if (e.key === 'ArrowRight') {
                goToNext();
            }
        };

        window.addEventListener('keydown', handleKeyDown);
        return () => {
            window.removeEventListener('keydown', handleKeyDown);
        };
    }, [currentIndex, onClose]);

    const goToPrev = () => {
        setCurrentIndex((prev) => (prev === 0 ? media.length - 1 : prev - 1));
        setOffset(0);
    };

    const goToNext = () => {
        setCurrentIndex((prev) => (prev === media.length - 1 ? 0 : prev + 1));
        setOffset(0);
    };

    // Touch event handlers for swipe gestures
    const handleTouchStart = (e: React.TouchEvent) => {
        setIsDragging(true);
        setStartX(e.touches[0].clientX);
        setOffset(0);
    };

    const handleTouchMove = (e: React.TouchEvent) => {
        if (!isDragging) return;

        const currentX = e.touches[0].clientX;
        const diff = currentX - startX;
        setOffset(diff);
    };

    const handleTouchEnd = () => {
        if (!isDragging) return;

        setIsDragging(false);

        // Determine if swipe was significant enough to change image
        const threshold = window.innerWidth * 0.2; // 20% of screen width

        if (Math.abs(offset) > threshold) {
            if (offset > 0) {
                goToPrev(); // Swipe right - previous image
            } else {
                goToNext(); // Swipe left - next image
            }
        } else {
            // Not enough swipe, snap back to center
            setOffset(0);
        }
    };

    // Mouse event handlers for desktop
    const handleMouseDown = (e: React.MouseEvent) => {
        setIsDragging(true);
        setStartX(e.clientX);
        setOffset(0);
    };

    const handleMouseMove = (e: React.MouseEvent) => {
        if (!isDragging) return;

        const currentX = e.clientX;
        const diff = currentX - startX;
        setOffset(diff);
    };

    const handleMouseUp = () => {
        if (!isDragging) return;

        setIsDragging(false);

        // Determine if swipe was significant enough to change image
        const threshold = window.innerWidth * 0.2; // 20% of screen width

        if (Math.abs(offset) > threshold) {
            if (offset > 0) {
                goToPrev(); // Swipe right - previous image
            } else {
                goToNext(); // Swipe left - next image
            }
        } else {
            // Not enough swipe, snap back to center
            setOffset(0);
        }
    };

    // Reset offset when currentIndex changes
    useEffect(() => {
        setOffset(0);
    }, [currentIndex]);

    return (
        <Box
            sx={{
                position: 'fixed',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                bgcolor: 'rgba(0, 0, 0, 0.9)',
                zIndex: 1300,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                userSelect: 'none',
                touchAction: 'none',
            }}
            onTouchStart={handleTouchStart}
            onTouchMove={handleTouchMove}
            onTouchEnd={handleTouchEnd}
            onMouseDown={handleMouseDown}
            onMouseMove={handleMouseMove}
            onMouseUp={handleMouseUp}
            onMouseLeave={handleMouseUp}
        >
            {/* Close button */}
            <IconButton
                onClick={onClose}
                sx={{
                    position: 'absolute',
                    top: 16,
                    right: 16,
                    color: 'white',
                    zIndex: 1400,
                    width: 40,
                    height: 40,
                }}
            >
                <Typography variant="h6" component="span" sx={{ color: 'white' }}>
                    ✕
                </Typography>
            </IconButton>

            {/* Navigation buttons */}
            <IconButton
                onClick={goToPrev}
                sx={{
                    position: 'absolute',
                    left: 16,
                    color: 'white',
                    zIndex: 1400,
                    width: 40,
                    height: 40,
                }}
            >
                <Typography variant="h6" component="span" sx={{ color: 'white' }}>
                    ‹
                </Typography>
            </IconButton>

            <IconButton
                onClick={goToNext}
                sx={{
                    position: 'absolute',
                    right: 16,
                    color: 'white',
                    zIndex: 1400,
                    width: 40,
                    height: 40,
                }}
            >
                <Typography variant="h6" component="span" sx={{ color: 'white' }}>
                    ›
                </Typography>
            </IconButton>

            {/* Image counter */}
            <Typography
                variant="body2"
                sx={{
                    position: 'absolute',
                    top: 16,
                    left: 16,
                    color: 'white',
                    zIndex: 1400,
                }}
            >
                {currentIndex + 1} / {media.length}
            </Typography>

            {/* Media display with swipe transition */}
            <Box
                sx={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    width: '100%',
                    height: '100%',
                    p: 2,
                    transition: isDragging ? 'none' : 'transform 0.3s ease-out',
                    transform: `translateX(${offset}px)`,
                }}
            >
                {isVideoUrl(currentMedia) ? (
                    <Box
                        component="video"
                        src={currentMedia}
                        controls
                        autoPlay
                        sx={{
                            maxWidth: '90vw',
                            maxHeight: '90vh',
                            objectFit: 'contain',
                        }}
                    />
                ) : (
                    <Box
                        component="img"
                        src={currentMedia}
                        alt="Full screen view"
                        sx={{
                            maxWidth: '90vw',
                            maxHeight: '90vh',
                            objectFit: 'contain',
                        }}
                    />
                )}
            </Box>
        </Box>
    );
};

export default ImageModal;