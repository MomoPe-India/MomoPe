"use client";

import { motion } from "framer-motion";
import { Share2, UserPlus, Gift, Copy, ChevronDown, ChevronUp } from "lucide-react";
import { useState } from "react";
import Image from "next/image";
import { Navbar } from "@/components/Navbar";
import { Footer } from "@/components/Footer";

export function ReferralContent() {
    return (
        <main className="bg-surface min-h-screen font-sans text-slate-800">
            <Navbar />

            {/* Hero Section */}
            <section className="pt-32 pb-20 bg-white relative overflow-hidden">
                <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-teal-50/50 rounded-full blur-3xl -z-10 translate-x-1/2 -translate-y-1/2" />
                <div className="container mx-auto px-6 text-center">
                    <motion.div
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass border-primary/20 text-primary-dark font-semibold text-sm mb-6"
                    >
                        <Gift size={14} /> MomoPe Referral Program
                    </motion.div>
                    <motion.h1
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 }}
                        className="text-5xl md:text-7xl font-black text-[#35255e] mb-6 tracking-tight"
                    >
                        Refer. Reward. <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#00C4A7] to-blue-600">Repeat.</span>
                    </motion.h1>
                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 }}
                        className="text-xl text-gray-500 max-w-2xl mx-auto leading-relaxed"
                    >
                        Invite friends to MomoPe. When they complete their first eligible transaction, both of you receive bonus Momo Coins.
                    </motion.p>
                </div>
            </section>

            {/* Main Content Split */}
            <section className="py-20 bg-gray-50/50">
                <div className="container mx-auto px-6 max-w-6xl">
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">

                        {/* Left: How It Works */}
                        <div className="space-y-12">
                            <h2 className="text-3xl font-bold text-[#35255e]">How it works</h2>
                            <div className="space-y-8 relative">
                                {/* Connector Line */}
                                <div className="absolute left-[27px] top-4 bottom-4 w-0.5 bg-gray-200 -z-10" />

                                <StepItem
                                    icon={<Share2 size={24} />}
                                    title="Share Your Code"
                                    desc="Share your unique referral code with friends and family via WhatsApp or SMS."
                                    step={1}
                                />
                                <StepItem
                                    icon={<UserPlus size={24} />}
                                    title="Friend joins & Pays"
                                    desc="Your friend signs up and completes their first eligible payment of ₹100 or more."
                                    step={2}
                                />
                                <StepItem
                                    icon={<Gift size={24} />}
                                    title="Both Earn Rewards"
                                    desc="You and your friend instantly receive bonus Momo Coins in your wallets."
                                    step={3}
                                    isCoin
                                />
                            </div>
                        </div>

                        {/* Right: Dashboard Mockup */}
                        <div className="relative">
                            <div className="absolute -inset-4 bg-gradient-to-br from-[#00C4A7]/20 to-purple-500/20 rounded-[2.5rem] blur-xl -z-10" />
                            <div className="bg-white rounded-[2rem] p-8 shadow-2xl border border-gray-100 overflow-hidden relative">
                                {/* Mock Header */}
                                <div className="flex items-center justify-between mb-8">
                                    <div className="text-sm font-bold text-gray-400 uppercase tracking-wider">Your Referral Dashboard</div>
                                    <div className="w-8 h-8 rounded-full bg-gray-100" />
                                </div>

                                {/* Main Stats */}
                                <div className="grid grid-cols-2 gap-4 mb-8">
                                    <div className="p-4 bg-black rounded-2xl border border-teal-100 flex items-center gap-3">
                                        <div className="relative w-10 h-10 shrink-0">
                                            <Image src="/images/momo-coin.png" alt="Coin" fill className="object-contain" />
                                        </div>
                                        <div>
                                            <div className="text-2xl font-black text-[#00C4A7]">2,400</div>
                                            <div className="text-[10px] font-bold text-teal-600/70 uppercase">Coins Earned</div>
                                        </div>
                                    </div>
                                    <div className="p-4 bg-purple-50 rounded-2xl border border-purple-100">
                                        <div className="text-2xl font-black text-purple-600">12</div>
                                        <div className="text-[10px] font-bold text-purple-600/70 uppercase">Friends Joined</div>
                                    </div>
                                </div>

                                {/* Copy Code Section */}
                                <div className="bg-gray-900 rounded-xl p-6 text-center text-white mb-8 relative overflow-hidden">
                                    <div className="relative z-10">
                                        <p className="text-gray-400 text-xs uppercase mb-2">Your Unique Code</p>
                                        <div className="text-3xl font-mono font-bold tracking-widest mb-4">MOHAN88</div>
                                        <button className="w-full py-3 bg-[#00C4A7] hover:bg-[#00A890] text-white rounded-lg font-bold flex items-center justify-center gap-2 transition-colors">
                                            <Copy size={18} /> Copy Code
                                        </button>
                                    </div>
                                    <div className="absolute top-0 right-0 w-32 h-32 bg-white/5 rounded-full blur-2xl -translate-y-1/2 translate-x-1/2" />
                                </div>

                                {/* Recent List Mock */}
                                <div className="space-y-4">
                                    <p className="text-xs font-bold text-gray-400 uppercase">Recent Invites</p>
                                    <InviteItem name="Suresh K." status="Completed" />
                                    <InviteItem name="Priya M." status="Pending" />
                                    <InviteItem name="Rahul R." status="Completed" />
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </section>

            {/* Terms Accordion */}
            <section className="py-20 bg-white border-t border-gray-100">
                <div className="container mx-auto px-6 max-w-3xl">
                    <h3 className="text-2xl font-bold text-[#35255e] mb-8 text-center">Program Terms & Policies</h3>
                    <div className="space-y-4">
                        <TermItem title="Eligibility" content="The offer is valid for new users who have never installed the MomoPe app before. The referral bonus is credited only after the first successful transaction." />
                        <TermItem title="Minimum Transaction" content="The referred user must complete a minimum transaction of ₹100 using MomoPe QR code at any merchant store to unlock the bonus." />
                        <TermItem title="Coin Expiry" content="Referral bonus coins follow the standard 90-day expiry policy. Unused coins will lapse after 90 days from the date of credit." />
                        <TermItem title="Redemption Rules" content="Consistent with MomoPe&apos;s economy policy, users can redeem up to 20% of the bill value using coins per transaction. The 80/20 rule applies to all referral bonuses." />
                    </div>
                    <p className="text-center text-gray-400 text-sm mt-12">
                        MomoPe reserves the right to modify or terminate the referral program at any time. Fraudulent activity will lead to account suspension.
                    </p>
                </div>
            </section>

            <Footer />
        </main>
    );
}

