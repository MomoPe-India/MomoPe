import { Metadata } from 'next';
import { ReferralContent } from '@/components/ReferralContent';

export const metadata: Metadata = {
    title: 'Refer & Earn - MomoPe | Grow Together',
    description: 'Invite your friends to MomoPe and earn bonus coins. Share your unique code, track referrals, and grow your rewards wallet.',
};

export default function ReferralPage() {
    return <ReferralContent />;
}
