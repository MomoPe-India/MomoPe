"use client";

import { usePathname } from 'next/navigation';

export function JsonLd() {
    const pathname = usePathname();

    const organizationSchema = {
        "@context": "https://schema.org",
        "@type": "Organization",
        "name": "MomoPe",
        "alternateName": "MomoPe Digital",
        "url": "https://momope.com",
        "logo": "https://momope.com/logo.png",
        "description": "India's first Offline-to-Online Commerce Cloud for local merchants.",
        "sameAs": [
            "https://twitter.com/momope",
            "https://linkedin.com/company/momope",
            "https://instagram.com/momope"
        ],
        "contactPoint": {
            "@type": "ContactPoint",
            "telephone": "+91-80-0000-0000",
            "contactType": "customer service",
            "areaServed": "IN",
            "availableLanguage": "en"
        },
        "address": {
            "@type": "PostalAddress",
            "addressLocality": "Bengaluru",
            "addressRegion": "Karnataka",
            "addressCountry": "IN"
        }
    };

    const breadcrumbSchema = {
        "@context": "https://schema.org",
        "@type": "BreadcrumbList",
        "itemListElement": [
            {
                "@type": "ListItem",
                "position": 1,
                "name": "Home",
                "item": "https://momope.com"
            },
            ...(pathname === '/merchant' ? [{
                "@type": "ListItem",
                "position": 2,
                "name": "Merchant",
                "item": "https://momope.com/merchant"
            }] : [])
        ]
    };

    const merchantFaqSchema = {
        "@context": "https://schema.org",
        "@type": "FAQPage",
        "mainEntity": [
            {
                "@type": "Question",
                "name": "How much does MomoPe cost for merchants?",
                "acceptedAnswer": {
                    "@type": "Answer",
                    "text": "Zero setup cost. You only pay a small commission on successful transactions, which covers customer acquisition and loyalty program costs."
                }
            },
            {
                "@type": "Question",
                "name": "When are settlements processed?",
                "acceptedAnswer": {
                    "@type": "Answer",
                    "text": "MomoPe offers standard T+1 settlements. Instant settlement options are available for premium merchants."
                }
            },
            {
                "@type": "Question",
                "name": "Do I need a special device to use MomoPe?",
                "acceptedAnswer": {
                    "@type": "Answer",
                    "text": "No, you just need a smartphone and our printed QR code. Soundboxes and POS devices are optional for high-volume stores."
                }
            }
        ]
    };

    return (
        <>
            <script
                type="application/ld+json"
                dangerouslySetInnerHTML={{ __html: JSON.stringify(organizationSchema) }}
            />
            <script
                type="application/ld+json"
                dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }}
            />
            {pathname === '/merchant' && (
                <script
                    type="application/ld+json"
                    dangerouslySetInnerHTML={{ __html: JSON.stringify(merchantFaqSchema) }}
                />
            )}
        </>
    );
}
