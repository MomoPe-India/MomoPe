import { Metadata } from 'next';
import { ContactContent } from '@/components/ContactContent';

export const metadata: Metadata = {
    title: 'Contact Us - MomoPe | Support & Partnerships',
    description: 'Get in touch with the MomoPe team. Visit our registered office in Kadapa or contact us via email/phone for support and merchant partnerships.',
};

export default function ContactPage() {
    return <ContactContent />;
}
