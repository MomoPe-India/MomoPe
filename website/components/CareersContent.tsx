"use client";

import React from "react";
import { motion } from "framer-motion";
import {
    ArrowRight,
    Code,
    Users,
    Heart,
    Zap,
    Shield,
    Globe,
    Coffee,
    Cpu,
    Rocket,
    MessageSquare
} from "lucide-react";
import {
    VelocityAnimation,
    FirstPrinciplesAnimation,
    EngineeringExcellenceAnimation
} from "./OperatingPrinciplesAnimations";
import { Footer } from "@/components/Footer";
import { Navbar } from "@/components/Navbar";
import Link from "next/link";

export function CareersContent() {
    return (
        <main className="bg-surface min-h-screen">
            <Navbar />

            {/* Hero - Dark & Premium */}
            <section className="pt-40 pb-32 bg-secondary relative overflow-hidden">
                {/* Decorative background elements */}
                <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-primary/10 rounded-full blur-[120px] -z-0" />
                <div className="absolute bottom-0 left-0 w-[400px] h-[400px] bg-accent/5 rounded-full blur-[100px] -z-0" />

                <div className="container mx-auto px-6 relative z-10">
                    <div className="max-w-4xl mx-auto text-center">
                        <motion.div
                            initial={{ opacity: 0, y: -20 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-primary/10 border border-primary/30 text-white text-sm font-bold mb-8 shadow-lg shadow-primary/10"
                        >
                            <span className="relative flex h-2 w-2">
                                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
                                <span className="relative inline-flex rounded-full h-2 w-2 bg-primary"></span>
                            </span>
                            We're hiring for 5+ open roles
                        </motion.div>

                        <motion.h1
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="text-5xl md:text-7xl font-bold mb-8 text-white tracking-tight"
                        >
                            Build the <span className="bg-clip-text text-transparent bg-gradient-to-r from-primary via-primary-light to-teal-200">Financial OS</span> <br />
                            for Local India
                        </motion.h1>

                        <motion.p
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.1 }}
                            className="text-xl text-gray-400 max-w-2xl mx-auto mb-12 leading-relaxed"
                        >
                            MomoPe is more than a payments app. We are engineering a new economic layer for millions of merchants. Join us in making commerce frictionless.
                        </motion.p>

                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.2 }}
                            className="flex flex-col sm:flex-row items-center justify-center gap-4"
                        >
                            <a
                                href="#openings"
                                className="w-full sm:w-auto px-8 py-4 bg-primary text-white rounded-full font-bold hover:bg-primary-dark transition-all shadow-lg shadow-primary/20 flex items-center justify-center gap-2 group"
                            >
                                Explorer Open Roles
                                <ArrowRight size={20} className="group-hover:translate-x-1 transition-transform" />
                            </a>
                            <Link
                                href="/about"
                                className="w-full sm:w-auto px-8 py-4 bg-white/5 text-white border border-white/10 rounded-full font-bold hover:bg-white/10 transition-all flex items-center justify-center"
                            >
                                Learn our Mission
                            </Link>
                        </motion.div>
                    </div>
                </div>

                {/* Floating Code Snippet Visual */}
                <div className="absolute bottom-10 left-1/2 -translate-x-1/2 opacity-20 pointer-events-none hidden lg:block">
                    <pre className="text-primary-light/50 text-xs font-mono">
                        {"const MomoPeContext = createContext({\n  transactionRate: 0.9999,\n  loyaltyEngine: 'active',\n  merchantGrowth: true\n});"}
                    </pre>
                </div>
            </section>

            {/* Culture / Values - Premium Refinement */}
            <section className="py-32 bg-white relative overflow-hidden">
                {/* Section Ambient Glows */}
                <div className="absolute top-1/4 -right-48 w-[600px] h-[600px] bg-primary/5 rounded-full blur-[120px] -z-0" />
                <div className="absolute bottom-1/4 -left-48 w-[400px] h-[400px] bg-accent/5 rounded-full blur-[100px] -z-0" />

                <div className="container mx-auto px-6 relative z-10">
                    <div className="text-center mb-24">
                        <motion.div
                            initial={{ opacity: 0, y: 10 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            viewport={{ once: true }}
                            className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-surface border border-gray-100 shadow-umbra-sm mb-6"
                        >
                            <div className="w-1.5 h-1.5 rounded-full bg-primary animate-pulse" />
                            <span className="text-[10px] font-black text-gray-400 uppercase tracking-[0.3em]">MomoPe DNA</span>
                        </motion.div>

                        <h2 className="text-4xl md:text-6xl lg:text-7xl font-black text-secondary mb-8 tracking-tighter leading-tight">
                            Our Operating <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-accent italic">Principles</span>
                        </h2>

                        <p className="text-text-secondary max-w-2xl mx-auto text-xl leading-relaxed">
                            We ship high-fidelity products at an <span className="text-secondary font-bold">unreasonable velocity</span>. We optimize for autonomy and impact over bureaucracy.
                        </p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                        <ValueCard
                            animation={<VelocityAnimation />}
                            title="Velocity as a Default"
                            text="We favor speed over certainty. We ship, learn, and iterate. Small, frequent releases beat a delayed perfect launch every time."
                            index={0}
                        />
                        <ValueCard
                            animation={<FirstPrinciplesAnimation />}
                            title="First Principles Thinking"
                            text="We don't do things because 'that's how it's done.' we break problems down to their fundamental truths and build from there."
                            index={1}
                        />
                        <ValueCard
                            animation={<EngineeringExcellenceAnimation />}
                            title="Engineering Excellence"
                            text="Code is our craft. We maintain high standards, rigorous testing, and a bias towards automation in everything we do."
                            index={2}
                        />
                    </div>
                </div>
            </section>

            {/* Benefits Section */}
            <section className="py-24 bg-surface border-y border-gray-100">
                <div className="container mx-auto px-6">
                    <div className="bg-secondary rounded-[3rem] p-12 md:p-20 relative overflow-hidden shadow-2xl">
                        <div className="absolute top-0 right-0 w-64 h-64 bg-primary/5 rounded-full blur-3xl" />

                        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-center flex-row-reverse">
                            <div>
                                <h3 className="text-3xl md:text-4xl font-bold text-white mb-8">Why join MomoPe?</h3>
                                <div className="space-y-8">
                                    <BenefitItem
                                        icon={<Rocket className="text-primary" />}
                                        title="Ownership & ESOPs"
                                        desc="We want every team member to think and act like a founder. Significant equity upside for early members."
                                    />
                                    <BenefitItem
                                        icon={<Globe className="text-teal-400" />}
                                        title="Work from Anywhere"
                                        desc="High-trust remote-first culture with occasional offsites to beautiful locations in India."
                                    />
                                    <BenefitItem
                                        icon={<Coffee className="text-accent" />}
                                        title="Deep Flow Environment"
                                        desc="No useless meetings. We protect engineering and creative flow time religiously."
                                    />
                                </div>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div className="space-y-4 pt-8">
                                    <div className="bg-white/5 backdrop-blur-sm border border-white/10 p-6 rounded-3xl">
                                        <div className="text-primary font-bold text-2xl mb-1">99.9%</div>
                                        <div className="text-gray-400 text-sm italic">Uptime Obsession</div>
                                    </div>
                                    <div className="bg-white/5 backdrop-blur-sm border border-white/10 p-6 rounded-3xl">
                                        <div className="text-accent font-bold text-2xl mb-1">100%</div>
                                        <div className="text-gray-400 text-sm italic">Ownership Culture</div>
                                    </div>
                                </div>
                                <div className="space-y-4">
                                    <div className="bg-white/5 backdrop-blur-sm border border-white/10 p-6 rounded-3xl">
                                        <div className="text-teal-400 font-bold text-2xl mb-1">Flex</div>
                                        <div className="text-gray-400 text-sm italic">Leave Policy</div>
                                    </div>
                                    <div className="bg-white/5 backdrop-blur-sm border border-white/10 p-6 rounded-3xl h-full flex items-center justify-center">
                                        <div className="text-white/20 text-4xl">MomoPe</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* Open Roles */}
            <section id="openings" className="py-32 bg-white">
                <div className="container mx-auto px-6">
                    <div className="max-w-4xl mx-auto">
                        <div className="flex flex-col md:flex-row md:items-end justify-between mb-16 gap-6">
                            <div>
                                <h2 className="text-4xl font-bold text-secondary mb-4">Open Missions</h2>
                                <p className="text-text-secondary text-lg">Help us build the next generation of financial infrastructure.</p>
                            </div>
                            <div className="bg-surface px-6 py-3 rounded-2xl border border-gray-100 hidden md:block">
                                <span className="text-primary font-bold">5</span> Roles open
                            </div>
                        </div>

                        <div className="space-y-12">
                            <RoleCategory title="Engineering & Product">
                                <JobRow
                                    title="Senior Flutter Engineer"
                                    location="Bangalore / Remote"
                                    tags={["High Impact", "Lead Role"]}
                                    link="#"
                                />
                                <JobRow
                                    title="Backend Lead (Go / Supabase)"
                                    location="Bangalore"
                                    tags={["Founding Member"]}
                                    link="#"
                                />
                                <JobRow
                                    title="Product Designer"
                                    location="Remote"
                                    tags={["Fintech UX"]}
                                    link="#"
                                />
                            </RoleCategory>

                            <RoleCategory title="Growth & Strategy">
                                <JobRow
                                    title="City Launcher (Tier-2 Expansion)"
                                    location="Field / Multi-city"
                                    tags={["On-ground", "Aggressive Growth"]}
                                    link="#"
                                />
                                <JobRow
                                    title="Merchant Success Associate"
                                    location="Bangalore"
                                    link="#"
                                />
                            </RoleCategory>
                        </div>

                        {/* General Inquiries */}
                        <div className="mt-20 p-10 bg-surface rounded-3xl border border-dashed border-gray-300 text-center">
                            <h4 className="text-xl font-bold text-secondary mb-2">Don't see a fit?</h4>
                            <p className="text-text-secondary mb-8">We are always looking for exceptional talent. Pitch yourself to us.</p>
                            <a
                                href="mailto:careers@momope.com"
                                className="inline-flex items-center gap-2 text-primary font-bold hover:gap-4 transition-all"
                            >
                                Send a speculative application <ArrowRight size={20} />
                            </a>
                        </div>
                    </div>
                </div>
            </section>


        </main>
    );
}

