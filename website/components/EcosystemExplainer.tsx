"use client";

import { motion } from "framer-motion";
import { ArrowRight, X, Check, RefreshCw, Coins, Store, Users, Zap } from "lucide-react";

export function EcosystemExplainer() {
    return (
        <section className="py-24 bg-white relative overflow-hidden">
            <div className="container mx-auto px-6">
                <div className="text-center max-w-3xl mx-auto mb-20">
                    <motion.div
                        initial={{ opacity: 0, y: 10 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        className="inline-block px-4 py-1.5 rounded-full bg-purple-50 text-purple-700 font-bold text-sm mb-6"
                    >
                        The Engine
                    </motion.div>
                    <motion.h2
                        initial={{ opacity: 0, y: 10 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        transition={{ delay: 0.1 }}
                        className="text-4xl md:text-5xl font-black text-[#35255e] mb-6"
                    >
                        The First &quot;Win-Win-Win&quot; <br /> Commerce Cloud.
                    </motion.h2>
                    <motion.p
                        initial={{ opacity: 0, y: 10 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        transition={{ delay: 0.2 }}
                        className="text-gray-500 text-lg leading-relaxed"
                    >
                        Traditional payments are a one-way street. MomoPe builds a highway.
                    </motion.p>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-24 items-center">

                    {/* The Old Way (Static & Broken) */}
                    <div className="relative group opacity-60 hover:opacity-100 transition-opacity">
                        <div className="absolute inset-0 bg-red-50 rounded-3xl transform -rotate-2 scale-95 transition-transform group-hover:rotate-0" />
                        <div className="bg-white border-2 border-red-100 p-10 rounded-3xl relative shadow-sm h-[400px] flex flex-col justify-between">
                            <h3 className="text-2xl font-bold text-gray-400 mb-6 flex items-center gap-3">
                                <span className="w-8 h-8 rounded-full bg-red-100 text-red-400 flex items-center justify-center"><X size={18} /></span>
                                The Old Way
                            </h3>

                            <div className="relative flex-1 flex flex-col justify-center">
                                <div className="flex items-center justify-between text-gray-300 px-4">
                                    <div className="flex flex-col items-center gap-2">
                                        <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center">
                                            <Users size={24} className="text-gray-400" />
                                        </div>
                                        <span className="font-bold">Customer</span>
                                    </div>

                                    {/* Unidirectional Arrow */}
                                    <div className="flex-1 mx-4 relative h-1 bg-gray-100 rounded-full">
                                        <div className="absolute right-0 top-1/2 -translate-y-1/2 text-gray-300">
                                            <ArrowRight size={20} />
                                        </div>
                                    </div>

                                    <div className="flex flex-col items-center gap-2">
                                        <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center">
                                            <Store size={24} className="text-gray-400" />
                                        </div>
                                        <span className="font-bold">Merchant</span>
                                    </div>
                                </div>

                                {/* Disconnected State */}
                                <div className="mt-12 text-center">
                                    <div className="inline-flex items-center gap-2 px-4 py-2 bg-red-50 text-red-400 rounded-lg text-sm font-medium">
                                        <div className="w-2 h-2 rounded-full bg-red-400" />
                                        Connection Terminated
                                    </div>
                                </div>
                            </div>

                            <p className="text-center text-gray-400 text-sm mt-4">Customer leaves. No data. No reason to return.</p>
                        </div>
                    </div>

                    {/* The MomoPe Way (Animated Engine) */}
                    <div className="relative">
                        <div className="absolute inset-0 bg-gradient-to-r from-primary/20 to-purple-500/20 rounded-3xl blur-2xl animate-pulse-slow" />

                        <div className="bg-white/80 backdrop-blur-xl border border-white/50 p-8 rounded-3xl relative shadow-2xl h-[450px] overflow-hidden">
                            <h3 className="text-2xl font-bold text-[#35255e] mb-2 flex items-center gap-3 relative z-10">
                                <span className="w-8 h-8 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center"><Check size={18} /></span>
                                The Growth Engine
                            </h3>

                            {/* ANIMATION CONTAINER */}
                            <div className="absolute inset-0 top-16 flex items-center justify-center">
                                {/* 1. Central Core (MomoPe) */}
                                <div className="absolute z-20">
                                    <motion.div
                                        animate={{ scale: [1, 1.1, 1], boxShadow: ["0 0 20px rgba(0,196,167,0.2)", "0 0 40px rgba(0,196,167,0.4)", "0 0 20px rgba(0,196,167,0.2)"] }}
                                        transition={{ duration: 2, repeat: Infinity }}
                                        className="w-24 h-24 bg-gradient-to-br from-primary to-primary-dark rounded-full flex items-center justify-center text-white font-black text-xl shadow-2xl relative"
                                    >
                                        M
                                        {/* Ripple Rings */}
                                        <motion.div
                                            animate={{ scale: [1, 2], opacity: [0.5, 0] }}
                                            transition={{ duration: 2, repeat: Infinity }}
                                            className="absolute inset-0 border border-primary rounded-full"
                                        />
                                    </motion.div>
                                </div>

                                {/* 2. Orbiting Path */}
                                <div className="absolute w-64 h-64 border border-dashed border-gray-200 rounded-full animate-spin-slow" />
                                <div className="absolute w-44 h-44 border border-primary/10 rounded-full" />

                                {/* 3. Orbiting Nodes */}
                                <OrbitingNode angle={0} color="bg-blue-500" icon={<Users size={18} />} label="Customer" delay={0} />
                                <OrbitingNode angle={120} color="bg-purple-500" icon={<Store size={18} />} label="Merchant" delay={1} />
                                <OrbitingNode angle={240} color="bg-amber-500" icon={<Coins size={18} />} label="Rewards" delay={2} />

                                {/* 4. Flowing Particles (Value Transfer) */}
                                <ParticleStream />
                            </div>

                            {/* Status Label (Bottom) */}
                            <div className="absolute bottom-6 left-0 right-0 text-center z-20">
                                <div className="inline-flex items-center gap-2 px-4 py-1.5 bg-gradient-to-r from-emerald-50 to-teal-50 text-emerald-700 rounded-full text-sm font-bold border border-emerald-100">
                                    <RefreshCw size={14} className="animate-spin-reverse" /> Infinite Value Loop
                                </div>
                            </div>
                        </div>
                    </div>

                </div>

                {/* 3 Pillars */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mt-24">
                    <Pillar
                        title="For You (User)"
                        desc="Your spending power increases. Every ₹1 spent = future savings."
                        color="bg-emerald-500"
                        icon={<Coins size={32} className="text-white" />}
                        illustration={
                            <div className="relative w-full h-32 bg-emerald-50 rounded-2xl mb-6 overflow-hidden flex items-center justify-center group-hover:bg-emerald-100 transition-colors">
                                <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1620714223084-8fcacc6dfd8d?q=80&w=200&auto=format&fit=crop')] bg-cover opacity-20" />
                                <div className="z-10 bg-emerald-500 w-16 h-16 rounded-full flex items-center justify-center shadow-lg transform group-hover:scale-110 transition-transform">
                                    <Users size={32} className="text-white" />
                                </div>
                            </div>
                        }
                    />
                    <Pillar
                        title="For Business"
                        desc="Acquire customers for free. Pay only when they actually pay you."
                        color="bg-purple-500"
                        icon={<Store size={32} className="text-white" />}
                        illustration={
                            <div className="relative w-full h-32 bg-purple-50 rounded-2xl mb-6 overflow-hidden flex items-center justify-center group-hover:bg-purple-100 transition-colors">
                                <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1556742049-0cfed4f7a07d?q=80&w=200&auto=format&fit=crop')] bg-cover opacity-20" />
                                <div className="z-10 bg-purple-500 w-16 h-16 rounded-full flex items-center justify-center shadow-lg transform group-hover:scale-110 transition-transform">
                                    <Store size={32} className="text-white" />
                                </div>
                            </div>
                        }
                    />
                    <Pillar
                        title="For Community"
                        desc="Money stays local. Helping Kadapa grow, one transaction at a time."
                        color="bg-orange-500"
                        icon={<Users size={32} className="text-white" />}
                        illustration={
                            <div className="relative w-full h-32 bg-orange-50 rounded-2xl mb-6 overflow-hidden flex items-center justify-center group-hover:bg-orange-100 transition-colors">
                                <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?q=80&w=200&auto=format&fit=crop')] bg-cover opacity-20" />
                                <div className="z-10 bg-orange-500 w-16 h-16 rounded-full flex items-center justify-center shadow-lg transform group-hover:scale-110 transition-transform">
                                    <Users size={32} className="text-white" />
                                </div>
                            </div>
                        }
                    />
                </div>
            </div>
        </section>
    );
}

function OrbitingNode({ angle, color, icon, label, delay }: { angle: number, color: string, icon: React.ReactNode, label: string, delay: number }) {
    return (
        <motion.div
            className="absolute"
            animate={{ rotate: 360 }}
            transition={{ duration: 10, repeat: Infinity, ease: "linear", delay: -delay * 3.33 }}
            style={{ width: '100%', height: '100%', pointerEvents: 'none' }}
        >
            <div
                className="absolute top-0 left-1/2 -translate-x-1/2 -translate-y-1/2 flex flex-col items-center"
                style={{ transform: `rotate(-${angle}deg)` }} // Initial offset if needed, but here we just animate the container
            >
                {/* Counter-rotate the icon so it stays upright */}
                <motion.div
                    animate={{ rotate: -360 }}
                    transition={{ duration: 10, repeat: Infinity, ease: "linear", delay: -delay * 3.33 }}
                    className={`w-14 h-14 ${color} rounded-2xl shadow-lg flex items-center justify-center text-white relative z-10`}
                >
                    {icon}
                </motion.div>
                <motion.span
                    animate={{ rotate: -360 }}
                    transition={{ duration: 10, repeat: Infinity, ease: "linear", delay: -delay * 3.33 }}
                    className="mt-2 text-xs font-bold text-gray-500 bg-white/80 px-2 py-0.5 rounded-md backdrop-blur-sm"
                >
                    {label}
                </motion.span>
            </div>
        </motion.div>
    );
}

function ParticleStream() {
    return (
        <div className="absolute inset-0 pointer-events-none">
            {/* Simpler Approach: Rotating container for particles */}
            <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 5, repeat: Infinity, ease: "linear" }}
                className="absolute inset-0 w-full h-full"
            >
                <div className="absolute top-0 left-1/2 w-3 h-3 bg-amber-400 rounded-full blur-[2px] shadow-[0_0_10px_orange]" />
                <div className="absolute bottom-0 left-1/2 w-3 h-3 bg-purple-400 rounded-full blur-[2px]" />
                <div className="absolute left-0 top-1/2 w-3 h-3 bg-blue-400 rounded-full blur-[2px]" />
            </motion.div>
        </div>
    )
}

function Pillar({ title, desc, color, icon, illustration }: { title: string, desc: string, color: string, icon?: React.ReactNode, illustration?: React.ReactNode }) {
    return (
        <div className="p-6 rounded-3xl bg-gray-50 hover:bg-white hover:shadow-xl transition-all border border-transparent hover:border-gray-100 group h-full">
            {illustration ? illustration : <div className={`w-12 h-1.5 rounded-full ${color} mb-6 group-hover:w-24 transition-all`} />}
            <h4 className="text-xl font-bold text-[#35255e] mb-3">{title}</h4>
            <p className="text-gray-500 leading-relaxed text-sm">{desc}</p>
        </div>
    );
}
