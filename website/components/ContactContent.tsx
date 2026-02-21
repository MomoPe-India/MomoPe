"use client";

import { motion, AnimatePresence } from "framer-motion";
import { Mail, MapPin, Phone, Send, MessageSquare, ChevronDown, HelpCircle, Briefcase, FileText } from "lucide-react";
import { useState } from "react";
import { Navbar } from "@/components/Navbar";
import { Footer } from "@/components/Footer";

export function ContactContent() {
    return (
        <main className="bg-surface min-h-screen font-sans text-slate-800">
            <Navbar />

            {/* Header */}
            <section className="pt-32 pb-20 bg-white relative overflow-hidden">
                <div className="absolute top-0 left-0 w-[600px] h-[600px] bg-teal-50/50 rounded-full blur-3xl -z-10 -translate-x-1/2 -translate-y-1/2" />
                <div className="absolute bottom-0 right-0 w-[400px] h-[400px] bg-blue-50/50 rounded-full blur-3xl -z-10 translate-x-1/2 translate-y-1/2" />

                <div className="container mx-auto px-6 text-center">
                    <motion.div
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass border-primary/20 text-primary-dark font-semibold text-sm mb-6"
                    >
                        <MessageSquare size={14} /> We're here to help
                    </motion.div>
                    <motion.h2
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 }}
                        className="text-5xl md:text-7xl font-black text-secondary mb-8 tracking-tight leading-tight"
                    >
                        Let&apos;s Start a <motion.span
                            initial={{ opacity: 0, scale: 0.98, filter: "blur(8px)" }}
                            animate={{ opacity: 1, scale: 1, filter: "blur(0px)" }}
                            transition={{ delay: 0.4, duration: 0.8, ease: "easeOut" }}
                            className="inline-block text-transparent bg-clip-text bg-gradient-to-r from-primary to-momo-blue animate-gradient-x drop-shadow-[0_5px_15px_rgba(0,114,255,0.25)]"
                        >
                            Conversation
                        </motion.span>
                    </motion.h2>
                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 }}
                        className="text-xl text-gray-500 max-w-2xl mx-auto leading-relaxed"
                    >
                        Whether you're a merchant looking to grow or a customer with a question, our team is ready to assist you 24/7.
                    </motion.p>
                </div>
            </section>

            {/* Department Grid */}
            <section className="py-12 bg-gray-50/50">
                <div className="container mx-auto px-6 max-w-6xl">
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <DepartmentCard
                            icon={<HelpCircle className="text-blue-500" />}
                            title="Customer Support"
                            email="support@momope.com"
                            desc="For app issues and payments."
                        />
                        <DepartmentCard
                            icon={<Briefcase className="text-[#00C4A7]" />}
                            title="Merchant Sales"
                            email="sales@momope.com"
                            desc="Join our merchant network."
                        />
                        <DepartmentCard
                            icon={<FileText className="text-purple-500" />}
                            title="Media & Press"
                            email="press@momope.com"
                            desc="News and brand inquiries."
                        />
                    </div>
                </div>
            </section>

            {/* Main Content Area */}
            <section className="py-20 bg-white">
                <div className="container mx-auto px-6 max-w-6xl">
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-16">

                        {/* Left Column: Info & FAQ */}
                        <div className="space-y-12">
                            {/* Address Block */}
                            <div>
                                <h3 className="text-2xl font-bold text-[#35255e] mb-6 flex items-center gap-3">
                                    <MapPin className="text-[#00C4A7]" /> Visit Our HQ
                                </h3>
                                <div className="bg-surface p-8 rounded-3xl border border-gray-100 shadow-sm relative overflow-hidden group hover:shadow-md transition-all">
                                    <div className="relative z-10">
                                        <p className="text-lg font-bold text-[#35255e] mb-2">MomoPe Digital Hub Pvt. Ltd.</p>
                                        <p className="text-gray-500 leading-relaxed mb-6">
                                            #4/106, Krishnapuram, Kadapa,<br />
                                            Andhra Pradesh, India - 516003
                                        </p>
                                        <div className="flex items-center gap-2 text-[#00C4A7] font-bold text-sm">
                                            <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
                                            Open Mon-Fri, 9am - 6pm
                                        </div>
                                    </div>
                                    {/* Map Background Hint */}
                                    <div className="absolute right-0 top-0 w-32 h-32 bg-gray-100 rounded-bl-full opacity-50 transition-transform group-hover:scale-110" />
                                </div>
                            </div>

                            {/* FAQ Accordion */}
                            <div>
                                <h3 className="text-2xl font-bold text-[#35255e] mb-6 flex items-center gap-3">
                                    <HelpCircle className="text-[#00C4A7]" /> Common Questions
                                </h3>
                                <div className="space-y-4">
                                    <FAQItem question="How do I become a merchant?" answer="Simply download the Merchant App or fill out the contact form. Our team will verify your business within 24 hours." />
                                    <FAQItem question="Is there a fee to join?" answer="MomoPe is free for customers. Merchants pay a small platform fee only on successful transactions." />
                                    <FAQItem question="Where is my refund?" answer="Refunds are processed instantly to your MomoPe wallet or within 3-5 days to your bank account." />
                                </div>
                            </div>
                        </div>

                        {/* Right Column: Dynamic Form */}
                        <div className="bg-gray-50 p-8 md:p-10 rounded-[2.5rem] border border-gray-100 shadow-xl shadow-gray-200/50">
                            <h3 className="text-3xl font-bold text-[#35255e] mb-2">Send a Message</h3>
                            <p className="text-gray-500 mb-8">We usually respond within 2 hours.</p>

                            <form className="space-y-6">
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                    <div className="space-y-2">
                                        <label className="text-sm font-bold text-gray-700 ml-1">First Name</label>
                                        <input type="text" className="w-full px-5 py-4 rounded-2xl bg-white border border-gray-200 focus:border-[#00C4A7] focus:ring-4 focus:ring-[#00C4A7]/10 outline-none transition-all placeholder:text-gray-300" placeholder="e.g. Rahul" />
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-sm font-bold text-gray-700 ml-1">Last Name</label>
                                        <input type="text" className="w-full px-5 py-4 rounded-2xl bg-white border border-gray-200 focus:border-[#00C4A7] focus:ring-4 focus:ring-[#00C4A7]/10 outline-none transition-all placeholder:text-gray-300" placeholder="e.g. Kumar" />
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-bold text-gray-700 ml-1">Email Address</label>
                                    <input type="email" className="w-full px-5 py-4 rounded-2xl bg-white border border-gray-200 focus:border-[#00C4A7] focus:ring-4 focus:ring-[#00C4A7]/10 outline-none transition-all placeholder:text-gray-300" placeholder="rahul@example.com" />
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-bold text-gray-700 ml-1">Topic</label>
                                    <div className="relative">
                                        <select className="w-full px-5 py-4 rounded-2xl bg-white border border-gray-200 focus:border-[#00C4A7] focus:ring-4 focus:ring-[#00C4A7]/10 outline-none transition-all appearance-none cursor-pointer">
                                            <option>General Inquiry</option>
                                            <option>Merchant Partnership</option>
                                            <option>Technical Support</option>
                                            <option>Media/Press</option>
                                        </select>
                                        <ChevronDown className="absolute right-5 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" size={20} />
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <label className="text-sm font-bold text-gray-700 ml-1">Message</label>
                                    <textarea rows={4} className="w-full px-5 py-4 rounded-2xl bg-white border border-gray-200 focus:border-[#00C4A7] focus:ring-4 focus:ring-[#00C4A7]/10 outline-none transition-all resize-none placeholder:text-gray-300" placeholder="Type your message here..."></textarea>
                                </div>
                                <button type="button" className="w-full py-4 bg-[#00C4A7] hover:bg-[#00A890] text-white rounded-2xl font-bold text-lg shadow-lg hover:shadow-teal-200/50 transition-all flex items-center justify-center gap-3 transform active:scale-95">
                                    Send Message <Send size={20} />
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </section>

            {/* Map Section */}
            <section className="h-[400px] w-full bg-gray-100 relative grayscale-[0.8] hover:grayscale-0 transition-all duration-1000">
                <iframe
                    width="100%"
                    height="100%"
                    frameBorder="0"
                    scrolling="no"
                    marginHeight={0}
                    marginWidth={0}
                    src="https://www.openstreetmap.org/export/embed.html?bbox=78.8000%2C14.4500%2C78.8500%2C14.5000&amp;layer=mapnik&amp;marker=14.4673%2C78.8242"
                    className="absolute inset-0"
                ></iframe>
                <div className="absolute inset-0 pointer-events-none shadow-[inset_0_0_50px_rgba(0,0,0,0.1)]" />
            </section>

        </main>
    );
}

