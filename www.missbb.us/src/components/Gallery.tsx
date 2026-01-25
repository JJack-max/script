import React, { useState, useEffect } from 'react';
import { Container, Typography, IconButton, Box, Chip, Divider } from '@mui/material';
import { useTranslation } from 'react-i18next';
import type { Portrait } from '../models/Portrait';
import ImageModal from './ImageModal';

interface GalleryProps {
    portrait: Portrait;
    onBack: () => void;
}

// Helper function to determine if a URL is a video
const isVideoUrl = (url: string): boolean => {
    return url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi') || url.endsWith('.webm');
};

const Gallery: React.FC<GalleryProps> = ({ portrait, onBack }) => {
    const { t } = useTranslation();
    const [modalOpen, setModalOpen] = useState(false);
    const [modalIndex, setModalIndex] = useState(0);

    // Scroll to top when component mounts
    useEffect(() => {
        window.scrollTo(0, 0);
    }, []);

    // Handle browser back button
    useEffect(() => {
        const handlePopState = () => {
            onBack();
        };

        window.addEventListener('popstate', handlePopState);
        return () => {
            window.removeEventListener('popstate', handlePopState);
        };
    }, [onBack]);

    // Handle image click to open modal
    const handleMediaClick = (index: number) => {
        setModalIndex(index);
        setModalOpen(true);
    };

    // Combine photos and videos into a single media array
    const allMedia = [
        ...(portrait.photos || []),
        ...(portrait.videos || [])
    ];

    return (
        <Container maxWidth="lg" sx={{ py: 0.5 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', mb: 0.5 }}>
                <IconButton onClick={onBack} sx={{ mr: 0.5, p: 0.5 }}>
                    <span>←</span> {/* Simple back arrow as text */}
                </IconButton>
                <Typography variant="h6" component="h1" sx={{ fontSize: '1.1rem' }}>
                    {portrait.name}
                </Typography>
            </Box>

            {/* Personal Information Section */}
            <Box sx={{
                backgroundColor: 'background.paper',
                borderRadius: 1,
                p: 1.5,
                mb: 1,
                boxShadow: 1
            }}>
                <Typography variant="h6" component="h2" sx={{ mb: 1, fontSize: '1rem' }}>
                    {t('personalInformation')}
                </Typography>

                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 1 }}>
                    <Box sx={{ flex: '1 1 45%', minWidth: 120 }}>
                        <Typography variant="body2" color="text.secondary">
                            {t('age')}
                        </Typography>
                        <Typography variant="body1">
                            {portrait.age} {t('yearsOld')}
                        </Typography>
                    </Box>

                    <Box sx={{ flex: '1 1 45%', minWidth: 120 }}>
                        <Typography variant="body2" color="text.secondary">
                            {t('nationality')}
                        </Typography>
                        <Typography variant="body1">
                            {portrait.nationality}
                        </Typography>
                    </Box>

                    <Box sx={{ flex: '1 1 45%', minWidth: 120 }}>
                        <Typography variant="body2" color="text.secondary">
                            {t('height')}
                        </Typography>
                        <Typography variant="body1">
                            {portrait.height}
                        </Typography>
                    </Box>

                    <Box sx={{ flex: '1 1 45%', minWidth: 120 }}>
                        <Typography variant="body2" color="text.secondary">
                            {t('weight')}
                        </Typography>
                        <Typography variant="body1">
                            {portrait.weight}
                        </Typography>
                    </Box>

                    <Box sx={{ flex: '1 1 45%', minWidth: 120 }}>
                        <Typography variant="body2" color="text.secondary">
                            {t('bloodType')}
                        </Typography>
                        <Typography variant="body1">
                            {portrait.bloodType}
                        </Typography>
                    </Box>

                    <Box sx={{ flex: '1 1 45%', minWidth: 120 }}>
                        <Typography variant="body2" color="text.secondary">
                            {t('bust')}
                        </Typography>
                        <Typography variant="body1">
                            {portrait.bust}
                        </Typography>
                    </Box>
                </Box>

                <Divider sx={{ my: 1 }} />

                <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
                    {t('frequentlyActiveLocations')}
                </Typography>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                    {portrait.locations.map((location, index) => (
                        <Chip
                            key={index}
                            label={location}
                            size="small"
                            variant="outlined"
                            sx={{ fontSize: '0.75rem', height: 20 }}
                        />
                    ))}
                </Box>

                <Divider sx={{ my: 1 }} />

                <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
                    {t('description')}
                </Typography>
                <Typography variant="body2">
                    {portrait.description}
                </Typography>
            </Box>

            {/* Photo Gallery */}
            <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                {allMedia.map((media, index) => (
                    <Box
                        key={index}
                        onClick={() => handleMediaClick(index)}
                        sx={{
                            width: { xs: '100%', sm: 'calc(50% - 2px)', md: 'calc(33.333% - 3px)' },
                            borderRadius: 0.5,
                            overflow: 'hidden',
                            cursor: 'pointer',
                        }}
                    >
                        {isVideoUrl(media) ? (
                            <Box
                                component="video"
                                src={media}
                                controls
                                sx={{
                                    width: '100%',
                                    height: 'auto',
                                    display: 'block',
                                    borderRadius: 0,
                                }}
                            />
                        ) : (
                            <Box
                                component="img"
                                src={media}
                                alt={`${portrait.name} - Media ${index + 1}`}
                                sx={{
                                    width: '100%',
                                    height: 'auto',
                                    display: 'block',
                                    borderRadius: 0,
                                }}
                            />
                        )}
                    </Box>
                ))}
            </Box>

            {/* Image Modal */}
            {modalOpen && (
                <ImageModal
                    media={allMedia}
                    initialIndex={modalIndex}
                    onClose={() => setModalOpen(false)}
                    isVideoUrl={isVideoUrl}
                />
            )}
        </Container>
    );
};

export default Gallery;