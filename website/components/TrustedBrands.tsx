"use client";

import { motion } from "framer-motion";

const BRANDS_ROW_1 = [
    "Srinivasa Silks", "Ravi Teja Mobiles", "Kadapa Spice", "Sai Electronics",
    "Lakshmi General Store", "Babu Chai Wala", "Vijaya Medicals", "Royal Bakers",
    "Balaji Sweets", "Krishna Textiles", "Amaravati Mobiles", "Seven Hills Opticals",
    "Reddy's Family Restaurant", "Priya Fancy Store", "Ganesh Medicals", "SVS Motors",
    "Aditya Books", "Jyothi Cinema Hall", "Venkateswara Tyres", "New City Mobiles"
];

const BRANDS_ROW_2 = [
    "Reddy's Biryani Point", "Venkateswara Hardwares", "Devi Fancy Store", "Kadapa Gold House",
    "City Supermarket", "Rayalaseema Ruchulu", "Metro Footwear", "Classic Men's Wear",
    "Maruti Automobiles", "Shanti Medicals", "Annapurna Mess", "Geetha Bangle Store",
    "Supreme Furniture", "Bhavani Travels", "Kadapa Tea House", "Modern Saloon",
    "Vasavi Cloth Showroom", "Royal Enfield Kadapa", "Coffee Day", "Sushma Hospital"
];

export function TrustedBrands() {
    return (
        <section className="py-16 bg-white border-b border-gray-50 relative overflow-hidden">
            <div className="container mx-auto px-6 text-center mb-10">
                <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-white border border-gray-100 shadow-umbra-sm mb-4"
                >
                    <div className="w-1.5 h-1.5 rounded-full bg-primary animate-pulse" />
                    <span className="text-xs font-black text-gray-500 uppercase tracking-[0.2em]">Live Network</span>
                </motion.div>
                <motion.h2
                    initial={{ opacity: 0, y: 10 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    transition={{ delay: 0.1 }}
                    className="text-2xl md:text-3xl font-black text-secondary tracking-tight"
                >
                    Trusted by 500+ Businesses in Kadapa
                </motion.h2>
            </div>

            <div className="relative flex flex-col gap-8 opacity-80">
                {/* Row 1: Left Scroll */}
                <div className="relative flex overflow-x-hidden group">
                    <div className="animate-marquee whitespace-nowrap flex items-center gap-16 px-8">
                        {BRANDS_ROW_1.map((brand, i) => (
                            <BrandItem key={i} name={brand} />
                        ))}
                        {BRANDS_ROW_1.map((brand, i) => (
                            <BrandItem key={`dup-${i}`} name={brand} />
                        ))}
                    </div>
                </div>

                {/* Row 2: Right Scroll (Slower/Different) */}
                <div className="relative flex overflow-x-hidden group">
                    <div className="animate-marquee2 whitespace-nowrap flex items-center gap-16 px-8" style={{ animationDuration: '35s' }}>
                        {BRANDS_ROW_2.map((brand, i) => (
                            <BrandItem key={i} name={brand} />
                        ))}
                        {BRANDS_ROW_2.map((brand, i) => (
                            <BrandItem key={`dup-${i}`} name={brand} />
                        ))}
                    </div>
                </div>
            </div>

            {/* Gradient Masks */}
            <div className="absolute inset-y-0 left-0 w-24 md:w-48 bg-gradient-to-r from-white via-white/80 to-transparent pointer-events-none z-10" />
            <div className="absolute inset-y-0 right-0 w-24 md:w-48 bg-gradient-to-l from-white via-white/80 to-transparent pointer-events-none z-10" />
        </section>
    );
}

function BrandItem({ name }: { name: string }) {
    return (
        <span className="text-2xl md:text-3xl font-black text-transparent bg-clip-text bg-gradient-to-b from-gray-300 to-gray-400 hover:from-primary hover:to-primary-dark transition-all cursor-default select-none grayscale hover:grayscale-0">
            {name}
        </span>
    );
}
