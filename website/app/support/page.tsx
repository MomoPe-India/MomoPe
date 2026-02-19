"use client";

import { motion } from "framer-motion";
import { Mail, MapPin, Phone, HelpCircle, ChevronDown, ChevronUp } from "lucide-react";
import { useState } from "react";
import { Footer } from "@/components/Footer";
import { Navbar } from "@/components/Navbar";

export default function SupportPage() {
    return (
        <main className="bg-surface min-h-screen">
            <Navbar />

            {/* Hero */}
            <section className="pt-32 pb-16 bg-secondary text-white text-center">
                <div className="container mx-auto px-6">
                    <h1 className="text-3xl md:text-5xl font-bold mb-4">How can we help?</h1>
                    <p className="text-gray-300 max-w-xl mx-auto">
                        Find answers to common questions or get in touch with our team.
                    </p>
                </div>
            </section>

            {/* Contact Cards */}
            <section className="py-12 -mt-10">
                <div className="container mx-auto px-6 grid grid-cols-1 md:grid-cols-3 gap-6">
                    <ContactCard
                        icon={<Mail className="text-primary" size={24} />}
                        title="Email Support"
                        info="support@momope.com"
                        sub="Response within 24 hours"
                    />
                    <ContactCard
                        icon={<Phone className="text-blue-500" size={24} />}
                        title="Merchant Hotline"
                        info="+91 80 1234 5678"
                        sub="Mon-Fri, 9am - 6pm"
                    />
                    <ContactCard
                        icon={<MapPin className="text-purple-500" size={24} />}
                        title="Headquarters"
                        info="Cuddapah, Andhra Pradesh"
                        sub="Registered Office"
                    />
                </div>
            </section>

            {/* FAQs */}
            <section className="py-16">
                <div className="container mx-auto px-6 max-w-3xl">
                    <h2 className="text-2xl font-bold text-secondary mb-8 flex items-center gap-2">
                        <HelpCircle className="text-primary" /> Frequently Asked Questions
                    </h2>

                    <div className="space-y-4">
                        <FaqItem
                            question="What are Momo Coins?"
                            answer="Momo Coins are rewards you earn on every transaction. 1 Coin = ₹1. You can redeem them at any partner store to pay up to 80% of your bill."
                        />
                        <FaqItem
                            question="Do my coins expire?"
                            answer="Yes, coins expire 90 days from the date they were earned. We'll send you a reminder 15 days before any coins expire."
                        />
                        <FaqItem
                            question="Is MomoPe a wallet?"
                            answer="No, MomoPe is not a wallet. You don't need to load money. You simply link your UPI app and pay directly, earning rewards instantly."
                        />
                        <FaqItem
                            question="For Merchants: When do I get settled?"
                            answer="Standard settlement is T+3 days. We also offer a premium T+1 settlement plan for high-volume merchants."
                        />
                    </div>
                </div>
            </section>

            <Footer />
        </main>
    );
}

function ContactCard({ icon, title, info, sub }: { icon: React.ReactNode, title: string, info: string, sub: string }) {
    return (
        <div className="bg-white p-6 rounded-xl shadow-lg border border-gray-100 text-center">
            <div className="w-12 h-12 bg-surface rounded-full flex items-center justify-center mx-auto mb-4">
                {icon}
            </div>
            <h3 className="font-bold text-secondary mb-1">{title}</h3>
            <p className="text-primary font-medium mb-1">{info}</p>
            <p className="text-xs text-gray-400">{sub}</p>
        </div>
    );
}

function FaqItem({ question, answer }: { question: string, answer: string }) {
    const [isOpen, setIsOpen] = useState(false);

    return (
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
            <button
                onClick={() => setIsOpen(!isOpen)}
                className="w-full flex items-center justify-between p-4 text-left font-medium text-secondary hover:bg-gray-50 transition-colors"
            >
                {question}
                {isOpen ? <ChevronUp size={20} className="text-gray-400" /> : <ChevronDown size={20} className="text-gray-400" />}
            </button>
            {isOpen && (
                <div className="p-4 pt-0 text-text-secondary text-sm leading-relaxed border-t border-gray-100 bg-gray-50/50">
                    {answer}
                </div>
            )}
        </div>
    );
}
