"use client";

import { motion } from "framer-motion";
import { Users, Zap, Shield, Repeat, Smartphone, QrCode, TrendingUp, UserMinus } from "lucide-react";

/**
 * StatusQuoVisual - Represents the "Dead End" Traditional UPI
 */
export function StatusQuoVisual() {
    return (
        <div className="relative w-full h-full flex items-center justify-center p-8 bg-gray-50/50 rounded-[3rem] border border-dashed border-gray-200 overflow-hidden group">
            <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(0,0,0,0.02)_1px,transparent_1px)] bg-[size:20px_20px]" />

            <div className="relative z-10">
                <motion.div
                    animate={{
                        opacity: [0.3, 0.4, 0.3],
                        scale: [1, 1.02, 1]
                    }}
                    transition={{ duration: 4, repeat: Infinity }}
                    className="w-40 h-40 bg-white rounded-3xl border-4 border-gray-300 flex items-center justify-center shadow-lg relative"
                >
                    <QrCode size={80} className="text-gray-300" />
                    <div className="absolute inset-0 flex items-center justify-center">
                        <div className="w-full h-[2px] bg-red-400 rotate-45 opacity-20" />
                    </div>
                </motion.div>

                {/* Vanishing Data Nodes */}
                {[...Array(6)].map((_, i) => (
                    <motion.div
                        key={i}
                        initial={{ opacity: 0, scale: 0 }}
                        animate={{
                            opacity: [0, 0.5, 0],
                            scale: [0.5, 1, 0.5],
                            x: [0, (i % 2 === 0 ? -60 : 60)],
                            y: [0, (i < 3 ? -60 : 60)]
                        }}
                        transition={{
                            duration: 3,
                            delay: i * 0.5,
                            repeat: Infinity,
                            ease: "easeOut"
                        }}
                        className="absolute top-1/2 left-1/2 w-8 h-8 -translate-x-1/2 -translate-y-1/2 bg-gray-100 rounded-full flex items-center justify-center border border-gray-200"
                    >
                        <UserMinus size={14} className="text-gray-400" />
                    </motion.div>
                ))}
            </div>

            <div className="absolute bottom-6 left-1/2 -translate-x-1/2 flex items-center gap-2 px-3 py-1 bg-gray-200/50 rounded-full">
                <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest italic">Disconnected</span>
            </div>
        </div>
    );
}

/**
 * GrowthOSVisual - Represents the vibrant MomoPe Growth Engine
 */
export function GrowthOSVisual() {
    return (
        <div className="relative w-full h-full flex items-center justify-center p-8 bg-primary/5 rounded-[3rem] border border-primary/20 overflow-hidden group">
            {/* Animated Grid */}
            <div className="absolute inset-0 opacity-20">
                <svg width="100%" height="100%">
                    <pattern id="comparison-grid" width="40" height="40" patternUnits="userSpaceOnUse">
                        <path d="M 40 0 L 0 0 0 40" fill="none" stroke="var(--primary)" strokeWidth="0.5" />
                    </pattern>
                    <rect width="100%" height="100%" fill="url(#comparison-grid)" />
                </svg>
            </div>

            {/* Central Terminal */}
            <div className="relative z-20">
                <motion.div
                    whileHover={{ scale: 1.05 }}
                    className="w-48 h-48 bg-white rounded-4xl border-4 border-primary shadow-umbra-lg flex items-center justify-center relative overflow-hidden"
                >
                    <div className="absolute inset-0 bg-gradient-to-br from-primary/10 to-transparent" />
                    <QrCode size={96} className="text-primary" />

                    {/* Pulsing Scan Line */}
                    <motion.div
                        animate={{ top: ['0%', '100%', '0%'] }}
                        transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
                        className="absolute left-0 right-0 h-0.5 bg-primary/30 shadow-[0_0_15px_rgba(0,196,167,0.5)]"
                    />
                </motion.div>

                {/* Outgoing Connections & Incoming Users */}
                {[...Array(8)].map((_, i) => {
                    const angle = (i * 45) * (Math.PI / 180);
                    const x = Math.cos(angle) * 120;
                    const y = Math.sin(angle) * 120;

                    return (
                        <div key={i} className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 pointer-events-none">
                            <motion.div
                                initial={{ opacity: 0, scale: 0 }}
                                animate={{
                                    opacity: [0, 1, 0],
                                    scale: [0.5, 1, 0.8],
                                    x: [0, x],
                                    y: [0, y]
                                }}
                                transition={{
                                    duration: 4,
                                    delay: i * 0.4,
                                    repeat: Infinity,
                                    ease: "easeOut"
                                }}
                                className="w-12 h-12 bg-white rounded-2xl shadow-lg border border-primary/20 flex items-center justify-center"
                            >
                                {i % 2 === 0 ? (
                                    <Users size={20} className="text-primary" />
                                ) : (
                                    <div className="w-6 h-6 bg-yellow-400 rounded-full flex items-center justify-center text-[10px] font-black text-white">$</div>
                                )}
                            </motion.div>

                            {/* Connector Line */}
                            <motion.div
                                initial={{ width: 0, opacity: 0 }}
                                animate={{
                                    width: [0, 120, 0],
                                    opacity: [0, 0.4, 0],
                                    rotate: angle * (180 / Math.PI)
                                }}
                                transition={{
                                    duration: 4,
                                    delay: i * 0.4,
                                    repeat: Infinity,
                                    ease: "easeOut"
                                }}
                                className="absolute top-1/2 left-0 h-px bg-primary origin-left"
                            />
                        </div>
                    );
                })}
            </div>

            {/* Ambient Background Glows */}
            <div className="absolute top-0 right-0 w-48 h-48 bg-primary/20 rounded-full blur-[80px]" />
            <div className="absolute bottom-0 left-0 w-32 h-32 bg-accent/20 rounded-full blur-[60px]" />

            <div className="absolute bottom-6 left-1/2 -translate-x-1/2 flex items-center gap-2 px-4 py-1.5 bg-primary/10 rounded-full border border-primary/20 shadow-lg">
                <div className="w-1.5 h-1.5 rounded-full bg-primary animate-pulse" />
                <span className="text-[10px] font-black text-primary uppercase tracking-[0.2em]">Growth Loop Active</span>
            </div>
        </div>
    );
}
