import { MetadataRoute } from 'next';

export default function sitemap(): MetadataRoute.Sitemap {
    const baseUrl = 'https://momope.com';

    const routes = [
        '',
        '/merchant',
        '/about',
        '/careers',
        '/contact',
        '/download',
        '/investors',
        '/support',
        '/terms',
        '/privacy',
    ].map((route) => ({
        url: `${baseUrl}${route}`,
        lastModified: new Date(),
        changeFrequency: (route === '' || route === '/merchant' ? 'daily' : 'weekly') as 'daily' | 'weekly',
        priority: route === '' ? 1 : route === '/merchant' ? 0.9 : 0.7,
    }));

    return routes;
}
