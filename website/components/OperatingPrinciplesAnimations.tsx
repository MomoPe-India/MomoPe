"use client";

import React from "react";
import { motion } from "framer-motion";

export function VelocityAnimation() {
    return (
        <div className="relative w-16 h-16 flex items-center justify-center">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <motion.path
                    d="M13 2L3 14H12L11 22L21 10H12L13 2Z"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    initial={{ pathLength: 0, opacity: 0 }}
                    animate={{ pathLength: 1, opacity: 1 }}
                    transition={{ duration: 1.5, repeat: Infinity, repeatType: "reverse" }}
                    className="text-accent"
                />
                {[...Array(3)].map((_, i) => (
                    <motion.line
                        key={i}
                        x1="22"
                        y1={8 + i * 4}
                        x2="18"
                        y2={8 + i * 4}
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                        animate={{ x1: [22, 10], x2: [18, 6], opacity: [0, 1, 0] }}
                        transition={{ duration: 0.8, repeat: Infinity, delay: i * 0.2 }}
                        className="text-accent/40"
                    />
                ))}
            </svg>
            <motion.div
                className="absolute inset-0 bg-accent/10 rounded-full blur-xl"
                animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.6, 0.3] }}
                transition={{ duration: 2, repeat: Infinity }}
            />
        </div>
    );
}

export function FirstPrinciplesAnimation() {
    return (
        <div className="relative w-16 h-16 flex items-center justify-center">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                {/* Foundation blocks */}
                <motion.rect
                    x="4" y="16" width="16" height="4" rx="1"
                    stroke="currentColor" strokeWidth="2"
                    animate={{ opacity: [0.3, 1, 0.3] }}
                    transition={{ duration: 2, repeat: Infinity }}
                    className="text-primary"
                />
                <motion.rect
                    x="6" y="10" width="12" height="4" rx="1"
                    stroke="currentColor" strokeWidth="2"
                    animate={{ opacity: [0.3, 1, 0.3] }}
                    transition={{ duration: 2, repeat: Infinity, delay: 0.5 }}
                    className="text-primary"
                />
                <motion.rect
                    x="9" y="4" width="6" height="4" rx="1"
                    stroke="currentColor" strokeWidth="2"
                    animate={{ opacity: [0.3, 1, 0.3] }}
                    transition={{ duration: 2, repeat: Infinity, delay: 1 }}
                    className="text-primary"
                />

                {/* Success lines */}
                <motion.path
                    d="M12 20V4"
                    stroke="currentColor"
                    strokeWidth="1"
                    strokeDasharray="4 4"
                    animate={{ strokeDashoffset: [0, -8] }}
                    transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                    className="text-primary/30"
                />
            </svg>
            <motion.div
                className="absolute inset-0 bg-primary/10 rounded-full blur-xl"
                animate={{ scale: [1, 1.1, 1], opacity: [0.2, 0.4, 0.2] }}
                transition={{ duration: 3, repeat: Infinity }}
            />
        </div>
    );
}

export function EngineeringExcellenceAnimation() {
    return (
        <div className="relative w-16 h-16 flex items-center justify-center">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                {/* Rotating Rings */}
                <motion.circle
                    cx="12" cy="12" r="9"
                    stroke="currentColor" strokeWidth="1"
                    strokeDasharray="10 20"
                    animate={{ rotate: 360 }}
                    transition={{ duration: 8, repeat: Infinity, ease: "linear" }}
                    className="text-indigo-400/30"
                />
                <motion.circle
                    cx="12" cy="12" r="6"
                    stroke="currentColor" strokeWidth="2"
                    strokeDasharray="5 5"
                    animate={{ rotate: -360 }}
                    transition={{ duration: 4, repeat: Infinity, ease: "linear" }}
                    className="text-indigo-500"
                />

                {/* Central Core */}
                <motion.rect
                    x="9" y="9" width="6" height="6" rx="1"
                    fill="currentColor"
                    animate={{ scale: [1, 1.2, 1], opacity: [0.8, 1, 0.8] }}
                    transition={{ duration: 2, repeat: Infinity }}
                    className="text-indigo-600"
                />

                {/* Data Pulses */}
                {[0, 90, 180, 270].map((angle, i) => (
                    <motion.line
                        key={i}
                        x1="12" y1="12" x2="12" y2="2"
                        stroke="currentColor" strokeWidth="1"
                        transform={`rotate(${angle} 12 12)`}
                        animate={{ y2: [6, 2], opacity: [1, 0] }}
                        transition={{ duration: 1.5, repeat: Infinity, delay: i * 0.3 }}
                        className="text-indigo-400"
                    />
                ))}
            </svg>
            <motion.div
                className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-indigo-500/20 to-transparent"
                animate={{ left: ["-100%", "200%"] }}
                transition={{ duration: 3, repeat: Infinity }}
            />
        </div>
    );
}
