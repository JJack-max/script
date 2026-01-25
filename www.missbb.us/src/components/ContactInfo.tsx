import React, { useState } from 'react';
import { Box, Typography, IconButton, Dialog, DialogContent, DialogTitle, Button } from '@mui/material';
import { useTranslation } from 'react-i18next';

interface ContactInfoProps {
    lineQrCode?: string;
    telegramQrCode?: string;
    onDialogOpen?: () => void;
    onDialogClose?: () => void;
}

const ContactInfo: React.FC<ContactInfoProps> = ({ lineQrCode, telegramQrCode, onDialogOpen, onDialogClose }) => {
    const { t } = useTranslation();
    const [openDialog, setOpenDialog] = useState<{
        type: 'line' | 'telegram' | null;
        url: string | null;
    }>({ type: null, url: null });

    const handleOpenQrCode = (type: 'line' | 'telegram', url: string) => {
        // Notify parent that dialog is opening
        onDialogOpen?.();
        setOpenDialog({ type, url });
    };

    const handleCloseDialog = () => {
        setOpenDialog({ type: null, url: null });
        // Notify parent that dialog is closing
        onDialogClose?.();
    };

    const hasContactInfo = lineQrCode || telegramQrCode;

    if (!hasContactInfo) {
        return null;
    }

    return (
        <Box sx={{
            position: 'fixed',
            bottom: 16,
            right: 16,
            zIndex: 1000,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'flex-end',
            gap: 1
        }}>
            <Box sx={{
                display: 'flex',
                gap: 1,
                bgcolor: 'background.paper',
                borderRadius: 2,
                p: 1,
                boxShadow: 2
            }}>
                {lineQrCode && (
                    <Button
                        variant="outlined"
                        size="small"
                        onClick={() => handleOpenQrCode('line', lineQrCode)}
                        sx={{
                            textTransform: 'none',
                            fontSize: '0.75rem',
                            minWidth: 80,
                            p: '4px 8px'
                        }}
                    >
                        LINE
                    </Button>
                )}

                {telegramQrCode && (
                    <Button
                        variant="outlined"
                        size="small"
                        onClick={() => handleOpenQrCode('telegram', telegramQrCode)}
                        sx={{
                            textTransform: 'none',
                            fontSize: '0.75rem',
                            minWidth: 80,
                            p: '4px 8px'
                        }}
                    >
                        Telegram
                    </Button>
                )}
            </Box>

            {/* QR Code Dialog */}
            <Dialog
                open={openDialog.type !== null}
                onClose={handleCloseDialog}
                maxWidth="xs"
                fullWidth
            >
                <DialogTitle>
                    {openDialog.type === 'line' ? t('lineContact') : t('telegramContact')}
                </DialogTitle>
                <IconButton
                    onClick={handleCloseDialog}
                    sx={{
                        position: 'absolute',
                        right: 8,
                        top: 8
                    }}
                >
                    <Typography variant="h6" component="span">✕</Typography>
                </IconButton>
                <DialogContent sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', p: 2, gap: 2 }}>
                    {openDialog.url && (
                        <>
                            <Box
                                component="img"
                                src={openDialog.url}
                                alt={`${openDialog.type} QR Code`}
                                sx={{
                                    maxWidth: '100%',
                                    height: 'auto',
                                    borderRadius: 1
                                }}
                            />
                            <Typography variant="body2" sx={{ textAlign: 'center' }}>
                                {t('scanQrCode', { app: openDialog.type === 'line' ? 'LINE' : 'Telegram' })}
                            </Typography>
                        </>
                    )}
                </DialogContent>
            </Dialog>
        </Box>
    );
};

export default ContactInfo;