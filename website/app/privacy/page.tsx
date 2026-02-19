import { Footer } from "@/components/Footer";
import { Navbar } from "@/components/Navbar";

export default function PrivacyPage() {
    return (
        <main className="bg-surface min-h-screen">
            <Navbar />
            <div className="container mx-auto px-6 py-32 max-w-4xl">
                <h1 className="text-4xl font-bold text-secondary mb-8">Privacy Policy</h1>
                <div className="prose prose-lg text-text-secondary max-w-none">
                    <p className="mb-4">Last Updated: February 18, 2026</p>
                    <p>
                        At MomoPe, we take your privacy seriously. This Privacy Policy outlines how we collect, use, and protect your personal information.
                    </p>

                    <h2 className="text-2xl font-bold text-secondary mt-8 mb-4">1. Information We Collect</h2>
                    <p>
                        We collect information you provide directly to us, such as when you create an account, make a transaction, or contact us for support.
                    </p>

                    <h2 className="text-2xl font-bold text-secondary mt-8 mb-4">2. How We Use Your Information</h2>
                    <p>
                        We use your information to provide, maintain, and improve our services, process transactions, and communicate with you.
                    </p>

                    <h2 className="text-2xl font-bold text-secondary mt-8 mb-4">3. Data Security</h2>
                    <p>
                        We implement appropriate technical and organizational measures to protect your personal data against unauthorized access or disclosure.
                    </p>

                    <p className="mt-8 italic text-sm">
                        This is a summary. For the full legal text, please contact our legal department.
                    </p>
                </div>
            </div>
            <Footer />
        </main>
    );
}
