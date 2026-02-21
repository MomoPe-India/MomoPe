"use client";

import Link from "next/link";
import { Navbar } from "@/components/Navbar";
import { DashboardPreview } from "@/components/DashboardPreview";
import { RoiCalculator } from "@/components/RoiCalculator";
import {
    CheckCircle2,
    ArrowRight,
    Wallet,
    Shield,
    Zap,
    Users,
    Repeat,
    ArrowUpRight,
    UserMinus,
    Smartphone,
    Coins,
    TrendingUp
} from "lucide-react";
import { motion } from "framer-motion";
import { StatusQuoVisual, GrowthOSVisual } from "@/components/ComparisonVisuals";

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
                        <div className="hidden md:block absolute top-[160px] left-0 w-full h-0.5 bg-gradient-to-r from-transparent via-gray-200 to-transparent -z-10" />

                        <ProcessCard
                            illustration={<AcquisitionIllustration />}
                            step="01"
                            title="Acquisition"
                            desc="Customers find you on the MomoPe App or scan your QR code. No expensive ads needed."
                        />
                        <ProcessCard
                            illustration={<TransactionIllustration />}
                            step="02"
                            title="Transaction"
                            desc="Customer pays. You get 80% instant cash + 20% is reinvested into Customer Coins (your acquisition cost)."
                        />
                        <ProcessCard
                            illustration={<RetentionIllustration />}
                            step="03"
                            title="Retention"
                            desc="Customer MUST return to redeem those coins. This creates an infinite loyalty loop."
                        />
                    </div>
                </div>
            </section>

            {/* 3. Comparison Section - The Reality Check Upgrade */}
            <section id="comparison" className="py-32 bg-surface relative overflow-hidden">
                <div className="container mx-auto px-6 relative z-10">
                    <div className="text-center max-w-3xl mx-auto mb-20">
                        <motion.div
                            initial={{ opacity: 0, y: 10 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            viewport={{ once: true }}
                            className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white border border-gray-100 shadow-umbra-sm mb-6"
                        >
                            <div className="w-1.5 h-1.5 rounded-full bg-primary animate-pulse" />
                            <span className="text-[10px] font-black text-gray-400 uppercase tracking-[0.3em]">Direct Comparison</span>
                        </motion.div>
                        <h2 className="text-4xl md:text-6xl font-black text-secondary mb-8 tracking-tighter leading-[0.95]">
                            Stop Leaving <br />
                            <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-accent italic">Money on the Table</span>
                        </h2>
                        <p className="text-xl text-text-secondary leading-relaxed">
                            A standard QR code is a dead end. MomoPe is a <span className="text-secondary font-bold underline decoration-primary/30 underline-offset-8">commercial growth engine</span>.
                        </p>
                    </div>

                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-stretch">
                        {/* Status Quo - The Traditional Way */}
                        <motion.div
                            initial={{ opacity: 0, x: -20 }}
                            whileInView={{ opacity: 1, x: 0 }}
                            viewport={{ once: true }}
                            className="bg-white rounded-[4rem] p-12 border border-gray-100 shadow-umbra-sm flex flex-col hover:border-gray-200 transition-colors"
                        >
                            <div className="mb-12">
                                <span className="text-[10px] font-black text-gray-400 uppercase tracking-[0.3em] block mb-4">The Status Quo</span>
                                <h3 className="text-3xl font-black text-secondary tracking-tight">Traditional UPI QR</h3>
                            </div>

                            <div className="flex-1 min-h-[300px] mb-12">
                                <StatusQuoVisual />
                            </div>

                            <div className="space-y-4">
                                <ComparisonPoint label="Customer Data" value="Anonymous" icon={<UserMinus size={18} />} negative />
                                <ComparisonPoint label="Retention" value="Zero Loop" icon={<Repeat size={18} />} negative />
                                <ComparisonPoint label="Marketing" value="Impossible" icon={<Smartphone size={18} />} negative />
                            </div>
                        </motion.div>

                        {/* The Future - MomoPe Growth OS */}
                        <motion.div
                            initial={{ opacity: 0, x: 20 }}
                            whileInView={{ opacity: 1, x: 0 }}
                            viewport={{ once: true }}
                            className="bg-white rounded-[4rem] p-12 border border-primary/20 shadow-umbra-xl flex flex-col relative overflow-hidden group"
                        >
                            {/* Ambient Glow */}
                            <div className="absolute top-0 right-0 w-64 h-64 bg-primary/5 rounded-full blur-[100px] -z-0" />

                            <div className="relative z-10 mb-12">
                                <div className="flex items-center justify-between mb-4">
                                    <span className="text-[10px] font-black text-primary uppercase tracking-[0.3em]">The Opportunity</span>
                                    <div className="px-3 py-1 bg-primary/10 rounded-full border border-primary/20">
                                        <span className="text-[8px] font-black text-primary uppercase tracking-widest">+42% Avg Retention</span>
                                    </div>
                                </div>
                                <h3 className="text-3xl font-black text-secondary tracking-tight">MomoPe Growth OS</h3>
                            </div>

                            <div className="flex-1 min-h-[300px] mb-12 relative z-10">
                                <GrowthOSVisual />
                            </div>

                            <div className="space-y-4 relative z-10">
                                <ComparisonPoint label="Customer Data" value="Rich Profiles" icon={<Users size={18} />} highlight />
                                <ComparisonPoint label="Retention" value="Coin Loyalty Loop" icon={<Coins size={18} />} highlight />
                                <ComparisonPoint label="Marketing" value="Direct Notifications" icon={<Smartphone size={18} />} highlight />
                            </div>

                            <div className="mt-12 pt-8 border-t border-gray-50 flex items-center justify-between group-hover:border-primary/20 transition-colors relative z-10">
                                <div className="flex items-center gap-3">
                                    <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary">
                                        <TrendingUp size={20} />
                                    </div>
                                    <span className="text-xs font-black text-secondary uppercase tracking-widest italic">Built for Scale</span>
                                </div>
                                <button className="flex items-center gap-2 text-primary font-black text-[10px] uppercase tracking-[0.25em] group/btn">
                                    View ROI <ArrowRight size={14} className="group-hover/btn:translate-x-1 transition-transform" />
                                </button>
                            </div>
                        </motion.div>
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

function ProcessCard({ illustration, step, title, desc }: { illustration: React.ReactNode, step: string, title: string, desc: string }) {
    return (
        <div className="bg-white p-8 rounded-[2.5rem] border border-gray-100 shadow-sm hover:shadow-2xl hover:shadow-primary/10 transition-all duration-500 relative group z-10 flex flex-col items-center text-center">
            <div className="absolute -top-6 -left-6 text-9xl font-black text-gray-50 opacity-50 select-none group-hover:scale-110 transition-transform duration-700">
                {step}
            </div>

            <div className="mb-8 relative z-10 w-full flex justify-center h-40">
                {illustration}
            </div>

            <h3 className="text-2xl font-bold text-secondary mb-4 relative z-10">{title}</h3>
            <p className="text-gray-500 leading-relaxed relative z-10">{desc}</p>
        </div>
    );
}

function AcquisitionIllustration() {
    return (
        <div className="relative w-32 h-32 flex items-center justify-center">
            {/* Background Glow */}
            <motion.div
                animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.5, 0.3] }}
                transition={{ duration: 4, repeat: Infinity }}
                className="absolute inset-0 bg-primary/20 rounded-full blur-2xl"
            />
            {/* Floating Shapes */}
            <motion.div
                animate={{ y: [-10, 10, -10], rotate: [0, 10, 0] }}
                transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }}
                className="absolute -top-4 -right-4 w-12 h-12 bg-teal-100 rounded-lg rotate-12 backdrop-blur-sm border border-white/50 shadow-lg"
            />
            <motion.div
                animate={{ x: [-10, 10, -10], rotate: [0, -10, 0] }}
                transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
                className="absolute -bottom-2 -left-4 w-10 h-10 bg-purple-100 rounded-full backdrop-blur-sm border border-white/50 shadow-lg"
            />
            {/* Central Icon Container */}
            <div className="w-24 h-24 bg-white rounded-3xl shadow-xl flex items-center justify-center z-10 border border-gray-50 overflow-hidden group-hover:scale-110 transition-transform duration-500">
                <div className="absolute inset-0 bg-gradient-to-br from-primary/5 to-transparent" />
                <Users size={48} className="text-primary relative z-10" />
            </div>
        </div>
    );
}