function StepItem({ icon, title, desc, step, isCoin }: { icon: React.ReactNode, title: string, desc: string, step: number, isCoin?: boolean }) {
    return (
        <div className="flex gap-6 relative bg-white p-6 rounded-2xl border border-gray-100 shadow-sm z-10">
            <div className={`w-14 h-14 rounded-full ${isCoin ? 'bg-black' : 'bg-[#35255e]'} text-white flex items-center justify-center shrink-0 shadow-lg ${isCoin ? '' : 'shadow-[#35255e]/20'} overflow-hidden relative`}>
                {isCoin ? (
                    <div className="relative w-full h-full p-2.5">
                        <Image src="/images/momo-coin.png" alt="Coin" fill className="object-contain" />
                    </div>
                ) : (
                    icon
                )}
            </div>
            <div>
                <div className="text-xs font-bold text-[#00C4A7] uppercase mb-1">Step {step}</div>
                <h3 className="text-xl font-bold text-[#35255e] mb-2">{title}</h3>
                <p className="text-gray-500 leading-relaxed text-sm">{desc}</p>
            </div>
        </div>
    )
}

function InviteItem({ name, status }: { name: string, status: "Completed" | "Pending" }) {
    const isCompleted = status === "Completed";
    return (
        <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg border border-gray-100">
            <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center text-xs font-bold text-gray-500">
                    {name.charAt(0)}
                </div>
                <div className="text-sm font-bold text-gray-700">{name}</div>
            </div>
            <div className={`px-3 py-1 rounded-full text-xs font-bold ${isCompleted ? 'bg-green-100 text-green-700' : 'bg-amber-100 text-amber-700'}`}>
                {status}
            </div>
        </div>
    )
}

function TermItem({ title, content }: { title: string, content: string }) {
    const [isOpen, setIsOpen] = useState(false);
    return (
        <div className="border border-gray-200 rounded-xl overflow-hidden">
            <button
                onClick={() => setIsOpen(!isOpen)}
                className="w-full flex items-center justify-between p-4 bg-gray-50 hover:bg-gray-100 transition-colors text-left"
            >
                <span className="font-bold text-[#35255e]">{title}</span>
                {isOpen ? <ChevronUp size={20} className="text-gray-400" /> : <ChevronDown size={20} className="text-gray-400" />}
            </button>
            {isOpen && (
                <div className="p-4 bg-white text-gray-500 text-sm leading-relaxed border-t border-gray-100">
                    {content}
                </div>
            )}
        </div>
    )
}
