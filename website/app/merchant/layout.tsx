import { Metadata } from "next";

export const metadata: Metadata = {
    title: "MomoPe Merchant | Grow Your Business with India's First Commerce Cloud",
    description: "Accept UPI payments, build customer loyalty, and get instant settlements. Transform your shop into a smart business with MomoPe's Growth OS.",
    alternates: {
        canonical: '/merchant',
    },
    openGraph: {
        title: "Grow Your Offline Business | MomoPe Merchant",
        description: "Zero cost customer acquisition and automated loyalty. Join thousands of smart Indian merchants.",
        images: ["/merchant-og.png"],
    }
};

export default function MerchantLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <>
            {children}
        </>
    );
}
