"use client";

import React from "react";
import { motion } from "framer-motion";
import { Users, Shield, TrendingUp, Linkedin, Mail, MapPin, Globe, Sparkles } from "lucide-react";
import Image from "next/image";
import { Footer } from "@/components/Footer";
import { Navbar } from "@/components/Navbar";
import Link from "next/link";

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
                        className="text-5xl md:text-7xl font-bold mb-8 text-white tracking-tight"
                    >
                        Revolutionizing <br />
                        <span className="bg-clip-text text-transparent bg-gradient-to-r from-primary via-primary-light to-teal-200">Local Commerce</span>
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

            {/* Roots in Kadapa Section - Premium Contrast */}
            <section className="py-32 bg-secondary text-white relative overflow-hidden">
                <div className="absolute inset-0 opacity-5 pointer-events-none">
                    <div className="absolute top-0 left-0 w-full h-full bg-[radial-gradient(#ffffff_1px,transparent_1px)] [background-size:40px_40px]" />
                </div>

                <div className="container mx-auto px-6 relative z-10">
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-20 items-center">
                        <div className="space-y-8">
                            <motion.div
                                initial={{ opacity: 0, x: -20 }}
                                whileInView={{ opacity: 1, x: 0 }}
                                viewport={{ once: true }}
                                className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-primary/10 text-primary-light font-bold text-sm backdrop-blur-md border border-primary/20"
                            >
                                <MapPin size={16} />
                                Native to Rayalaseema
                            </motion.div>

                            <h2 className="text-4xl md:text-6xl font-extrabold leading-tight tracking-tighter">
                                Built in <span className="text-primary italic">Kadapa</span>.<br />
                                For the Heart of <span className="underline decoration-primary/50 underline-offset-8">Bharat</span>.
                            </h2>

                            <p className="text-gray-400 text-lg leading-relaxed">
                                MomoPe wasn't born in a glass office in Bangalore. We started in the bustling streets of Krishnapuram, Kadapa. We understand the grit of Tier-3 merchants because we live among them.
                            </p>

                            <div className="grid grid-cols-2 gap-6 pt-4">
                                <div className="p-8 rounded-[2rem] bg-white/5 border border-white/10 backdrop-blur-sm umbra-sm hover:border-primary/30 transition-colors group">
                                    <div className="text-4xl font-bold text-white mb-2 group-hover:text-primary transition-colors">516003</div>
                                    <div className="text-xs text-gray-500 font-bold uppercase tracking-[0.2em]">Pincode of Origin</div>
                                </div>
                                <div className="p-8 rounded-[2rem] bg-white/5 border border-white/10 backdrop-blur-sm umbra-sm hover:border-primary/30 transition-colors group">
                                    <div className="text-4xl font-bold text-white mb-2 group-hover:text-primary transition-colors">100%</div>
                                    <div className="text-xs text-gray-500 font-bold uppercase tracking-[0.2em]">Local Talent</div>
                                </div>
                            </div>
                        </div>

                        <motion.div
                            initial={{ opacity: 0, scale: 0.95 }}
                            whileInView={{ opacity: 1, scale: 1 }}
                            viewport={{ once: true }}
                            className="relative h-[500px] lg:h-[600px] rounded-[3rem] overflow-hidden border border-white/10 shadow-2xl group"
                        >
                            <Image
                                src="/images/kadapa_map_stylized.svg"
                                alt="Kadapa Innovation Hub"
                                fill
                                className="object-cover opacity-40 group-hover:opacity-60 transition-all duration-1000 group-hover:scale-105 filter grayscale group-hover:grayscale-0"
                            />
                            <div className="absolute inset-0 bg-gradient-to-t from-secondary via-secondary/20 to-transparent" />

                            <div className="absolute bottom-12 left-12 right-12 p-8 rounded-3xl bg-white/5 backdrop-blur-xl border border-white/10">
                                <div className="flex items-center gap-3 mb-3">
                                    <span className="relative flex h-3 w-3">
                                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                                        <span className="relative inline-flex rounded-full h-3 w-3 bg-green-500"></span>
                                    </span>
                                    <span className="text-xs font-black text-green-400 uppercase tracking-widest">Live Operations</span>
                                </div>
                                <h3 className="text-2xl font-black text-white">YSR District HQ</h3>
                                <p className="text-gray-400 text-sm mt-2 leading-relaxed italic">Powering 60M+ merchants from the heart of Andhra Pradesh.</p>
                            </div>
                        </motion.div>
                    </div>
                </div>
            </section>

            {/* Mission & Vision - Deep Fintech Layout */}
            <section className="py-32 bg-surface overflow-hidden">
                <div className="container mx-auto px-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-20 items-center">
                        <div className="relative">
                            <h2 className="text-4xl font-bold text-secondary mb-8">Our Mission & <br /><span className="text-primary italic">Core Philosophy</span></h2>
                            <p className="text-xl text-text-secondary leading-relaxed mb-12">
                                We believe technology should serve the many, not the few. Our philosophy is rooted in decentralizing commerce.
                            </p>
                            <div className="space-y-6">
                                <ValueItem icon={<Users />} title="Community First" text="We prioritize the long-term success of local retailers over short-term fees." />
                                <ValueItem icon={<TrendingUp />} title="Sustainable Growth" text="Fair commissions and instant liquidity ensure merchant health." />
                                <ValueItem icon={<Shield />} title="Absolute Integrity" text="Transparent mechanics and 100% compliant financial infrastructure." />
                            </div>
                        </div>

                        <div className="bg-white p-12 rounded-[3rem] shadow-2xl shadow-primary/5 border border-gray-100 relative">
                            <div className="absolute -top-6 -right-6 w-24 h-24 bg-primary/10 rounded-full blur-2xl" />
                            <h3 className="text-2xl font-bold text-secondary mb-10 flex items-center gap-3">
                                <Globe className="text-primary" />
                                The 10-Year Roadmap
                            </h3>
                            <div className="space-y-12 relative">
                                <div className="absolute left-6 top-2 bottom-2 w-0.5 bg-gradient-to-b from-primary via-primary/20 to-transparent" />

                                <RoadmapItem year="2024-25" title="Foundation" text="Establishing presence in Rayalaseema. Target: 150 elite merchants." current />
                                <RoadmapItem year="2026-27" title="State-wide Expansion" text="Scaling to Andhra Pradesh and Telangana. 1M+ user base." />
                                <RoadmapItem year="2028-30" title="National Footprint" text="MomoPe as the default OS for Bharat commerce." />
                            </div>
                        </div>
                    </div>
                </div>
            </section>


        </main>
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