function TransactionIllustration() {
    return (
        <div className="relative w-32 h-32 flex items-center justify-center">
            <motion.div
                animate={{ scale: [1, 1.3, 1], opacity: [0.2, 0.4, 0.2] }}
                transition={{ duration: 5, repeat: Infinity }}
                className="absolute inset-0 bg-emerald-400/20 rounded-full blur-2xl"
            />
            {/* Floating "Coins" */}
            <motion.div
                animate={{ y: [-20, 0, -20], opacity: [0, 1, 0] }}
                transition={{ duration: 3, repeat: Infinity, ease: "easeOut" }}
                className="absolute top-0 right-0 w-8 h-8 bg-yellow-400 rounded-full border-2 border-white shadow-md z-20 flex items-center justify-center text-[10px] font-bold text-white"
            >
                ₹
            </motion.div>
            <motion.div
                animate={{ y: [-15, 5, -15], opacity: [0, 0.8, 0] }}
                transition={{ duration: 3, delay: 1, repeat: Infinity, ease: "easeOut" }}
                className="absolute top-10 left-0 w-6 h-6 bg-yellow-300 rounded-full border-2 border-white shadow-md z-20"
            />

            <div className="w-24 h-24 bg-white rounded-3xl shadow-xl flex items-center justify-center z-10 border border-gray-50 relative group-hover:scale-110 transition-transform duration-500">
                <div className="absolute inset-0 bg-gradient-to-br from-emerald-500/5 to-transparent" />
                <Wallet size={48} className="text-emerald-500 relative z-10" />
            </div>
        </div>
    );
}

