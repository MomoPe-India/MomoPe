"use client";

import { motion } from "framer-motion";
import { ArrowRight, Code, Users, Heart, Zap } from "lucide-react";
import { Footer } from "@/components/Footer";
import { Navbar } from "@/components/Navbar";
import Link from "next/link";

export function CareersContent() {
    return (
        <main className="bg-surface min-h-screen">
            <Navbar />

            {/* Hero - Light */}
            <section className="pt-32 pb-20 bg-gradient-to-b from-white to-gray-50 relative overflow-hidden">
                <div className="absolute top-0 right-0 w-[500px] h-[500px] bg-primary/10 rounded-full blur-3xl -z-10" />
                <div className="container mx-auto px-6 text-center relative z-10">
                    <motion.h1
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="text-4xl md:text-6xl font-bold mb-6 text-secondary"
                    >
                        Build the <span className="text-primary">Financial OS</span> <br /> for Local India
                    </motion.h1>
                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 }}
                        className="text-xl text-text-secondary max-w-2xl mx-auto mb-10"
                    >
                        Join a mission-driven team solving the hardest problems in fintech, offline payments, and loyalty economics.
                    </motion.p>
                    <motion.a
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 }}
                        href="#openings"
                        className="inline-flex items-center gap-2 px-8 py-4 bg-primary text-white rounded-full font-bold hover:bg-primary-dark transition-all shadow-lg hover:shadow-primary/30"
                    >
                        View Open Roles <ArrowRight size={20} />
                    </motion.a>
                </div>
            </section>

            {/* Culture Values */}
            <section className="py-20 bg-white">
                <div className="container mx-auto px-6">
                    <div className="text-center mb-16">
                        <h2 className="text-3xl font-bold text-secondary mb-4">Why MomoPe?</h2>
                        <p className="text-text-secondary max-w-2xl mx-auto text-lg">
                            We operate like a sports team, not a family. We value performance, honest feedback, and extreme ownership.
                        </p>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                        <ValueCard
                            icon={<Zap className="text-accent" size={32} />}
                            title="Speed Matters"
                            text="We ship fast. Perfection is the enemy of progress. We iterate based on real feedback, not boardroom theories."
                        />
                        <ValueCard
                            icon={<Users className="text-primary" size={32} />}
                            title="Customer Obsession"
                            text="We don't build features; we solve problems. Every line of code must eventually help a shopkeeper or a shopper."
                        />
                        <ValueCard
                            icon={<Heart className="text-red-500" size={32} />}
                            title="Radical Candor"
                            text="We challenge directly and care personally. Rank doesn't matter; the best idea wins."
                        />
                    </div>
                </div>
            </section>

            {/* Open Roles */}
            <section id="openings" className="py-24 bg-surface">
                <div className="container mx-auto px-6">
                    <h2 className="text-3xl font-bold text-secondary mb-12 text-center md:text-left">Open Positions</h2>

                    <div className="space-y-8">
                        <RoleCategory title="Engineering">
                            <JobRow title="Senior Flutter Engineer" type="Bangalore • On-site" link="#" />
                            <JobRow title="Backend Lead (Supabase/Postgres)" type="Bangalore • On-site" link="#" />
                        </RoleCategory>

                        <RoleCategory title="Growth & Sales">
                            <JobRow title="City Launcher (Tier-1)" type="Remote / Field" link="#" />
                            <JobRow title="Merchant Success Manager" type="Bangalore • On-site" link="#" />
                        </RoleCategory>

                        <RoleCategory title="Product & Design">
                            <JobRow title="Product Designer (UI/UX)" type="Bangalore • Hybrid" link="#" />
                        </RoleCategory>
                    </div>
                </div>
            </section>

        </main>
    );
}

function ValueCard({ icon, title, text }: { icon: React.ReactNode, title: string, text: string }) {
    return (
        <div className="p-8 bg-surface rounded-3xl border border-gray-100 shadow-sm hover:shadow-lg hover:shadow-gray-200/50 hover:-translate-y-1 transition-all">
            <div className="w-16 h-16 rounded-2xl bg-white flex items-center justify-center mb-6 shadow-sm">
                {icon}
            </div>
            <h3 className="text-xl font-bold text-secondary mb-3">{title}</h3>
            <p className="text-text-secondary leading-relaxed">{text}</p>
        </div>
    );
}

function RoleCategory({ title, children }: { title: string, children: React.ReactNode }) {
    return (
        <div className="mb-12">
            <h3 className="text-xl font-bold text-primary-dark mb-6 px-2">{title}</h3>
            <div className="space-y-3">
                {children}
            </div>
        </div>
    );
}

function JobRow({ title, type, link }: { title: string, type: string, link: string }) {
    return (
        <Link href={link} className="flex items-center justify-between p-6 bg-white rounded-2xl border border-gray-100 hover:border-primary/30 hover:shadow-md transition-all group">
            <div>
                <h4 className="font-bold text-secondary text-lg group-hover:text-primary transition-colors">{title}</h4>
                <p className="text-text-secondary text-sm flex items-center gap-2 mt-1">
                    <span className="w-1.5 h-1.5 rounded-full bg-green-500"></span>
                    {type}
                </p>
            </div>
            <div className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center group-hover:bg-primary group-hover:text-white transition-all">
                <ArrowRight size={20} />
            </div>
        </Link>
    );
}