function ValueItem({ icon, title, text }: { icon: React.ReactNode, title: string, text: string }) {
    return (
        <div className="flex gap-6 p-6 rounded-3xl hover:bg-white hover:shadow-xl hover:shadow-primary/5 transition-all group">
            <div className="w-14 h-14 rounded-2xl bg-primary/5 text-primary flex items-center justify-center shrink-0 group-hover:bg-primary group-hover:text-white transition-all">
                {React.isValidElement(icon) ? React.cloneElement(icon as React.ReactElement<any>, { size: 28 }) : icon}
            </div>
            <div>
                <h4 className="font-bold text-secondary text-lg mb-1">{title}</h4>
                <p className="text-text-secondary text-sm leading-relaxed">{text}</p>
            </div>
        </div>
    );
}

function RoadmapItem({ year, title, text, current }: { year: string, title: string, text: string, current?: boolean }) {
    return (
        <div className="relative pl-16 group">
            <div className={`absolute left-4 top-1.5 w-4 h-4 rounded-full border-4 border-white shadow-sm z-10 transition-all duration-500 ${current ? 'bg-primary scale-125' : 'bg-gray-200 group-hover:bg-primary/50'}`} />

            <span className={`text-xs font-black uppercase tracking-[0.2em] mb-2 block ${current ? 'text-primary' : 'text-gray-400'}`}>{year}</span>
            <h4 className={`text-lg font-bold transition-colors ${current ? 'text-secondary' : 'text-gray-400 group-hover:text-secondary'}`}>{title}</h4>
            <p className="text-gray-500 text-sm leading-relaxed mt-1">{text}</p>

            {current && (
                <div className="absolute -left-12 -top-1 w-24 h-24 bg-primary/5 rounded-full blur-2xl -z-0" />
            )}
        </div>
    );
}
