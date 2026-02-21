import type { Config } from 'tailwindcss'

const config: Config = {
    content: [
        './pages/**/*.{js,ts,jsx,tsx,mdx}',
        './components/**/*.{js,ts,jsx,tsx,mdx}',
        './app/**/*.{js,ts,jsx,tsx,mdx}',
    ],
    theme: {
        extend: {
            colors: {
                brand: {
                    teal: '#00C4A7',
                    'teal-light': '#00E5CC',
                    dark: '#0B0F19',
                    'dark-card': '#111827',
                    'dark-border': 'rgba(255,255,255,0.08)',
                },
            },
            backgroundImage: {
                'gradient-brand': 'linear-gradient(135deg, #00C4A7, #00E5CC)',
            },
            fontFamily: {
                sans: ['Inter', 'system-ui', 'sans-serif'],
                mono: ['JetBrains Mono', 'monospace'],
            },
        },
    },
    plugins: [],
}

export default config
