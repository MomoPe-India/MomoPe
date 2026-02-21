"use client";

import React from "react";
import { motion } from "framer-motion";
import {
    Users,
    Shield,
    TrendingUp,
    Linkedin,
    Mail,
    MapPin,
    Globe,
    Sparkles,
    ArrowRight
} from "lucide-react";
import Image from "next/image";
import { Footer } from "@/components/Footer";
import { Navbar } from "@/components/Navbar";
import Link from "next/link";
import { DataFlowAnimation, FoundationIllustration, MissionIcon } from "./PhilosophyVisuals";

function ValueItem({ title, text, type }: { title: string, text: string, type: 'community' | 'growth' | 'integrity' }) {
    return (
        <motion.div
            whileHover={{ x: 10 }}
            className="flex gap-6 p-8 rounded-[2.5rem] bg-white border border-gray-50 shadow-umbra-sm hover:shadow-umbra-lg transition-all group"
        >
            <div className="w-14 h-14 rounded-2xl bg-primary/5 flex items-center justify-center text-primary group-hover:bg-primary group-hover:text-white transition-all shadow-sm shrink-0">
                <MissionIcon type={type} />
            </div>
            <div>
                <h4 className="text-xl font-black text-secondary mb-2 tracking-tight">{title}</h4>
                <p className="text-text-secondary leading-relaxed text-base">{text}</p>
            </div>
        </motion.div>
    );
}

function RoadmapItem({ year, title, text, current }: { year: string, title: string, text: string, current?: boolean }) {
    return (
        <div className="relative pl-12">
            <div className={`absolute left-0 top-0.5 w-10 h-10 rounded-2xl flex items-center justify-center z-10 ${current ? 'bg-primary text-white shadow-lg shadow-primary/20' : 'bg-surface text-gray-400 border border-gray-100'}`}>
                <div className={`w-2 h-2 rounded-full ${current ? 'bg-white animate-pulse' : 'bg-gray-300'}`} />
            </div>
            <div>
                <span className={`text-[10px] font-black uppercase tracking-[0.3em] mb-2 block ${current ? 'text-primary' : 'text-gray-400'}`}>{year}</span>
                <h4 className="text-xl font-black text-secondary mb-2 tracking-tight">{title}</h4>
                <p className="text-text-secondary text-sm leading-relaxed">{text}</p>
            </div>
        </div>
    );
}

function FounderCard({ name, role, imageSrc, linkedinUrl, email }: { name: string, role: string, imageSrc: string, linkedinUrl?: string, email: string }) {
    return (
        <div className="flex flex-col items-center group text-center">
            <div className="w-full aspect-[4/5] relative mb-8 rounded-[2.5rem] overflow-hidden bg-gray-50 border border-gray-100 shadow-sm group-hover:shadow-umbra-lg transition-all duration-500">
                <Image
                    src={imageSrc}
                    alt={name}
                    fill
                    className="object-cover transition-transform duration-700 group-hover:scale-110 grayscale group-hover:grayscale-0"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-secondary/80 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 flex items-end justify-center pb-8 p-4">
                    <div className="flex items-center gap-4">
                        {linkedinUrl && linkedinUrl !== '#' && (
                            <a href={linkedinUrl} target="_blank" rel="noopener noreferrer" className="w-12 h-12 rounded-2xl bg-white flex items-center justify-center text-[#0077b5] hover:scale-110 transition-transform">
                                <Linkedin size={22} />
                            </a>
                        )}
                        <a href={`mailto:${email}`} className="w-12 h-12 rounded-2xl bg-primary flex items-center justify-center text-white hover:scale-110 transition-transform">
                            <Mail size={22} />
                        </a>
                    </div>
                </div>
            </div>

            <h3 className="text-2xl font-bold text-secondary mb-1 group-hover:text-primary transition-colors">{name}</h3>
            <p className="text-primary font-bold text-xs uppercase tracking-widest">{role}</p>
        </div>
    );
}

