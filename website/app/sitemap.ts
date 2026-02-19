import { MetadataRoute } from 'next';

export default function sitemap(): MetadataRoute.Sitemap {
    const baseUrl = 'https://momope.com';

    return [
        {
            url: baseUrl,
            lastModified: new Date(),
            changeFrequency: 'weekly',
            priority: 1,
        },
        {
            url: `${baseUrl}/merchant`,
            lastModified: new Date(),
            changeFrequency: 'weekly',
            priority: 0.9,
        },
        {
            url: `${baseUrl}/download`,
            lastModified: new Date(),
            changeFrequency: 'monthly',
            priority: 0.8,
        },
        {
            url: `${baseUrl}/about`,
            lastModified: new Date(),
            changeFrequency: 'monthly',
            priority: 0.7,
        },
        {
            url: `${baseUrl}/careers`,
            lastModified: new Date(),
            changeFrequency: 'weekly',
            priority: 0.7,
        },
        {
            url: `${baseUrl}/investors`,
            lastModified: new Date(),
            changeFrequency: 'monthly',
            priority: 0.6,
        },
        {
            url: `${baseUrl}/support`,
            lastModified: new Date(),
            changeFrequency: 'yearly',
            priority: 0.5,
        },
    ];
}
