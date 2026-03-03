// src/lib/notifications.ts
// Utility to send push notifications using Firebase Admin SDK.

import { adminAuth, adminDb } from './admin-clients';
import * as admin from 'firebase-admin';

export async function sendPushNotification(
    userId: string,
    payload: {
        title: string;
        body: string;
        data?: Record<string, string>;
    }
) {
    try {
        // 1. Get tokens from fcm_tokens table
        const { data: tokens, error } = await adminDb
            .from('fcm_tokens')
            .select('device_token')
            .eq('user_id', userId);

        if (error || !tokens || tokens.length === 0) {
            console.log(`[Push] No tokens found for user ${userId}`);
            return;
        }

        const deviceTokens = tokens.map(t => t.device_token);

        // 2. Send via Firebase Admin
        const message: admin.messaging.MulticastMessage = {
            tokens: deviceTokens,
            notification: {
                title: payload.title,
                body: payload.body,
            },
            data: payload.data,
            android: {
                priority: 'high',
                notification: {
                    sound: 'default',
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                }
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                    }
                }
            }
        };

        const response = await admin.messaging().sendEachForMulticast(message);
        console.log(`[Push] Sent ${response.successCount} successful messages for ${userId}`);

        // Cleanup failed tokens if needed (invalid ones)
        if (response.failureCount > 0) {
            const failedTokens: string[] = [];
            response.responses.forEach((resp, idx) => {
                if (!resp.success) {
                    const code = resp.error?.code;
                    if (code === 'messaging/invalid-registration-token' || code === 'messaging/registration-token-not-registered') {
                        failedTokens.push(deviceTokens[idx]);
                    }
                }
            });

            if (failedTokens.length > 0) {
                await adminDb.from('fcm_tokens').delete().in('device_token', failedTokens);
                console.log(`[Push] Cleaned up ${failedTokens.length} stale tokens`);
            }
        }
    } catch (err) {
        console.error('[Push] Fatal error:', err);
    }
}
