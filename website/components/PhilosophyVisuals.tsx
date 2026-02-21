"use client";

import { motion } from "framer-motion";

export function DataFlowAnimation() {
    return (
        <div className="absolute inset-0 pointer-events-none overflow-hidden opacity-20">
            <svg className="w-full h-full" xmlns="http://www.w3.org/2000/svg">
                <defs>
                    <linearGradient id="flow-grad" x1="0%" y1="0%" x2="100%" y2="100%">
                        <stop offset="0%" stopColor="var(--primary)" stopOpacity="0" />
                        <stop offset="50%" stopColor="var(--primary)" stopOpacity="1" />
                        <stop offset="100%" stopColor="var(--primary)" stopOpacity="0" />
                    </linearGradient>
                </defs>

                {/* Circuit Lines */}
                {[...Array(5)].map((_, i) => (
                    <motion.path
                        key={`line-${i}`}
                        d={`M -20 ${100 + i * 150} Q ${200 + i * 100} ${50 + i * 50}, 1200 ${300 + i * 100}`}
                        stroke="rgba(0, 196, 167, 0.1)"
                        strokeWidth="1"
                        fill="none"
                        initial={{ pathLength: 0 }}
                        animate={{ pathLength: 1 }}
                        transition={{ duration: 3, delay: i * 0.5, repeat: Infinity, repeatType: "reverse" }}
                    />
                ))}

                {/* Moving Nodes */}
                {[...Array(8)].map((_, i) => (
                    <motion.circle
                        key={`node-${i}`}
                        r="2"
                        fill="var(--primary)"
                        initial={{ offsetDistance: "0%", opacity: 0 }}
                        animate={{
                            offsetDistance: "100%",
                            opacity: [0, 1, 1, 0],
                            scale: [1, 1.5, 1]
                        }}
                        transition={{
                            duration: 5 + Math.random() * 5,
                            delay: i * 1.2,
                            repeat: Infinity,
                            ease: "linear"
                        }}
                        style={{
                            offsetPath: `path('M -20 ${100 + (i % 5) * 150} Q ${200 + (i % 5) * 100} ${50 + (i % 5) * 50}, 1200 ${300 + (i % 5) * 100}')`,
                            position: 'absolute'
                        }}
                    >
                        <animate
                            attributeName="filter"
                            values="blur(0px);blur(4px);blur(0px)"
                            dur="2s"
                            repeatCount="indefinite"
                        />
                    </motion.circle>
                ))}
            </svg>
        </div>
    );
}

export function FoundationIllustration() {
    return (
        <div className="absolute inset-0 pointer-events-none opacity-10 group-hover:opacity-20 transition-opacity duration-1000">
            <svg className="w-full h-full" viewBox="0 0 400 600" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M 50 50 L 50 550 L 350 550" stroke="currentColor" strokeWidth="1" strokeDasharray="4 4" className="text-secondary" />

                {/* Foundation Blocks */}
                <motion.rect
                    x="40" y="500" width="100" height="40"
                    stroke="var(--primary)" strokeWidth="1"
                    initial={{ opacity: 0, scale: 0.8 }}
                    whileInView={{ opacity: 1, scale: 1 }}
                    transition={{ duration: 1 }}
                />

                <motion.path
                    d="M 140 520 L 180 400 L 220 300 L 260 150"
                    stroke="var(--primary)"
                    strokeWidth="2"
                    strokeLinecap="round"
                    initial={{ pathLength: 0 }}
                    whileInView={{ pathLength: 1 }}
                    transition={{ duration: 2, ease: "easeInOut" }}
                />

                {/* Pulsing Nodes on Roadmap Path */}
                {[520, 400, 300, 150].map((y, i) => {
                    const x = 140 + i * 40;
                    return (
                        <motion.circle
                            key={i}
                            cx={x} cy={y} r="4"
                            fill="var(--primary)"
                            initial={{ scale: 0 }}
                            whileInView={{ scale: [1, 1.5, 1] }}
                            transition={{ repeat: Infinity, duration: 2, delay: i * 0.5 }}
                        />
                    );
                })}

                <defs>
                    <filter id="glow">
                        <feGaussianBlur stdDeviation="2.5" result="coloredBlur" />
                        <feMerge>
                            <feMergeNode in="coloredBlur" />
                            <feMergeNode in="SourceGraphic" />
                        </feMerge>
                    </filter>
                </defs>
            </svg>
        </div>
    );
}

export function MissionIcon({ type }: { type: 'community' | 'growth' | 'integrity' }) {
    if (type === 'community') {
        return (
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <motion.path
                    d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"
                    stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                    initial={{ pathLength: 0 }} animate={{ pathLength: 1 }} transition={{ duration: 1 }}
                />
                <motion.circle
                    cx="9" cy="7" r="4"
                    stroke="currentColor" strokeWidth="2"
                    initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ duration: 0.5, delay: 0.5 }}
                />
                <motion.path
                    d="M23 21v-2a4 4 0 0 0-3-3.87"
                    stroke="currentColor" strokeWidth="2" strokeLinecap="round"
                    initial={{ pathLength: 0 }} animate={{ pathLength: 1 }} transition={{ duration: 1, delay: 0.8 }}
                />
                <motion.path
                    d="M16 3.13a4 4 0 0 1 0 7.75"
                    stroke="currentColor" strokeWidth="2"
                    initial={{ pathLength: 0 }} animate={{ pathLength: 1 }} transition={{ duration: 1, delay: 1 }}
                />
            </svg>
        );
    }

    if (type === 'growth') {
        return (
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <motion.path
                    d="M22 11.08V12a10 10 0 1 1-5.93-9.14"
                    stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                    initial={{ pathLength: 0 }} animate={{ pathLength: 1 }} transition={{ duration: 1 }}
                />
                <motion.path
                    d="M22 4L12 14.01l-3-3"
                    stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                    initial={{ pathLength: 0, opacity: 0 }} animate={{ pathLength: 1, opacity: 1 }} transition={{ duration: 0.8, delay: 1 }}
                />
            </svg>
        );
    }

    return (
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <motion.path
                d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"
                stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                initial={{ pathLength: 0 }} animate={{ pathLength: 1 }} transition={{ duration: 1 }}
            />
            <motion.path
                d="M9 12l2 2 4-4"
                stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ duration: 0.5, delay: 1 }}
            />
        </svg>
    );
}
