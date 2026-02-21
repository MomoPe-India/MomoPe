"use client";

import { motion } from "framer-motion";
import { Smartphone, Apple, Star, Download, QrCode, CheckCircle2 } from "lucide-react";
import { Navbar } from "@/components/Navbar";
import { Shield, Lock, CreditCard, ChevronDown } from "lucide-react";

export function DownloadContent() {
    return (
        <main className="bg-surface min-h-screen font-sans text-slate-800 overflow-hidden">
            <Navbar />

            {/* Hero Section */}
            <section className="relative pt-32 pb-20 md:pt-48 md:pb-32 min-h-[80vh] flex items-center">
                {/* Ambient Background */}
                <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-gradient-to-br from-teal-50 to-blue-50 rounded-full blur-3xl -z-10 translate-x-1/3 -translate-y-1/4" />
                <div className="absolute bottom-0 left-0 w-[600px] h-[600px] bg-purple-50/50 rounded-full blur-3xl -z-10 -translate-x-1/4 translate-y-1/4" />

                <div className="container mx-auto px-6 z-10">
                    <div className="flex flex-col lg:flex-row items-center gap-16 lg:gap-24">

                        {/* Text Content */}
                        <motion.div
                            initial={{ opacity: 0, x: -50 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ duration: 0.8 }}
                            className="flex-1 text-center lg:text-left"
                        >
                            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-teal-50 text-[#00C4A7] font-bold text-xs uppercase tracking-widest mb-8 border border-teal-100">
                                <Star size={14} fill="currentColor" /> #1 Rewards App
                            </div>

                            <h1 className="text-5xl md:text-7xl font-black text-secondary mb-8 leading-tight tracking-tight">
                                Your Money, <br />
                                <motion.span
                                    initial={{ opacity: 0, scale: 0.98, filter: "blur(8px)" }}
                                    animate={{ opacity: 1, scale: 1, filter: "blur(0px)" }}
                                    transition={{ delay: 0.4, duration: 0.8, ease: "easeOut" }}
                                    className="inline-block text-transparent bg-clip-text bg-gradient-to-r from-primary to-momo-blue animate-gradient-x drop-shadow-[0_5px_15px_rgba(0,114,255,0.25)]"
                                >
                                    Upgraded.
                                </motion.span>
                            </h1>

                            <p className="text-xl text-gray-500 mb-10 max-w-lg mx-auto lg:mx-0 leading-relaxed">
                                Join 10,000+ users earning real cashback on every local payment. Scan, pay, and watch your savings grow.
                            </p>

                            <div className="flex flex-col sm:flex-row items-center gap-4 justify-center lg:justify-start mb-12">
                                <StoreButton
                                    icon={<Smartphone size={24} />}
                                    label="Get it on"
                                    store="Google Play"
                                    active
                                />
                                <StoreButton
                                    icon={<Apple size={24} />}
                                    label="Download on the"
                                    store="App Store"
                                />
                            </div>

                            {/* Ratings / Social Proof */}
                            <div className="flex items-center justify-center lg:justify-start gap-8 border-t border-gray-100 pt-8">
                                <div>
                                    <div className="text-3xl font-bold text-[#35255e]">4.8</div>
                                    <div className="flex text-amber-400 text-xs">
                                        <Star size={12} fill="currentColor" />
                                        <Star size={12} fill="currentColor" />
                                        <Star size={12} fill="currentColor" />
                                        <Star size={12} fill="currentColor" />
                                        <Star size={12} fill="currentColor" />
                                    </div>
                                    <div className="text-xs text-gray-400 mt-1">App Store Rating</div>
                                </div>
                                <div className="w-px h-12 bg-gray-200" />
                                <div>
                                    <div className="text-3xl font-bold text-[#35255e]">10k+</div>
                                    <div className="text-xs text-gray-400 mt-1">Active Users</div>
                                </div>
                                <div className="w-px h-12 bg-gray-200" />
                                <div>
                                    <div className="text-3xl font-bold text-[#35255e]">₹1Cr+</div>
                                    <div className="text-xs text-gray-400 mt-1">Processed</div>
                                </div>
                            </div>
                        </motion.div>

                        {/* Visual Content (Phone & QR) */}
                        <motion.div
                            initial={{ opacity: 0, scale: 0.8 }}
                            animate={{ opacity: 1, scale: 1 }}
                            transition={{ duration: 0.8, delay: 0.2 }}
                            className="flex-1 relative flex justify-center"
                        >
                            {/* Decorative Blobs behind phone */}
                            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[300px] h-[600px] bg-gradient-to-t from-[#00C4A7]/20 to-blue-500/20 rounded-full blur-3xl -z-10 animate-pulse" />

                            {/* CSS Phone Mockup */}
                            <div className="relative w-[300px] h-[600px] bg-gray-900 rounded-[3rem] border-[8px] border-gray-900 shadow-2xl overflow-hidden ring-4 ring-gray-100">
                                {/* Dynamic Island */}
                                <div className="absolute top-0 left-1/2 -translate-x-1/2 w-1/3 h-7 bg-black rounded-b-2xl z-20" />

                                {/* App Screen */}
                                <div className="w-full h-full bg-white relative overflow-hidden flex flex-col">
                                    {/* App Header */}
                                    <div className="h-24 bg-[#35255e] p-6 pt-10 flex justify-between items-center text-white">
                                        <div className="font-bold">MomoPe</div>
                                        <div className="w-8 h-8 rounded-full bg-white/20" />
                                    </div>

                                    {/* App Body */}
                                    <div className="p-6 flex-1 bg-gray-50">
                                        <div className="bg-white p-6 rounded-2xl shadow-sm mb-6 text-center">
                                            <div className="text-gray-400 text-xs font-bold uppercase mb-1">Total Rewards</div>
                                            <div className="text-4xl font-black text-[#00C4A7]">5,420</div>
                                            <div className="text-xs text-gray-400 mt-1">Momo Coins</div>
                                        </div>

                                        <div className="space-y-3">
                                            <div className="text-xs font-bold text-gray-400 uppercase">Recent Activity</div>
                                            <TransactionItem name="Starbucks Coffee" amount="₹350" reward="+35" />
                                            <TransactionItem name="Uber Ride" amount="₹120" reward="+12" />
                                            <TransactionItem name="Fresh Mart" amount="₹850" reward="+85" />
                                            <TransactionItem name="Movie Ticket" amount="₹400" reward="+40" />
                                        </div>
                                    </div>

                                    {/* App Tab Bar */}
                                    <div className="h-16 bg-white border-t border-gray-100 flex items-center justify-around text-gray-300">
                                        <div className="w-6 h-6 rounded-full bg-[#00C4A7]" />
                                        <div className="w-6 h-6 rounded-full bg-gray-200" />
                                        <div className="w-6 h-6 rounded-full bg-gray-200" />
                                    </div>

                                    {/* Success Notification Popup */}
                                    <motion.div
                                        initial={{ y: 100, opacity: 0 }}
                                        animate={{ y: 0, opacity: 1 }}
                                        transition={{ delay: 1, type: "spring" }}
                                        className="absolute bottom-20 left-4 right-4 bg-white p-4 rounded-xl shadow-xl flex items-center gap-4 z-10"
                                    >
                                        <div className="w-10 h-10 rounded-full bg-green-100 text-green-600 flex items-center justify-center">
                                            <CheckCircle2 size={20} />
                                        </div>
                                        <div>
                                            <div className="text-sm font-bold text-gray-800">Payment Successful</div>
                                            <div className="text-xs text-gray-500">You earned 50 coins!</div>
                                        </div>
                                    </motion.div>
                                </div>
                            </div>

                            {/* Floating QR Code Card */}
                            <motion.div
                                initial={{ opacity: 0, x: 50, rotate: 10 }}
                                animate={{ opacity: 1, x: 0, rotate: 3 }}
                                transition={{ delay: 0.5, type: "spring" }}
                                className="absolute bottom-20 -right-12 bg-white p-4 rounded-2xl shadow-xl border border-gray-100 hidden md:block transform hover:rotate-0 transition-transform duration-300"
                            >
                                <div className="w-32 h-32 bg-gray-900 rounded-xl flex items-center justify-center text-white mb-3">
                                    <QrCode size={64} />
                                </div>
                                <div className="text-center">
                                    <div className="text-xs font-bold text-[#35255e]">Scan to Install</div>
                                    <div className="text-[10px] text-gray-400">iOS & Android</div>
                                </div>
                            </motion.div>

                        </motion.div>
                    </div>
                </div>
            </section>

            {/* Why Download Section */}
            <section className="py-24 bg-white relative">
                <div className="container mx-auto px-6 z-10 relative">
                    <div className="text-center max-w-3xl mx-auto mb-16">
                        <h2 className="text-3xl md:text-5xl font-black text-[#35255e] mb-6">Why MomoPe?</h2>
                        <p className="text-gray-500 text-lg">More than just payments. It's your financial upgrade.</p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                        <FeatureCard
                            icon={<Star size={32} className="text-yellow-400" />}
                            title="Instant Rewards"
                            desc="Earn 1% to 10% cashback in Momo Coins on every single scan. No scratch cards, no bad luck."
                        />
                        <FeatureCard
                            icon={<Smartphone size={32} className="text-blue-500" />}
                            title="Expense Analytics"
                            desc="Track where your money goes. Auto-categorized monthly reports for smart spending."
                        />
                        <FeatureCard
                            icon={<CreditCard size={32} className="text-[#00C4A7]" />}
                            title="Bank Offers"
                            desc="Link your credit cards and automatically unlock hidden bank discounts at partner stores."
                        />
                    </div>
                </div>
            </section>

            {/* Security Section - Powered by PayU */}
            <section className="py-20 bg-slate-50 border-y border-gray-200">
                <div className="container mx-auto px-6">
                    <div className="flex flex-col md:flex-row items-center justify-between gap-12 bg-white p-8 md:p-12 rounded-3xl shadow-sm border border-gray-100">
                        <div className="md:w-1/2">
                            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-green-100 text-green-700 font-bold text-xs uppercase tracking-wider mb-4">
                                <Shield size={14} /> 100% Secure
                            </div>
                            <h2 className="text-3xl font-bold text-[#35255e] mb-4">Bank-Grade Security</h2>
                            <p className="text-gray-500 leading-relaxed mb-6">
                                Your money is safe with us. All payments are processed through <strong>PayU</strong>, India's leading payment gateway.
                            </p>
                            <ul className="space-y-3">
                                <SecurityItem text="PCI-DSS Compliant Infrastructure (via PayU)" />
                                <SecurityItem text="256-bit End-to-End Encryption (via PayU)" />
                                <SecurityItem text="24/7 Fraud Monitoring" />
                            </ul>
                        </div>
                        <div className="md:w-1/2 flex justify-center">
                            <div className="relative">
                                <div className="absolute inset-0 bg-green-500/10 blur-[60px] rounded-full" />
                                <Lock size={180} className="text-[#00C4A7] relative z-10 opacity-80" />
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* FAQ Section */}
            <section className="py-24 bg-white">
                <div className="container mx-auto px-6 max-w-3xl">
                    <div className="text-center mb-12">
                        <h2 className="text-3xl font-bold text-[#35255e]">Common Questions</h2>
                    </div>
                    <div className="space-y-4">
                        <FaqItem
                            q="Is the app completely free?"
                            a="Yes! MomoPe is 100% free for users. You pay zero commissions and zero hidden fees."
                        />
                        <FaqItem
                            q="Where can I use Momo Coins?"
                            a="You can use Momo Coins at any MomoPe partner store. They work exactly like cash for up to 80% of your bill value."
                        />
                        <FaqItem
                            q="Is my bank data safe?"
                            a="Absolutely. We do not store your banking passwords. All transactions are securely handled by PayU's encrypted payment gateway."
                        />
                    </div>
                </div>
            </section>

            {/* Final CTA */}
            <section className="py-20 bg-[#35255e] text-center text-white relative overflow-hidden">
                <div className="absolute top-0 left-0 w-full h-full opacity-20">
                    <div className="absolute right-0 top-0 w-[400px] h-[400px] bg-[#00C4A7] rounded-full blur-[100px]" />
                </div>
                <div className="container mx-auto px-6 relative z-10">
                    <h2 className="text-3xl md:text-5xl font-black mb-8">Start Saving Today</h2>
                    <div className="flex flex-col sm:flex-row justify-center gap-4">
                        <StoreButton
                            icon={<Smartphone size={24} />}
                            label="Get it on"
                            store="Google Play"
                            active
                            href="https://whatsapp.com/channel/0029VbBhoLk7z4kiZU9cBz1U"
                        />
                        <StoreButton
                            icon={<Apple size={24} />}
                            label="Download on the"
                            store="App Store"
                            href="https://whatsapp.com/channel/0029VbBhoLk7z4kiZU9cBz1U"
                        />
                    </div>
                </div>
            </section>
        </main>
    );
}

function FeatureCard({ icon, title, desc }: { icon: React.ReactNode, title: string, desc: string }) {
    return (
        <div className="p-8 rounded-3xl bg-slate-50 border border-slate-100 hover:bg-white hover:shadow-xl transition-all group">
            <div className="w-14 h-14 rounded-2xl bg-white shadow-sm flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                {icon}
            </div>
            <h3 className="text-xl font-bold text-[#35255e] mb-3">{title}</h3>
            <p className="text-gray-500 leading-relaxed">{desc}</p>
        </div>
    )
}

function SecurityItem({ text }: { text: string }) {
    return (
        <div className="flex items-center gap-3">
            <div className="w-5 h-5 rounded-full bg-green-100 flex items-center justify-center text-green-600 shrink-0">
                <CheckCircle2 size={12} />
            </div>
            <span className="text-gray-700 font-medium">{text}</span>
        </div>
    )
}

function FaqItem({ q, a }: { q: string, a: string }) {
    return (
        <div className="border border-gray-100 rounded-2xl p-6 bg-slate-50 hover:bg-white hover:shadow-md transition-all">
            <h4 className="font-bold text-[#35255e] text-lg mb-2 flex items-center justify-between">
                {q}
                <ChevronDown size={20} className="text-gray-400" />
            </h4>
            <p className="text-gray-500 leading-relaxed text-sm">{a}</p>
        </div>
    )
}

function StoreButton({ icon, label, store, active, href }: { icon: React.ReactNode, label: string, store: string, active?: boolean, href?: string }) {
    return (
        <a href={href || "#"} target="_blank" className={`flex items-center gap-3 px-8 py-4 rounded-xl font-bold transition-all hover:scale-105 shadow-lg ${active ? 'bg-[#35255e] text-white ring-4 ring-[#35255e]/10' : 'bg-white text-[#35255e] border border-gray-200 hover:border-gray-300'}`}>
            {icon}
            <div className="text-left">
                <div className="text-[10px] font-medium opacity-80 uppercase tracking-wide">{label}</div>
                <div className="text-lg leading-none">{store}</div>
            </div>
        </a>
    )
}

function TransactionItem({ name, amount, reward }: { name: string, amount: string, reward: string }) {
    return (
        <div className="flex items-center justify-between p-3 bg-white rounded-xl shadow-sm border border-gray-50">
            <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-gray-100" />
                <div>
                    <div className="text-xs font-bold text-gray-700">{name}</div>
                    <div className="text-[10px] text-gray-400">Today, 2:30 PM</div>
                </div>
            </div>
            <div className="text-right">
                <div className="text-xs font-bold text-gray-800">-{amount}</div>
                <div className="text-[10px] font-bold text-[#00C4A7]">{reward} Coins</div>
            </div>
        </div>
    )
}
