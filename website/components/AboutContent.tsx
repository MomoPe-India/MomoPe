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

function CountUpNumber({ value, suffix = "", format = true }: { value: number, suffix?: string, format?: boolean }) {
    const [count, setCount] = React.useState(0);
    const [isVisible, setIsVisible] = React.useState(false);
    const elementRef = React.useRef(null);

    React.useEffect(() => {
        const observer = new IntersectionObserver(
            ([entry]) => {
                if (entry.isIntersecting) {
                    setIsVisible(true);
                    observer.disconnect();
                }
            },
            { threshold: 0.1 }
        );

        if (elementRef.current) {
            observer.observe(elementRef.current);
        }

        return () => observer.disconnect();
    }, []);

    React.useEffect(() => {
        if (!isVisible) return;

        let start = 0;
        const end = value;
        const duration = 2000;
        const increment = end / (duration / 16);

        const timer = setInterval(() => {
            start += increment;
            if (start >= end) {
                setCount(end);
                clearInterval(timer);
            } else {
                setCount(Math.floor(start));
            }
        }, 16);

        return () => clearInterval(timer);
    }, [isVisible, value]);

    return (
        <span ref={elementRef}>
            {format ? count.toLocaleString() : count}{suffix}
        </span>
    );
}

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

function FounderCard({ name, role, bio, imageSrc, linkedinUrl, email }: { name: string, role: string, bio: string, imageSrc: string, linkedinUrl?: string, email: string }) {
    return (
        <motion.div
            whileHover={{ y: -12 }}
            transition={{ type: "spring", stiffness: 300, damping: 20 }}
            className="flex flex-col items-center group text-center relative"
        >
            <div className="w-full aspect-[4/5] relative mb-12 rounded-[3.5rem] overflow-hidden bg-gray-50 border border-gray-100 shadow-umbra-sm group-hover:shadow-umbra-xl group-hover:border-primary/20 transition-all duration-500">
                <Image
                    src={imageSrc}
                    alt={name}
                    fill
                    className="object-cover transition-transform duration-700 group-hover:scale-105"
                />

                {/* Enhanced Hover Overlay */}
                <div className="absolute inset-0 bg-gradient-to-t from-secondary/90 via-secondary/20 to-transparent opacity-0 group-hover:opacity-100 transition-all duration-500 flex items-end justify-center pb-12 p-6">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        whileHover={{ opacity: 1, y: 0 }}
                        className="flex items-center gap-5"
                    >
                        {linkedinUrl && linkedinUrl !== '#' && (
                            <a href={linkedinUrl} target="_blank" rel="noopener noreferrer" className="w-14 h-14 rounded-[1.5rem] bg-white flex items-center justify-center text-[#0077b5] hover:scale-110 shadow-lg transition-transform">
                                <Linkedin size={24} />
                            </a>
                        )}
                        <a href={`mailto:${email}`} className="w-14 h-14 rounded-[1.5rem] bg-primary flex items-center justify-center text-white hover:scale-110 shadow-lg shadow-primary/20 transition-transform">
                            <Mail size={24} />
                        </a>
                    </motion.div>
                </div>

                {/* Corner Accent */}
                <div className="absolute top-6 right-6 w-3 h-3 rounded-full bg-primary/40 opacity-0 group-hover:opacity-100 transition-opacity" />
            </div>

            <div className="space-y-3 px-4">
                <h3 className="text-3xl font-black text-secondary tracking-tight group-hover:text-primary transition-colors duration-300">{name}</h3>
                <div className="flex flex-col gap-2">
                    <p className="text-[11px] font-black text-gray-400 uppercase tracking-[0.3em]">{role}</p>

                    {/* Bio Expansion on Hover */}
                    <div className="overflow-hidden">
                        <motion.p
                            initial={{ opacity: 0.6, y: 0 }}
                            className="text-secondary/70 font-medium text-sm italic py-1 border-t border-transparent group-hover:text-secondary group-hover:opacity-100 transition-all"
                        >
                            &ldquo;{bio}&rdquo;
                        </motion.p>
                    </div>
                </div>
            </div>

            {/* Soft Glow Border Effect */}
            <div className="absolute -inset-4 bg-primary/5 rounded-[4rem] blur-2xl opacity-0 group-hover:opacity-100 transition-opacity -z-10" />
        </motion.div>
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
            <section className="py-32 bg-white relative overflow-hidden">
                {/* Subtle Background Accent */}
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full h-[600px] bg-gradient-to-b from-primary/5 to-transparent blur-[120px] pointer-events-none opacity-50" />

                <div className="container mx-auto px-6 relative z-10">
                    <div className="max-w-3xl mx-auto text-center mb-24">
                        <motion.div
                            initial={{ opacity: 0, y: 10 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-primary/5 border border-primary/20 text-primary text-[10px] font-black uppercase tracking-widest mb-6"
                        >
                            The Core Engine
                        </motion.div>
                        <h2 className="text-4xl md:text-6xl font-black text-secondary mb-8 tracking-tighter">The Visionaries</h2>
                        <p className="text-xl text-text-secondary leading-relaxed max-w-2xl mx-auto">
                            MomoPe is driven by a team that balances deep technical expertise with a boots-on-the-ground understanding of Indian retail.
                        </p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-12 lg:gap-16 max-w-7xl mx-auto">
                        <FounderCard
                            name="Damerla Mohan"
                            role="CEO, Co-founder"
                            bio="Driving vision and scale."
                            imageSrc="/images/team/mohan_premium.png"
                            linkedinUrl="https://www.linkedin.com/in/mohan-damerla/"
                            email="damerlamohan17@gmail.com"
                        />
                        <div className="md:-translate-y-12 transition-transform">
                            <FounderCard
                                name="Damerla Mounika"
                                role="Director, Co-founder"
                                bio="Orchestrating operational excellence."
                                imageSrc="/images/team/mounika.png"
                                linkedinUrl="#"
                                email="damerla.mounika2016@gmail.com"
                            />
                        </div>
                        <FounderCard
                            name="Bathini Meghana"
                            role="CTO, Co-founder"
                            bio="Building the engine for Bharat."
                            imageSrc="/images/team/meghana.png"
                            linkedinUrl="https://www.linkedin.com/in/meghana-b-07607120a/"
                            email="meghanakishan986@gmail.com"
                        />
                    </div>

                    {/* Authority Signals */}
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true }}
                        className="mt-32 text-center"
                    >
                        <div className="inline-flex flex-col md:flex-row items-center gap-8 md:gap-16 px-12 py-8 rounded-[3rem] bg-surface border border-gray-100 shadow-umbra-sm group hover:border-primary/20 transition-all">
                            <div className="flex flex-col items-center md:items-start">
                                <span className="text-3xl font-black text-secondary leading-none mb-2">15+ Years</span>
                                <span className="text-[10px] font-black text-gray-400 uppercase tracking-widest">Combined Fintech Expertise</span>
                            </div>
                            <div className="hidden md:block w-px h-12 bg-gray-100" />
                            <div className="flex flex-col items-center md:items-start text-center md:text-left">
                                <span className="text-xl font-bold text-secondary mb-1">Serving merchants across YSR & beyond.</span>
                                <span className="text-gray-500 font-medium text-sm">Deeply rooted. Nationally focused.</span>
                            </div>
                        </div>

                        {/* Emotional Brand Narratve Closer */}
                        <p className="mt-16 text-2xl md:text-3xl font-black tracking-tight text-secondary/40 group-hover:text-secondary transition-colors duration-500">
                            Rooted in <span className="text-secondary/80 italic">Rayalaseema</span>. Scaling to <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-momo-blue font-black tracking-tighter">Bharat.</span>
                        </p>
                    </motion.div>
                </div>
            </section>

            {/* Roots in Kadapa Section - Premium Deep Fintech */}
            <section className="py-32 bg-secondary text-white relative overflow-hidden">
                {/* Advanced Background Texture - Reduced Opacity */}
                <div className="absolute inset-0 opacity-[0.02] pointer-events-none">
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

                {/* Background Spotlight / Radial Glow */}
                <div className="absolute top-1/2 left-1/4 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-primary/5 rounded-full blur-[160px] pointer-events-none" />
                <div className="absolute top-[40%] right-[10%] w-[600px] h-[600px] bg-accent/5 rounded-full blur-[140px] pointer-events-none" />

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

                            <div className="relative">
                                {/* Subtle Radial Glow behind Kadapa */}
                                <div className="absolute top-1/2 left-0 -translate-y-1/2 w-48 h-48 bg-primary/20 rounded-full blur-[80px] -z-10" />

                                <h2 className="text-5xl md:text-7xl lg:text-8xl font-black leading-[1.05] tracking-tight">
                                    <motion.span
                                        initial={{ opacity: 0, y: 20 }}
                                        whileInView={{ opacity: 1, y: 0 }}
                                        viewport={{ once: true }}
                                        className="block mb-1"
                                    >Born in</motion.span>
                                    <motion.span
                                        initial={{ opacity: 0, y: 20 }}
                                        whileInView={{ opacity: 1, y: 0 }}
                                        viewport={{ once: true }}
                                        transition={{ delay: 0.1 }}
                                        className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-momo-blue animate-gradient-x drop-shadow-sm"
                                    >Kadapa</motion.span>.<br />
                                    <motion.span
                                        initial={{ opacity: 0, y: 20 }}
                                        whileInView={{ opacity: 1, y: 0 }}
                                        viewport={{ once: true }}
                                        transition={{ delay: 0.2 }}
                                        className="text-gray-400"
                                    >
                                        Built for <span className="relative">
                                            <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#FF9933] via-white to-[#128807] drop-shadow-sm font-black">Bharat.</span>
                                            <motion.div
                                                initial={{ width: 0 }}
                                                whileInView={{ width: '100%' }}
                                                viewport={{ once: true }}
                                                transition={{ delay: 0.8, duration: 1 }}
                                                className="absolute -bottom-2 left-0 h-2 bg-gradient-to-r from-[#FF9933]/40 via-white/40 to-[#128807]/40 rounded-full"
                                            />
                                        </span>
                                    </motion.span>
                                </h2>
                            </div>

                            <motion.p
                                initial={{ opacity: 0, y: 10 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                viewport={{ once: true }}
                                transition={{ delay: 0.3 }}
                                className="text-gray-400 text-lg md:text-xl leading-snug max-w-xl font-medium"
                            >
                                We weren&apos;t built in glass towers. <br />
                                <span className="text-white">We were built in real markets, real streets, and real merchant counters.</span>
                            </motion.p>

                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 pt-6">
                                <motion.div
                                    whileHover={{ y: -8, scale: 1.02 }}
                                    className="p-12 rounded-[4rem] bg-white/5 border border-white/10 backdrop-blur-md shadow-2xl hover:border-primary/40 transition-all group relative overflow-hidden"
                                >
                                    <div className="absolute top-0 right-0 w-32 h-32 bg-primary/10 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2 group-hover:bg-primary/20 transition-colors" />
                                    <div className="text-5xl md:text-6xl font-black text-white mb-3 group-hover:text-primary transition-colors tracking-tighter">
                                        <CountUpNumber value={516003} format={false} />
                                    </div>
                                    <div className="text-[11px] text-gray-500 font-black uppercase tracking-[0.35em] flex items-center gap-3">
                                        <div className="w-6 h-px bg-primary/40" />
                                        Our First Battlefield
                                    </div>
                                </motion.div>
                                <motion.div
                                    whileHover={{ y: -8, scale: 1.02 }}
                                    className="p-12 rounded-[4rem] bg-white/5 border border-white/10 backdrop-blur-md shadow-2xl hover:border-accent/40 transition-all group relative overflow-hidden"
                                >
                                    <div className="absolute top-0 right-0 w-32 h-32 bg-accent/10 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2 group-hover:bg-accent/20 transition-colors" />
                                    <div className="text-5xl md:text-6xl font-black text-white mb-3 group-hover:text-accent transition-colors tracking-tighter">
                                        <CountUpNumber value={100} suffix="%" />
                                    </div>
                                    <div className="text-[11px] text-gray-500 font-black uppercase tracking-[0.35em] flex items-center gap-3">
                                        <div className="w-6 h-px bg-accent/40" />
                                        Local Engineering DNA
                                    </div>
                                </motion.div>
                            </div>
                        </div>

                        <motion.div
                            initial={{ opacity: 0, y: 30 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            viewport={{ once: true }}
                            className="relative h-[650px] lg:h-[800px] rounded-[5rem] overflow-hidden border border-white/10 shadow-umbra-lg group"
                        >
                            {/* Momo Coin Visual - Bold Branding */}
                            <div className="absolute top-0 -right-20 w-[700px] h-[700px] opacity-[0.35] pointer-events-none z-0 rotate-12 group-hover:opacity-[0.5] transition-opacity duration-1000">
                                <Image
                                    src="/images/momo-coin.png"
                                    alt="Momo Coin Visual"
                                    fill
                                    className="object-contain"
                                />
                            </div>

                            {/* Animated Background Overlay */}
                            <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/carbon-fibre.png')] opacity-[0.03] z-10" />

                            {/* AP Map Background - Optional Enhancement */}
                            <div className="absolute inset-0 z-0">
                                <Image
                                    src="/images/kadapa_map_stylized.svg"
                                    alt="Andhra Pradesh Focus"
                                    fill
                                    className="object-cover opacity-10 group-hover:opacity-25 transition-all duration-1000 group-hover:scale-105 filter grayscale brightness-150"
                                />
                                {/* Pulsing Dot on Kadapa */}
                                <div className="absolute top-[65%] left-[45%] flex h-6 w-6">
                                    <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
                                    <span className="relative inline-flex rounded-full h-6 w-6 bg-primary shadow-[0_0_20px_rgba(0,196,167,1)]"></span>
                                </div>
                            </div>

                            <div className="absolute inset-0 bg-gradient-to-t from-secondary via-secondary/40 to-transparent z-10" />

                            {/* Command Center Card - Redesigned */}
                            <div className="absolute bottom-8 left-8 right-8 p-12 rounded-[4rem] bg-white/5 backdrop-blur-3xl border border-white/10 shadow-2xl z-20 overflow-hidden group/card transition-all duration-500">
                                {/* Animated Gradient Border Simulation */}
                                <div className="absolute inset-0 bg-gradient-to-r from-primary/20 via-transparent to-momo-blue/20 opacity-30 group-hover/card:opacity-60 transition-opacity duration-700 -z-10 animate-gradient-x" />

                                <div className="flex items-center gap-4 mb-8">
                                    <div className="relative flex h-5 w-5">
                                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-60"></span>
                                        <span className="relative inline-flex rounded-full h-5 w-5 bg-primary shadow-[0_0_15px_rgba(0,196,167,0.8)]"></span>
                                    </div>
                                    <div className="flex flex-col">
                                        <span className="text-[10px] font-black text-primary uppercase tracking-[0.3em]">Live Operations Control</span>
                                        <span className="text-[8px] text-gray-500 uppercase tracking-widest font-black">24/7 Monitoring Active</span>
                                    </div>
                                </div>

                                <h3 className="text-3xl lg:text-4xl font-black text-white leading-tight tracking-tight mb-2">MomoPe <br />Command Center</h3>
                                <p className="text-gray-400 text-lg mt-4 leading-relaxed max-w-sm italic opacity-80 group-hover/card:opacity-100 transition-opacity">Engineering the future of 60M+ merchants from AP&apos;s digital heart.</p>

                                <div className="mt-10 pt-10 border-t border-white/5 flex items-center justify-between">
                                    <div className="flex -space-x-4">
                                        {['mohan_premium', 'mounika', 'meghana'].map((name, i) => (
                                            <motion.div
                                                key={i}
                                                whileHover={{ y: -5, zIndex: 30 }}
                                                className="w-12 h-12 rounded-full border-4 border-secondary bg-gray-800 overflow-hidden shadow-2xl relative transition-transform"
                                            >
                                                <Image src={`/images/team/${name}.png`} alt="Team" width={48} height={48} className="object-cover" />
                                            </motion.div>
                                        ))}
                                    </div>
                                    <div className="text-[10px] font-black text-primary-light uppercase tracking-widest bg-primary/20 px-4 py-2 rounded-full border border-primary/40 shadow-[0_0_15px_rgba(0,196,167,0.3)] backdrop-blur-md">Active Engineering Hub</div>
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