function DepartmentCard({ icon, title, email, desc }: { icon: React.ReactNode, title: string, email: string, desc: string }) {
    return (
        <a href={`mailto:${email}`} className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm hover:shadow-md hover:border-[#00C4A7]/30 transition-all group">
            <div className="flex items-center gap-4 mb-4">
                <div className="w-12 h-12 rounded-full bg-gray-50 flex items-center justify-center group-hover:scale-110 transition-transform">
                    {icon}
                </div>
                <div>
                    <h4 className="font-bold text-[#35255e]">{title}</h4>
                    <p className="text-xs text-gray-400">{desc}</p>
                </div>
            </div>
            <div className="text-[#00C4A7] font-medium text-sm flex items-center gap-2 group-hover:underline">
                {email} <Send size={12} />
            </div>
        </a>
    )
}

function FAQItem({ question, answer }: { question: string, answer: string }) {
    const [isOpen, setIsOpen] = useState(false);

    return (
        <div className="bg-white rounded-2xl border border-gray-100 overflow-hidden">
            <button
                onClick={() => setIsOpen(!isOpen)}
                className="w-full flex items-center justify-between p-5 text-left font-bold text-[#35255e] hover:bg-gray-50 transition-colors"
            >
                {question}
                <ChevronDown className={`text-gray-400 transition-transform duration-300 ${isOpen ? "rotate-180" : ""}`} size={20} />
            </button>
            <AnimatePresence>
                {isOpen && (
                    <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: "auto", opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        className="overflow-hidden"
                    >
                        <div className="p-5 pt-0 text-gray-500 leading-relaxed text-sm">
                            {answer}
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    )
}
