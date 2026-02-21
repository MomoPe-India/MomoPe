"use client";

import { motion } from "framer-motion";
import Link from "next/link";
import { ArrowRight, Shield } from "lucide-react";
import { HeroVisual } from "./HeroVisual";

export function HeroSection() {
    return (
        <section className="relative pt-28 pb-16 md:pt-40 md:pb-24 overflow-hidden">

            {/* Background Gradients - Deeper & More Immersive */}
            <div className="absolute top-[-20%] right-[-10%] w-[70%] h-[70%] bg-primary/10 rounded-full blur-[120px] -z-10 animate-pulse transition-opacity duration-1000" />
            <div className="absolute bottom-[-10%] left-[-10%] w-[50%] h-[50%] bg-primary/5 rounded-full blur-[100px] -z-10" />
            <div className="absolute top-[20%] left-[20%] w-[30%] h-[30%] bg-purple-500/5 rounded-full blur-[120px] -z-10" />

            {/* Floating Elements (Decorations) */}
            <motion.div
                animate={{ y: [-10, 10, -10] }}
                transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
                className="absolute top-40 left-[10%] w-16 h-16 bg-gradient-to-br from-amber-300 to-orange-400 rounded-full blur-xl opacity-60 -z-10"
            />
            <motion.div
                animate={{ y: [15, -15, 15] }}
                transition={{ duration: 5, repeat: Infinity, ease: "easeInOut" }}
                className="absolute bottom-40 right-[15%] w-24 h-24 bg-gradient-to-br from-purple-400 to-indigo-500 rounded-full blur-2xl opacity-40 -z-10"
            />

            <div className="container mx-auto px-4 md:px-6 relative z-10">
                <div className="flex flex-col lg:flex-row items-center gap-12 lg:gap-8">

                    {/* Left Content */}
                    <div className="flex-1 text-center lg:text-left z-20">
                        <motion.div
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="inline-flex items-center gap-2 px-5 py-2 rounded-full glass border-primary/30 text-primary-dark font-bold text-sm mb-8 shadow-lg shadow-primary/10"
                        >
                            <div className="w-2.5 h-2.5 rounded-full bg-primary animate-pulse" />
                            Payments 2.0 is Live
                        </motion.div>

                        <motion.h1
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.1 }}
                            className="text-4xl sm:text-5xl md:text-6xl lg:text-8xl font-black text-secondary tracking-tight mb-8 leading-[1.02]"
                        >
                            Scan. Pay. <br className="hidden sm:block" />
                            <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary via-primary-dark to-secondary animate-gradient-x drop-shadow-[0_0_15px_rgba(0,196,167,0.3)]">
                                & Earn.
                            </span>
                        </motion.h1>

                        <motion.p
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.2 }}
                            className="text-lg md:text-xl text-text-secondary mb-10 leading-relaxed max-w-lg mx-auto lg:mx-0 font-medium"
                        >
                            A future-ready digital payments app that turns every transaction into a fast, seamless, and rewarding experience for the modern economy.
                        </motion.p>

                        <motion.div
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.3 }}
                            className="flex flex-col sm:flex-row items-center gap-4 justify-center lg:justify-start w-full sm:w-auto"
                        >
                            <Link
                                href="/download"
                                className="w-full sm:w-auto px-8 py-4 btn-premium rounded-full font-bold text-lg flex items-center justify-center gap-2"
                            >
                                Get Started <ArrowRight size={20} />
                            </Link>

                        </motion.div>



                        {/* Premium Trust Strip (Restored & Positioned) */}
                        {/* Premium Trust Strip (Restored & Positioned) */}
                        {/* Premium Trust Strip (Restored & Positioned) */}
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.5 }}
                            className="mt-12 md:mt-16 p-6 rounded-[2rem] glass border border-white/60 shadow-umbra-lg flex flex-col sm:flex-row items-center justify-between gap-5 sm:gap-8 w-full max-w-md sm:max-w-xl mx-auto lg:mx-0 backdrop-blur-2xl bg-white/40"
                        >
                            {/* Security & Power - Mobile: Side by Side, Desktop: Side by Side */}
                            <div className="flex flex-row items-center justify-center gap-3 sm:gap-5 w-full sm:w-auto">
                                <div className="flex items-center gap-2 px-3 py-2 rounded-full bg-green-500/10 border border-green-500/20 text-green-700 font-bold text-[10px] sm:text-xs uppercase tracking-wider whitespace-nowrap shadow-sm">
                                    <Shield size={12} className="fill-current sm:w-[14px] sm:h-[14px]" /> 100% Secure
                                </div>
                                <div className="hidden sm:block h-5 w-px bg-gray-400/50" />
                                <div className="text-[10px] sm:text-xs font-bold text-gray-500 flex items-center gap-1 whitespace-nowrap">
                                    <span className="uppercase tracking-widest opacity-80">Powered by</span>
                                    <span className="text-gray-900 font-black text-xs sm:text-sm">PayU</span>
                                </div>
                            </div>

                            {/* Mobile Separator */}
                            <div className="w-full h-px bg-gradient-to-r from-transparent via-gray-200 to-transparent sm:hidden" />

                            {/* Partner CTA (Integrated) */}
                            <Link
                                href="/merchant"
                                className="flex items-center gap-2 text-primary font-bold text-sm hover:text-primary-dark transition-colors group sm:ml-auto w-full sm:w-auto justify-center sm:justify-start"
                            >
                                Partner with Us <ArrowRight size={16} className="group-hover:translate-x-1 transition-transform" />
                            </Link>
                        </motion.div>
                    </div>

                    {/* Right Visual - Image */}
                    <div className="flex-1 w-full flex justify-center lg:justify-end relative min-h-[400px] md:min-h-[600px]">
                        <HeroVisual />
                    </div>
                </div>
            </div>
        </section >
    );
}