function ValueCard({ animation, title, text, index }: { animation: React.ReactNode, title: string, text: string, index: number }) {
    return (
        <motion.div
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: index * 0.1, duration: 0.6 }}
            className="p-8 md:p-12 bg-white rounded-[3rem] md:rounded-[3.5rem] border border-gray-100 shadow-umbra-sm hover:shadow-umbra-lg hover:-translate-y-3 transition-all duration-700 group relative overflow-hidden flex flex-col h-full"
        >
            {/* Background Texture & Glows */}
            <div className="absolute top-0 right-0 w-48 h-48 bg-primary/5 rounded-full blur-3xl -z-0 opacity-0 group-hover:opacity-100 transition-opacity duration-700" />
            <div className="absolute inset-0 opacity-[0.02] pointer-events-none group-hover:opacity-[0.05] transition-opacity duration-700">
                <svg className="w-full h-full" xmlns="http://www.w3.org/2000/svg">
                    <pattern id={`grid-${index}`} width="20" height="20" patternUnits="userSpaceOnUse">
                        <circle cx="2" cy="2" r="1" fill="currentColor" className="text-secondary" />
                    </pattern>
                    <rect width="100%" height="100%" fill={`url(#grid-${index})`} />
                </svg>
            </div>

            {/* Principle Number Badge */}
            <div className="absolute top-10 right-10 text-[40px] md:text-[60px] font-black text-secondary/5 group-hover:text-primary/10 transition-colors duration-500 leading-none select-none">
                0{index + 1}
            </div>

            <div className="w-20 h-20 md:w-24 md:h-24 rounded-2xl md:rounded-[2rem] bg-gray-50 flex items-center justify-center mb-8 md:mb-12 shadow-umbra-sm border border-gray-100 group-hover:border-primary/20 group-hover:bg-white transition-all duration-700 relative z-10 hover:scale-110">
                {animation}
            </div>

            <div className="flex-1 flex flex-col">
                <h4 className="text-2xl md:text-3xl font-black text-secondary mb-4 md:mb-6 tracking-tight group-hover:text-primary transition-colors duration-300 leading-tight">
                    {title}
                </h4>
                <p className="text-text-secondary leading-relaxed text-base md:text-lg mb-8">
                    {text}
                </p>
            </div>

            <div className="mt-auto pt-8 border-t border-gray-50 flex items-center justify-between opacity-0 group-hover:opacity-100 transition-all duration-500 transform translate-y-4 group-hover:translate-y-0">
                <span className="text-[10px] font-black text-primary uppercase tracking-[0.3em] flex items-center gap-2">
                    MOMOPE CULTURE <ArrowRight size={14} />
                </span>
                <div className="w-8 h-px bg-primary/30" />
            </div>
        </motion.div>
    );
}

