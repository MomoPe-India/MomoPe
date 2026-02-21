"use client";

import { motion } from "framer-motion";
import Image from "next/image";
import { CheckCircle2, Coins } from "lucide-react";

export function HeroVisual() {
    return (
        <div className="relative w-full h-[500px] md:h-[700px] flex items-center justify-center">

            {/* Glassy Background Circle */}
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[350px] h-[350px] md:w-[600px] md:h-[600px] bg-gradient-to-tr from-primary/20 to-blue-400/10 rounded-full blur-[80px] -z-10" />

            {/* Main Hero Image - Responsive Container */}
            <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.8 }}
                className="relative z-10 w-full h-full max-w-[500px] md:max-w-[650px] mx-auto"
            >
                <Image
                    src="/images/hero-lady.webp"
                    alt="MomoPe Happy User"
                    fill
                    className="object-contain drop-shadow-2xl hover:scale-[1.02] transition-transform duration-700"
                    priority
                    sizes="(max-width: 768px) 100vw, 50vw"
                />
            </motion.div>

            {/* Floating Callout 1: Payment Success (Minimal) */}
            <motion.div
                initial={{ opacity: 0, scale: 0.8, x: -30 }}
                animate={{ opacity: 1, scale: 1, x: 0 }}
                transition={{ delay: 0.6, type: "spring", stiffness: 200, damping: 20 }}
                className="absolute bottom-[15%] left-[0%] md:left-[-2%] glass-card p-2.5 pr-4 flex items-center gap-3 z-20 hover:scale-105 transition-transform cursor-default"
            >
                <div className="w-8 h-8 bg-green-100/90 rounded-full flex items-center justify-center text-green-600 backdrop-blur-sm shadow-sm">
                    <CheckCircle2 size={16} strokeWidth={3} />
                </div>
                <div>
                    <div className="text-[9px] text-gray-400 font-bold uppercase tracking-wider">Paid</div>
                    <div className="text-[#35255e] font-bold text-sm leading-tight">₹250.00</div>
                </div>
            </motion.div>

            {/* Floating Callout 2: Cashback Earned (Minimal) */}
            <motion.div
                initial={{ opacity: 0, scale: 0.8, x: 30 }}
                animate={{ opacity: 1, scale: 1, x: 0 }}
                transition={{ delay: 0.9, type: "spring", stiffness: 200, damping: 20 }}
                className="absolute top-[25%] right-[2%] md:right-[0%] glass-card p-2.5 pr-4 flex items-center gap-3 z-20 hover:scale-105 transition-transform cursor-default"
            >
                <div className="w-8 h-8 bg-amber-100/90 rounded-full flex items-center justify-center text-amber-600 backdrop-blur-sm shadow-sm">
                    <Coins size={16} fill="currentColor" />
                </div>
                <div>
                    <div className="text-[9px] text-gray-400 font-bold uppercase tracking-wider">Cashback</div>
                    <div className="text-[#35255e] font-bold text-sm leading-tight">+50 Coins</div>
                </div>
            </motion.div>

            {/* Decorative Elements - Very Subtle */}
            <FloatingIcon delay={1.2} x="85%" y="15%" size={32} icon="₹" />
            <FloatingIcon delay={1.5} x="12%" y="35%" size={24} icon="%" />
        </div>
    );
}

function FloatingIcon({ delay, x, y, size, icon }: { delay: number, x: string, y: string, size: number, icon: string }) {
    return (
        <motion.div
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay, type: "spring", stiffness: 200 }}
            className="absolute z-10 glass-card flex items-center justify-center text-[#35255e]/50 font-bold shadow-sm"
            style={{
                left: x,
                top: y,
                width: size,
                height: size,
                borderRadius: '50%',
                fontSize: size * 0.5
            }}
        >
            {icon}
        </motion.div>
    )
}