export function AboutContent() {
    return (
        <main className="bg-surface min-h-screen">
            <Navbar />

            {/* Hero Section - Dark & Premium */}
            <section className="pt-40 pb-24 bg-secondary relative overflow-hidden">
                {/* Decorative background elements */}
                <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-primary/10 rounded-full blur-[120px] -z-0" />
                <div className="absolute bottom-0 left-0 w-[400px] h-[400px] bg-accent/5 rounded-full blur-[100px] -z-0" />

                <div className="container mx-auto px-6 relative z-10 text-center">
                    <motion.div
                        initial={{ opacity: 0, y: -20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-primary/10 border border-primary/30 text-white text-sm font-bold mb-8 shadow-lg shadow-primary/10"
                    >
                        <Sparkles size={16} className="text-primary animate-pulse" />
                        Our Vision for Bharat
                    </motion.div>

                    <motion.h1
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="text-5xl md:text-7xl font-black mb-8 text-white tracking-tight leading-tight"
                    >
                        Revolutionizing <br />
                        <motion.span
                            initial={{ opacity: 0, scale: 0.98, filter: "blur(8px)" }}
                            animate={{ opacity: 1, scale: 1, filter: "blur(0px)" }}
                            transition={{ delay: 0.4, duration: 0.8, ease: "easeOut" }}
                            className="inline-block bg-clip-text text-transparent bg-gradient-to-r from-primary to-momo-blue animate-gradient-x drop-shadow-[0_5px_15px_rgba(0,114,255,0.25)]"
                        >
                            Local Commerce
                        </motion.span>
                    </motion.h1>

                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 }}
                        className="text-xl text-gray-400 max-w-2xl mx-auto leading-relaxed mb-12"
                    >
                        We are engineering the win-win ecosystem where local merchants thrive and customers are rewarded for every community interaction.
                    </motion.p>

                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 0.2 }}
                        className="absolute bottom-0 left-1/2 -translate-x-1/2 text-[120px] font-black text-white pointer-events-none select-none whitespace-nowrap hidden lg:block"
                    >
                        MOMOPÉ ORIGINS
                    </motion.div>
                </div>
            </section>

            {/* Founders / Leadership Team */}
            <section className="py-24 bg-white relative">
                <div className="container mx-auto px-6">
                    <div className="max-w-3xl mx-auto text-center mb-20">
                        <h2 className="text-4xl md:text-5xl font-bold text-secondary mb-6 italic">The Visionaries</h2>
                        <p className="text-lg text-text-secondary leading-relaxed">
                            MomoPe is driven by a team that balances deep technical expertise with a boots-on-the-ground understanding of Indian retail.
                        </p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8 lg:gap-12 max-w-6xl mx-auto">
                        <FounderCard
                            name="Damerla Mohan"
                            role="CEO, Co-founder"
                            imageSrc="/images/team/mohan_premium.png"
                            linkedinUrl="https://www.linkedin.com/in/mohan-damerla/"
                            email="damerlamohan17@gmail.com"
                        />
                        <FounderCard
                            name="Damerla Mounika"
                            role="Director, Co-founder"
                            imageSrc="/images/team/mounika.png"
                            linkedinUrl="#"
                            email="damerla.mounika2016@gmail.com"
                        />
                        <FounderCard
                            name="Bathini Meghana"
                            role="CTO, Co-founder"
                            imageSrc="/images/team/meghana.png"
                            linkedinUrl="https://www.linkedin.com/in/meghana-b-07607120a/"
                            email="meghanakishan986@gmail.com"
                        />
                    </div>
                </div>
            </section>

            {/* Roots in Kadapa Section - Premium Deep Fintech */}
            <section className="py-32 bg-secondary text-white relative overflow-hidden">
                {/* Advanced Background Texture */}
                <div className="absolute inset-0 opacity-[0.03] pointer-events-none">
                    <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(#ffffff_1px,transparent_1px)] [background-size:32px_32px]" />
                    <svg className="absolute inset-0 w-full h-full" xmlns="http://www.w3.org/2000/svg">
                        <defs>
                            <pattern id="grid-coordinates" width="100" height="100" patternUnits="userSpaceOnUse">
                                <path d="M 100 0 L 0 0 0 100" fill="none" stroke="white" strokeWidth="0.5" />
                            </pattern>
                        </defs>
                        <rect width="100%" height="100%" fill="url(#grid-coordinates)" />
                    </svg>
                </div>

                {/* Ambient Glows */}
                <div className="absolute top-1/4 -left-24 w-96 h-96 bg-primary/20 rounded-full blur-[140px] animate-pulse" />
                <div className="absolute bottom-1/4 -right-24 w-96 h-96 bg-accent/10 rounded-full blur-[120px]" />

                <div className="container mx-auto px-6 relative z-10">
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 lg:gap-24 items-center">
                        <div className="space-y-10">
                            <motion.div
                                initial={{ opacity: 0, x: -20 }}
                                whileInView={{ opacity: 1, x: 0 }}
                                viewport={{ once: true }}
                                className="inline-flex items-center gap-2.5 px-5 py-2 rounded-full bg-primary/10 text-primary-light font-black text-xs uppercase tracking-[0.2em] backdrop-blur-md border border-primary/20 shadow-lg shadow-primary/5"
                            >
                                <MapPin size={14} className="animate-bounce" />
                                Native to Rayalaseema
                            </motion.div>

                            <h2 className="text-5xl md:text-7xl lg:text-8xl font-black leading-[0.95] tracking-tighter">
                                Built in <br />
                                <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-momo-blue animate-gradient-x italic drop-shadow-[0_5px_15px_rgba(0,114,255,0.25)]">Kadapa</span>.<br />
                                <span className="inline-block relative">
                                    Bharat.
                                    <motion.div
                                        initial={{ width: 0 }}
                                        whileInView={{ width: '100%' }}
                                        viewport={{ once: true }}
                                        transition={{ delay: 0.5, duration: 1 }}
                                        className="absolute -bottom-2 left-0 h-2 bg-primary/30 rounded-full"
                                    />
                                </span>
                            </h2>

                            <p className="text-gray-400 text-xl leading-relaxed max-w-xl">
                                MomoPe wasn&apos;t born in a glass office in Bangalore. We started in the bustling streets of <span className="text-white font-bold">Krishnapuram</span>. We understand the grit of Tier-3 merchants because we live among them.
                            </p>

                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 pt-6">
                                <motion.div
                                    whileHover={{ y: -5 }}
                                    className="p-10 rounded-[3.5rem] bg-white/5 border border-white/10 backdrop-blur-md shadow-umbra-lg hover:border-primary/40 transition-all group relative overflow-hidden"
                                >
                                    <div className="absolute top-0 right-0 w-24 h-24 bg-primary/10 rounded-full blur-2xl -translate-y-1/2 translate-x-1/2" />
                                    <div className="text-5xl font-black text-white mb-2 group-hover:text-primary transition-colors tracking-tighter">516003</div>
                                    <div className="text-[10px] text-gray-500 font-black uppercase tracking-[0.3em] flex items-center gap-2">
                                        <div className="w-4 h-px bg-primary/50" />
                                        Pincode of Origin
                                    </div>
                                </motion.div>
                                <motion.div
                                    whileHover={{ y: -5 }}
                                    className="p-10 rounded-[3.5rem] bg-white/5 border border-white/10 backdrop-blur-md shadow-umbra-lg hover:border-primary/40 transition-all group relative overflow-hidden"
                                >
                                    <div className="absolute top-0 right-0 w-24 h-24 bg-accent/10 rounded-full blur-2xl -translate-y-1/2 translate-x-1/2" />
                                    <div className="text-5xl font-black text-white mb-2 group-hover:text-accent transition-colors tracking-tighter">100%</div>
                                    <div className="text-[10px] text-gray-500 font-black uppercase tracking-[0.3em] flex items-center gap-2">
                                        <div className="w-4 h-px bg-accent/50" />
                                        Local Talent
                                    </div>
                                </motion.div>
                            </div>
                        </div>

                        <motion.div
                            initial={{ opacity: 0, scale: 0.95 }}
                            whileInView={{ opacity: 1, scale: 1 }}
                            viewport={{ once: true }}
                            className="relative h-[600px] lg:h-[750px] rounded-[4rem] overflow-hidden border border-white/10 shadow-umbra-lg group"
                        >
                            {/* Animated Background Overlay */}
                            <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/carbon-fibre.png')] opacity-[0.05] z-10" />

                            <Image
                                src="/images/kadapa_map_stylized.svg"
                                alt="Kadapa Innovation Hub"
                                fill
                                className="object-cover opacity-20 group-hover:opacity-40 transition-all duration-1000 group-hover:scale-110 filter grayscale brightness-150"
                            />

                            {/* Decorative Lines */}
                            <svg className="absolute inset-0 w-full h-full opacity-20 pointer-events-none" xmlns="http://www.w3.org/2000/svg">
                                <motion.path
                                    d="M 100 100 L 500 500"
                                    stroke="white"
                                    strokeWidth="1"
                                    initial={{ pathLength: 0 }}
                                    whileInView={{ pathLength: 1 }}
                                    transition={{ duration: 2 }}
                                />
                            </svg>

                            <div className="absolute inset-0 bg-gradient-to-t from-secondary via-secondary/40 to-transparent" />

                            <div className="absolute bottom-10 left-10 right-10 p-10 rounded-[3rem] bg-white/5 backdrop-blur-2xl border border-white/10 shadow-2xl">
                                <div className="flex items-center gap-3 mb-6">
                                    <span className="relative flex h-4 w-4">
                                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
                                        <span className="relative inline-flex rounded-full h-4 w-4 bg-primary shadow-[0_0_15px_rgba(0,196,167,0.8)]"></span>
                                    </span>
                                    <span className="text-xs font-black text-primary uppercase tracking-[0.25em]">Live Operations Control</span>
                                </div>
                                <h3 className="text-3xl lg:text-4xl font-black text-white leading-tight">YSR District HQ</h3>
                                <p className="text-gray-400 text-lg mt-4 leading-relaxed max-w-sm italic">Engineering the future of 60M+ merchants from AP&apos;s digital heart.</p>

                                <div className="mt-8 pt-8 border-t border-white/5 flex items-center justify-between">
                                    <div className="flex -space-x-3">
                                        {[1, 2, 3, 4].map(i => (
                                            <div key={i} className="w-10 h-10 rounded-full border-2 border-secondary bg-gray-800 overflow-hidden shadow-lg">
                                                <Image src={`/images/team/${i === 1 ? 'mohan_premium' : i === 2 ? 'mounika' : 'meghana'}.png`} alt="Team" width={40} height={40} className="object-cover" />
                                            </div>
                                        ))}
                                    </div>
                                    <div className="text-[10px] font-black text-gray-500 uppercase tracking-widest">Active Engineering Hub</div>
                                </div>
                            </div>
                        </motion.div>
                    </div>
                </div>
            </section>

            {/* Mission & Vision - Premium Deep Fintech Upgrade */}
            <section className="py-32 bg-surface relative overflow-hidden">
                <DataFlowAnimation />

                {/* Ambient Glows */}
                <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-primary/5 rounded-full blur-[120px] -z-0" />
                <div className="absolute bottom-0 left-0 w-[400px] h-[400px] bg-accent/5 rounded-full blur-[100px] -z-0" />

                <div className="container mx-auto px-6 relative z-10">
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-24 items-center">
                        <div className="relative">
                            <motion.div
                                initial={{ opacity: 0, y: 10 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                viewport={{ once: true }}
                                className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white border border-gray-100 shadow-umbra-sm mb-8"
                            >
                                <div className="w-1.5 h-1.5 rounded-full bg-primary animate-pulse" />
                                <span className="text-[10px] font-black text-gray-400 uppercase tracking-[0.3em]">Our Purpose</span>
                            </motion.div>

                            <h2 className="text-4xl md:text-6xl font-black text-secondary mb-8 tracking-tighter leading-tight">
                                Our Mission & <br />
                                <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-momo-blue animate-gradient-x italic drop-shadow-[0_5px_15px_rgba(0,114,255,0.25)]">Core Philosophy</span>
                            </h2>
                            <p className="text-2xl text-text-secondary leading-relaxed mb-16 max-w-xl">
                                We believe technology should serve the many, not the few. Our philosophy is rooted in <span className="text-secondary font-bold underline decoration-primary/30 underline-offset-8">decentralizing commerce</span>.
                            </p>

                            <div className="space-y-6">
                                <ValueItem type="community" title="Community First" text="We prioritize the long-term success of local retailers over short-term fees." />
                                <ValueItem type="growth" title="Sustainable Growth" text="Fair commissions and instant liquidity ensure merchant health." />
                                <ValueItem type="integrity" title="Absolute Integrity" text="Transparent mechanics and 100% compliant financial infrastructure." />
                            </div>
                        </div>

                        <div className="relative">
                            <motion.div
                                initial={{ opacity: 0, x: 20 }}
                                whileInView={{ opacity: 1, x: 0 }}
                                viewport={{ once: true }}
                                className="bg-white p-12 md:p-16 rounded-[4rem] shadow-umbra-lg border border-gray-100 relative overflow-hidden group"
                            >
                                <FoundationIllustration />

                                <div className="relative z-10">
                                    <div className="flex items-center justify-between mb-16">
                                        <h3 className="text-3xl font-black text-secondary flex items-center gap-4 tracking-tight">
                                            <div className="p-3 bg-primary/10 rounded-2xl text-primary">
                                                <Globe size={28} />
                                            </div>
                                            10-Year Roadmap
                                        </h3>
                                        <div className="hidden md:block px-4 py-2 bg-gray-50 rounded-2xl border border-gray-100">
                                            <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest">Phase 01 Active</span>
                                        </div>
                                    </div>

                                    <div className="space-y-12 relative">
                                        <div className="absolute left-6 top-2 bottom-2 w-px bg-gradient-to-b from-primary via-primary/20 to-transparent" />

                                        <RoadmapItem year="2024-25" title="Foundation" text="Establishing presence in Rayalaseema. Target: 150 elite merchants." current />
                                        <RoadmapItem year="2026-27" title="State-wide Expansion" text="Scaling to Andhra Pradesh and Telangana. 1M+ user base." />
                                        <RoadmapItem year="2028-30" title="National Footprint" text="MomoPe as the default OS for Bharat commerce." />
                                    </div>

                                    <div className="mt-16 pt-8 border-t border-gray-50 flex items-center justify-between group-hover:border-primary/20 transition-colors">
                                        <div className="flex items-center gap-3">
                                            <div className="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center text-gray-400">
                                                <TrendingUp size={20} />
                                            </div>
                                            <span className="text-xs font-black text-secondary uppercase tracking-widest">Growth Trajectory</span>
                                        </div>
                                        <button className="flex items-center gap-2 text-primary font-black text-[10px] uppercase tracking-[0.25em] group/btn">
                                            Full Strategy <ArrowRight size={14} className="group-hover/btn:translate-x-1 transition-transform" />
                                        </button>
                                    </div>
                                </div>
                            </motion.div>

                            {/* Decorative Grid Component */}
                            <div className="absolute -bottom-10 -right-10 w-64 h-64 opacity-10 pointer-events-none -z-10">
                                <svg width="100%" height="100%" viewBox="0 0 100 100">
                                    <pattern id="dot-grid" x="0" y="0" width="10" height="10" patternUnits="userSpaceOnUse">
                                        <circle cx="2" cy="2" r="1.5" fill="currentColor" className="text-primary" />
                                    </pattern>
                                    <rect width="100%" height="100%" fill="url(#dot-grid)" />
                                </svg>
                            </div>
                        </div>
                    </div>
                </div>
            </section>


        </main>
    );
}

