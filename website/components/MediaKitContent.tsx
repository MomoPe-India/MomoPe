"use client";

import { motion } from "framer-motion";
import { Download, Mail, Linkedin, MapPin, Calendar, Globe, Layers, Award, Target } from "lucide-react";
import Image from "next/image";
import { Navbar } from "@/components/Navbar";
import { Footer } from "@/components/Footer";

export function MediaKitContent() {
    return (
        <main className="bg-surface min-h-screen font-sans text-slate-800">
            <Navbar />

            {/* 1. Hero Section */}
            <section className="pt-40 pb-20 bg-white relative overflow-hidden">
                <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-blue-50/50 rounded-full blur-3xl -z-10 translate-x-1/2 -translate-y-1/2" />
                <div className="container mx-auto px-6 max-w-5xl text-center">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="inline-block px-4 py-1.5 rounded-full bg-teal-50 text-teal-700 font-bold text-xs uppercase tracking-widest mb-8"
                    >
                        Media Resources
                    </motion.div>
                    <motion.h1
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 }}
                        className="text-5xl md:text-7xl font-bold mb-8 text-[#35255e] tracking-tight leading-tight"
                    >
                        Powering Local Commerce with <span className="text-[#00C4A7]">Smart Digital Payments</span>
                    </motion.h1>
                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 }}
                        className="text-xl md:text-2xl text-gray-500 max-w-3xl mx-auto leading-relaxed mb-12"
                    >
                        MomoPe is a next-generation fintech platform enabling seamless QR payments, merchant growth, and rewards-driven customer engagement.
                    </motion.p>
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.3 }}
                        className="flex flex-col sm:flex-row items-center justify-center gap-4"
                    >
                        <a href="#assets" className="px-8 py-4 bg-[#00C4A7] text-white rounded-xl font-bold text-lg hover:bg-[#00A890] transition-all shadow-lg hover:shadow-teal-200/50 flex items-center gap-3">
                            <Download size={20} /> Download Brand Assets
                        </a>
                        <a href="#contact" className="px-8 py-4 bg-white text-[#35255e] border border-gray-200 rounded-xl font-bold text-lg hover:border-gray-300 transition-all flex items-center gap-3">
                            <Mail size={20} /> Contact Media Team
                        </a>
                    </motion.div>
                </div>
            </section>

            {/* 2. Company Snapshot */}
            <section className="py-20 bg-gray-50 border-y border-gray-100">
                <div className="container mx-auto px-6">
                    <h2 className="text-3xl font-bold text-[#35255e] mb-12 text-center">Company Snapshot</h2>
                    <div className="grid grid-cols-2 lg:grid-cols-3 gap-6 max-w-6xl mx-auto">
                        <SnapshotItem icon={<Calendar />} label="Founded" value="2025" />
                        <SnapshotItem icon={<MapPin />} label="Headquarters" value="Kadapa, Andhra Pradesh" />
                        <SnapshotItem icon={<Globe />} label="Industry" value="Fintech / Digital Payments" />
                        <SnapshotItem icon={<Layers />} label="Products" value="Customer App, Merchant App" />
                        <SnapshotItem
                            icon={
                                <div className="relative w-full h-full p-1.5">
                                    <Image src="/images/momo-coin.png" alt="Coin" fill className="object-contain" />
                                </div>
                            }
                            label="Key Reward"
                            value="Momo Coins (₹100 min txn)"
                            isCoin
                        />
                        <SnapshotItem icon={<Target />} label="Target Market" value="Local Businesses & Merchants" />
                    </div>
                </div>
            </section>

            {/* 3. About MomoPe */}
            <section className="py-24 bg-white">
                <div className="container mx-auto px-6 max-w-4xl">
                    <h2 className="text-3xl font-bold text-[#35255e] mb-8">About MomoPe</h2>
                    <div className="space-y-6 text-lg text-gray-600 leading-relaxed">
                        <p>
                            MomoPe was created to bridge the widening gap between offline local merchants and the digital economy. While e-commerce giants dominate online retail, millions of small businesses in Tier-2 and Tier-3 cities struggle with generic payment solutions that offer zero customer retention tools. MomoPe solves this by integrating payments with a powerful loyalty engine.
                        </p>
                        <p>
                            Our platform empowers merchants to not just accept payments, but to understand and retain their customers through data-driven insights and automated rewards. By turning every transaction into a relationship-building opportunity, we help local businesses compete on a level playing field with large retailers.
                        </p>
                        <p>
                            With a scalable vision to digitize 60 million+ merchants across India, MomoPe is building the operating system for local commerce—one that is fair, transparent, and rewarding for both shop owners and their customers.
                        </p>
                    </div>
                </div>
            </section>

            {/* 4. Leadership */}
            <section className="py-24 bg-surface">
                <div className="container mx-auto px-6">
                    <div className="text-center mb-16">
                        <h2 className="text-3xl font-bold text-[#35255e] mb-4">Leadership Team</h2>
                        <p className="text-gray-500">The visionaries driving the MomoPe ecosystem.</p>
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-10 max-w-6xl mx-auto">
                        <LeaderCard
                            name="Damerla Mohan"
                            role="CEO, Co-founder"
                            image="/images/team/mohan.png"
                            linkedin="https://www.linkedin.com/in/mohan-damerla/"
                            email="damerlamohan17@gmail.com"
                        />
                        <LeaderCard
                            name="Damerla Mounika"
                            role="Director, Co-founder"
                            image="/images/team/mounika.png"
                            linkedin="#"
                            email="damerla.mounika2016@gmail.com"
                        />
                        <LeaderCard
                            name="Bathini Meghana"
                            role="CTO - Chief Technology Officer"
                            image="/images/team/meghana.png"
                            linkedin="https://www.linkedin.com/in/meghana-b-07607120a/"
                            email="meghanakishan986@gmail.com"
                        />
                    </div>
                </div>
            </section>

            {/* 5. Product Overview */}
            <section className="py-24 bg-white border-y border-gray-100">
                <div className="container mx-auto px-6 max-w-7xl">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-20">
                        <div>
                            <div className="mb-8">
                                <span className="text-[#00C4A7] font-bold uppercase tracking-wider text-sm">For Users</span>
                                <h3 className="text-3xl font-bold text-[#35255e] mt-2 mb-4">Customer Experience</h3>
                                <ul className="space-y-4">
                                    <ProductFeature title="Scan QR to Pay" desc="Lightning fast UPI payments at any MomoPe merchant." />
                                    <ProductFeature title="Earn Momo Coins" desc="Get real rewards on every eligible transaction above ₹100." />
                                    <ProductFeature title="Discover Merchants" desc="Find best-rated local shops and exclusive deals nearby." />
                                </ul>
                            </div>
                            <div className="h-64 bg-gray-100 rounded-2xl border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-medium">
                                App Mockup Placeholder
                            </div>
                        </div>
                        <div>
                            <div className="mb-8">
                                <span className="text-blue-600 font-bold uppercase tracking-wider text-sm">For Business</span>
                                <h3 className="text-3xl font-bold text-[#35255e] mt-2 mb-4">Merchant Experience</h3>
                                <ul className="space-y-4">
                                    <ProductFeature title="Accept Digital Payments" desc="One QR code for all UPI apps. Zero downtime." />
                                    <ProductFeature title="Increase Visibility" desc="Get listed on the MomoPe app and attract new customers." />
                                    <ProductFeature title="Customer Engagement" desc="Automated loyalty programs to bring customers back." />
                                </ul>
                            </div>
                            <div className="h-64 bg-gray-100 rounded-2xl border-2 border-dashed border-gray-300 flex items-center justify-center text-gray-400 font-medium">
                                Dashboard Mockup Placeholder
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* 6. Brand Assets */}
            <section id="assets" className="py-24 bg-gray-900 text-white">
                <div className="container mx-auto px-6 max-w-5xl">
                    <h2 className="text-3xl font-bold mb-12 text-center">Brand Assets</h2>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-10 mb-12">
                        <div className="bg-gray-800 p-8 rounded-2xl border border-gray-700">
                            <h3 className="text-xl font-bold mb-6 text-gray-200">Logo & Colors</h3>
                            <div className="flex items-center gap-6 mb-8">
                                <div className="p-4 bg-white rounded-lg">
                                    <Image src="/images/website_logo.png" alt="Logo" width={40} height={40} className="object-contain" />
                                </div>
                                <div className="space-y-2">
                                    <ColorSwatch color="#00C4A7" label="Momo Teal" />
                                    <ColorSwatch color="#35255e" label="Momo Slate" />
                                </div>
                            </div>
                            <button className="w-full py-3 bg-white/10 hover:bg-white/20 rounded-lg font-bold text-sm transition-colors flex items-center justify-center gap-2">
                                Download Logos (ZIP) <Download size={16} />
                            </button>
                        </div>
                        <div className="bg-gray-800 p-8 rounded-2xl border border-gray-700">
                            <h3 className="text-xl font-bold mb-6 text-gray-200">Press Kit</h3>
                            <p className="text-gray-400 mb-8 leading-relaxed">
                                Includes high-resolution app screenshots, founder headshots, and the official 100-word company boilerplate description for press releases.
                            </p>
                            <button className="w-full py-3 bg-[#00C4A7] hover:bg-[#00A890] text-white rounded-lg font-bold text-sm transition-colors flex items-center justify-center gap-2">
                                Download Complete Media Kit <Download size={16} />
                            </button>
                        </div>
                    </div>
                </div>
            </section>

            {/* 7. Vision & Roadmap */}
            <section className="py-24 bg-white">
                <div className="container mx-auto px-6 max-w-4xl text-center">
                    <h2 className="text-3xl font-bold text-[#35255e] mb-12">Strategic Vision</h2>
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                        <VisionCard title="Expansion" desc="Scaling to 50+ Tier-2 cities by 2027." />
                        <VisionCard title="Acquisition" desc="Onboarding 1 Million+ active merchants." />
                        <VisionCard title="Infrastructure" desc="Building proprietary lending protocols." />
                        <VisionCard title="Ecosystem" desc="Complete offline-to-online commerce cloud." />
                    </div>
                </div>
            </section>

            {/* 8. Media Contact */}
            <section id="contact" className="py-20 bg-gray-50 border-t border-gray-200">
                <div className="container mx-auto px-6 text-center">
                    <h2 className="text-2xl font-bold text-[#35255e] mb-4">Media Inquiries</h2>
                    <p className="text-gray-500 mb-8">For press releases, interviews, and official statements.</p>
                    <a href="mailto:press@momope.com" className="inline-flex items-center gap-3 px-8 py-4 bg-white border border-gray-200 shadow-sm rounded-xl text-lg font-bold text-[#35255e] hover:text-[#00C4A7] hover:border-[#00C4A7] transition-all">
                        <Mail size={20} /> press@momope.com
                    </a>
                </div>
            </section>

            <Footer />
        </main>
    );
}

