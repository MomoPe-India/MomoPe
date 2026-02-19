import { Metadata } from 'next';
import { MediaKitContent } from '@/components/MediaKitContent';

export const metadata: Metadata = {
    title: 'Media Kit - MomoPe | Official Brand Assets & Press Resources',
    description: 'Download official MomoPe brand assets, logos, and leadership profiles. Access press releases and company background for media coverage.',
};

export default function MediaKitPage() {
    return <MediaKitContent />;
}
