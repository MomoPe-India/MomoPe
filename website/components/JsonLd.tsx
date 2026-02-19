export function JsonLd() {
    const organizationSchema = {
        "@context": "https://schema.org",
        "@type": "Organization",
        "name": "MomoPe",
        "url": "https://momope.com",
        "logo": "https://momope.com/logo.png",
        "sameAs": [
            "https://twitter.com/momope",
            "https://linkedin.com/company/momope",
            "https://instagram.com/momope"
        ],
        "contactPoint": {
            "@type": "ContactPoint",
            "telephone": "+91-80-1234-5678",
            "contactType": "customer service",
            "areaServed": "IN",
            "availableLanguage": "en"
        }
    };

    const appSchema = {
        "@context": "https://schema.org",
        "@type": "SoftwareApplication",
        "name": "MomoPe",
        "applicationCategory": "FinanceApplication",
        "operatingSystem": "Android, iOS",
        "offers": {
            "@type": "Offer",
            "price": "0",
            "priceCurrency": "INR"
        },
        "aggregateRating": {
            "@type": "AggregateRating",
            "ratingValue": "4.8",
            "ratingCount": "1250"
        }
    };

    return (
        <>
            <script
                type="application/ld+json"
                dangerouslySetInnerHTML={{ __html: JSON.stringify(organizationSchema) }}
            />
            <script
                type="application/ld+json"
                dangerouslySetInnerHTML={{ __html: JSON.stringify(appSchema) }}
            />
        </>
    );
}