function SnapshotItem({ icon, label, value, isCoin }: { icon: React.ReactNode, label: string, value: string, isCoin?: boolean }) {
    return (
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
            <div className={`w-10 h-10 rounded-full ${isCoin ? 'bg-black' : 'bg-blue-50'} ${isCoin ? '' : 'text-blue-600'} flex items-center justify-center mb-4 overflow-hidden`}>
                {icon}
            </div>
            <div className="text-gray-400 text-xs font-bold uppercase tracking-wider mb-1">{label}</div>
            <div className="text-[#35255e] font-bold text-lg leading-tight">{value}</div>
        </div>
    );
}

function LeaderCard({ name, role, image, linkedin, email }: { name: string, role: string, image: string, linkedin: string, email: string }) {
    return (
        <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm hover:shadow-lg transition-all group">
            <div className="w-24 h-24 relative mb-6 rounded-full overflow-hidden mx-auto bg-gray-100">
                <Image src={image} alt={name} fill className="object-cover" />
            </div>
            <div className="text-center">
                <h3 className="text-xl font-bold text-[#35255e] mb-1">{name}</h3>
                <div className="text-[#00C4A7] font-medium text-sm mb-6">{role}</div>
                <div className="flex items-center justify-center gap-3">
                    {linkedin !== '#' ? (
                        <a href={linkedin} target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-[#0077b5] hover:bg-[#0077b5] hover:text-white transition-colors">
                            <Linkedin size={18} />
                        </a>
                    ) : (
                        <div className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-gray-300">
                            <Linkedin size={18} />
                        </div>
                    )}
                    <a href={`mailto:${email}`} className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-gray-600 hover:bg-[#35255e] hover:text-white transition-colors">
                        <Mail size={18} />
                    </a>
                </div>
            </div>
        </div>
    );
}

function ProductFeature({ title, desc }: { title: string, desc: string }) {
    return (
        <div className="flex items-start gap-3">
            <div className="mt-1.5 w-1.5 h-1.5 rounded-full bg-[#00C4A7] shrink-0" />
            <div>
                <h4 className="font-bold text-[#35255e]">{title}</h4>
                <p className="text-sm text-gray-500 leading-relaxed">{desc}</p>
            </div>
        </div>
    );
}

function VisionCard({ title, desc }: { title: string, desc: string }) {
    return (
        <div className="p-6 bg-gray-50 rounded-xl border border-gray-100">
            <h4 className="font-bold text-[#35255e] mb-2">{title}</h4>
            <p className="text-sm text-gray-500">{desc}</p>
        </div>
    );
}

function ColorSwatch({ color, label }: { color: string, label: string }) {
    return (
        <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg shadow-sm" style={{ backgroundColor: color }} />
            <div className="text-sm font-medium text-gray-300">{label} <span className="opacity-50 ml-2 font-mono text-xs">{color}</span></div>
        </div>
    )
}
