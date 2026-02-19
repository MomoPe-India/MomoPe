"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { X, Smartphone, ArrowRight } from "lucide-react";
import Link from "next/link";

export function MobileDownloadPrompt() {
    const [isVisible, setIsVisible] = useState(false);
    const [isDismissed, setIsDismissed] = useState(false);

    useEffect(() => {
        // Don't show if already dismissed in this session (simple logic)
        // For persistence we would need localStorage, but simple state is fine for now
        if (isDismissed) return;

        // Show after 15 seconds
        const timer = setTimeout(() => {
            setIsVisible(true);
        }, 15000);

        // Show on scroll
        const handleScroll = () => {
            if (window.scrollY > 400) {
                setIsVisible(true);
            }
        };

        window.addEventListener("scroll", handleScroll);

        return () => {
            clearTimeout(timer);
            window.removeEventListener("scroll", handleScroll);
        };
    }, [isDismissed]);

    const handleDismiss = () => {
        setIsVisible(false);
        setIsDismissed(true);
    };

    return (
        <AnimatePresence>
            {isVisible && !isDismissed && (
                <motion.div
                    initial={{ y: 100, opacity: 0 }}
                    animate={{ y: 0, opacity: 1 }}
                    exit={{ y: 100, opacity: 0 }}
                    transition={{ type: "spring", stiffness: 300, damping: 30 }}
                    className="fixed bottom-6 left-4 right-4 z-50 md:hidden"
                >
                    <div className="bg-white/90 backdrop-blur-xl border border-white/20 p-4 rounded-2xl shadow-2xl flex items-center justify-between gap-4 relative overflow-hidden">

                        {/* Decorative background */}
                        <div className="absolute top-0 right-0 w-24 h-24 bg-teal-500/10 rounded-full blur-2xl -z-10" />

                        <div className="flex items-center gap-3">
                            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-primary to-emerald-500 flex items-center justify-center text-white shadow-lg">
                                <Smartphone size={20} className="animate-pulse" />
                            </div>
                            <div className="flex flex-col">
                                <span className="font-bold text-[#35255e] text-sm leading-tight">MomoPe</span>
                                <span className="text-xs text-gray-500 font-medium">Get the app for free</span>
                            </div>
                        </div>

                        <div className="flex items-center gap-3">
                            <Link
                                href="https://whatsapp.com/channel/0029VbBhoLk7z4kiZU9cBz1U"
                                target="_blank"
                                className="px-4 py-2 bg-[#35255e] text-white text-xs font-bold rounded-lg shadow-md hover:bg-[#2a1d4a] transition-colors flex items-center gap-1"
                            >
                                Get <ArrowRight size={12} />
                            </Link>
                            <button
                                onClick={handleDismiss}
                                className="p-1.5 rounded-full bg-gray-100/80 text-gray-500 hover:bg-gray-200 transition-colors"
                            >
                                <X size={16} />
                            </button>
                        </div>
                    </div>
                </motion.div>
            )}
        </AnimatePresence>
    );
}