function RetentionIllustration() {
    return (
        <div className="relative w-32 h-32 flex items-center justify-center">
            <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                className="absolute inset-0 border-2 border-dashed border-primary/20 rounded-full"
            />
            <motion.div
                animate={{ scale: [1, 1.1, 1] }}
                transition={{ duration: 3, repeat: Infinity }}
                className="absolute inset-4 bg-primary/5 rounded-full blur-xl"
            />

            <div className="w-24 h-24 bg-white rounded-3xl shadow-xl flex items-center justify-center z-10 border border-gray-50 overflow-hidden group-hover:scale-110 transition-transform duration-500">
                <div className="absolute inset-0 bg-gradient-to-br from-primary/10 to-transparent" />
                <motion.div
                    animate={{ rotate: 360 }}
                    transition={{ duration: 8, repeat: Infinity, ease: "easeInOut" }}
                >
                    <Repeat size={48} className="text-primary" />
                </motion.div>
            </div>

            {/* Orbiting Dot */}
            <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 4, repeat: Infinity, ease: "linear" }}
                className="absolute inset-0"
            >
                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-4 h-4 bg-primary rounded-full shadow-lg border-2 border-white" />
            </motion.div>
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

function ComparisonPoint({ label, value, icon, negative, highlight }: { label: string, value: string, icon: React.ReactNode, negative?: boolean, highlight?: boolean }) {
    return (
        <div className={`flex items-center justify-between p-4 rounded-2xl border transition-all ${highlight ? 'bg-primary/[0.02] border-primary/10 shadow-sm' : 'bg-gray-50/50 border-gray-100'}`}>
            <div className="flex items-center gap-4">
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${negative ? 'bg-gray-100 text-gray-400' : 'bg-primary/10 text-primary'}`}>
                    {icon}
                </div>
                <div>
                    <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest block mb-1">{label}</span>
                    <span className={`text-sm font-bold ${negative ? 'text-gray-500' : 'text-secondary'}`}>{value}</span>
                </div>
            </div>
            {!negative && (
                <div className="w-6 h-6 rounded-full bg-primary/20 flex items-center justify-center">
                    <CheckCircle2 size={14} className="text-primary" />
                </div>
            )}
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
