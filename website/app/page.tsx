"use client";

import { Navbar } from "@/components/Navbar";
import { Footer } from "@/components/Footer";
import { HeroSection } from "@/components/HeroSection";
import { HowItWorks } from "@/components/HowItWorks";
import { EcosystemExplainer } from "@/components/EcosystemExplainer";
import { Testimonials } from "@/components/Testimonials";
import { TrustedBrands } from "@/components/TrustedBrands";
import { HomeReferralSection } from "@/components/HomeReferralSection";
import { ArrowRight, TrendingUp, Store, Users } from "lucide-react";
import { motion } from "framer-motion";
import Link from "next/link";

export default function Home() {
  return (
    <main className="min-h-screen bg-white font-sans text-slate-800">
      <Navbar />

      {/* New Premium Hero */}
      <HeroSection />

      {/* Trust Indicators (Local Businesses) */}
      <TrustedBrands />

      {/* How It Works (Process) */}
      <HowItWorks />

      {/* Ecosystem Deep Dive (New) */}
      <EcosystemExplainer />

      {/* Referral Section (Summary) */}
      <HomeReferralSection />

      {/* Stats Section - Premium Elevate */}
      <section className="py-24 bg-secondary text-white relative overflow-hidden border-y border-white/5">
        {/* Advanced Background Texture */}
        <div className="absolute inset-0 opacity-20 pointer-events-none">
          <div className="absolute right-[-10%] bottom-[-20%] w-[600px] h-[600px] bg-primary rounded-full blur-[150px]" />
          <div className="absolute left-[-5%] top-[-10%] w-[400px] h-[400px] bg-purple-600 rounded-full blur-[120px]" />
          <div className="absolute inset-0 bg-[url('/images/grid-white.svg')] opacity-10" />
        </div>

        <div className="container mx-auto px-6 relative z-10">
          <div aria-label="Key Platform Statistics" className="grid grid-cols-1 md:grid-cols-3 gap-16 md:gap-8 text-center">
            <StatItem icon={<Users size={40} />} value="15,000+" label="Active Users" color="text-primary" />
            <StatItem icon={<Store size={40} />} value="500+" label="Merchant Partners" color="text-purple-400" />
            <StatItem icon={<TrendingUp size={40} />} value="₹2.5Cr" label="Processed Volume" color="text-amber-400" />
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <Testimonials />

      {/* Merchant CTA (Premium Overhaul) */}
      <section className="py-28 bg-white relative overflow-hidden">
        <div className="absolute right-0 top-0 w-1/2 h-full bg-primary/5 skew-x-12 translate-x-32" />

        <div className="container mx-auto px-6 relative z-10">
          <div className="bg-secondary rounded-[3.5rem] p-12 md:p-24 text-white overflow-hidden relative shadow-umbra-lg border border-white/10">
            {/* Background Texture */}
            <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-primary/20 rounded-full blur-[120px] -z-10" />
            <div className="absolute bottom-[-10%] left-[-10%] w-[400px] h-[400px] bg-purple-500/10 rounded-full blur-[100px] -z-10" />

            <div className="flex flex-col lg:flex-row items-center justify-between gap-16 lg:gap-24">
              <div className="lg:w-3/5 text-center lg:text-left">
                <div className="inline-block px-5 py-2 bg-primary/20 rounded-full text-primary font-black text-xs uppercase tracking-widest mb-8 border border-primary/30">
                  Business Growth Platform
                </div>
                <h2 className="text-4xl md:text-6xl lg:text-7xl font-black mb-8 leading-[1.1] tracking-tight">
                  Stop paying for ads. <br />
                  <span className="text-primary">Start paying for results.</span>
                </h2>
                <p className="text-xl text-gray-300 mb-12 leading-relaxed max-w-2xl mx-auto lg:mx-0">
                  MomoPe switches your marketing spend from &quot;impressions&quot; to &quot;transactions&quot;. Only pay a small commission when a customer actually buys.
                </p>

                <div className="flex flex-wrap justify-center lg:justify-start gap-4 mb-12">
                  <BenefitTag text="Zero Setup Fees" />
                  <BenefitTag text="Instant Settlements" />
                  <BenefitTag text="Direct CRM Access" />
                </div>

                <Link
                  href="/merchant"
                  className="inline-flex items-center gap-3 px-10 py-5 bg-white text-secondary rounded-2xl font-black text-lg hover:shadow-[0_20px_40px_rgba(255,255,255,0.2)] transition-all transform hover:-translate-y-1 active:scale-95"
                >
                  Become a Partner <ArrowRight size={22} strokeWidth={3} />
                </Link>
              </div>

              <div className="lg:w-2/5 flex justify-center relative">
                {/* Visual Representation of Growth */}
                <div className="relative p-12 bg-white/5 rounded-[3rem] border border-white/10 backdrop-blur-sm group hover:scale-105 transition-transform duration-700">
                  <TrendingUp size={240} className="text-primary opacity-30 animate-pulse" />
                  <div className="absolute inset-0 flex flex-col items-center justify-center">
                    <motion.div
                      animate={{ scale: [1, 1.1, 1] }}
                      transition={{ duration: 3, repeat: Infinity }}
                      className="text-6xl md:text-7xl font-black text-white mb-2"
                    >
                      +34%
                    </motion.div>
                    <div className="text-sm text-primary uppercase font-black tracking-widest bg-primary/10 px-4 py-1.5 rounded-full border border-primary/20">
                      Average Growth
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

    </main>
  );
}

function StatItem({ icon, value, label, color }: { icon: React.ReactNode, value: string, label: string, color?: string }) {
  return (
    <article className="flex flex-col items-center p-8 group transition-transform hover:-translate-y-2">
      <div aria-hidden="true" className={`mb-6 ${color || 'text-primary'} scale-125 group-hover:scale-150 group-hover:rotate-12 transition-transform duration-500 drop-shadow-[0_0_10px_rgba(0,196,167,0.4)]`}>
        {icon}
      </div>
      <div className="text-5xl md:text-6xl lg:text-7xl font-black mb-3 tracking-tighter tabular-nums">{value}</div>
      <h3 className="text-xs font-black uppercase tracking-[0.3em] opacity-40 group-hover:opacity-70 transition-opacity">{label}</h3>
    </article>
  )
}

function BenefitTag({ text }: { text: string }) {
  return (
    <div className="flex items-center gap-3 px-5 py-2.5 bg-white/5 rounded-xl text-sm font-bold border border-white/10 hover:border-primary/50 transition-colors group cursor-default">
      <div className="w-2 h-2 rounded-full bg-primary shadow-[0_0_8px_#00C4A7]" />
      <span className="group-hover:text-primary transition-colors">{text}</span>
    </div>
  );
}
