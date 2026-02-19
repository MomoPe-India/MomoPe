import { Metadata } from 'next';
import { DownloadContent } from '@/components/DownloadContent';

export const metadata: Metadata = {
    title: 'Download MomoPe - The #1 Rewards App for India',
    description: 'Get the MomoPe app on iOS and Android. Join 10,000+ users earning real cashback on every local payment. Scan, pay, and save.',
};

export default function DownloadPage() {
    return <DownloadContent />;
}