function BenefitItem({ icon, title, desc }: { icon: React.ReactNode, title: string, desc: string }) {
    return (
        <div className="flex gap-6 group">
            <div className="flex-shrink-0 w-12 h-12 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center group-hover:bg-primary/20 transition-colors">
                {icon}
            </div>
            <div>
                <h5 className="text-lg font-bold text-white mb-1">{title}</h5>
                <p className="text-gray-400 text-sm leading-relaxed">{desc}</p>
            </div>
        </div>
    );
}

function RoleCategory({ title, children }: { title: string, children: React.ReactNode }) {
    return (
        <div>
            <h3 className="text-sm font-bold text-primary uppercase tracking-widest mb-6 border-l-4 border-primary pl-4">{title}</h3>
            <div className="grid gap-4">
                {children}
            </div>
        </div>
    );
}

function JobRow({ title, location, tags, link }: { title: string, location: string, tags?: string[], link: string }) {
    return (
        <Link href={link} className="flex flex-col md:flex-row md:items-center justify-between p-6 bg-white rounded-2xl border border-gray-100 hover:border-primary/40 hover:shadow-lg transition-all group gap-4">
            <div className="flex-1">
                <div className="flex flex-wrap items-center gap-3 mb-2">
                    <h4 className="font-bold text-secondary text-xl group-hover:text-primary transition-colors">{title}</h4>
                    {tags?.map(tag => (
                        <span key={tag} className="px-2 py-0.5 bg-primary/5 text-primary text-[10px] uppercase font-bold rounded-md">
                            {tag}
                        </span>
                    ))}
                </div>
                <div className="flex items-center gap-4 text-text-secondary text-sm">
                    <span className="flex items-center gap-1.5">
                        <Globe size={14} className="text-gray-400" />
                        {location}
                    </span>
                    <span className="flex items-center gap-1.5">
                        <Zap size={14} className="text-accent" />
                        Full-time
                    </span>
                </div>
            </div>
            <div className="flex items-center gap-4">
                <button className="hidden md:flex items-center gap-2 px-4 py-2 bg-secondary text-white text-xs font-bold rounded-xl hover:bg-primary transition-all opacity-0 group-hover:opacity-100">
                    Quick Apply
                </button>
                <div className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center group-hover:bg-primary group-hover:text-white transition-all">
                    <ArrowRight size={20} />
                </div>
            </div>
        </Link>
    );
}
