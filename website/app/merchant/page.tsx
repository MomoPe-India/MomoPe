"use client";

import Link from "next/link";
import { Navbar } from "@/components/Navbar";
import { DashboardPreview } from "@/components/DashboardPreview";
import { RoiCalculator } from "@/components/RoiCalculator";
import { CheckCircle2, ArrowRight, Wallet, Shield, Zap, Users, Repeat } from "lucide-react";
import { motion } from "framer-motion";

export default function MerchantPage() {
    return (
        <main className="bg-surface overflow-hidden">
            <Navbar theme="dark" />

            {/* 1. Hero Section - The Growth Promise */}
            <section className="pt-32 pb-20 md:pt-48 md:pb-32 bg-[#0B0F19] relative text-white overflow-hidden">
                {/* Abstract Background */}
                <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-primary/20 rounded-full blur-[120px] -z-10" />
                <div className="absolute bottom-0 left-0 w-[600px] h-[600px] bg-purple-900/30 rounded-full blur-[100px] -z-10" />
                <div className="absolute inset-0 bg-[url('/images/grid-white.svg')] opacity-[0.05] bg-center animate-pulse-slow" />

                <div className="container mx-auto px-6 text-center relative z-10">
                    <motion.div
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white/10 text-primary-light font-medium text-sm mb-8 border border-white/10 backdrop-blur-md"
                    >
                        <Zap size={16} className="fill-current" /> Zero Investment. 100% Growth.
                    </motion.div>

                    <motion.h1
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 }}
                        className="text-5xl md:text-7xl font-black mb-8 leading-tight tracking-tight"
                    >
                        Don't Just Accept Payments.<br />
                        <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-teal-200">Multiply Your Customers.</span>
                    </motion.h1>

                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 }}
                        className="text-xl text-gray-400 max-w-2xl mx-auto mb-12 leading-relaxed"
                    >
                        MomoPe is India's first <b>Offline-to-Online Commerce Cloud</b>. We turn every transaction into a loyal customer relationship, automatically.
                    </motion.p>

                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.3 }}
                        className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-20"
                    >
                        <Link
                            href="/contact"
                            className="px-8 py-4 bg-primary text-white rounded-xl font-bold text-lg hover:bg-primary-dark transition-all shadow-lg hover:shadow-primary/40 hover:-translate-y-1 w-full sm:w-auto flex items-center justify-center gap-2"
                        >
                            Start for Free <ArrowRight size={20} />
                        </Link>
                        <Link
                            href="#comparison"
                            className="px-8 py-4 bg-white/5 text-white border border-white/10 rounded-xl font-bold text-lg hover:bg-white/10 transition-colors w-full sm:w-auto"
                        >
                            Why MomoPe?
                        </Link>
                    </motion.div>

                    {/* Dashboard Preview Component */}
                    <div className="relative z-10">
                        <div className="absolute inset-0 bg-primary/10 blur-[100px] -z-10 transform scale-75" />
                        <DashboardPreview />
                    </div>
                </div>
            </section>

            {/* 2. The Growth Engine (Ecosystem Explainer) */}
            <section className="py-24 bg-white">
                <div className="container mx-auto px-6">
                    <div className="text-center max-w-3xl mx-auto mb-20">
                        <h2 className="text-3xl md:text-5xl font-bold text-secondary mb-6">The Growth Flywheel</h2>
                        <p className="text-gray-500 text-xl">How MomoPe turns one-time walk-ins into rigorous regulars.</p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-12 relative">
                        {/* Connecting Line (Desktop) */}
                        <div className="hidden md:block absolute top-12 left-0 w-full h-0.5 bg-gradient-to-r from-transparent via-gray-200 to-transparent -z-10" />

                        <ProcessCard
                            icon={<Users size={32} />}
                            step="01"
                            title="Acquisition"
                            desc="Customers find you on the MomoPe App or scan your QR code. No expensive ads needed."
                        />
                        <ProcessCard
                            icon={<Wallet size={32} />}
                            step="02"
                            title="Transaction"
                            desc="Customer pays. You get 80% instant cash + 20% is reinvested into Customer Coins (your acquisition cost)."
                        />
                        <ProcessCard
                            icon={<Repeat size={32} />}
                            step="03"
                            title="Retention"
                            desc="Customer MUST return to redeem those coins. This creates an infinite loyalty loop."
                        />
                    </div>
                </div>
            </section>

            {/* 3. Comparison Section */}
            <section id="comparison" className="py-24 bg-surface">
                <div className="container mx-auto px-6">
                    <div className="text-center max-w-3xl mx-auto mb-16">
                        <h2 className="text-3xl md:text-4xl font-bold text-secondary mb-4">Stop Leaving Money on the Table</h2>
                        <p className="text-gray-500 text-lg">Compare MomoPe with your standard QR code.</p>
                    </div>

                    <div className="max-w-4xl mx-auto bg-white rounded-3xl shadow-xl overflow-hidden border border-gray-100">
                        <div className="grid grid-cols-3 bg-gray-50 border-b border-gray-200">
                            <div className="p-6 font-bold text-gray-500">Feature</div>
                            <div className="p-6 font-bold text-gray-500 text-center border-l border-gray-200">Traditional UPI</div>
                            <div className="p-6 font-bold text-primary text-center border-l border-gray-200 bg-primary/5">MomoPe Growth OS</div>
                        </div>

                        <CorrectionRow feature="Payment Acceptance" oldWay="Yes" newWay="Yes" />
                        <CorrectionRow feature="Customer Data" oldWay="None" newWay="Full Profile" highlight />
                        <CorrectionRow feature="Retention Tool" oldWay="None" newWay="Coin Loyalty" highlight />
                        <CorrectionRow feature="Marketing" oldWay="Impossible" newWay="Push Notifications" />
                        <CorrectionRow feature="Credit Line" oldWay="Based on Bank" newWay="Based on Transactions" />
                        <CorrectionRow feature="Cost" oldWay="0% (But 0 Growth)" newWay="Small Commission (High ROI)" />
                    </div>
                </div>
            </section>

            {/* 4. ROI Calculator Section */}
            <section className="py-24 bg-white relative overflow-hidden">
                <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-green-500/5 rounded-full blur-[100px] -z-10" />
                <div className="container mx-auto px-6 relative z-10">
                    <div className="text-center max-w-3xl mx-auto mb-16">
                        <h2 className="text-3xl md:text-4xl font-bold text-secondary mb-4">Calculate Your ROI</h2>
                        <p className="text-text-secondary text-lg">See exactly how much revenue you're missing out on.</p>
                    </div>
                    <div className="glass-card p-2 rounded-3xl shadow-2xl shadow-gray-200/50">
                        <RoiCalculator />
                    </div>
                </div>
            </section>

            {/* 5. Deep Dive Features */}
            <section className="py-24 bg-surface">
                <div className="container mx-auto px-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-16 items-center">
                        <div className="space-y-8">
                            <div className="inline-block px-4 py-1.5 rounded-full bg-blue-100 text-blue-700 font-bold text-sm">
                                Feature Spotlight
                            </div>
                            <h2 className="text-4xl font-bold text-secondary">Smart QR. Smarter Business.</h2>
                            <p className="text-gray-600 text-lg leading-relaxed">
                                Our QR code isn't just a payment link. It's an intelligent gateway that identifies your customer, checks their loyalty tier, applies dynamic rewards, and settles the payment—all in 200 milliseconds.
                            </p>
                            <ul className="space-y-4">
                                <FeatureCheck text="Accepts UPI, Credit Cards, and Debit Cards" />
                                <FeatureCheck text="Works with 80+ Banking Apps" />
                                <FeatureCheck text="Dynamic Coin Redemption" />
                                <FeatureCheck text="Instant Audio Confirmation (Soundbox)" />
                            </ul>
                        </div>
                        <div className="relative h-[500px] bg-[#0B0F19] rounded-3xl overflow-hidden shadow-2xl border border-gray-800 flex items-center justify-center">
                            {/* Decorative Code */}
                            <div className="text-xs font-mono text-green-400 opacity-20 absolute inset-0 p-8 overflow-hidden select-none">
                                {`class SmartQR {
  process(payment) {
    user = identify(payment.source);
    tier = loyalty.check_tier(user);
    coins = calculate_rewards(amount, tier);
    settle(merchant_account, amount * 0.8);
    return "Payment Successful";
  }
}`}
                            </div>
                            <div className="relative z-10 bg-white p-6 rounded-2xl shadow-xl">
                                <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=MomoPePayment" alt="Smart QR" className="w-48 h-48" />
                                <div className="text-center mt-4 font-bold text-secondary">Scan to Grow</div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* 6. FAQ Section */}
            <section className="py-24 bg-white border-t border-gray-100">
                <div className="container mx-auto px-6 max-w-4xl">
                    <div className="text-center mb-16">
                        <h2 className="text-3xl font-bold text-secondary mb-4">Frequent Questions</h2>
                    </div>

                    <div className="space-y-6">
                        <FaqItem
                            q="How much does it cost?"
                            a="Zero setup cost. You only pay a small commission (15-20%) on successful transactions. This commission effectively covers your customer acquisition and loyalty program costs."
                        />
                        <FaqItem
                            q="When do I get my money?"
                            a="We offer standard T+1 settlement (next day). For premium merchants, we offer Instant Settlement options so you never have cash flow issues."
                        />
                        <FaqItem
                            q="Do I need a special device?"
                            a="No! You can start with just a smartphone and our printed QR code. We also offer Soundbox and POS devices for high-volume stores."
                        />
                        <FaqItem
                            q="What if a customer only redeems coins?"
                            a="Customers can redeem maximum 80% of the bill value using coins. You will ALWAYS receive at least 20% in cash/fiat, ensuring cash flow."
                        />
                    </div>
                </div>
            </section>

            {/* 7. Final CTA */}
            <section className="py-20 bg-[#0B0F19] text-white overflow-hidden relative">
                <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-teal-500/10 rounded-full blur-[120px]" />
                <div className="container mx-auto px-6 text-center relative z-10">
                    <h2 className="text-4xl md:text-5xl font-black mb-8">Ready to dominate your market?</h2>
                    <p className="text-xl text-gray-400 mb-12 max-w-2xl mx-auto">
                        Join the 60M+ revolution. Start accepting payments that actually grow your business.
                    </p>
                    <Link
                        href="/contact"
                        className="inline-flex items-center gap-2 px-10 py-5 bg-primary text-white rounded-xl font-bold text-lg hover:bg-primary-dark transition-all shadow-lg hover:shadow-primary/30"
                    >
                        Create Merchant Account
                    </Link>
                </div>
            </section>

        </main>
    );
}

