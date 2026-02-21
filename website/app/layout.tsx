import type { Metadata } from "next";
import { Geist, Geist_Mono, Outfit } from "next/font/google";
import "./globals.css";
import { JsonLd } from "@/components/JsonLd";
import { Footer } from "@/components/Footer";
import { MobileDownloadPrompt } from "@/components/MobileDownloadPrompt";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

const outfit = Outfit({
  variable: "--font-outfit",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  metadataBase: new URL('https://momope.com'),
  title: {
    default: "MomoPe | Scan. Pay. & Earn.",
    template: "%s | MomoPe"
  },
  description: "Earn real rewards at your favorite local stores. MomoPe helps 10,000+ merchants grow revenue with automated loyalty and instant settlements.",
  keywords: ["UPI Payments", "Loyalty Rewards", "Merchant Payments", "Fintech India", "Cashback App"],
  authors: [{ name: "MomoPe Team" }],
  creator: "MomoPe",
  publisher: "MomoPe Digital Hub Pvt Ltd",
  alternates: {
    canonical: '/',
  },
  openGraph: {
    type: "website",
    locale: "en_IN",
    url: "https://momope.com",
    title: "MomoPe | Scan. Pay. & Earn.",
    description: "The rewards platform that actually works. Join 10k+ users earning real value on every transaction at local stores.",
    siteName: "MomoPe",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "MomoPe - Scan. Pay. & Earn.",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "MomoPe | The Financial OS for Local Commerce",
    description: "Accept payments, manage customers, and grow your revenue with India's first commerce cloud.",
    creator: "@momope",
    images: ["/twitter-card.png"],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} ${outfit.variable} antialiased`}
      >
        <JsonLd />
        {children}
        <MobileDownloadPrompt />
        <Footer />
      </body>
    </html>
  );
}
