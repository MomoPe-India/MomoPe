"use client";

import { motion } from "framer-motion";
import { TrendingUp, Mail } from "lucide-react";
import { Footer } from "@/components/Footer";
import { Navbar } from "@/components/Navbar";

export function InvestorsContent() {
    return (
        <main className="bg-surface min-h-screen">
            <Navbar />

            {/* Hero - Light */}
            <section className="pt-32 pb-20 bg-gradient-to-b from-white to-gray-50 relative">
                <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-primary/5 rounded-full blur-3xl -z-10" />
                <div className="container mx-auto px-6 relative z-10">
                    <div className="max-w-4xl">
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-blue-50 text-blue-700 font-medium text-sm mb-6"
                        >
                            <TrendingUp size={16} /> Investor Relations
                        </motion.div>
                        <motion.h1
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.1 }}
                            className="text-4xl md:text-6xl font-bold mb-6 leading-tight text-secondary"
                        >
                            Building the <span className="text-primary">Engagement Layer</span> <br /> for 60M+ Indian Merchants
                        </motion.h1>
                        <motion.p
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.2 }}
                            className="text-xl text-text-secondary max-w-2xl leading-relaxed"
                        >
                            MomoPe is unlocking the next trillion dollars in offline commerce by solving the &quot;Retention Problem&quot; for local businesses.
                        </motion.p>
                    </div>
                </div>
            </section>

            {/* Key Metrics */}
            <section className="py-12 bg-white border-y border-gray-100">
                <div className="container mx-auto px-6">
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
                        <MetricBox label="Market Size" value="$1.2T" sub="Offline Retail GMV" />
                        <MetricBox label="Audience" value="60M+" sub="SME Merchants" />
                        <MetricBox label="Problem" value="0%" sub="Digital Retention Tools" />
                        <MetricBox label="Solution" value="10x" sub="More Effective vs Ads" />
                    </div>
                </div>
            </section>

            {/* The Vision */}
            <section className="py-24 bg-surface">
                <div className="container mx-auto px-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-16 items-center">
                        <div>
                            <h2 className="text-3xl font-bold text-secondary mb-6">Sustainable Growth. <br />Real Economics.</h2>
                            <p className="text-text-secondary text-lg leading-relaxed mb-6">
                                Unlike the previous generation of fintechs fueled by cashback burn, MomoPe is built on positive unit economics from Day 1.
                            </p>
                            <p className="text-text-secondary text-lg leading-relaxed mb-8">
                                Our proprietary &quot;Coin Economy&quot; ensures that rewards are funded by merchants who see tangible ROI, not by venture capital.
                            </p>
                            <ul className="space-y-4">
                                <ListItem text="Zero-Burn Acquisition Model" />
                                <ListItem text="High-Margin B2B SaaS Potential" />
                                <ListItem text="Regulatory-First Architecture" />
                            </ul>
                        </div>
                        <div className="bg-white p-10 rounded-3xl shadow-xl shadow-gray-200/50 border border-gray-100 relative overflow-hidden">
                            <div className="absolute -right-20 -top-20 w-80 h-80 bg-primary/10 rounded-full blur-3xl" />
                            <h3 className="font-bold text-xl mb-8 relative z-10 text-secondary">The 10-Year Roadmap</h3>
                            <div className="space-y-8 relative z-10 border-l border-gray-200 pl-8">
                                <TimelineItem year="Phase 1 (Now)" title="Bangalore Density" desc="Validation of city-wide network effects." active />
                                <TimelineItem year="Phase 2 (2027)" title="India Scale" desc="Expansion to top 10 metros. 5M+ Users." />
                                <TimelineItem year="Phase 3 (2030)" title="The Super App" desc="Lending, Inventory, and Supply Chain integration." />
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* Contact */}
            <section className="py-20 bg-white border-t border-gray-100">
                <div className="container mx-auto px-6 text-center">
                    <h2 className="text-3xl font-bold text-secondary mb-8">Partner with us</h2>
                    <div className="inline-block p-10 bg-surface rounded-3xl shadow-sm border border-gray-100">
                        <p className="text-text-secondary mb-6 text-lg">For investment inquiries and partnership opportunities:</p>
                        <a href="mailto:investors@momope.com" className="flex items-center justify-center gap-2 text-2xl font-bold text-primary hover:text-primary-dark transition-colors">
                            <Mail size={24} /> investors@momope.com
                        </a>
                    </div>
                </div>
            </section>

            <Footer />
        </main>
    );
}

function MetricBox({ label, value, sub }: { label: string, value: string, sub: string }) {
    return (
        <div>
            <div className="text-sm text-gray-400 font-bold uppercase tracking-wider mb-2">{label}</div>
            <div className="text-4xl md:text-5xl font-bold text-secondary mb-1">{value}</div>
            <div className="text-sm text-text-secondary font-medium">{sub}</div>
        </div>
    );
}

function ListItem({ text }: { text: string }) {
    return (
        <li className="flex items-center gap-3">
            <div className="w-5 h-5 rounded-full bg-green-100 text-green-600 flex items-center justify-center text-xs">✓</div>
            <span className="font-medium text-secondary">{text}</span>
        </li>
    );
}

function TimelineItem({ year, title, desc, active }: { year: string, title: string, desc: string, active?: boolean }) {
    return (
        <div className="relative">
            <div className={`absolute -left-[41px] w-5 h-5 rounded-full border-4 border-white shadow-sm ${active ? 'bg-primary' : 'bg-gray-300'}`} />
            <div className={`text-xs font-bold mb-1 ${active ? 'text-primary' : 'text-gray-400'}`}>{year}</div>
            <div className="font-bold text-lg mb-1 text-secondary">{title}</div>
            <p className="text-sm text-text-secondary">{desc}</p>
        </div>
    );
}
