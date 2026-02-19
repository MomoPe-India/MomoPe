"use client";

import { motion } from "framer-motion";
import { Users, Shield, TrendingUp, Linkedin, Mail } from "lucide-react";
import Image from "next/image";
import { Footer } from "@/components/Footer";
import { Navbar } from "@/components/Navbar";

export function AboutContent() {
    return (
        <main className="bg-surface min-h-screen">
            <Navbar />

            {/* Hero Section - Light */}
            <section className="pt-32 pb-20 bg-gradient-to-b from-white to-gray-50 relative overflow-hidden">
                <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-primary/10 rounded-full blur-3xl -z-10" />
                <div className="container mx-auto px-6 text-center z-10 relative">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="inline-block px-4 py-1.5 rounded-full bg-blue-50 text-primary-dark font-medium text-sm mb-6"
                    >
                        Our Story
                    </motion.div>
                    <motion.h1
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 }}
                        className="text-4xl md:text-6xl font-bold mb-6 text-[#35255e]"
                    >
                        Revolutionizing <span className="text-primary">Local Commerce</span>
                    </motion.h1>
                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 }}
                        className="text-xl text-gray-500 max-w-2xl mx-auto leading-relaxed"
                    >
                        We are building a win-win ecosystem where customers earn real rewards and merchants grow sustainably.
                    </motion.p>
                </div>
            </section>

            {/* Founders / Leadership Team */}
            <section className="py-24 bg-white border-y border-gray-100">
                <div className="container mx-auto px-6">
                    <div className="text-center mb-16">
                        <h2 className="text-3xl font-bold text-[#35255e] mb-4">Meet the Visionaries</h2>
                        <p className="text-gray-500 max-w-2xl mx-auto">The leadership team driving MomoPe's mission to digitize 60M+ merchants.</p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-12 max-w-5xl mx-auto">
                        <FounderCard
                            name="Damerla Mohan"
                            role="CEO, Co-founder"
                            imageSrc="/images/team/mohan.png"
                            linkedinUrl="https://www.linkedin.com/in/mohan-damerla/"
                            email="damerlamohan17@gmail.com"
                        />
                        <FounderCard
                            name="Damerla Mounika"
                            role="Director, Co-founder"
                            imageSrc="/images/team/mounika.png"
                            linkedinUrl="#" // Placeholder as requested
                            email="damerla.mounika2016@gmail.com"
                        />
                        <FounderCard
                            name="Bathini Meghana"
                            role="CTO - Chief Technology Officer"
                            imageSrc="/images/team/meghana.png"
                            linkedinUrl="https://www.linkedin.com/in/meghana-b-07607120a/"
                            email="meghanakishan986@gmail.com"
                        />
                    </div>
                </div>
            </section>

            {/* Roots in Kadapa Section */}
            <section className="py-24 bg-[#0f172a] text-white relative overflow-hidden">
                {/* Background Map Effect */}
                <div className="absolute inset-0 opacity-10 pointer-events-none">
                    <svg className="w-full h-full" viewBox="0 0 100 100" preserveAspectRatio="none">
                        <path d="M0 100 C 20 0 50 0 100 100 Z" fill="url(#grad1)" />
                        <defs>
                            <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="0%">
                                <stop offset="0%" style={{ stopColor: '#00C4A7', stopOpacity: 1 }} />
                                <stop offset="100%" style={{ stopColor: '#35255e', stopOpacity: 1 }} />
                            </linearGradient>
                        </defs>
                    </svg>
                </div>

                <div className="container mx-auto px-6 relative z-10">
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
                        <div className="space-y-8">
                            <div className="inline-block px-4 py-1.5 rounded-full bg-white/10 text-primary font-bold text-sm backdrop-blur-md border border-white/20">
                                Native to Rayalaseema
                            </div>
                            <h2 className="text-4xl md:text-5xl font-black leading-tight">
                                Built in <span className="text-primary">Kadapa</span>.<br />
                                For the Heart of Bharat.
                            </h2>
                            <p className="text-gray-400 text-lg leading-relaxed">
                                MomoPe wasn't born in a glass office in Bangalore or Mumbai. We started in the bustling streets of Krishnapuram, Kadapa.
                            </p>
                            <p className="text-gray-400 text-lg leading-relaxed">
                                We understand the grit of Tier-3 merchants because we live among them. We don't just solve "payments"; we solve trust, cash flow, and community connection for the real India.
                            </p>

                            <div className="grid grid-cols-2 gap-6 pt-4">
                                <div className="p-6 rounded-2xl bg-white/5 border border-white/10 backdrop-blur-sm">
                                    <div className="text-3xl font-bold text-white mb-1">516003</div>
                                    <div className="text-sm text-gray-500 font-medium uppercase tracking-wider">Pincode of Origin</div>
                                </div>
                                <div className="p-6 rounded-2xl bg-white/5 border border-white/10 backdrop-blur-sm">
                                    <div className="text-3xl font-bold text-white mb-1">100%</div>
                                    <div className="text-sm text-gray-500 font-medium uppercase tracking-wider">Local Talent</div>
                                </div>
                            </div>
                        </div>

                        <div className="relative h-[400px] lg:h-[500px] rounded-[2rem] overflow-hidden border border-white/10 shadow-2xl group">
                            <Image
                                src="/images/kadapa_map_stylized.svg"
                                alt="Kadapa Innovation Hub"
                                fill
                                className="object-cover opacity-60 group-hover:opacity-80 transition-opacity duration-700 hover:scale-105"
                            />
                            <div className="absolute inset-0 bg-gradient-to-t from-[#0f172a] via-transparent to-transparent" />

                            <div className="absolute bottom-8 left-8 right-8">
                                <div className="flex items-center gap-3 mb-2">
                                    <div className="w-3 h-3 rounded-full bg-green-500 animate-pulse" />
                                    <span className="text-sm font-bold text-green-400 uppercase tracking-widest">Live Operations</span>
                                </div>
                                <h3 className="text-2xl font-bold text-white">The Rayalaseema Innovation Hub</h3>
                                <p className="text-gray-400 text-sm mt-2">Powering 60M+ merchants from YSR District.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* Mission & Vision */}
            <section className="py-24 bg-surface">
                <div className="container mx-auto px-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-16 items-center">
                        <div>
                            <h2 className="text-3xl font-bold text-[#35255e] mb-6">Our Mission</h2>
                            <p className="text-lg text-gray-600 leading-relaxed mb-8">
                                To empower local businesses with technology-driven customer engagement tools while rewarding customers for supporting their community.
                            </p>
                            <div className="space-y-4">
                                <ValueItem icon={<Users size={20} />} title="Customer Trust" text="Transparent mechanics, no hidden terms." />
                                <ValueItem icon={<TrendingUp size={20} />} title="Merchant Partnership" text="Fair commissions and instant liquidity." />
                                <ValueItem icon={<Shield size={20} />} title="Financial Integrity" text="Auditable ledgers and 100% compliance." />
                            </div>
                        </div>
                        <div className="bg-white p-8 rounded-3xl shadow-lg shadow-gray-200/50 border border-gray-100">
                            <h3 className="text-xl font-bold text-[#35255e] mb-8">The 10-Year Roadmap</h3>
                            <div className="space-y-8 relative pl-8 border-l-2 border-primary/20">
                                <RoadmapItem year="Year 1-2" title="Foundation" text="Establish presence in Kadapa & Rayalaseema. 10k users, 150 merchants." current />
                                <RoadmapItem year="Year 3-5" title="Expansion" text="Scale to Tier-1 cities. 1M users, 5k merchants." />
                                <RoadmapItem year="Year 5-7" title="Pan-India" text="National coverage. 10M users, 50k merchants." />
                                <RoadmapItem year="Year 7-10" title="Global Leader" text="International expansion and category dominance." />
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
        <div className="flex flex-col items-center text-center group">
            <div className="w-48 h-56 relative mb-6 overflow-hidden rounded-2xl shadow-sm group-hover:shadow-xl transition-shadow duration-300 bg-gray-100">
                <Image
                    src={imageSrc}
                    alt={name}
                    fill
                    className="object-cover transition-transform duration-500 group-hover:scale-105"
                />
            </div>
            <h3 className="text-xl font-bold text-[#35255e] mb-1">{name}</h3>
            <div className="text-primary font-medium text-sm mb-4 h-10">{role}</div>

            <div className="flex items-center gap-3 mt-auto">
                {/* LinkedIn Button */}
                {linkedinUrl && linkedinUrl !== '#' ? (
                    <a
                        href={linkedinUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-[#0077b5] hover:bg-[#0077b5] hover:text-white transition-all shadow-sm hover:shadow-md"
                        title="LinkedIn Profile"
                    >
                        <Linkedin size={18} />
                    </a>
                ) : (
                    <div className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-gray-300 cursor-not-allowed" title="LinkedIn Not Available">
                        <Linkedin size={18} />
                    </div>
                )}

                {/* Email Button */}
                <a
                    href={`mailto:${email}`}
                    className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-gray-600 hover:bg-primary hover:text-white transition-all shadow-sm hover:shadow-md"
                    title={`Email ${name}`}
                >
                    <Mail size={18} />
                </a>
            </div>
        </div>
    );
}

function ValueItem({ icon, title, text }: { icon: React.ReactNode, title: string, text: string }) {
    return (
        <div className="flex gap-4 p-4 rounded-xl hover:bg-white transition-colors">
            <div className="w-12 h-12 rounded-xl bg-primary/10 text-primary flex items-center justify-center shrink-0">
                {icon}
            </div>
            <div>
                <h4 className="font-bold text-[#35255e] text-lg">{title}</h4>
                <p className="text-gray-500 text-sm leading-relaxed">{text}</p>
            </div>
        </div>
    );
}

function RoadmapItem({ year, title, text, current }: { year: string, title: string, text: string, current?: boolean }) {
    return (
        <div className="relative group">
            <div className={`absolute -left-[41px] w-5 h-5 rounded-full border-4 border-white shadow-sm ${current ? 'bg-primary scale-110' : 'bg-gray-300'}`} />
            <span className={`text-sm font-bold ${current ? 'text-primary' : 'text-gray-400'}`}>{year}</span>
            <h4 className={`font-bold text-lg transition-colors ${current ? 'text-[#35255e]' : 'text-gray-500 group-hover:text-[#35255e]'}`}>{title}</h4>
            <p className="text-gray-500 text-sm">{text}</p>
        </div>
    );
}
