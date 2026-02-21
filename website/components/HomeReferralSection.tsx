"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Share2, UserCheck, Gift, Store, TrendingUp, CheckCircle, ArrowRight } from "lucide-react";
import Link from "next/link";

type ViewType = "users" | "merchants";

export function HomeReferralSection() {
    const [view, setView] = useState<ViewType>("users");

    return (
        <section className="py-24 bg-surface relative overflow-hidden">
            {/* Ambient Background */}
            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full h-full max-w-7xl">
                <div className="absolute top-[20%] left-[10%] w-72 h-72 bg-primary/5 rounded-full blur-[100px]" />
                <div className="absolute bottom-[20%] right-[10%] w-96 h-96 bg-purple-500/5 rounded-full blur-[100px]" />
            </div>

            <div className="container mx-auto px-6 relative z-10">

                {/* Header & Toggle */}
                <div className="flex flex-col items-center text-center mb-16">
                    <motion.div
                        initial={{ opacity: 0, y: 10 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        className="mb-8"
                    >
                        <h2 className="text-4xl md:text-5xl font-black text-[#35255e] mb-4">Grow Together. Earn Together.</h2>
                        <p className="text-gray-500 text-xl max-w-2xl mx-auto">
                            Invite friends and businesses to the MomoPe ecosystem. Unlock exclusive rewards for every successful connection.
                        </p>
                    </motion.div>

                    {/* Premium Toggle */}
                    <div className="bg-white p-1.5 rounded-full shadow-umbra-md border border-gray-100 inline-flex relative overflow-hidden">
                        {/* Sliding Background */}
                        <motion.div
                            className="absolute top-1.5 bottom-1.5 bg-secondary rounded-full shadow-lg z-0"
                            initial={false}
                            animate={{
                                left: view === "users" ? "6px" : "calc(50% + 1px)",
                                width: "calc(50% - 7px)"
                            }}
                            transition={{ type: "spring", stiffness: 400, damping: 35 }}
                        />

                        <button
                            onClick={() => setView("users")}
                            className={`relative z-10 px-10 py-3 rounded-full text-xs font-black uppercase tracking-widest transition-colors duration-500 ${view === "users" ? "text-white" : "text-gray-400 hover:text-secondary"}`}
                        >
                            Consumer
                        </button>
                        <button
                            onClick={() => setView("merchants")}
                            className={`relative z-10 px-10 py-3 rounded-full text-xs font-black uppercase tracking-widest transition-colors duration-500 ${view === "merchants" ? "text-white" : "text-gray-400 hover:text-secondary"}`}
                        >
                            Merchant
                        </button>
                    </div>
                </div>

                {/* Content Cards */}
                <div className="max-w-5xl mx-auto min-h-[400px]">
                    <AnimatePresence mode="wait">
                        <motion.div
                            key={view}
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            exit={{ opacity: 0, y: -20 }}
                            transition={{ duration: 0.3 }}
                            className="grid grid-cols-1 md:grid-cols-3 gap-6 md:gap-8"
                        >
                            {view === "users" ? (
                                <>
                                    <ReferralCard
                                        icon={<Share2 size={32} />}
                                        title="Share Your Code"
                                        desc="Send your unique invite link to friends & family via WhatsApp."
                                        step={1}
                                        color="text-blue-500"
                                        bg="bg-blue-50"
                                    />
                                    <ReferralCard
                                        icon={<UserCheck size={32} />}
                                        title="Friend Transacts"
                                        desc="Your friend completes their first eligible payment of ₹100+."
                                        step={2}
                                        color="text-purple-500"
                                        bg="bg-purple-50"
                                    />
                                    <ReferralCard
                                        icon={<Gift size={32} />}
                                        title="Both Earn Rewards"
                                        desc="You both instantly receive bonus Momo Coins in your wallet."
                                        step={3}
                                        color="text-primary"
                                        bg="bg-teal-50"
                                        isCoin
                                    />
                                </>
                            ) : (
                                <>
                                    <ReferralCard
                                        icon={<Store size={32} />}
                                        title="Invite Businesses"
                                        desc="Know a shop owner? Refer them to join the MomoPe Business network."
                                        step={1}
                                        color="text-indigo-500"
                                        bg="bg-indigo-50"
                                    />
                                    <ReferralCard
                                        icon={<CheckCircle size={32} />}
                                        title="Onboarding Success"
                                        desc="They sign up and start accepting payments via MomoPe QR."
                                        step={2}
                                        color="text-emerald-500"
                                        bg="bg-emerald-50"
                                    />
                                    <ReferralCard
                                        icon={<TrendingUp size={32} />}
                                        title="Earn Commissions"
                                        desc="Get significant referral bonuses and ongoing partner incentives."
                                        step={3}
                                        color="text-amber-500"
                                        bg="bg-amber-50"
                                        isCoin
                                    />
                                </>
                            )}
                        </motion.div>
                    </AnimatePresence>

                    {/* Footer CTA */}
                    <motion.div
                        initial={{ opacity: 0 }}
                        whileInView={{ opacity: 1 }}
                        transition={{ delay: 0.4 }}
                        className="text-center mt-16"
                    >
                        <Link href="/referral-program" className="inline-flex items-center gap-2 text-primary font-bold hover:text-primary-dark transition-colors border-b-2 border-transparent hover:border-primary">
                            View Full Program Details <ArrowRight size={18} />
                        </Link>
                    </motion.div>
                </div>
            </div>
        </section>
    );
}

interface CardProps {
    icon: React.ReactNode;
    title: string;
    desc: string;
    step: number;
    color: string;
    bg: string;
    isCoin?: boolean;
}

function ReferralCard({ icon, title, desc, step, color, bg, isCoin }: CardProps) {
    return (
        <div className="group relative bg-white/80 backdrop-blur-xl p-8 rounded-3xl border border-white/50 shadow-umbra-lg hover:shadow-premium hover:-translate-y-2 transition-all duration-500 overflow-hidden">

            {/* Gradient Border Effect on Hover */}
            <div className="absolute inset-0 border-2 border-transparent group-hover:border-primary/10 rounded-3xl transition-colors duration-500 pointer-events-none" />

            {/* Ambient Glow */}
            <div className={`absolute -right-10 -top-10 w-32 h-32 ${bg} rounded-full blur-[50px] opacity-0 group-hover:opacity-100 transition-opacity duration-700`} />

            {/* Step Number */}
            <div className="absolute top-6 right-6 text-6xl font-black text-gray-100 select-none group-hover:text-gray-200/80 transition-colors duration-500">
                0{step}
            </div>

            {/* Icon Container */}
            <div className={`relative w-16 h-16 rounded-2xl ${bg} ${color} flex items-center justify-center mb-6 shadow-sm group-hover:scale-110 group-hover:rotate-3 transition-all duration-500 z-10`}>
                {icon}
            </div>

            {/* Content */}
            <div className="relative z-10">
                <h3 className="text-xl font-bold text-[#35255e] mb-3 group-hover:text-primary transition-colors duration-300">{title}</h3>
                <p className="text-gray-500 leading-relaxed text-sm group-hover:text-gray-600 transition-colors duration-300">{desc}</p>
            </div>

            {/* Shine Effect */}
            <div className="absolute top-0 -left-[100%] w-full h-full bg-gradient-to-r from-transparent via-white/40 to-transparent skew-x-12 group-hover:left-[100%] transition-all duration-1000 ease-in-out" />
        </div>
    );
}
