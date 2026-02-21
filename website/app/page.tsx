import { Navbar } from "@/components/Navbar";
import { Footer } from "@/components/Footer";
import { HeroSection } from "@/components/HeroSection";
import { HowItWorks } from "@/components/HowItWorks";
import { EcosystemExplainer } from "@/components/EcosystemExplainer";
import { Testimonials } from "@/components/Testimonials";
import { TrustedBrands } from "@/components/TrustedBrands";
import { HomeReferralSection } from "@/components/HomeReferralSection";
import { ArrowRight, TrendingUp, Store, Users } from "lucide-react";
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

      {/* Stats Section */}
      <section className="py-20 bg-[#35255e] text-white relative overflow-hidden">
        {/* Background Patterns */}
        <div className="absolute top-0 left-0 w-full h-full opacity-10">
          <div className="absolute right-0 bottom-0 w-[400px] h-[400px] bg-[#00C4A7] rounded-full blur-[100px]" />
          <div className="absolute left-0 top-0 w-[300px] h-[300px] bg-purple-500 rounded-full blur-[80px]" />
        </div>

        <div className="container mx-auto px-6 relative z-10">
          <div aria-label="Key Platform Statistics" className="grid grid-cols-1 md:grid-cols-3 gap-12 text-center divide-y md:divide-y-0 md:divide-x divide-white/10">
            <StatItem icon={<Users size={32} />} value="15,000+" label="Active Users" />
            <StatItem icon={<Store size={32} />} value="500+" label="Merchant Partners" />
            <StatItem icon={<TrendingUp size={32} />} value="₹2.5Cr" label="Processed Volume" />
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <Testimonials />

      {/* Merchant CTA (Polished) */}
      <section className="py-24 bg-white relative overflow-hidden">
        <div className="absolute right-0 top-0 w-1/2 h-full bg-secondary/5 skew-x-12 translate-x-32" />

        <div className="container mx-auto px-6 relative z-10">
          <div className="bg-secondary rounded-[3rem] p-10 md:p-20 text-white overflow-hidden relative shadow-2xl">
            {/* Background Texture */}
            <div className="absolute top-0 right-0 w-[600px] h-[600px] bg-primary/20 rounded-full blur-[100px] -z-10" />

            <div className="flex flex-col md:flex-row items-center justify-between gap-16">
              <div className="md:w-3/5">
                <div className="inline-block px-4 py-1.5 bg-primary/20 rounded-full text-primary font-bold text-sm mb-6">
                  For Business Owners
                </div>
                <h2 className="text-4xl md:text-6xl font-bold mb-6 leading-tight">
                  Stop paying for ads. <br /> Start paying for results.
                </h2>
                <p className="text-xl text-gray-300 mb-10 leading-relaxed max-w-xl">
                  MomoPe switches your marketing spend from "impressions" to "transactions". Only pay when a customer actually buys.
                </p>

                <div className="flex flex-wrap gap-4 mb-10">
                  <BenefitTag text="Zero Setup Fees" />
                  <BenefitTag text="Instant Settlements" />
                  <BenefitTag text="20% More Retention" />
                </div>

                <Link
                  href="/merchant"
                  className="inline-flex items-center gap-2 px-10 py-5 bg-white text-secondary rounded-2xl font-bold text-lg hover:bg-gray-100 transition-colors shadow-lg"
                >
                  Become a Merchant <ArrowRight size={20} />
                </Link>
              </div>

              <div className="md:w-2/5 flex justify-center">
                {/* Abstract Chart Visual */}
                <div className="relative">
                  <TrendingUp size={240} className="text-primary opacity-20" />
                  <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 text-center">
                    <div className="text-5xl font-bold text-white mb-2">+34%</div>
                    <div className="text-sm text-primary uppercase font-bold tracking-widest">Growth</div>
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

function StatItem({ icon, value, label }: { icon: React.ReactNode, value: string, label: string }) {
  return (
    <article className="flex flex-col items-center p-6">
      <div aria-hidden="true" className="mb-4 text-[#00C4A7] opacity-80">{icon}</div>
      <div className="text-4xl md:text-5xl font-black mb-2">{value}</div>
      <h3 className="text-sm font-bold uppercase tracking-widest opacity-50">{label}</h3>
    </article>
  )
}

function BenefitTag({ text }: { text: string }) {
  return (
    <div className="flex items-center gap-2 px-4 py-2 bg-white/10 rounded-lg text-sm font-medium">
      <div className="w-1.5 h-1.5 rounded-full bg-primary" />
      {text}
    </div>
  );
}
