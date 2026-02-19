import { Footer } from "@/components/Footer";
import { Navbar } from "@/components/Navbar";

export default function TermsPage() {
    return (
        <main className="bg-surface min-h-screen">
            <Navbar />
            <div className="container mx-auto px-6 py-32 max-w-4xl">
                <h1 className="text-4xl font-bold text-secondary mb-8">Terms of Service</h1>
                <div className="prose prose-lg text-text-secondary max-w-none">
                    <p className="mb-4">Last Updated: February 18, 2026</p>
                    <p>
                        Please read these Terms of Service carefully before using the MomoPe platform.
                    </p>

                    <h2 className="text-2xl font-bold text-secondary mt-8 mb-4">1. Acceptance of Terms</h2>
                    <p>
                        By accessing or using our services, you agree to be bound by these terms. If you do not agree to these terms, you may not use our services.
                    </p>

                    <h2 className="text-2xl font-bold text-secondary mt-8 mb-4">2. User Accounts</h2>
                    <p>
                        You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.
                    </p>

                    <h2 className="text-2xl font-bold text-secondary mt-8 mb-4">3. Momo Coins</h2>
                    <p>
                        Momo Coins have no cash value and cannot be exchanged for cash. They are promotional rewards subject to our redemption policies.
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