function ProcessCard({ icon, step, title, desc }: { icon: React.ReactNode, step: string, title: string, desc: string }) {
    return (
        <div className="bg-white p-8 rounded-3xl border border-gray-100 shadow-sm hover:shadow-xl transition-all relative group z-10">
            <div className="absolute -top-6 -left-6 text-9xl font-black text-gray-50 opacity-50 select-none group-hover:scale-110 transition-transform">
                {step}
            </div>
            <div className="w-16 h-16 rounded-2xl bg-primary/10 text-primary flex items-center justify-center mb-6 relative z-10 group-hover:bg-primary group-hover:text-white transition-colors">
                {icon}
            </div>
            <h3 className="text-2xl font-bold text-secondary mb-4 relative z-10">{title}</h3>
            <p className="text-gray-500 leading-relaxed relative z-10">{desc}</p>
        </div>
    );
}

function CorrectionRow({ feature, oldWay, newWay, highlight }: { feature: string, oldWay: string, newWay: string, highlight?: boolean }) {
    return (
        <div className={`grid grid-cols-3 border-b border-gray-100 hover:bg-gray-50 transition-colors ${highlight ? 'bg-blue-50/30' : ''}`}>
            <div className="p-6 font-medium text-gray-700 flex items-center">{feature}</div>
            <div className="p-6 text-gray-500 text-center border-l border-gray-200 flex items-center justify-center">{oldWay}</div>
            <div className={`p-6 font-bold text-center border-l border-gray-200 flex items-center justify-center ${highlight ? 'text-primary' : 'text-gray-800'}`}>{newWay}</div>
        </div>
    );
}

function FeatureCheck({ text }: { text: string }) {
    return (
        <div className="flex items-center gap-3">
            <CheckCircle2 className="text-primary shrink-0" size={20} />
            <span className="text-gray-700 font-medium">{text}</span>
        </div>
    );
}

function FaqItem({ q, a }: { q: string, a: string }) {
    return (
        <details className="group bg-gray-50 rounded-2xl p-6 open:bg-white open:shadow-lg transition-all border border-transparent open:border-gray-100">
            <summary className="flex items-center justify-between font-bold text-lg text-secondary cursor-pointer list-none">
                {q}
                <span className="transition-transform group-open:rotate-180">
                    <ArrowRight className="rotate-90" size={20} />
                </span>
            </summary>
            <p className="mt-4 text-gray-600 leading-relaxed max-w-3xl">
                {a}
            </p>
        </details>
    );
}
