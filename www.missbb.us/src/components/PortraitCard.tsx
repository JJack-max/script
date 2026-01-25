import React from 'react';
import { Card, CardContent, CardMedia, Typography, CardActionArea } from '@mui/material';
import type { Portrait } from '../models/Portrait';

interface PortraitCardProps {
    portrait: Portrait;
    onClick: () => void;
}

const PortraitCard: React.FC<PortraitCardProps> = ({ portrait, onClick }) => {
    return (
        <Card sx={{
            width: { xs: '100%', sm: 'calc(50% - 8px)', md: 'calc(33.333% - 12px)' },
            margin: 0.5,
            boxShadow: 2,
            '&:hover': {
                boxShadow: 4,
            }
        }}>
            <CardActionArea onClick={onClick}>
                <CardMedia
                    component="img"
                    image={portrait.imageUrl}
                    alt={portrait.name}
                    sx={{ width: '100%', height: 'auto' }}
                />
                <CardContent sx={{ p: 1, '&:last-child': { pb: 1 } }}>
                    <Typography gutterBottom variant="subtitle1" component="div" sx={{ m: 0, fontSize: '1rem' }}>
                        {portrait.name}
                    </Typography>
                    <Typography variant="body2" color="text.secondary" sx={{ fontSize: '0.8rem' }}>
                        {portrait.description}
                    </Typography>
                </CardContent>
            </CardActionArea>
        </Card>
    );
};

export default PortraitCard;